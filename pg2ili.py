# -*- coding: utf-8 -*-
"""
/***************************************************************************
pg2ili, a script to import tables from PG SQL file to INTERLIS
                             --------------------
        begin                : 2019-11-29
        git sha              : :%H$
        copyright            : (C) 2019 by Germán Carrillo
        email                : gcarrillo@linuxmail.org
 ***************************************************************************/
/***************************************************************************
 *                                                                         *
 *   This program is free software; you can redistribute it and/or modify  *
 *   it under the terms of the GNU General Public License v3.0 as          *
 *   published by the Free Software Foundation.                            *
 *                                                                         *
 ***************************************************************************/
"""
import sys
import re

# CONFIG
DEBUG = False
PREFER_3D = True
GEOMETRY_MODEL_NAME = "ISO19107_PLANAS_V1"

class PG2ILI:
    PG_TYPES = {
        'smallint': "NUMERIC",
        'integer': "NUMERIC",
        'bigint': "NUMERIC",
        'int': "NUMERIC",
        "real": "NUMERIC.",
        "float(n)": "NUMERIC.n",
        "double precision": "NUMERIC.",
        "boolean": "BOOLEAN",
        "character varying(n)": "TEXT*n",
        "varchar(n)": "TEXT*n",
        "character(n)": "TEXT*n",
        "char(n)": "TEXT*n",
        "text": "TEXT*255",
        "varchar": "TEXT*255",
        "date": "INTERLIS.XMLDate",
        "timestamp": "INTERLIS.XMLDateTime",
        "time": "INTERLIS.XMLTime",
        "geometry(t)": "GEOMETRY"
    }
    PG_TYPES_COMPILED = {re.compile("^{}".format(k.replace("(n)", "([\s]*?\(\d+\))").replace("(t)", "([\s]*?\([\w\,\s]+\))"), re.I)): k for k, v in PG_TYPES.items()}

    GEOMETRY_TYPES = {
        "point": {"2d": "GM_Point2D", "3d": "GM_Point3D"},
        "curve": {"2d": "GM_Curve2D", "3d": "GM_Curve3D"},
        "linestring": {"2d": "GM_Curve2D", "3d": "GM_Curve3D"},
        "surface": {"2d": "GM_Surface3D", "3d": "GM_Surface3D"},
        "polygon": {"2d": "GM_Surface3D", "3d": "GM_Surface3D"},
        "polyhedralsurface": {"2d": None, "3d": None},
        "geomcollection": {"2d": None, "3d": None},
        "multipoint": {"2d": "GM_MultiPoint2D", "3d": "GM_MultiPoint3D"},
        "multicurve": {"2d": "GM_MultiCurve2D", "3d": "GM_MultiCurve3D"},
        "multilinestring": {"2d": "GM_MultiCurve2D", "3d": "GM_MultiCurve3D"},
        "multisurface": {"2d": "GM_MultiSurface2D", "3d": "GM_MultiSurface3D"},
        "multipolygon": {"2d": "GM_MultiSurface2D", "3d": "GM_MultiSurface3D"}
    }
    NOT_NULL = "NOT NULL"

    def __init__(self, sql_file, model_name="My_Model", topic_name="My_Topic"):
        self.sql_file = sql_file
        self.model_name = model_name
        self.topic_name = topic_name

        self.re_create_table = re.compile("^CREATE TABLE [IF NOT EXISTS ]*?([\w\.]+)\s\(", re.I)
        self.re_end_create_table = re.compile(r"\);$")
        self.re_alter_table = re.compile("^ALTER TABLE [ONLY ]*([\w\.]+)")
        self.re_alter_table_one_line = re.compile("^ALTER TABLE [ONLY ]*([\w\.]+).*?;$")
        self.re_unique_constraint = re.compile("^ALTER TABLE [ONLY ]*([\w\.]+)\sADD CONSTRAINT [\w\.]+ UNIQUE \(([\w\.\,\s]+)\);$")

        self.currently_inside_table = False
        self.currently_inside_alter_table = False
        self.interlis_content = ""
        self.pg_tables = dict()  # {Class name: [[attr1_def], [attr2_def], ... [attrN_def]]}
        self.pg_unique_constraints = dict()  # {Class name: [[attrs_unique1], [attrs_another_unique], ...]}

    def convert(self):
        # Parse file
        self.interlis_content += self.get_header()

        sql_table = ""
        sql_alter_table = ""

        with open(self.sql_file) as f:
            for line in f:
                if DEBUG: print("[pg2ili]", line.strip())
                line = line.split("--")[0].strip()  # Remove comment if any
                if not line: continue

                if not self.currently_inside_table and not self.currently_inside_alter_table:
                    # Create table?
                    result = self.re_create_table.search(line)
                    if result:
                        self.currently_inside_table = True
                        sql_table += line

                    # Alter table?
                    result = self.re_alter_table.search(line)
                    if result:
                        # Alter table in one line?
                        one_line_result = self.re_alter_table_one_line.search(line)
                        if one_line_result:
                            self.parse_pg_alter_table(line)
                            continue
                        self.currently_inside_alter_table = True
                        sql_alter_table += line

                elif self.currently_inside_table:  # Inside CREATE TABLE
                    sql_table += f"\n{line}"
                    result = self.re_end_create_table.search(line)
                    if result:
                        self.currently_inside_table = False
                        self.parse_pg_table(sql_table.strip())
                        sql_table = ""  # Get it ready for the next table

                elif self.currently_inside_alter_table:  # Inside ALTER table
                    sql_alter_table += f" {line}"

                    if DEBUG: print("[pg2ili] # # # MERGED ALTER TABLE # # #  --> ", sql_alter_table)

                    result = self.re_alter_table_one_line.search(sql_alter_table)
                    if result:
                        self.currently_inside_alter_table = False
                        self.parse_pg_alter_table(sql_alter_table)
                        sql_alter_table = ""  # Get it ready for the next constraint

        for class_name, attributes in self.pg_tables.items():
            self.interlis_content += self.get_ili_class(class_name, attributes)

        self.interlis_content += self.get_footer()

        return self.interlis_content

    def parse_pg_table(self, pg_table_sql):
        if DEBUG: print("\n[parse_pg_table]", pg_table_sql)
        first_chunk = pg_table_sql.split("(")[0] + "("
        result = self.re_create_table.search(first_chunk)
        class_name = result.group(1).strip()
        pg_table_sql = pg_table_sql[len(first_chunk)+1:]
        attributes = list()

        for line in pg_table_sql.split("\n"):
            line = line.strip()
            if not line or line == ");": continue
            if DEBUG: print("[parse_pg_table]", line)

            field_name = line.split(" ")[0]
            line = line[len(field_name)+1:]  # Preserve the rest
            ili_type = ""
            constraint = ""
            for k,v in self.PG_TYPES_COMPILED.items():
                result = k.search(line)
                if result:
                    ili_type = self.convert_type(v, self.PG_TYPES[v], result.groups())
                    break

            if not ili_type:
                if DEBUG: print("###[WARNING]### Could not convert line: '{} {}'".format(field_name, line))
                continue

            if self.NOT_NULL in line:
                constraint = "MANDATORY"

            attributes.append([field_name, ili_type, constraint])

        self.pg_tables[class_name] = attributes

    def parse_pg_alter_table(self, pg_alter_table_sql):
        if DEBUG: print("\n[parse_pg_alter_table]", pg_alter_table_sql)

        # UNIQUE constraint
        unique_result = self.re_unique_constraint.search(pg_alter_table_sql)
        if unique_result:
            self.parse_pg_unique_constraint(pg_alter_table_sql, unique_result.groups())

    def parse_pg_unique_constraint(self, pg_unique_sql, groups):
        if DEBUG: print("\n[parse_pg_unique_constraint]", pg_unique_sql)

        class_name = groups[0]
        unique_attrs = [attr_name.strip() for attr_name in groups[1].split(",")]

        if class_name in self.pg_unique_constraints:
            self.pg_unique_constraints[class_name].append(unique_attrs)
        else:
            self.pg_unique_constraints[class_name] = [unique_attrs]  # List of lists

    def convert_type(self, pg_type, ili_type, extra):
        if DEBUG: print("[convert_type]", pg_type, ili_type, extra)
        res = ""
        n = 0
        t = ""
        if extra:
            n = extra[0].strip().strip("(").strip(")")
            if ili_type == "GEOMETRY":
                t = n.split(",")[0]
        if ili_type == "NUMERIC":
            res = "0 .. 9999999999"
        elif ili_type == "NUMERIC.":
            res = "0.00 .. 9999999999.99"
        elif ili_type == "NUMERIC.n":
            res = "0.{} .. 9999999999.{}".format("0"*n, "9"*n)
        elif ili_type == "TEXT":
            res = "TEXT*255"
        elif ili_type == "TEXT*n":
            res = f"TEXT*{n}"
        elif ili_type == "GEOMETRY":
            for k,v in self.GEOMETRY_TYPES.items():
                if t.lower().startswith(k):
                    res = "{}.{}".format(GEOMETRY_MODEL_NAME, v["3d"] if PREFER_3D else v["2d"])
                    break
        else:
            res = ili_type

        return res

    def get_header(self):
        return """INTERLIS 2.3;
    
MODEL {} (en)
AT "mailto:gcarrillo@linuxmail.org"
VERSION "2019-10-11" =
    
  TOPIC {} =
      
""".format(self.model_name, self.topic_name)

    def get_footer(self):
        return """  END {};
      
END {}.
    """.format(self.topic_name, self.model_name)

    def get_ili_class(self, class_name, attributes):
        if DEBUG: print("\n[get_ili_class]", class_name, attributes)
        if DEBUG: print("[get_ili_class] UNIQUE Constraints: ", self.pg_unique_constraints[class_name] if class_name in self.pg_unique_constraints else [])
        ili_class = ""
        ili_class += f"    CLASS {class_name} ="
        for attribute in attributes:
            ili_class = "{}\n      {} : {}{};".format(ili_class,
                                                    attribute[0],
                                                    f"{attribute[2]} " if attribute[2] else "",
                                                    attribute[1])

        # Write UNIQUE constraints
        if class_name in self.pg_unique_constraints:
            for unique_attributes in self.pg_unique_constraints[class_name]:  # Iterate list of lists
                attribute_names = [attr_def[0] for attr_def in attributes]
                all_attributes = True

                for unique_attribute in unique_attributes:
                    if unique_attribute not in attribute_names:
                        all_attributes = False

                if all_attributes:
                    ili_class += "\n      UNIQUE {};".format(",".join(unique_attributes))

        ili_class += "\n    END {};\n\n".format(class_name)
        return ili_class


if __name__== "__main__":
    sql_file = sys.argv[1]
    model_name = sys.argv[2] if len(sys.argv) > 2 else "My_Model"
    topic_name = sys.argv[3] if len(sys.argv) > 3 else "My_Topic"
    pg2ili = PG2ILI(sql_file, model_name, topic_name)
    print(pg2ili.convert())

    #python3 ./pg2ili.py ./tests/test1.sql
    #python3 ./pg2ili.py ./tests/test2.sql
    #python3 ./pg2ili.py ./tests/test3.sql > /tmp/res.ili


# TODO:
#       Default values
#       More constraints
#       Associations?
#       Ignore certain tables