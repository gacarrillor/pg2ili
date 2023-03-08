import os.path
import nose2
import unittest

from pg2ili import PG2ILI


def real_path(filename: str):
    tests_path = os.path.join(os.path.dirname(os.path.dirname(__file__)), 'tests')
    return os.path.join(tests_path, filename)


SQL1 = real_path(filename="test1.sql")
ILI1 = real_path("res1.ili")
SQL2 = real_path("test2.sql")
ILI2 = real_path("res2.ili")
SQL3 = real_path("test3.sql")
ILI3 = real_path("res3.ili")
SQL4 = real_path("test4.sql")
ILI4 = real_path("res4.ili")
SQL5 = real_path("test5.sql")
ILI5 = real_path("res5.ili")
SQL6 = real_path("test6.sql")
ILI6 = real_path("res6.ili")
SQL7 = real_path("test7.sql")
ILI7 = real_path("res7.ili")
SQL8 = real_path("test8.sql")
ILI8 = real_path("res8.ili")
SQL9 = real_path("test9.sql")
ILI9 = real_path("res9.ili")
SQL10 = real_path("test10.sql")
ILI10 = real_path("res10.ili")
SQL11 = real_path("test11.sql")
ILI11 = real_path("res11.ili")
SQL12 = real_path("test12.sql")
ILI12a = real_path("res12a.ili")
ILI12b = real_path("res12b.ili")
SQL13 = real_path("test13.sql")
ILI13 = ILI1


