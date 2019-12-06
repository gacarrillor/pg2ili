# pg2ili
Python script to import tables from a PostgreSQL/PostGIS SQL file to [INTERLIS](https://www.interlis.ch/en).


If you start from a PostgreSQL/PostGIS database and want to obtain a model in INTERLIS from it, you can use this script to get all your PG tables written as INTERLIS classes. Then you can open the obtained ili file in [UML/INTERLIS Editor](https://github.com/AgenciaImplementacion/umleditor/) and adjust your model, i.e., add relationships, meta-attributes and the like. 

**Usage:**

    python3 ./pg2ili.py ./tests/test3.sql My_New_Model My_New_Topic > /tmp/res.ili


**Examples:**

See the `tests/` folder for input and output examples.


**Unit tests:**

To run the unit tests, open the project in PyCharm, open `tests.py` file and press `Ctrl + Shift + F10`.
