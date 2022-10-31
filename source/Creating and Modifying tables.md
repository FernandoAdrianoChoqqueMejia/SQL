# **Creating and Modifying tables (Chapter 3.1.1 | Ramakrishnan / Gehrke)**

## **Schema**

We can configure table groupings using schemas.

create SCHEMA:

```sql
CREATE SCHEMA SolarSystem; -- create
GRANT USAGE ON SCHEMA SolarSystem TO narmstrong; -- only read
GRANT ALL PRIVILEGES ON SCHEMA SolarSystem TO csagan; -- all
```

## **Add table**

```sql
CREATE TABLE SolarSystem.Landing (
    spacecraft VARCHAR (255),
    planet VARCHAR (255),
    country VARCHAR (255),
    year_ SMALLINT,
)
```

## **Delete table**

```sql
DROP TABLE SolarSystem.Landing
```

## **Add Tuple**

```sql
INSERT INTO SolarSystem.Landing VALUES ('Messenger', 'Mercury', 'EEUU', 2015);
INSERT INTO SolarSystem.Landing VALUES ('Venera 3', 'Venus', 'URRS', 1966);
INSERT INTO SolarSystem.Landing VALUES ('Pioneer', 'Venus', 'EEUU', 1978);
-- INSERT INTO SolarSystem.Landing VALUES ('Mars 2 lander', 'Mars', 'URRS', '1971'); -- error
INSERT INTO SolarSystem.Landing (country, spacecraft, planet) VALUES ('EEUU', 'Mars 2 lander', 'Mars');

CREATE TABLE SolarSystem.LandingEEUU (
    spacecraft VARCHAR (255),
    planet VARCHAR (255),
    country VARCHAR (255),
    year_ SMALLINT,
);

INSERT INTO SolarSystem.LandingEEUU (
    SELECT *
    FROM SolarSystem.Landing
    WHERE country = 'EEUU'
);
```

## **Update Tuple**

```sql
UPDATE SolarSystem.Landing SET year_ = 1971, country = 'URRS'
WHERE spacecraft = 'Mars 2 lander'
```

## **Delete Tuple**

```sql
DELETE FROM SolarSystem.LandingEEUU
WHERE year_ = IS NULL
```

## **Add column**

```sql
ALTER TABLE SolarSystem.LandingEEUU ADD COLUMN takeoff DATE
```

## **Update column**

```sql
ALTER TABLE SolarSystem.LandingEEUU ALTER COLUMN takeoff VARCHAR(255)
```

## **Delete column**

```sql
ALTER TABLE SolarSystem.LandingEEUU DROP COLUMN country
```