class TestPG2ILI(unittest.TestCase):

    @classmethod
    def setUpClass(self):
        print('\nINFO: Set up...\n')

    def test_sql1(self):
        print('INFO: Validating pg2ili single table...')
        pg2ili = PG2ILI(SQL1)
        ili_string = pg2ili.convert()
        self.assertEqual(len(pg2ili.pg_primary_keys), 0)
        self.assertEqual(len(pg2ili.pg_uniques), 0)
        self.assertTrue(self.compare_ili_to_str(ILI1, ili_string), "Test 1 failed!")

    def test_sql2(self):
        print('INFO: Validating pg2ili two tables...')
        pg2ili = PG2ILI(SQL2)
        ili_string = pg2ili.convert()
        self.assertEqual(len(pg2ili.pg_primary_keys), 0)
        self.assertEqual(len(pg2ili.pg_uniques), 0)
        self.assertTrue(self.compare_ili_to_str(ILI2, ili_string), "Test 2 failed!")

    def test_sql3(self):
        print('INFO: Validating pg2ili complete...')
        pg2ili = PG2ILI(SQL3)
        ili_string = pg2ili.convert()
        self.assertEqual(len(pg2ili.pg_primary_keys), 45)
        self.assertEqual(len(pg2ili.pg_uniques), 4)
        self.assertTrue(self.compare_ili_to_str(ILI3, ili_string), "Test 3 failed!")

    def test_sql4(self):
        print('INFO: Validating pg2ili UNIQUE constraints...')
        pg2ili = PG2ILI(SQL4)
        ili_string = pg2ili.convert()
        self.assertEqual(len(pg2ili.pg_primary_keys), 1)
        self.assertEqual(len(pg2ili.pg_uniques), 1)
        self.assertTrue(self.compare_ili_to_str(ILI4, ili_string), "Test 4 failed!")

    def test_sql5(self):
        print('INFO: Validating pg2ili associations...')
        pg2ili = PG2ILI(SQL5)
        ili_string = pg2ili.convert()
        self.assertEqual(len(pg2ili.pg_primary_keys), 3)
        self.assertEqual(len(pg2ili.pg_uniques), 1)
        self.assertEqual(len(pg2ili.pg_foreign_keys), 2)
        self.assertTrue(self.compare_ili_to_str(ILI5, ili_string), "Test 5 failed!")

    def test_sql6(self):
        print('INFO: Validating pg2ili 1:0..1 (NN,U) association and ignored tables and attrs...')
        pg2ili = PG2ILI(SQL6)
        ili_string = pg2ili.convert()
        self.assertEqual(len(pg2ili.pg_primary_keys), 2)
        self.assertEqual(len(pg2ili.pg_uniques), 1)
        self.assertEqual(len(pg2ili.pg_foreign_keys), 1)
        self.assertTrue(self.compare_ili_to_str(ILI6, ili_string), "Test 6 failed!")

    def test_sql7(self):
        print('INFO: Validating pg2ili 0..1:0..* () association...')
        pg2ili = PG2ILI(SQL7)
        ili_string = pg2ili.convert()
        self.assertEqual(len(pg2ili.pg_primary_keys), 0)
        self.assertEqual(len(pg2ili.pg_uniques), 0)
        self.assertEqual(len(pg2ili.pg_foreign_keys), 1)
        self.assertTrue(self.compare_ili_to_str(ILI7, ili_string), "Test 7 failed!")

    def test_sql8(self):
        print('INFO: Validating pg2ili 0..1:0..1 (U) association...')
        pg2ili = PG2ILI(SQL8)
        ili_string = pg2ili.convert()
        self.assertEqual(len(pg2ili.pg_primary_keys), 0)
        self.assertEqual(len(pg2ili.pg_uniques), 1)
        self.assertEqual(len(pg2ili.pg_foreign_keys), 1)
        self.assertTrue(self.compare_ili_to_str(ILI8, ili_string), "Test 8 failed!")

    def test_sql9(self):
        print('INFO: Validating pg2ili 1:0..* (NN) association...')
        pg2ili = PG2ILI(SQL9)
        ili_string = pg2ili.convert()
        self.assertEqual(len(pg2ili.pg_primary_keys), 0)
        self.assertEqual(len(pg2ili.pg_uniques), 0)
        self.assertEqual(len(pg2ili.pg_foreign_keys), 1)
        self.assertTrue(self.compare_ili_to_str(ILI9, ili_string), "Test 9 failed!")

    def test_sql10(self):
        print('INFO: Validating pg2ili M:N association...')
        pg2ili = PG2ILI(SQL10)
        ili_string = pg2ili.convert()
        self.assertEqual(len(pg2ili.pg_primary_keys), 2)
        self.assertEqual(len(pg2ili.pg_uniques), 0)
        self.assertEqual(len(pg2ili.pg_foreign_keys), 0)
        self.assertEqual(len(pg2ili.m_n_associations), 1)
        self.assertTrue(self.compare_ili_to_str(ILI10, ili_string), "Test 10 failed!")

    def test_sql11(self):
        print('INFO: Validating pg2ili "numeric(p, s)" types...')
        pg2ili = PG2ILI(SQL11)
        ili_string = pg2ili.convert()
        self.assertEqual(len(pg2ili.pg_primary_keys), 0)
        self.assertEqual(len(pg2ili.pg_uniques), 0)
        self.assertEqual(len(pg2ili.pg_foreign_keys), 0)
        self.assertEqual(len(pg2ili.m_n_associations), 0)
        self.assertTrue(self.compare_ili_to_str(ILI11, ili_string), "Test 11 failed!")

    def test_sql12(self):
        print('INFO: Validating pg2ili ignoring Primary Keys...')
        pg2ili = PG2ILI(SQL12)  # Omitting PKs
        ili_string = pg2ili.convert()
        self.assertEqual(len(pg2ili.pg_primary_keys), 3)
        self.assertEqual(len(pg2ili.pg_uniques), 1)
        self.assertEqual(len(pg2ili.pg_foreign_keys), 1)
        self.assertEqual(len(pg2ili.m_n_associations), 1)
        self.assertTrue(self.compare_ili_to_str(ILI12a, ili_string), "Test 12a failed!")

        pg2ili = PG2ILI(SQL12, omit_primary_keys=False)
        ili_string = pg2ili.convert()
        self.assertEqual(len(pg2ili.pg_primary_keys), 3)
        self.assertEqual(len(pg2ili.pg_uniques), 1)
        self.assertEqual(len(pg2ili.pg_foreign_keys), 1)
        self.assertEqual(len(pg2ili.m_n_associations), 1)
        self.assertTrue(self.compare_ili_to_str(ILI12b, ili_string), "Test 12b failed!")

    def test_sql13(self):
        print('INFO: Validating pg2ili single table with schema in geometry column...')
        pg2ili = PG2ILI(SQL13)
        ili_string = pg2ili.convert()
        self.assertEqual(len(pg2ili.pg_primary_keys), 0)
        self.assertEqual(len(pg2ili.pg_uniques), 0)
        print(ili_string)
        self.assertTrue(self.compare_ili_to_str(ILI13, ili_string), "Test 13 failed!")

    def compare_ili_to_str(self, ili_file, ili_string):
        file_contents = ""
        with open(ili_file) as f:
            file_contents = f.read()

        str_lines = ili_string.split("\n")
        file_lines = file_contents.split("\n")

        if len(str_lines) != len(file_lines):
            print("Number of lines in ili string ({}) differs from number of lines in ili file ({})".format(
                len(str_lines),
                len(file_lines)))
            return False

        for i, file_line in enumerate(file_lines):
            if file_line.strip() != str_lines[i].strip():
                print("ERROR: Different line ({})!".format(i))
                print("file_line: (length: {}".format(len(file_line)), file_line)
                print("str_line: (length: {})".format(len(str_lines[i])), str_lines[i])
                return False

        return True

    @classmethod
    def tearDownClass(self):
        print('INFO: Tear down...')

if __name__ == '__main__':
    nose2.main()
