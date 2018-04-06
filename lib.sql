/*
    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU Affero General Public License as published by
    the Free Software Foundation, version 3 of the License.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU Affero General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/

CREATE DATABASE _;
USE _;


-- Example:
-- SELECT _.quote_name('my`table');
DROP FUNCTION IF EXISTS quote_name;
CREATE FUNCTION quote_name(p_name VARCHAR(64))
    RETURNS TEXT
    CONTAINS SQL
    COMMENT 'Return specified name quoted with backticks and escaped'
BEGIN
    RETURN CONCAT('`', REPLACE(p_name, '`', '``'), '`');
END;

-- Example:
-- SELECT _.quote_name2('my`db', 'my`table');
DROP FUNCTION IF EXISTS quote_name2;
CREATE FUNCTION quote_name2(p_name1 VARCHAR(64), p_name2 VARCHAR(64))
    RETURNS TEXT
    CONTAINS SQL
    COMMENT 'Return specified FQN quoted with backticks and escaped'
BEGIN
    RETURN CONCAT(
        '`', REPLACE(p_name1, '`', '``'), '`',
        '.',
        '`', REPLACE(p_name2, '`', '``'), '`'
    );
END;

-- Example:
-- SELECT _.quote_name3('my`db', 'my`table', 'my`column');
DROP FUNCTION IF EXISTS quote_name3;
CREATE FUNCTION quote_name3(p_name1 VARCHAR(64), p_name2 VARCHAR(64), p_name3 VARCHAR(64))
    RETURNS TEXT
    CONTAINS SQL
    COMMENT 'Return specified FQN quoted with backticks and escaped'
BEGIN
    RETURN CONCAT(
        '`', REPLACE(p_name1, '`', '``'), '`',
        '.',
        '`', REPLACE(p_name2, '`', '``'), '`'
        '.',
        '`', REPLACE(p_name3, '`', '``'), '`'
    );
END;


# release MDL, if any
COMMIT;
