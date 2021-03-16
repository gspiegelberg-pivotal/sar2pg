BEGIN;

INSERT INTO alter_sar (id,summary) VALUES
( 10002, 'file load tracking' );

CREATE TABLE file_tracking(
	host_id       int REFERENCES hosts(id) ON UPDATE CASCADE ON DELETE CASCADE,
	created       timestamptz NOT NULL DEFAULT now(),
	sar_date      timestamp NOT NULL
);

INSERT INTO file_tracking (host_id, sar_date)
SELECT distinct on (host_id) host_id, date_trunc('day',ts) AS sar_date
  FROM loadavg
 ORDER BY host_id;

COMMIT;
