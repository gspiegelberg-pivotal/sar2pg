BEGIN;

INSERT INTO alter_sar (id,summary) VALUES
( 10006, 'Group data volume configuration' );

CREATE TABLE group_attribs(
	id          serial PRIMARY KEY,
	group_id    int    REFERENCES groups(id) ON UPDATE CASCADE ON DELETE CASCADE,
	name        varchar(32) NOT NULL,
	val         varchar(128) NOT NULL
);

INSERT INTO group_attribs (group_id,name,val)
SELECT id, 'datavol1', 'dev8-16' FROM groups WHERE name = 'Zions'
UNION
SELECT id, 'datavol2', 'dev8-32' FROM groups WHERE name = 'Zions';


COMMIT;
