BEGIN;

INSERT INTO alter_sar (id,summary) VALUES
( 10013, 'Whole replacement of sar_parse.sh' );


CREATE SCHEMA IF NOT EXISTS import;


CREATE TABLE import.sar_regexp(
	sar_order     int PRIMARY KEY,
	sar_table     varchar(256) NOT NULL,
	start_marker  varchar(256) NOT NULL,
	end_marker    varchar(256) NOT NULL
);

INSERT INTO import.sar_regexp (sar_order, sar_table, start_marker, end_marker) VALUES
 ( 1,  'cpu', 'CPU.*usr.*nice.*sys.*iowait.*steal.*irq.*soft.*guest.*gnice.*idle', '^Average:' ),
 ( 5,  'disk_io', 'tps.*rtps.*wtps.*bread.*bwrtn', '^Average:'),
 ( 12, 'disk_stats', 'DEV.*tps.*rd_sec.*wr_sec.*avgrq-sz.*avgqu-sz.*await.*svctm.*util', '^Average:'),
 ( 10, 'file_inode', 'dentunusd.*file-nr.*inode-nr.*pty-nr', '^Average:' ),
 ( 9,  'hugepages', 'kbhugfree.*kbhugused.*hugused', '^Average:'),
 ( 11, 'loadavg', 'runq-sz.*plist-sz.*ldavg-1.*ldavg-5.*ldavg-15.*blocked', '^Average:'),
 ( 6,  'memory_stats', 'frmpg.*bufpg.*campg', '^Average:'),
 ( 8,  'memory_swapped', 'kbswpfree.*kbswpused.*swpused.*kbswpcad.*swpcad', '^Average:'),
 ( 7,  'memory_usage', 'kbmemfree.*kbmemused.*memused.*kbbuffers.*kbcached.*kbcommit.*commit.*kbactive.*kbinact', '^Average:'),
 ( 14, 'network_errors', 'IFACE.*rxerr.*txerr.*coll.*rxdrop.*txdrop.*txcarr.*rxfram.*rxfifo', '^Average:'),
 ( 13, 'network_stats', 'IFACE.*rxpck.*txpck.*rxkB.*txkB.*rxcmp.*txcmp.*rxmcst', '^Average:'),
 ( 15, 'nfs_client', 'call.*retrans.*read.*write.*access.*getatt', '^Average:'),
 ( 16, 'nfs_server', 'scall.*badcall.*packet.*udp.*tcp.*hit.*miss.*sread.*swrite', '^Average:'),
 ( 4,  'pages', 'pgpgin.*pgpgout.*fault.*majflt.*pgfree.*pgscank.*pgscand.*pgsteal.*vmeff', '^Average:'),
 ( 2,  'procs', 'proc.*cswch', '^Average'),
 ( 17, 'sockets', 'totsck.*tcpsck.*udpsck.*rawsck.*ip-frag.*tcp-tw', '^Average:'),
 ( 3,  'swap', 'pswpin.*pswpout', '^Average:');


CREATE EXTENSION IF NOT EXISTS file_fdw;

CREATE SERVER IF NOT EXISTS import_sar_log FOREIGN DATA WRAPPER file_fdw;

CREATE OR REPLACE FUNCTION import.ingest_sar_log(
	v_sar_file        text,
	v_group_name      text,
	v_matview_refresh boolean
) RETURNS int AS $$
DECLARE
	sarrec        record;        -- 
	infrec        record;        -- 
	prev_rn       int;           -- 
	start_rn      int;           -- 
	end_rn        int;           -- 
	sql           text;          -- general purpose
	metric_cols   text;
	sar_cols      int;           -- columns for dest table less host_id & ts
	sar_fdt       text;          -- foreign table
	content_table text;          -- temp in database table
	sar_hostname  varchar(256);  -- hostname
	sar_kernel    varchar(256);  -- host kernel
	sar_base_date timestamp;     -- start date of sar
	group_id      int;
	host_id       int;
	row_count     int;
	total_rows    int;
