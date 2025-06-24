

## 📚 Course: Introduction to Data Management and Engineering

### 📌 Project 1: Relational Database Design for MovieLens
- **Type:** Hands-on SQL/pgAdmin project
- **Summary:** Designed a complete normalized schema for the MovieLens dataset, including:
  - Database and table creation
  - Foreign key constraints
  - Relationship tables (e.g., HasGenre, BelongsToCollection)
  - ER diagram construction
- **Tools:** PostgreSQL, pgAdmin, ER modeling
- **Deliverables:**
  - [Assignment Report 1 (PDF)](./Report%20Assignment%201%20f3352410.pdf)
  - SQL Scripts:
    - `create_tables.sql` (not uploaded)
    - [`alterTables.sql`](./d.alterTables.sql) – Add constraints
    - [`a.sql`](./a.sql) – Duplicate removal
    - [`b.ER.pdf`](./b.ER.pdf) – ER Diagram
    - [`c.answer.txt`](./c.answer.txt) – Design explanation

---

### 📌 Project 2: SQL Query Optimization & Data Exploration
- **Type:** Advanced SQL querying
- **Summary:** Developed 12 complex SQL queries to extract insights from the MovieLens dataset. The queries included:
  - JOINs (INNER, LEFT)
  - Subqueries with `IN`, `ANY`, `EXISTS`
  - Aggregations and logical filters
  - Performance optimization through indexing and EXPLAIN plans
- **Tools:** PostgreSQL, pgAdmin
- **Deliverables:**
  - [Assignment Report 2 (PDF)](./Assignment%202%20Report%20Giagkos%20Stylianos%20f3352410.pdf)
  - SQL Scripts:
    - [`a.sql`](./a.sql) – Views: Actor, CrewMember, Person
    - [`b.sql`](./b.sql) – Data cleaning on person identity
    - [`c.SQL`](./c.SQL) – Execution plans & indexing
    - [`d.alterTables.sql`](./d.alterTables.sql)

---

### 📌 Project 3: Data Cleaning and Entity Resolution
- **Summary:** Focused on cleaning, deduplicating, and logically merging entities across MovieLens using SQL logic and view abstraction.
- **Key Contributions:**
  - Created views (`Actor`, `CrewMember`, `Person`) to unify and abstract data
  - Removed duplicate rows from relationship tables
  - Enforced primary key constraints on associative entities
- **Files:**
  - [`a.sql`](./a.sql) – Views for `Actor`, `CrewMember`, `Person`
  - [`b.sql`](./b.sql) – Fix person identity conflicts and rebuild `Person` view
  - [`c.answer.txt`](./c.answer.txt) – Justification for design choices
  - [`d.alterTables.sql`](./d.alterTables.sql) – Add primary keys

---

### 📌 Project 4: SQL Performance Optimization
- **Summary:** Optimized MovieLens queries by analyzing execution plans and implementing indexing strategies.
- **Key Contributions:**
  - Used `EXPLAIN` to evaluate performance
  - Created indexes to reduce scan costs
  - Demonstrated query improvement with `EXPLAIN ANALYZE`
- **File:**
  - [`c.SQL`](./c.SQL)

---

## 🧠 Key Topics Covered
- Database schema design and normalization
- ER modeling and foreign key relationships
- Complex SQL query writing
- Query optimization and indexing
- Data cleaning and consistency enforcement using SQL logic
- Views and abstraction over raw tables

---

## 🛠️ Technologies Used
- PostgreSQL & pgAdmin
- SQL (DDL, DML, Views, Indexing)
- Entity-Relationship (ER) modeling
- EXPLAIN and query cost analysis

---
