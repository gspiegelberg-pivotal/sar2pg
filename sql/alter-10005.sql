BEGIN;

INSERT INTO alter_sar (id,summary) VALUES
( 10005, 'add indexes' );

CREATE INDEX ON cpu(host_id,ts);
CREATE INDEX ON procs(host_id,ts);
CREATE INDEX ON swap(host_id,ts);
CREATE INDEX ON pages(host_id,ts);
CREATE INDEX ON disk_io(host_id,ts);
CREATE INDEX ON memory_stats(host_id,ts);
CREATE INDEX ON memory_usage(host_id,ts);
CREATE INDEX ON memory_swapped(host_id,ts);
CREATE INDEX ON hugepages(host_id,ts);
CREATE INDEX ON file_inode(host_id,ts);
CREATE INDEX ON loadavg(host_id,ts);
CREATE INDEX ON disk_stats(host_id,ts);
CREATE INDEX ON network_stats(host_id,ts);
CREATE INDEX ON network_errors(host_id,ts);
CREATE INDEX ON nfs_client(host_id,ts);
CREATE INDEX ON nfs_server(host_id,ts);
CREATE INDEX ON sockets(host_id,ts);

CREATE INDEX disk_stats_device_idx ON disk_stats(host_id,ts,device);

COMMIT;
