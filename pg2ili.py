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
IGNORE_TABLES = ["t_ili2db_attrname",
                 "t_ili2db_basket",
                 "t_ili2db_classname",
                 "t_ili2db_column_prop",
                 "t_ili2db_dataset",
                 "t_ili2db_inheritance",
                 "t_ili2db_meta_attrs",
                 "t_ili2db_model",
                 "t_ili2db_settings",
                 "t_ili2db_table_prop",
                 "t_ili2db_trafo"]
IGNORE_ATTRIBUTES = ["t_ili_tid"]


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

        self.re_create_table = re.compile("^CREATE TABLE (?:IF NOT EXISTS )?([\"\w\.]+)\s\(", re.I)
        self.re_end_create_table = re.compile(r"\);$")
        self.re_alter_table = re.compile("^ALTER TABLE (?:ONLY )?([\"\w\.]+)", re.I)
        self.re_alter_table_one_line = re.compile("^ALTER TABLE (?:ONLY )?([\"\w\.]+).*?;$", re.I)
        self.re_unique_constraint = re.compile("^ALTER TABLE (?:ONLY )?([\"\w\.]+)\sADD CONSTRAINT [\w\.]+ UNIQUE \(([\w\.\,\s]+)\);$", re.I)
        self.re_primary_key_constraint = re.compile("^ALTER TABLE (?:ONLY )?([\"\w\.]+)\sADD CONSTRAINT [\w\.]+ PRIMARY KEY \(([\w\.\,\s]+)\);$", re.I)
        self.re_foreign_key_constraint = re.compile("^ALTER TABLE (?:ONLY )?([\"\w\.]+)\sADD CONSTRAINT [\w\.]+ FOREIGN KEY \(([\w\.\,]+)\) REFERENCES ([\w\.\,\(\)]+)(?: .*)?;$", re.I)

        self.currently_inside_table = False
        self.currently_inside_alter_table = False
        self.interlis_content = ""
        self.any_geometry = False
        self.pg_tables = dict()  # {Class name: [[attr_name, type], [attr_name, type], ... [attr_name, type]]}
        self.pg_not_nulls = dict()  # {Class name: [attr1, attr2, ..., attrN]}
        self.pg_uniques = dict()  # {Class name: [[attrs_unique1], [attrs_another_unique], ...]}
        self.pg_primary_keys = dict()  # {Class name: [attr1, attr2, ..., attrN]}
        self.pg_foreign_keys = dict()  # {Class name: [fk1_def, fk2_def, ..., fkN_def]}, fk_def = [[referencing_attrs], referenced_table, [referenced_attrs], referencing_cardinality, referenced_cardinality]
        self.m_n_associations = list()  # [foreign_key_def1, foreign_key_def2, [[attr_name, type, NN, [unique_attr1, ... unique_attrN]], ..., [...]]

    def convert(self):
        # Parse file
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

        # Convert to INTERLIS
        self.interlis_content += self.get_header()

        # Any M:N relationship?
        self.identify_m_n_relationships()

        for class_name, attributes in self.pg_tables.items():
            self.interlis_content += self.get_ili_class(class_name, attributes)

        for class_name, foreign_key_defs in self.pg_foreign_keys.items():
            for foreign_key_def in foreign_key_defs:
                self.interlis_content += self.get_ili_association(class_name, foreign_key_def)

        for m_n_rel_def in self.m_n_associations:
            self.interlis_content += self.get_ili_m_n_association(m_n_rel_def)

        self.interlis_content += self.get_footer()

        return self.interlis_content

    def parse_pg_table(self, pg_table_sql):
        if DEBUG: print("\n[parse_pg_table]", pg_table_sql)
        first_chunk = pg_table_sql.split("(")[0] + "("
        result = self.re_create_table.search(first_chunk)
        class_name = self.normalize_class_name(result.group(1).strip())
        if class_name in IGNORE_TABLES:
            return

        pg_table_sql = pg_table_sql[len(first_chunk)+1:]
        attributes = list()

        for line in pg_table_sql.split("\n"):
            line = line.strip()
            if not line or line == ");": continue
            if DEBUG: print("[parse_pg_table]", line)

            field_name = line.split(" ")[0]
            if field_name in IGNORE_ATTRIBUTES:
                continue

            line = line[len(field_name)+1:]  # Preserve the rest
            ili_type = ""
            for k,v in self.PG_TYPES_COMPILED.items():
                result = k.search(line)
                if result:
                    ili_type = self.convert_type(v, self.PG_TYPES[v], result.groups())
                    break

            if not ili_type:
                if DEBUG: print("###[WARNING]### Could not convert line: '{} {}'".format(field_name, line))
                continue

            if self.NOT_NULL in line:
                if not class_name in self.pg_not_nulls:
                    self.pg_not_nulls[class_name] = [field_name]
                else:
                    self.pg_not_nulls[class_name].append(field_name)

            attributes.append([field_name, ili_type])

        self.pg_tables[class_name] = attributes

    def parse_pg_alter_table(self, pg_alter_table_sql):
        if DEBUG: print("\n[parse_pg_alter_table]", pg_alter_table_sql)

        # PRIMARY KEY constraint
        primary_key_result = self.re_primary_key_constraint.search(pg_alter_table_sql)
        if primary_key_result:
            self.parse_pg_primary_key_constraint(pg_alter_table_sql, primary_key_result.groups())
            return

        # FOREIGN KEY constraint
        foreign_key_result = self.re_foreign_key_constraint.search(pg_alter_table_sql)
        if foreign_key_result:
            self.parse_pg_foreign_key_constraint(pg_alter_table_sql, foreign_key_result.groups())
            return

        # UNIQUE constraint
        unique_result = self.re_unique_constraint.search(pg_alter_table_sql)
        if unique_result:
            self.parse_pg_unique_constraint(pg_alter_table_sql, unique_result.groups())
            return

    def parse_pg_primary_key_constraint(self, pg_unique_sql, groups):
        if DEBUG: print("\n[parse_pg_primary_key_constraint]", pg_unique_sql)

        class_name = self.normalize_class_name(groups[0])
        if class_name in IGNORE_TABLES:
            return

        primary_key_attrs = [attr_name.strip() for attr_name in groups[1].split(",") if not attr_name.strip() in IGNORE_ATTRIBUTES]

        self.pg_primary_keys[class_name] = primary_key_attrs

    def parse_pg_foreign_key_constraint(self, pg_unique_sql, groups):
        if DEBUG: print("\n[parse_pg_foreign_key_constraint]", pg_unique_sql)

        class_name = self.normalize_class_name(groups[0])  # Referencing table
        if class_name in IGNORE_TABLES:
            return

        referencing_attrs = [attr_name.strip() for attr_name in groups[1].split(",")]
        for attr in referencing_attrs:
            if attr in IGNORE_ATTRIBUTES:
                return

        parts = groups[2].split("(")
        referenced_table = self.normalize_class_name(parts[0])
        referenced_attrs = [attr_name.strip() for attr_name in parts[1].split(")")[0].split(",")]
        for attr in referenced_attrs:
            if attr in IGNORE_ATTRIBUTES:
                return

        referencing_cardinality = self.get_role_cardinality(class_name, referencing_attrs[0], "referencing")
        referenced_cardinality = self.get_role_cardinality(class_name, referencing_attrs[0], "referenced")

        foreign_key_def = [referencing_attrs, referenced_table, referenced_attrs, referencing_cardinality, referenced_cardinality]

        if class_name in self.pg_foreign_keys:
            self.pg_foreign_keys[class_name].append(foreign_key_def)
        else:
            self.pg_foreign_keys[class_name] = [foreign_key_def]  # List of lists

    def parse_pg_unique_constraint(self, pg_unique_sql, groups):
        if DEBUG: print("\n[parse_pg_unique_constraint]", pg_unique_sql)

        class_name = self.normalize_class_name(groups[0])
        if class_name in IGNORE_TABLES:
            return

        unique_attrs = [attr_name.strip() for attr_name in groups[1].split(",") if not attr_name.strip() in IGNORE_ATTRIBUTES]

        if class_name in self.pg_uniques:
            self.pg_uniques[class_name].append(unique_attrs)
        else:
            self.pg_uniques[class_name] = [unique_attrs]  # List of lists

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
                    self.any_geometry = True
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
  {}
  TOPIC {} =
      
