BEGIN;

INSERT INTO alter_sar (id,summary) VALUES
( 10004, 'Views with master flag' );

DROP VIEW cpu_v;
DROP VIEW disk_io_v;
DROP VIEW disk_stats_v;
DROP VIEW file_inode_v;
DROP VIEW hugepages_v;
DROP VIEW loadavg_v;
DROP VIEW memory_stats_v;
DROP VIEW memory_swapped_v;
DROP VIEW memory_usage_v;
DROP VIEW network_errors_v;
DROP VIEW network_stats_v;
DROP VIEW nfs_client_v;
DROP VIEW nfs_server_v;
DROP VIEW pages_v;
DROP VIEW procs_v;
DROP VIEW sockets_v;
DROP VIEW swap_v;

CREATE OR REPLACE VIEW cpu_v AS
SELECT g.name AS group_name, h.name AS hostname, h.master, c.*
  FROM groups g
       JOIN group_host gh ON (g.id = gh.group_id)
       JOIN hosts h ON (gh.host_id = h.id)
       JOIN cpu c ON (h.id = c.host_id);

CREATE OR REPLACE VIEW disk_io_v AS
SELECT g.name AS group_name, h.name AS hostname, h.master, c.*
  FROM groups g
       JOIN group_host gh ON (g.id = gh.group_id)
       JOIN hosts h ON (gh.host_id = h.id)
       JOIN disk_io c ON (h.id = c.host_id);

CREATE OR REPLACE VIEW disk_stats_v AS
SELECT g.name AS group_name, h.name AS hostname, h.master, c.*
  FROM groups g
       JOIN group_host gh ON (g.id = gh.group_id)
       JOIN hosts h ON (gh.host_id = h.id)
       JOIN disk_stats c ON (h.id = c.host_id);

CREATE OR REPLACE VIEW file_inode_v AS
SELECT g.name AS group_name, h.name AS hostname, h.master, c.*
  FROM groups g
       JOIN group_host gh ON (g.id = gh.group_id)
       JOIN hosts h ON (gh.host_id = h.id)
       JOIN file_inode c ON (h.id = c.host_id);

CREATE OR REPLACE VIEW hugepages_v AS
SELECT g.name AS group_name, h.name AS hostname, h.master, c.*
  FROM groups g
       JOIN group_host gh ON (g.id = gh.group_id)
       JOIN hosts h ON (gh.host_id = h.id)
       JOIN hugepages c ON (h.id = c.host_id);

CREATE OR REPLACE VIEW loadavg_v AS
SELECT g.name AS group_name, h.name AS hostname, h.master, c.*
  FROM groups g
       JOIN group_host gh ON (g.id = gh.group_id)
       JOIN hosts h ON (gh.host_id = h.id)
       JOIN loadavg c ON (h.id = c.host_id);

CREATE OR REPLACE VIEW memory_stats_v AS
SELECT g.name AS group_name, h.name AS hostname, h.master, c.*
  FROM groups g
       JOIN group_host gh ON (g.id = gh.group_id)
       JOIN hosts h ON (gh.host_id = h.id)
       JOIN memory_stats c ON (h.id = c.host_id);

CREATE OR REPLACE VIEW memory_swapped_v AS
SELECT g.name AS group_name, h.name AS hostname, h.master, c.*
  FROM groups g
       JOIN group_host gh ON (g.id = gh.group_id)
       JOIN hosts h ON (gh.host_id = h.id)
       JOIN memory_swapped c ON (h.id = c.host_id);

CREATE OR REPLACE VIEW memory_usage_v AS
SELECT g.name AS group_name, h.name AS hostname, h.master, c.*
  FROM groups g
       JOIN group_host gh ON (g.id = gh.group_id)
       JOIN hosts h ON (gh.host_id = h.id)
       JOIN memory_usage c ON (h.id = c.host_id);

CREATE OR REPLACE VIEW network_errors_v AS
SELECT g.name AS group_name, h.name AS hostname, h.master, c.*
  FROM groups g
       JOIN group_host gh ON (g.id = gh.group_id)
       JOIN hosts h ON (gh.host_id = h.id)
       JOIN network_errors c ON (h.id = c.host_id);

CREATE OR REPLACE VIEW network_stats_v AS
SELECT g.name AS group_name, h.name AS hostname, h.master, c.*
  FROM groups g
       JOIN group_host gh ON (g.id = gh.group_id)
       JOIN hosts h ON (gh.host_id = h.id)
       JOIN network_stats c ON (h.id = c.host_id);

CREATE OR REPLACE VIEW nfs_client_v AS
SELECT g.name AS group_name, h.name AS hostname, h.master, c.*
  FROM groups g
       JOIN group_host gh ON (g.id = gh.group_id)
       JOIN hosts h ON (gh.host_id = h.id)
       JOIN nfs_client c ON (h.id = c.host_id);

CREATE OR REPLACE VIEW nfs_server_v AS
SELECT g.name AS group_name, h.name AS hostname, h.master, c.*
  FROM groups g
       JOIN group_host gh ON (g.id = gh.group_id)
       JOIN hosts h ON (gh.host_id = h.id)
       JOIN nfs_server c ON (h.id = c.host_id);

CREATE OR REPLACE VIEW pages_v AS
SELECT g.name AS group_name, h.name AS hostname, h.master, c.*
  FROM groups g
       JOIN group_host gh ON (g.id = gh.group_id)
       JOIN hosts h ON (gh.host_id = h.id)
       JOIN pages c ON (h.id = c.host_id);

CREATE OR REPLACE VIEW procs_v AS
SELECT g.name AS group_name, h.name AS hostname, h.master, c.*
  FROM groups g
       JOIN group_host gh ON (g.id = gh.group_id)
       JOIN hosts h ON (gh.host_id = h.id)
       JOIN procs c ON (h.id = c.host_id);

CREATE OR REPLACE VIEW sockets_v AS
SELECT g.name AS group_name, h.name AS hostname, h.master, c.*
  FROM groups g
       JOIN group_host gh ON (g.id = gh.group_id)
       JOIN hosts h ON (gh.host_id = h.id)
       JOIN sockets c ON (h.id = c.host_id);

CREATE OR REPLACE VIEW swap_v AS
SELECT g.name AS group_name, h.name AS hostname, h.master, c.*
  FROM groups g
       JOIN group_host gh ON (g.id = gh.group_id)
       JOIN hosts h ON (gh.host_id = h.id)
       JOIN swap c ON (h.id = c.host_id);


COMMIT;
