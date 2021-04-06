BEGIN;

INSERT INTO alter_sar (id,summary) VALUES
( 10010, 'fix fkeys' );

ALTER TABLE cpu DROP CONSTRAINT IF EXISTS cpu_host_id_fkey;
ALTER TABLE disk_io DROP CONSTRAINT IF EXISTS disk_io_host_id_fkey;
ALTER TABLE disk_stats DROP CONSTRAINT IF EXISTS disk_stats_host_id_fkey;
ALTER TABLE file_inode DROP CONSTRAINT IF EXISTS file_inode_host_id_fkey;
ALTER TABLE file_tracking DROP CONSTRAINT IF EXISTS file_tracking_host_id_fkey;
ALTER TABLE hugepages DROP CONSTRAINT IF EXISTS hugepages_host_id_fkey;
ALTER TABLE loadavg DROP CONSTRAINT IF EXISTS loadavg_host_id_fkey;
ALTER TABLE memory_stats DROP CONSTRAINT IF EXISTS memory_stats_host_id_fkey;
ALTER TABLE memory_swapped DROP CONSTRAINT IF EXISTS memory_swapped_host_id_fkey;
ALTER TABLE memory_usage DROP CONSTRAINT IF EXISTS memory_usage_host_id_fkey;
ALTER TABLE network_errors DROP CONSTRAINT IF EXISTS network_errors_host_id_fkey;
ALTER TABLE network_stats DROP CONSTRAINT IF EXISTS network_stats_host_id_fkey;
ALTER TABLE nfs_client DROP CONSTRAINT IF EXISTS nfs_client_host_id_fkey;
ALTER TABLE nfs_server DROP CONSTRAINT IF EXISTS nfs_server_host_id_fkey;
ALTER TABLE pages DROP CONSTRAINT IF EXISTS pages_host_id_fkey;
ALTER TABLE procs DROP CONSTRAINT IF EXISTS procs_host_id_fkey;
ALTER TABLE sockets DROP CONSTRAINT IF EXISTS sockets_host_id_fkey;
ALTER TABLE swap DROP CONSTRAINT IF EXISTS swap_host_id_fkey;

ALTER TABLE cpu ADD CONSTRAINT cpu_host_id_fkey 
  FOREIGN KEY (host_id) REFERENCES public.hosts(id) ON UPDATE CASCADE ON DELETE CASCADE;
ALTER TABLE disk_io ADD CONSTRAINT disk_io_host_id_fkey 
  FOREIGN KEY (host_id) REFERENCES public.hosts(id) ON UPDATE CASCADE ON DELETE CASCADE;
ALTER TABLE disk_stats ADD CONSTRAINT disk_stats_host_id_fkey 
  FOREIGN KEY (host_id) REFERENCES public.hosts(id) ON UPDATE CASCADE ON DELETE CASCADE;
ALTER TABLE file_inode ADD CONSTRAINT file_inode_host_id_fkey 
  FOREIGN KEY (host_id) REFERENCES public.hosts(id) ON UPDATE CASCADE ON DELETE CASCADE;
ALTER TABLE file_tracking ADD CONSTRAINT file_tracking_host_id_fkey 
  FOREIGN KEY (host_id) REFERENCES public.hosts(id) ON UPDATE CASCADE ON DELETE CASCADE;
ALTER TABLE hugepages ADD CONSTRAINT hugepages_host_id_fkey 
  FOREIGN KEY (host_id) REFERENCES public.hosts(id) ON UPDATE CASCADE ON DELETE CASCADE;
ALTER TABLE loadavg ADD CONSTRAINT loadavg_host_id_fkey 
  FOREIGN KEY (host_id) REFERENCES public.hosts(id) ON UPDATE CASCADE ON DELETE CASCADE;
ALTER TABLE memory_stats ADD CONSTRAINT memory_stats_host_id_fkey 
  FOREIGN KEY (host_id) REFERENCES public.hosts(id) ON UPDATE CASCADE ON DELETE CASCADE;
ALTER TABLE memory_swapped ADD CONSTRAINT memory_swapped_host_id_fkey 
  FOREIGN KEY (host_id) REFERENCES public.hosts(id) ON UPDATE CASCADE ON DELETE CASCADE;
ALTER TABLE memory_usage ADD CONSTRAINT memory_usage_host_id_fkey 
  FOREIGN KEY (host_id) REFERENCES public.hosts(id) ON UPDATE CASCADE ON DELETE CASCADE;
ALTER TABLE network_errors ADD CONSTRAINT network_errors_host_id_fkey 
  FOREIGN KEY (host_id) REFERENCES public.hosts(id) ON UPDATE CASCADE ON DELETE CASCADE;
ALTER TABLE network_stats ADD CONSTRAINT network_stats_host_id_fkey 
  FOREIGN KEY (host_id) REFERENCES public.hosts(id) ON UPDATE CASCADE ON DELETE CASCADE;
ALTER TABLE nfs_client ADD CONSTRAINT nfs_client_host_id_fkey 
  FOREIGN KEY (host_id) REFERENCES public.hosts(id) ON UPDATE CASCADE ON DELETE CASCADE;
ALTER TABLE nfs_server ADD CONSTRAINT nfs_server_host_id_fkey 
  FOREIGN KEY (host_id) REFERENCES public.hosts(id) ON UPDATE CASCADE ON DELETE CASCADE;
ALTER TABLE pages ADD CONSTRAINT pages_host_id_fkey 
  FOREIGN KEY (host_id) REFERENCES public.hosts(id) ON UPDATE CASCADE ON DELETE CASCADE;
ALTER TABLE procs ADD CONSTRAINT procs_host_id_fkey 
  FOREIGN KEY (host_id) REFERENCES public.hosts(id) ON UPDATE CASCADE ON DELETE CASCADE;
ALTER TABLE sockets ADD CONSTRAINT sockets_host_id_fkey 
  FOREIGN KEY (host_id) REFERENCES public.hosts(id) ON UPDATE CASCADE ON DELETE CASCADE;
ALTER TABLE swap ADD CONSTRAINT swap_host_id_fkey 
  FOREIGN KEY (host_id) REFERENCES public.hosts(id) ON UPDATE CASCADE ON DELETE CASCADE;

COMMIT;

