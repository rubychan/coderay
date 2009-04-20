# All of the values below are valid MySQL syntax accoring to
# the Reference Manual:
#   http://dev.mysql.com/doc/refman/5.1/en/language-structure.html
# unless stated otherwise.

# strings
SELECT 'a string';
SELECT "another string";

SELECT _latin1'string';
SELECT _latin1'string' COLLATE latin1_danish_ci;

SELECT N'some text';
SELECT n'some text';
SELECT _utf8'some text';

SELECT "\0\'\"''""\b\n\r\t\Z\\\%\_";  # "
SELECT '\0\'\"''""\b\n\r\t\Z\\\%\_';  # '

SELECT "\B\x";  # "
SELECT '\B\x';  # '

SELECT 'hello', '"hello"', '""hello""', 'hel''lo', '\'hello';  -- '
SELECT "hello", "'hello'", "''hello''", "hel""lo", "\"hello";  -- "

SELECT 'This\nIs\nFour\nLines';
SELECT 'disappearing\ backslash';

# numbers
select 1221;
select 0;
select -32:

select 294.42:
select -32032.6809e+10;
select 148.00;

select 10e+10;
select 10e10;

# hexadecimal
SELECT X'4D7953514C';
SELECT 0x0a+0;
SELECT 0x5061756c;
SELECT 0x41, CAST(0x41 AS UNSIGNED);
SELECT HEX('cat');
SELECT 0x636174;
insert into t (md5) values (0xad65);
SELECT * FROM SomeTable WHERE BinaryColumn = CAST( x'a0f44ef7a52411de' AS BINARY );
select x'000bdddc0e9153f5a93447fc3310f710', x'0bdddc0e9153f5a93447fc3310f710';

SELECT TRUE, true, FALSE, false;
SELECT NULL, null, nuLL, \N;
SELECT \n;  # invalid!

# bit-field
CREATE TABLE t (b BIT(8));
INSERT INTO t SET b = b'11111111';
INSERT INTO t SET b = b'1010';
INSERT INTO t SET b = b'0101';
SELECT b+0, BIN(b+0), OCT(b+0), HEX(b+0) FROM t;

SET @v1 = b'1000001';
SET @v2 = CAST(b'1000001' AS UNSIGNED), @v3 = b'1000001'+0;
SELECT @v1, @v2, @v3;

INSERT INTO my_table (phone) VALUES (NULL);
INSERT INTO my_table (phone) VALUES ('');

# schema object names
SELECT * FROM `select` WHERE `select`.id > 100;

CREATE TABLE `a``b` (`c"d` INT);
SELECT 1 AS `one`, 2 AS 'two';

select foo from foo;
select `foo` from foo;
select foo.bar from foo;
select `foo`.bar from foo;
select foo.`bar` from foo;
select `foo.bar` from foo;
select `foo`.`bar` from foo;

# How to handle ANSI_QUOTES?
CREATE TABLE "test" (col INT);
SET sql_mode='ANSI_QUOTES';
CREATE TABLE "test" (col INT);

# identifiers
SELECT * FROM my_table WHERE MY_TABLE.col=1;
SHOW COLUMNS FROM `#mysql50#a@b`;

# Function Name Parsing and Resolution


SELECT COUNT(*) FROM mytable;  -- the first reference to count is a function call
CREATE TABLE count (i INT);  -- whereas the second reference is a table name
CREATE TABLE `count`(i INT);  -- this too
CREATE TABLE `count` (i INT);  -- this too

# IGNORE_SPACE
SELECT COUNT(*) FROM mytable;
SELECT COUNT (*) FROM mytable;

# reserved words
CREATE TABLE interval (begin INT, end INT);  -- errror
CREATE TABLE `interval` (begin INT, end INT);  -- valid
CREATE TABLE mydb.interval (begin INT, end INT);  -- valid
SELECT `foo`, `bar` FROM `baz` WHERE `bal` = `quiche`;  -- valid
