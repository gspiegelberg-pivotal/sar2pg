BEGIN;

INSERT INTO alter_sar (id,summary) VALUES
( 10003, 'add master flag' );

ALTER TABLE hosts
  ADD COLUMN master boolean DEFAULT false;

UPDATE hosts SET master=false;
UPDATE hosts SET master=true WHERE name='utlxa480';

COMMIT;
