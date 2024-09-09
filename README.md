# pg2ili
Python script to import tables and relationships from a PostgreSQL/PostGIS SQL (DDL) file to [INTERLIS](https://www.interlis.ch/en).

![pg2ili](https://user-images.githubusercontent.com/652785/70843347-9fe97f80-1dfe-11ea-9a18-3780fd41d965.png)

pg2ili was created for saving time when extracting (or reverse engineering) information about the structure of an existing physical model.

If you start from a PostgreSQL/PostGIS database and want to obtain an INTERLIS model from it, you can use pg2ili to get all your PG tables written as INTERLIS classes. Then you can open the obtained ili file in [UML/INTERLIS Editor](https://github.com/claeis/umleditor) and adjust your model, i.e., adding meta-attributes, adjusting numeric ranges, among others.

**Usage:**

Go to pgAdmin v3 or v4 and create a (SQL) plain backup of your database schema. Now go to a terminal and run:

    python3 ./pg2ili.py /docs/backup.sql My_New_Model My_New_Topic > /docs/my_model.ili


**Examples:**

See the `tests/` folder for input and output examples.


**Unit tests:**

To run the unit tests, open the project in PyCharm, open `tests.py` file and press `Ctrl + Shift + F10`.

Individual tests can be run by typing this in a console (from repo folder):

    python3 -m unittest tests.tests.TestPG2ILI.test_sql13    
