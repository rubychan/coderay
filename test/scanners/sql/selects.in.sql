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

SELECT * FROM users;

select * from users;

SELECT `First Name`, `Last Name` FROM `User Table`;

select first_name, last_name FROM users;

select first_name || ' ' || last_name from users;

select first_name || " " || last_name from users;

SELECT * FROM users JOIN companies USING (company_id) WHERE company_type = 'Fortune 500';

SELECT * FROM users WHERE name_first LIKE '%Keith%';

SELECT CASE WHEN foo.bar = 'PY'
   THEN 'BAR'
   ELSE 'FOO'
   END as bar_type,
   user_id,
   company_id,
   sum(
      case when foo.bar = 'PY'
      then -amt else amt
   end
   ) over (order by id, amt) as balance;

SELECT users.*, (SELECT company_name FROM companies WHERE company_id = users.company_id) FROM users;

