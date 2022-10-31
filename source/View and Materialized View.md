# **View and Materialized View (Chapter 3.6 | Ramakrishnan / Gehrke)**

## **View**

A view is a table whose rows are not explicitly stored in the database but are computed as needed from a view definition.

```
Artist(_name_, country, retired)
Album(_name_, artist, year)
Evaluation(_album_, _artist_, _fount_, eval)
```

create VIEW:

```sql
CREATE VIEW AlbumEvaluation AS
    SELECT album, artist, FLOOR(AVG(evaluation)) AS mean, COUNT(evaluation) AS n
    FROM Evaluation
    GROUP BY album, artist
```

delete VIEW:

```sql
DROP VIEW AlbumEvaluation
```

The SQL-92 standard allows updates to be specified only on views that are defined on a single base table using just selection and projection, with no use of aggregate operations. Such views are called **updatable views**.

```sql
CREATE VIEW EvaluationGuardian AS
    SELECT * 
    FROM Evaluation
    WHERE fount = 'The Guardian';

INSERT INTO EvaluationGuardian VALUES ('Purpose', 'Justin Bieber', 'The Guardian', 60);

SELECT * FROM EvaluationGuardian;
SELECT * FROM Evaluation;
```

what are the views for?
- reduces query complexity (**abstraction**)
- you can give access to a view(a subset of the data) and not to all data (**security**)

## **Materialized View**

In a materialized view, the query is saved to make it easier to update the view at a later stage.

create MATERIALIZED VIEW:

```sql
CREATE MATERIALIZED VIEW AlbumEvaluation AS
    SELECT album, artist, FLOOR(AVG(evaluation)) AS mean, COUNT(evaluation) AS n
    FROM Evaluation
    GROUP BY album, artist
```

refresh MATERIALIZED VIEW:

```sql
REFRESH MATERIALIZED VIEW AlbumEvaluation
```

Can we change views?

![](img/alter%20%5Bmaterialized%5D%20view.png)

    WARNING: 
    - view is standard.
    - materialized view are not standard (but there is support in Oracle and Postgres 13+).