BEGIN
	total_rows := 0;

	-- create file_fdw table
	SELECT INTO sar_fdt import.create_fdt( v_sar_file );
	content_table := format('import.local_%s', sar_fdt);

	-- pull in sar file to local table
	sql := format(
		'CREATE UNLOGGED TABLE %s (rn serial, line text);',
		content_table
	);
	EXECUTE sql;

	sql := format('INSERT INTO %s (line) SELECT line FROM import.%s',
		content_table, sar_fdt
	);
	EXECUTE sql;

	-- drop file_fdw table
	PERFORM import.drop_fdt( 'import.'||sar_fdt );

	-- create group if does not exist
	SELECT INTO group_id create_group FROM import.create_group( v_group_name );

	-- determine server name
	-- determine kernel
	-- determine base date
	SELECT INTO sar_hostname import.determine_hostname(content_table);
	SELECT INTO sar_kernel import.determine_kernel(content_table);
	SELECT INTO sar_base_date import.determine_base_date(content_table);

	SELECT INTO host_id create_host FROM import.create_host( sar_hostname, sar_kernel, group_id );

	-- parse and populate:
	--   cpu, disk_io, disk_stats, file_inode, file_tracking, hugepages, loadavg, memory_stats,
	--   memory_swapped, memory_usage, network_errors, network_stats, nfs_client, nfs_server,
	--   pages, procs, sockets, swap
	prev_rn := 2;
	FOR sarrec in SELECT * FROM import.sar_regexp ORDER BY sar_order
	LOOP

		EXECUTE format(
			'SELECT * FROM import.find_start_marker(%s, %s, %s)',
			quote_literal(content_table), quote_literal(prev_rn), quote_literal(sarrec.start_marker)
		) INTO start_rn;

		IF start_rn IS NULL THEN
			RAISE NOTICE 'section for % appears to be missing start marker, skipping', sarrec.sar_table;
			CONTINUE;
		END IF;

		EXECUTE format(
			'SELECT * FROM import.find_end_marker(%s, %s, %s)',
			quote_literal(content_table), quote_literal(start_rn), quote_literal(sarrec.end_marker)
		) INTO end_rn;

		IF end_rn IS NULL THEN
			RAISE NOTICE 'section for % appears to be missing end marker, skipping', sarrec.sar_table;
			CONTINUE;
		END IF;

		-- create metric_cols
		metric_cols := '';
		FOR infrec IN SELECT row_number() OVER () AS rn, data_type 
		  FROM information_schema.columns
		 WHERE table_schema = 'public'
		   AND table_name = sarrec.sar_table
		   AND column_name NOT IN ('host_id','ts')
		LOOP
			metric_cols := format(
				'%s,(metrics[%s])::%s',
				metric_cols, infrec.rn, infrec.data_type
			);
		END LOOP;
		metric_cols := substr(metric_cols, 2);  -- drop leading comma

		sql := format('WITH src AS (
SELECT row_number() OVER() AS rn, ''%s''::date + (substr(line,0,12))::time AS ts, line FROM %s
 WHERE rn >= %s AND rn <= %s
   AND line != '''' AND line !~ ''CPU'' AND line !~ ''all''
), s2 AS (
SELECT * FROM src ORDER BY rn ASC LIMIT 1
), data AS (
SELECT %s AS host_id,
       CASE WHEN s1.ts < s2.ts THEN s1.ts + interval''1 day'' ELSE s1.ts END AS ts
     , regexp_split_to_array( regexp_replace( btrim( substr(s1.line,12),'' ''), ''[\s+]{1,}'', '','', ''g''), '','') AS metrics
  FROM src s1, s2 ORDER BY 1
), ins AS (
INSERT INTO %s SELECT host_id, ts, %s FROM data RETURNING host_id)
SELECT count(*) FROM ins',
			sar_base_date, content_table, 
			start_rn, end_rn, -- sarrec.start_marker,
			host_id, 
			sarrec.sar_table, metric_cols
		);

		EXECUTE sql INTO row_count;
		total_rows := total_rows + row_count;

	END LOOP;

	IF v_matview_refresh THEN
		REFRESH MATERIALIZED VIEW public.summary WITH DATA;
	END IF;

	-- clean up
	EXECUTE format('DROP TABLE %s', content_table);

	RETURN total_rows;
END;
$$ LANGUAGE 'plpgsql';



CREATE OR REPLACE FUNCTION import.create_fdt(
	v_sar_file text
) RETURNS text AS $$
DECLARE
	fdt  text;
	sql  text;
BEGIN
	fdt := format( 'fdt_%s', md5(v_sar_file) );

	PERFORM * FROM import.drop_fdt( fdt );

	sql := format(
		'CREATE FOREIGN TABLE import.%s( line text ) SERVER import_sar_log OPTIONS ( filename ''%s'', FORMAT ''csv'' );',
		fdt, v_sar_file
	);
	EXECUTE sql;

	RETURN fdt;
END;
$$ LANGUAGE 'plpgsql';


CREATE OR REPLACE FUNCTION import.create_group(
	v_group_name text
) RETURNS int AS $$
DECLARE
	group_id  int;
BEGIN
	SELECT INTO group_id id FROM public.groups WHERE name = v_group_name;
	IF group_id IS NULL THEN
		WITH ins AS (INSERT INTO public.groups (name) SELECT v_group_name AS name RETURNING id)
		SELECT INTO group_id ins.id FROM ins;
		RAISE NOTICE 'group % (id=%) created', v_group_name, group_id;
	END IF;
	RETURN group_id;
END;
$$ LANGUAGE 'plpgsql';


CREATE OR REPLACE FUNCTION import.create_host(
  v_hostname text,
	v_kernel   text,
	v_group_id int
) RETURNS int AS $$
DECLARE
  host_id  int;
BEGIN
  SELECT INTO host_id h.id
	  FROM public.hosts h JOIN public.group_host gh ON (h.id = gh.host_id)
	 WHERE name = v_hostname;

  IF NOT FOUND THEN
    WITH ins AS (
			INSERT INTO public.hosts (name, kernel) VALUES ( v_hostname, v_kernel )
			RETURNING id
		), ghins AS (
			INSERT INTO public.group_host (group_id, host_id)
			SELECT v_group_id, ins.id FROM ins
			RETURNING *
		)
    SELECT INTO host_id ins.id FROM ins;
    RAISE NOTICE 'host % (id=%) created', v_hostname, host_id;
  END IF;

  RETURN host_id;
END;
$$ LANGUAGE 'plpgsql';


CREATE OR REPLACE FUNCTION import.drop_fdt(
	v_fdt  text
) RETURNS boolean AS $$
BEGIN
	EXECUTE format('DROP FOREIGN TABLE IF EXISTS %s', v_fdt);
	RETURN true;
END;
$$ LANGUAGE 'plpgsql';


CREATE OR REPLACE FUNCTION import.determine_hostname(
	v_table text
) RETURNS text AS $$
DECLARE
	hn varchar(256);
BEGIN
	EXECUTE format(
		'SELECT split_part(split_part(line,''('',2),'')'',1) FROM %s WHERE rn = 1;',
		v_table
	) INTO hn;
	RETURN hn;
END;
$$ LANGUAGE 'plpgsql';


CREATE OR REPLACE FUNCTION import.determine_kernel(
  v_table text
) RETURNS text AS $$
DECLARE
  krnl varchar(256);
BEGIN
  EXECUTE format(
    'SELECT split_part(line,'' '',2) FROM %s WHERE rn = 1;',
    v_table
  ) INTO krnl;
  RETURN krnl;
END;
$$ LANGUAGE 'plpgsql';


CREATE OR REPLACE FUNCTION import.determine_base_date(
	v_table text
) RETURNS date AS $$
DECLARE
	d date;
BEGIN
	EXECUTE format(
		'SELECT btrim(split_part(line,'' '',4),'' '')::date FROM %s WHERE rn = 1',
		v_table
	) INTO d;
	RETURN d;
END;
$$ LANGUAGE 'plpgsql';


CREATE OR REPLACE FUNCTION import.find_start_marker(
	v_content_table text,
	v_min_rn        int,
	v_marker_regexp text
) RETURNS int AS $$
DECLARE
	rn int;
BEGIN
	EXECUTE format(
		'SELECT min(rn)+1 FROM %s WHERE rn > %s AND line ~ ''%s''',
		v_content_table, v_min_rn, v_marker_regexp
	) INTO rn;
	RETURN rn;
END;
$$ LANGUAGE 'plpgsql';


CREATE OR REPLACE FUNCTION import.find_end_marker(
	v_content_table  text,
	v_min_rn         int,
	v_marker_regexp  text
) RETURNS int AS $$
DECLARE
	rn int;
BEGIN
  EXECUTE format(
    'SELECT (min(rn)-1) FROM %s WHERE rn > %s AND line ~ ''%s''',
    v_content_table, v_min_rn, v_marker_regexp
  ) INTO rn;
	RETURN rn;
END;
$$ LANGUAGE 'plpgsql';


COMMIT;

