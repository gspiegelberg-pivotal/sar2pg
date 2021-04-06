BEGIN;

INSERT INTO alter_sar (id,summary) VALUES
( 10011, 'utility function to determine interconnect' );

CREATE OR REPLACE FUNCTION detect_interconnect( v_group_name text )
RETURNS void AS $$
BEGIN
  PERFORM * FROM group_attribs ga JOIN groups g ON (ga.group_id=g.id)
    WHERE g.name = v_group_name
      AND ga.name = 'net.interconnect';
  IF FOUND THEN
    RAISE NOTICE 'net.interconnect exists already in group_attribs for group %', v_group_name;
    RETURN;
  END IF;

  WITH src AS (
  SELECT hostname, interface, avg(rxkb_psec)
    FROM network_stats_v
   WHERE group_name = v_group_name
     AND NOT master
     AND interface != 'lo'
   GROUP BY 1,2
   HAVING avg(rxkb_psec) > 100
   ORDER BY 3 DESC
  ), selection AS (
  SELECT interface, avg(avg)
    FROM src
   GROUP BY 1
   ORDER BY 2 DESC
   LIMIT 1
  )
  INSERT INTO group_attribs (group_id, name, val)
  SELECT g.id AS group_id, 'net.interconnect' AS name, s.interface AS val
    FROM selection s, public.groups g
   WHERE g.name = v_group_name;

  REFRESH MATERIALIZED VIEW summary WITH DATA;

  RETURN;
END;
$$ LANGUAGE 'plpgsql';

COMMIT;