""".format(self.model_name, "IMPORTS {};\n".format(GEOMETRY_MODEL_NAME) if self.any_geometry else "", self.topic_name)

    def get_footer(self):
        return """  END {};
      
END {}.
    """.format(self.topic_name, self.model_name)

    def get_ili_class(self, class_name, attributes):
        if DEBUG: print("\n[get_ili_class]", class_name, attributes)
        if DEBUG: print("[get_ili_class] UNIQUE Constraints: ", self.pg_uniques[class_name] if class_name in self.pg_uniques else [])
        if DEBUG: print("[get_ili_class] PRIMARY KEY Constraint: ", self.pg_primary_keys[class_name] if class_name in self.pg_primary_keys else [])
        if DEBUG: print("[get_ili_class] FOREIGN KEY Constraint: ", self.pg_foreign_keys[class_name] if class_name in self.pg_foreign_keys else [])
        ili_class = ""
        ili_class += f"    CLASS {class_name} ="

        # List of attributes to skip (found in associations), as INTERLIS creates them from the association itself
        skip_attribute_names = ["t_id"]  # We take t_id into account (e.g., in associations) but do not define it in the output ILI
        if class_name in self.pg_foreign_keys:
            skip_attribute_names += [referencing_field for foreign_key_def in self.pg_foreign_keys[class_name] for referencing_field in foreign_key_def[0]]

        for attribute in attributes:
            if attribute[0] in skip_attribute_names:
                continue

            ili_class = "{}\n      {} : {}{};".format(ili_class,
                                                      attribute[0],
                                                      "MANDATORY " if class_name in self.pg_not_nulls and attribute[0] in self.pg_not_nulls[class_name] else "",
                                                      attribute[1])

        # Write UNIQUE constraints
        if class_name in self.pg_uniques:
            for unique_attributes in self.pg_uniques[class_name]:  # Iterate list of lists
                attribute_names = [attr_def[0] for attr_def in attributes if attr_def[0] not in skip_attribute_names]
                all_attributes = True

                for unique_attribute in unique_attributes:
                    if unique_attribute not in attribute_names:
                        all_attributes = False

                if all_attributes:
                    ili_class += "\n      UNIQUE {};".format(",".join(unique_attributes))

        ili_class += "\n    END {};\n\n".format(class_name)
        return ili_class

    def get_ili_association(self, class_name, foreign_key_def):
        if DEBUG: print("\n[get_ili_association]", class_name, foreign_key_def)

        ili_association = ""
        ili_association += f"    ASSOCIATION ="

        referencing_table = class_name
        referencing_fields, referenced_table, referenced_fields, referencing_cardinality, referenced_cardinality = foreign_key_def

        ili_association += "\n      {} -- {{{}}} {};".format(referencing_table,  # Role
                                                             referencing_cardinality,
                                                             referencing_table)  # Class
        ili_association += "\n      {} -- {{{}}} {};".format(referencing_fields[0],  # Role
                                                             referenced_cardinality,
                                                             referenced_table)  # Class

        ili_association += "\n    END;\n\n"
        return ili_association

    def get_role_cardinality(self, table, attribute, table_type):
        if DEBUG: print("\n[get_role_cardinality] NOT NULLs for {}:".format(table), self.pg_not_nulls[table] if table in self.pg_not_nulls else [])
        cardinality = ""
        if table_type == 'referenced':
            cardinality = "1" if table in self.pg_not_nulls and attribute in self.pg_not_nulls[table] else "0..1"
        else:  # Referencing
            #           UNIQUE          NOT NULL
            # 0..*
            # 0..1        x
            # 1..*        ?                 ?
            # 1           ?                 ?
            # not_null = True if table in self.pg_not_nulls and attribute in self.pg_not_nulls[table] else False
            unique = True if table in self.pg_uniques and [attribute] in self.pg_uniques[table] else False

            cardinality = "0..1" if unique else "0..*"

        return cardinality

    def identify_m_n_relationships(self):
        classes_to_remove = list()
        for class_name, foreign_key_defs in self.pg_foreign_keys.items():
            if len(foreign_key_defs) == 2:
                one_many_count = 0
                for foreign_key_def in foreign_key_defs:
                    if foreign_key_def[3].endswith("..*"):  # Check cardinality
                        one_many_count += 1

                if one_many_count == 2: # M:N!!!
                    # Store and expand extra attrs from current class to transfer them to M:N relationship
                    attrs = self.pg_tables[class_name]
                    for attr in attrs:
                        attr.append(attr[0] in self.pg_not_nulls[class_name] if class_name in self.pg_not_nulls else False)

                    # UNIQUE constraints?
                    uniques_to_store = list()
                    if class_name in self.pg_uniques:
                        for uniques in self.pg_uniques[class_name]:
                            all_attrs = True
                            for attr in attrs:
                                if attr not in uniques:
                                    all_attrs = False
                            if all_attrs:
                                uniques_to_store.append(uniques)

                    # Remove intermediate class from all other dicts
                    if class_name in self.pg_tables: del self.pg_tables[class_name]
                    if class_name in self.pg_not_nulls: del self.pg_not_nulls[class_name]
                    if class_name in self.pg_uniques: del self.pg_uniques[class_name]
                    if class_name in self.pg_primary_keys: del self.pg_primary_keys[class_name]
                    classes_to_remove.append(class_name)

                    # Add relationship to M:N list
                    self.m_n_associations.append([foreign_key_defs, attrs, uniques_to_store])

        for class_name in classes_to_remove:
            if class_name in self.pg_foreign_keys: del self.pg_foreign_keys[class_name]

    def get_ili_m_n_association(self, m_n_rel_def):
        if DEBUG: print("\n[get_ili_m_n_association]", m_n_rel_def)
        foreign_key_defs, attrs, uniques = m_n_rel_def

        ili_association = ""
        ili_association += f"    ASSOCIATION ="

        referencing_fields1, referenced_table1, referenced_fields1, referencing_cardinality1, referenced_cardinality1 = foreign_key_defs[0]
        referencing_fields2, referenced_table2, referenced_fields2, referencing_cardinality2, referenced_cardinality2 = foreign_key_defs[1]

        ili_association += "\n      {} -- {{{}}} {};".format(referencing_fields1[0],  # Role
                                                             referencing_cardinality1,
                                                             referenced_table1)  # Class
        ili_association += "\n      {} -- {{{}}} {};".format(referencing_fields2[0],  # Role
                                                             referencing_cardinality2,
                                                             referenced_table2)  # Class

        # List of attributes to skip (found in associations), as INTERLIS creates them from the association itself
        skip_attribute_names = ["t_id"]  # We take t_id into account (e.g., in associations) but do not define it in the output ILI
        skip_attribute_names += [referencing_field for referencing_field in referencing_fields1]
        skip_attribute_names += [referencing_field for referencing_field in referencing_fields2]

        for attr in attrs:
            attr_name, attr_type, not_null = attr
            if attr_name in skip_attribute_names:
                continue

            ili_association += "\n      {} : {}{};".format(attr_name,
                                                           "MANDATORY " if not_null else "",
                                                           attr_type)

        ili_association += "\n    END;\n\n"
        return ili_association

    def normalize_class_name(self, name):
        parts = name.split(".")
        if len(parts) == 2:
            return parts[1]

        return name


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
#
#       If a relation references a primary key, use t_id instead
#       Remove primary key attributes from ili classes (Optional?)
