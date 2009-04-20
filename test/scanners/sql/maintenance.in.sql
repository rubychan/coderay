--RANDOM SQL QUERIES THAT DO NOTHING INTERESTING
--Copyright (C) 2009 - Keith Pitt <keith@keithpitt.com>

--This program is free software: you can redistribute it and/or modify
--it under the terms of the GNU General Public License as published by
--the Free Software Foundation, either version 3 of the License, or
--(at your option) any later version.

--This program is distributed in the hope that it will be useful,
--but WITHOUT ANY WARRANTY; without even the implied warranty of
--MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
--GNU General Public License for more details.

--You should have received a copy of the GNU General Public License
--along with this program.  If not, see <http://www.gnu.org/licenses/>.

INSERT INTO users (first_name, last_name) VALUES ('John', 'Doe');

INSERT INTO users (first_name, last_name) VALUES ("John", "Doe");

UPDATE users SET first_name = 'Keith' WHERE first_name = 'JOHN';

DELETE FROM users WHERE first_name = 'Keith';

