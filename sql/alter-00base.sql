BEGIN;

CREATE TABLE alter_sar(
	id        int PRIMARY KEY,
	created   timestamptz NOT NULL DEFAULT now(),
	summary   varchar(128) NOT NULL
);

INSERT INTO alter_sar (id,summary) VALUES
( 10000, 'base schema' );


CREATE TABLE groups(
	id        serial PRIMARY KEY,
	name      varchar(32) NOT NULL
);

INSERT INTO groups (name) VALUES ('Zions');


CREATE TABLE hosts(
	id       serial primary key,
	name     varchar(256),
	kernel   varchar(256)
);


CREATE TABLE group_host(
	group_id    int REFERENCES groups(id) ON UPDATE CASCADE ON DELETE CASCADE,
	host_id     int REFERENCES hosts(id) ON UPDATE CASCADE ON DELETE CASCADE
);

INSERT INTO group_host (group_id, host_id)
SELECT g.id, h.id
  FROM groups g, hosts h
 WHERE g.name = 'Zions';


CREATE TABLE cpu(
	host_id      int references hosts(id),
	ts           timestamptz,
	core         varchar(4),
	usr_pct      float,
	nice_pct     float,
	sys_pct      float,
	iowait_pct   float,
	steal_pct    float,
	irq_pct      float,
	soft_pct     float,
	guest_pct    float,
	gnice_pct    float,
	idle_pct     float
);


CREATE TABLE procs(
	host_id      int references hosts(id),
	ts           timestamptz,
	proc_psec    float,
	cswch_psec   float
);


CREATE TABLE swap(
	host_id      int references hosts(id),
	ts           timestamptz,
	pswpin_psec  float,
	pswpout_psec float
);


CREATE TABLE pages(
	host_id      int references hosts(id),
	ts           timestamptz,
	pgpgin_psec  float,
	pgpgout_psec float,
	fault_psec   float,
	majflt_psec  float,
	pgfree_psec  float,
	pgscank_psec float,
	pgscand_psec float,
	pgsteal_psec float,
	vmeff_pct    float
);


CREATE TABLE disk_io(
	host_id      int references hosts(id),
	ts           timestamptz,
	tps          float,
	rtps         float,
	wtps         float,
	bread_psec   float,
	bwrtn_psec   float
);


CREATE TABLE memory_stats(
	host_id      int references hosts(id),
	ts           timestamptz,
	frmpg_psec   float,
	bufpg_psec   float,
	campg_psec   float
);


CREATE TABLE memory_usage(
	host_id      int references hosts(id),
	ts           timestamptz,
	kbmemfree    int,
	kbmemused    int,
	memused_pct  float,
	kbbuffers    int,
	kbcached     int,
	kbcommit     int,
	commit_pct   float,
	kbactive     int,
	kbinact      int,
	kbdirty      int
);


CREATE TABLE memory_swapped(
	host_id      int references hosts(id),
	ts           timestamptz,
	kbswpfree    int,
	kbswpused    int,
	swpused_pct  float,
	kbswpcad     int,
	swpcad_pct   float
);


CREATE TABLE hugepages(
	host_id      int references hosts(id),
	ts           timestamptz,
	kbhugfree    int,
	kbhugused    int,
	hugused_pct  float
);


CREATE TABLE file_inode(
	host_id      int references hosts(id),
	ts           timestamptz,
	dentunusd    int,
	file_nr      int,
	inode_nr     int,
	pty_nr       int
);


CREATE TABLE loadavg(
	host_id      int references hosts(id),
	ts           timestamptz,
	runq_sz      int,
	plist_sz     int,
	ldavg_1      float,
	ldavg_5      float,
	ldavg_15     float,
	blocked      int
);


/*
CREATE TABLE template(
	host_id      int references hosts(id),
	ts           timestamptz,
	tty          int,
	rcvin_psec   float,
	xmtin_psec   float,
	framerr_psec float,
	prtyerr_psec float,
	brk_psec     float,
	ovrun_psec   float
);
*/


CREATE TABLE disk_stats(
	host_id      int references hosts(id),
	ts           timestamptz,
	device       varchar(32),
	tps          float,
	rd_sec_psec  float,
	wr_sec_psec  float,
	avgrq_sz     float,
	avgqu_sz     float,
	await        float,
	svctm        float,
	util_pct     float
);


CREATE TABLE network_stats(
	host_id      int references hosts(id),
	ts           timestamptz,
	interface    varchar(32),
	rxpck_psec   float,
	txpck_psec   float,
	rxkb_psec    float,
	txkb_psec    float,
	rxcmp_psec   float,
	txcmp_psec   float,
	rxmcst_psec  float
);


CREATE TABLE network_errors(
	host_id      int references hosts(id),
	ts           timestamptz,
	interface    varchar(32),
	rxerr_psec   float,
	txerr_psec   float,
	coll_psec    float,
	rxdrop_psec  float,
	txdrop_psec  float,
	txcarr_psec  float,
	rxfram_psec  float,
	rxfifo_psec  float,
	txfifo_psec  float
);


CREATE TABLE nfs_client(
	host_id      int references hosts(id),
	ts           timestamptz,
	call_psec    float,
	retrans_psec float,
	read_psec    float,
	write_psec   float,
	access_psec  float,
	getatt_psec  float
);


CREATE TABLE nfs_server(
	host_id      int references hosts(id),
	ts           timestamptz,
	scall_psec   float,
	badcall_psec float,
	packet_psec  float,
	udp_psec     float,
	tcp_psec     float,
	hit_psec     float,
	miss_psec    float,
	sread_psec   float,
	swrite_psec  float,
	saccess_psec float,
	sgetatt_psec float
);


CREATE TABLE sockets(
	host_id      int references hosts(id),
	ts           timestamptz,
	totsck       int,
	tcpsck       int,
	udpsck       int,
	rawsck       int,
	ip_frag      int,
	tcp_tw       int
);


/*
CREATE TABLE template(
	host_id      int references hosts(id),
	ts           timestamptz,
);
*/










COMMIT;
