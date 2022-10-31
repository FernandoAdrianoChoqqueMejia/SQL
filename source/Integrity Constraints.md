# **Integrity Constraints (Chapter 5.7 | Ramakrishnan / Gehrke)**

## **Key Constraints**

Consider the Students table and the constraint that no two students have the same student id. This is an example of a key constraint. A **key constraints** is a statement that a certain *minimal* subset of the fields of a table is a unique identifier for a tuple. A set of fields that uniquely identifies a tuple according to a key constraint is called a **candidate key** for the table; we often abbreviate this to just key.

Out of all the available candidate keys, a database designer can identify a **primary key**. Intuitively, a tuple can be referred to from elsewhere in the database by storing the values of its primary key fields.

```sql
CREATE TABLE Students (
    id CHAR(20),
    name_ CHAR (30),
    login_ CHAR(20),
    age INTEGER,
    gpa REAL,

    UNIQUE (name_, age),
    CONSTRAINT StudentsKey PRIMARY KEY (id)
)
```

## **Foreign Key Constraints**

Sometimes the information stored in a table is linked to the information stored in another table. If one of the tables is modified, the other must be checked, and perhaps modified, to keep the data consistent.

```sql
CREATE TABLE Enrolled (
    studid CHAR(20),
    cid CHAR(20),
    grade CHAR(10),

    PRIMARY KEY (studid, cid),
    FOREIGN KEY (studid) REFERENCES Students (id)
)
```

What should we do if a Students row is deleted?

The options are:

- Delete all Enrolled rows that refer to the deleted Students row.
- Disallow the deletion of the Students row if an Enrolled row refers to it.
- Set the *studid* column to the *id* of some (existing) 'default' student, for every Enrolled row that refers to the deleted Students row.
- For every Enrolled row that refers to it, set the *studid* column to *null*. In our example, this option conflicts with the fact that *studid* is part of the primary key of Enrolled and therefore cannot be set to *null*. Therefore, we are limited to the first three options in our example, although this fourth option (setting the foreign key to *null*) is available in general.

```sql
CREATE TABLE Enrolled (
    studid CHAR(20),
    cid CHAR(20) ,
    grade CHAR(10),

    PRIMARY KEY (studid, id),
    FOREIGN KEY (studid) REFERENCES Students (id)
        ON DELETE CASCADE
        ON UPDATE NO ACTION
)
```

## **Check**

We can specify complex constraints over a single table using table constraints, which have the form CHECK *conditional-expression*.

```sql
CREATE TABLE Sailors (
    sid_ INTEGER,
    sname CHAR(10),
    rating INTEGER,
    age REAL,

    PRIMARY KEY (sid_),
    CHECK ( rating >= 1 AND rating <= 10 )
)
```

To enforce the constraint that Interlake boats cannot be reserved, we could use:

```sql
CREATE TABLE Reserves (
    sid_ INTEGER,
    bid INTEGER,
    day_ DATE,

    FOREIGN KEY (sid_) REFERENCES Sailors (sid_),
    FOREIGN KEY (bid) REFERENCES Boats (bid),
    CONSTRAINT noInterlakeRes CHECK (
        'Interlake' <> ( SELECT B.bname FROM Boats B WHERE B.bid = Reserves.bid )
    )
)
```

## **Domain Constraints and Distinct Types**

A user can define a new domain using the CREATE DOMAIN statement, which uses CHECK constraints.

```sql
CREATE DOMAIN ratingval INTEGER DEFAULT 1
    CHECK ( VALUE >= 1 AND VALUE <= 10 );

CREATE DOMAIN A1_str VARCHAR(10)
    CHECK ( VALUE LIKE 'A1%' );
```

This statement defines a new *distinct* type called ratingtype, with INTEGER as its source type.

```sql
CREATE TYPE ratingtype AS INTEGER
```

and compound type called valuetype.

```sql
CREATE TYPE valuetype AS (
    pen BIGINT,
    usd DOUBLE PRECISION
)
```

**Domain:**
- You can compare domain values ​​with other values ​​as if it were of the base type.

**Type:**
- Cannot compare values ​​of the new type with values ​​of other types (just between them).
- Functions of the base type cannot be used with values ​​of the new type.

## **Assertions (independent constraints)**

Table constraints are associated with a single table, although the conditional expression in the CHECK clause can refer to other tables. Table constraints are required to hold only if the associated table is nonempty. Thus, when a constraint involves two or more tables, the table constraint mechanism is sometimes cumbersome and not quite what is desired. To cover such situations, SQL supports the creation of assertions, which are constraints not associated with anyone table.

As an example, suppose that we wish to enforce the constraint that the number of boats plus the number of sailors should be less than 100. (This condition Illight be required, say, to qualify as a 'smaIl' sailing club.) We could try the following table constraint:

```sql
CREATE TABLE Sailors (
    sid_ INTEGER,
    sname CHAR ( 10),
    rating INTEGER,
    age REAL,

    PRIMARY KEY (sid_),
    CHECK ( rating >= 1 AND rating <= 10)
    CHECK (
        ( SELECT COUNT (S.sid_) FROM Sailors S ) + ( SELECT COUNT (B.bid) FROM Boats B ) < 100 
    )
)
```

This solution suffers from two drawbacks. It is associated with Sailors, although it involves Boats in a completely symmetric way. More important, if the Sailors table is empty, this constraint is defined (as per the semantics of table constraints) to always hold, even if we have more than 100 rows in Boats! We could extend this constraint specification to check that Sailors is nonempty, but this approach becomes cumbersome. The best solution is to create an assertion, as follows:

```sql
CREATE ASSERTION smallClub
CHECK (
    ( SELECT COUNT (S.sid) FROM Sailors S ) + ( SELECT COUNT (B. bid) FROM Boats B) < 100
)
```