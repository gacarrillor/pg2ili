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
        "time": "INTERLIS.XMLDate",
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

        self.interlis_content = ""
        self.currently_inside_table = False
        self.re_create_table = re.compile("^CREATE TABLE [IF NOT EXISTS ]*?([\w\.]+)\s\(", re.I)
        self.re_end_create_table = re.compile(r"\);$")

    def convert(self):
        # Parse file
        self.interlis_content += self.get_header()

        sql_table = ""

        with open(self.sql_file) as f:
            for line in f:
                if DEBUG: print("[pg2ili]", line.strip())
                line = line.split("--")[0].strip()  # Remove comment if any
                if not line: continue

                if not self.currently_inside_table:
                    result = self.re_create_table.search(line)
                    if result:
                        self.currently_inside_table = True
                        sql_table += line
                else:  # Inside CREATE TABLE
                    sql_table += f"\n{line}"
                    result = self.re_end_create_table.search(line)
                    if result:
                        self.currently_inside_table = False
                        self.interlis_content += self.pg_table_to_ili_class(sql_table.strip())
                        sql_table = ""  # Initialize var

        self.interlis_content += self.get_footer()

        return self.interlis_content

    def pg_table_to_ili_class(self, pg_table_sql):
        if DEBUG: print("[pg_table_to_ili_class]", pg_table_sql)
        first_chunk = pg_table_sql.split("(")[0] + "("
        result = self.re_create_table.search(first_chunk)
        class_name = result.group(1).strip()
        pg_table_sql = pg_table_sql[len(first_chunk)+1:]
        attributes = list()

        for line in pg_table_sql.split("\n"):
            line = line.strip()
            if not line or line == ");": continue
            if DEBUG: print("[pg_table_to_ili_class]", line)

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

        return self.get_ili_class(class_name, attributes)

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
        if DEBUG: print("[get_ili_class]", class_name, attributes)
        ili_class = ""
        ili_class += f"    CLASS {class_name} ="
        for attribute in attributes:
            ili_class = "{}\n      {} : {}{};".format(ili_class,
                                                    attribute[0],
                                                    f"{attribute[2]} " if attribute[2] else "",
                                                    attribute[1])
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