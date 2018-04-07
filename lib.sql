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

-- Example:
-- SELECT quote_account('u`ser', 'h`ost');
DROP FUNCTION IF EXISTS quote_account;
CREATE FUNCTION quote_account(p_user VARCHAR(32), p_host VARCHAR(60))
    RETURNS TEXT
    CONTAINS SQL
    COMMENT 'Return valid syntax for specified account'
BEGIN
    RETURN CONCAT(
        '`', REPLACE(p_user, '`', '``'), '`',
        '@',
        '`', REPLACE(p_host, '`', '``'), '`'
    );
END;

-- Example:
-- SELECT _.escape_like('_90%_');
DROP FUNCTION IF EXISTS escape_like;
CREATE FUNCTION escape_like(p_like TEXT)
    RETURNS TEXT
    CONTAINS SQL
    COMMENT 'Return input string with LIKE special characters escaped'
BEGIN
    RETURN REPLACE(
        REPLACE(p_like, '%', '\%'),
        '_', '\_'
    );
END;


# release MDL, if any
COMMIT;
