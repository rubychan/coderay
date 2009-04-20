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

-- Comment: Drop table
DROP TABLE IF EXISTS `general_lookups`;

-- Create table
CREATE TABLE `general_lookups` (
  `name` varchar(255) default NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- Drop table again
DROP TABLE IF EXISTS customer;

-- Create customers
CREATE TABLE customer (
   first_name char(50),
   last_name char(50),
   address char(50),
   city char(50),
   country char(25),
   birth_date date,
   created_at timestamp, -- Differnt sort of date here
   updated_at timestamp
)

-- Create business
CREATE TABLE business (
   compant_name char(50),
   address char(50) default 'Address Unknown', -- Oohh, defaults..
   city char(50) default 'Adelaide',
   country char(150) default 'Australia'
)

-- Some random table

DROP TABLE IF EXISTS customer_statuses;

CREATE TABLE `customer_statuses` (
   -- Auto incrementing IDs
  `id` smallint(6) unsigned NOT NULL auto_increment,
  `customer_id` int(10) unsigned NOT NULL default '0',
  `customer_client_code` varchar(15) default NULL,
  `entry_date` date default NULL,
  `status_id` smallint(6) unsigned default NULL,
  `comments` varchar(100) default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- Try creating an index.
CREATE INDEX customer_status_status_id ON customer_statuses (status_id)

/* Now lets try and make a really big table */

DROP TABLE IF EXISTS `legacy_clients`;
CREATE TABLE `legacy_clients` (
  `id` int(10) unsigned NOT NULL auto_increment,
  `client_code` varchar(15) default NULL,
  `first_name` varchar(20) NOT NULL default '',
  `other_name` varchar(20) default NULL,
  `surname` varchar(30) NOT NULL default '',
  `address` varchar(50) default NULL,
  `suburb` varchar(50) default NULL,
  `postcode` varchar(10) default NULL,
  `location_id` smallint(3) default NULL,
  `home_phone` varchar(15) default NULL,
  `work_phone` varchar(15) default NULL,
  `fax` varchar(15) default NULL,
  `mobile` varchar(15) default NULL,
  `email` varchar(50) default NULL,
  `date_of_birth` date default NULL,
  `business_id` int(11) default NULL,
  `comments` varchar(100) default NULL,
  `state` char(3) default NULL,
  `sex` char(1) default NULL,
  `location_temp` varchar(50) default NULL,
  `employer_temp` varchar(50) default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;


