BEGIN;

INSERT INTO alter_sar (id,summary) VALUES
( 10008, 'summary view' );

CREATE OR REPLACE VIEW summary AS
WITH cores AS (
SELECT group_name, 'cores' AS name, (count(distinct core) - 1)::text AS value
  FROM public.cpu_v
 WHERE master = false
 GROUP BY 1,2
), disk AS (
SELECT g.name AS group_name, 'data volumes' AS name, (count(distinct ga.name))::text AS value
  FROM public.group_attribs ga JOIN groups g ON (ga.group_id = g.id)
 WHERE ga.name ~ '^datavol'
 GROUP BY 1,2
), network AS (
SELECT g.name AS group_name, 'interconnect' AS name, COALESCE(ga.val, 'does not exist') AS value
  FROM groups g LEFT JOIN public.group_attribs ga ON (ga.group_id = g.id)
 WHERE ga.name = 'net.interconnect'
), seghosts AS (
SELECT g.name AS group_name, 'segment hosts' AS name, (count(distinct h.name))::text AS value
  FROM hosts h
       JOIN group_host gh ON (h.id = gh.host_id)
       JOIN groups g ON (gh.group_id = g.id)
 WHERE h.master = false
 GROUP BY 1, 2
), masterhosts AS (
SELECT g.name AS group_name, 'master hosts' AS name, (count(distinct h.name))::text AS value
  FROM hosts h
       JOIN group_host gh ON (h.id = gh.host_id)
       JOIN groups g ON (gh.group_id = g.id)
 WHERE h.master = true
 GROUP BY 1, 2
)
SELECT * FROM cores
 UNION ALL
SELECT * FROM disk
 UNION ALL
SELECT * FROM network
 UNION ALL
SELECT * FROM seghosts
 UNION ALL
SELECT * FROM masterhosts
 ORDER BY 1, 2;

COMMIT;

