BEGIN;

INSERT INTO alter_sar (id,summary) VALUES
( 10012, 'utility function to normalize data volumes' );


--
-- WARNING: Changes disk_stats.device normalizing inconsistent cluster environments
--   Use only when necessary
--
CREATE OR REPLACE FUNCTION detect_datavols( v_group_name text )
RETURNS void AS $$
BEGIN
  PERFORM * FROM group_attribs ga JOIN groups g ON (ga.group_id=g.id)
    WHERE g.name = v_group_name
      AND ga.name ~ '^datavol';
  IF FOUND THEN
    RAISE NOTICE 'datavol records exist already in group_attribs for group %', v_group_name;
    RETURN;
  END IF;

  WITH src AS (
  SELECT host_id, device, avg(util_pct), rank() OVER (PARTITION BY host_id ORDER BY avg(util_pct) ASC)
    FROM disk_stats_v
   WHERE group_name = v_group_name
   GROUP BY 1,2
   HAVING avg(util_pct) > 5  -- magic number, do not like
   ORDER BY 1,4
  ), upd AS (
  UPDATE disk_stats AS d
     SET device = 'datavol'||s.rank
    FROM src s
   WHERE d.host_id = s.host_id
     AND d.device = s.device
   RETURNING d.device
  )
  INSERT INTO group_attribs (group_id, name, val)
  SELECT distinct g.id AS group_id, device AS name, device AS val
    FROM upd, public.groups g
   WHERE g.name = v_group_name;

  REFRESH MATERIALIZED VIEW summary WITH DATA;

  RETURN;
END;
$$ LANGUAGE 'plpgsql';


COMMIT;

