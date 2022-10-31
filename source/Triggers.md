# **Triggers and Active DataBase (Chapter 5.8 | Ramakrishnan / Gehrke)**

A trigger is a procedure that is automatically invoked by the DBMS in response to specified changes to the database, and is typically specified by the DBA. A database that has a set of associated triggers is called an active database. A trigger description contains three parts:

- Event: A change to the database that activates the trigger.
- Condition: A query or test that is run when the trigger is activated.
- Action: A procedure that is executed when the trigger is activated and its condition is true.

trigger can be thought of as a 'daemon' that monitors a database, and is executed when the database is modified in a way that matches the event specification. An insert, delete, or update statement could activate a trigger, regardless of which user or application invoked the activating statement; users may not even be aware that a trigger was executed as a side effect of their program.

create TRIGGER:

![](img/trigger%20tables.png)

```sql
CREATE TRIGGER mytrigger
    AFTER UPDATE OF mean ON AlbumEval
    REFERENCING
        OLD ROW AS oldtuple
        NEW ROW AS newtuple
    FOR EACH ROW
        WHEN ( oldtuple.mean > newtuple.mean )
        SET newtuple.mean = oldtuple.mean
```

not changes:

```sql
UPDATE AlbumEval
SET mean = 50
WHERE album = 'ARTPOP' AND artist = 'Lady Gaga'
```

other TRIGGER:

```sql
CREATE TRIGGER actualizeMean
    AFTER INSERT OR UPDATE ON Evaluation
    REFERENCING
        NEW ROW AS TN
    FOR EACH ROW
        BEGIN
            IF EXISTS (
                SELECT *
                FROM AlbumEval A
                WHERE A.album = TN.album AND A.artist = TN.artist
            )
            THEN
                UPDATE AlbumEval
                SET mean = P.newmean, n = P.newn
                FROM (
                    SELECT AVG(E.eval) AS newmean, COUNT(E.eval) AS newn
                    FROM Evaluation E
                    WHERE E.album = TN.album AND E.artist = TN.artist
                ) P;
            ELSE
                INSERT INTO AlbumEval (album, artist, mean, n)
                SELECT E.album, E.artist, AVG(E.eval) AS newmean, COUNT(E.eval) AS newn
                FROM Evaluation E
                WHERE E.album = TN.album AND E.artist = TN.artist;
            END IF;
        END;
```

Triggers are standard, But their implementation on various engines varies a lot

## **Triggers in postgresql**

Postgres uses "stored procedures":

```sql
CREATE OR actualizeMean() RETURNS TRIGGER AS
$$
BEGIN
    IF EXISTS (
        SELECT *
        FROM AlbumEval A
        WHERE A.album = NEW.album AND A.artist = NEW.artist
    )
    THEN
        UPDATE AlbumEval
        SET mean = P.newmean, n = P.newn
        FROM (
            SELECT AVG(E.eval) AS newmean, COUNT(E.eval) AS newn
            FROM Evaluation E
            WHERE E.album = NEW.album AND E.artist = NEW.artist
        ) P;
    ELSE
        INSERT INTO AlbumEval (album, artist, mean, n)
        SELECT E.album, E.artist, AVG(E.eval) AS newmean, COUNT(E.eval) AS newn
        FROM Evaluation E
        WHERE E.album = NEW.album AND E.artist = NEW.artist;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER actualizeMeanTrigger
AFTER INSERT OR UPDATE ON Evaluation
FOR EACH ROW EXECUTE PROCEDURE actualizeMean();
```

Trigger + Materialized View:

```sql
CREATE MATERIALIZED VIEW AlbumEval AS
SELECT album, artist, FLOOR(AVG(eval)) AS mean, COUNT(eval) AS n
FROM Evaluation
GROUP BY album, artist;

CREATE FUNCTION actualizeMeanMV() RETURNS TRIGGER AS
$$
BEGIN
    REFRESH MATERIALIZED VIEW AlbumEval;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER actualizeMeanMVTrigger
AFTER INSERT OR UPDATE ON Evaluation
FOR EACH ROW EXECUTE PROCEDURE actualizeMeanMV();
```