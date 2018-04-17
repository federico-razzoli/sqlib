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

DROP DATABASE IF EXISTS _;
CREATE DATABASE _;
USE _;


/*
    SYNONYMS
    ========

    Synonyms for built-in functions whose names are not easy to remember.
    Always keep this section first.
*/

-- Example:
-- SELECT _.today();
DROP FUNCTION IF EXISTS today;
CREATE FUNCTION today()
    RETURNS DATE
    NOT DETERMINISTIC
    CONTAINS SQL
    COMMENT 'Synonym for CURDATE()'
BEGIN
    RETURN CURDATE();
END;


/*
    CUSTOM EXCEPTIONS
    =================

    `exception_dictionary` table serves as a documentation of all custom
    exceptions used by SQLib.
*/

CREATE TABLE exception_dictionary (
    `sqlstate` CHAR(5) NOT NULL,
    `code` SMALLINT UNSIGNED NOT NULL,
    `message` TEXT NOT NULL,
    PRIMARY KEY (`code`)
)
    ENGINE InnoDB,
    COMMENT 'Custom exceptions used by SQLib';

INSERT INTO exception_dictionary
    (`sqlstate`, `code`, `message`)
    VALUES
    ('45000', 32001, 'No namespace available for prepared statement');


/*
    LANGUAGE EXTENSIONS
    ===================

    Routines that make development of other routines easier,
    alleviating the need to write verbose or ugly code
    to accomplish reasonably common tasks.
*/

-- Example:
-- CALL _.raise_exception(32000, 'Test error');
DROP PROCEDURE IF EXISTS raise_exception;
CREATE PROCEDURE raise_exception(IN in_code SMALLINT UNSIGNED, IN in_message TEXT)
    CONTAINS SQL
    COMMENT 'SIGNAL a custom error with SQLSTATE ''45000'''
BEGIN
    SIGNAL SQLSTATE '45000' SET
        MYSQL_ERRNO = in_code,
        MESSAGE_TEXT = in_message;
END;

-- Example:
-- CALL _.raise_warning(32000, 'Test warning');
-- SHOW WARNINGS;
DROP PROCEDURE IF EXISTS raise_warning;
CREATE PROCEDURE raise_warning(IN in_code SMALLINT UNSIGNED, IN in_message TEXT)
    CONTAINS SQL
    COMMENT 'SIGNAL a custom warning with SQLSTATE ''01000'''
BEGIN
    SIGNAL SQLSTATE '01000' SET
        MYSQL_ERRNO = in_code,
        MESSAGE_TEXT = in_message;
END;

-- Example:
-- SELECT _.quote_name('my`table');
DROP FUNCTION IF EXISTS quote_name;
CREATE FUNCTION quote_name(p_name VARCHAR(64))
    RETURNS TEXT
    DETERMINISTIC
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
    DETERMINISTIC
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
    DETERMINISTIC
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
-- SELECT _.quote_account('u`ser', 'h`ost');
DROP FUNCTION IF EXISTS quote_account;
CREATE FUNCTION quote_account(p_user VARCHAR(32), p_host VARCHAR(60))
    RETURNS TEXT
    DETERMINISTIC
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
    DETERMINISTIC
    CONTAINS SQL
    COMMENT 'Return input string with LIKE special characters escaped'
BEGIN
    RETURN REPLACE(
        REPLACE(p_like, '%', '\%'),
        '_', '\_'
    );
END;

-- Example:
-- CALL _.is_valid_name('order', @is_valid);
-- SELECT @is_valid;
DROP PROCEDURE IF EXISTS is_valid_name;
CREATE PROCEDURE is_valid_name(IN in_name TEXT, OUT out_is_valid BOOL)
    CONTAINS SQL
    COMMENT 'Set `out_is_valid` to TRUE if id is valid name, else FALSE. The check is done by trying to use it as an alias in a prepared statement.'
BEGIN
    DECLARE EXIT HANDLER
        FOR 1064
    BEGIN
        SET out_is_valid = FALSE;
    END;
 
    SET @sql_query = CONCAT('DO (SELECT 0 AS ', in_name, ');');
    PREPARE stmt FROM @sql_query;
    EXECUTE stmt;
    DEALLOCATE PREPARE stmt;
 
    SET `out_is_valid` = TRUE;
END;

-- Example:
-- CALL _.run_sql0('SELECT 1;');
DROP PROCEDURE IF EXISTS run_sql0;
CREATE PROCEDURE run_sql0(IN in_sql TEXT)
    MODIFIES SQL DATA
    COMMENT 'Run specified SQL query. Cannot be called recursively'
BEGIN
    SET @_run_sql_sql0 = in_sql;
    PREPARE _stmt_run_sql_sql0 FROM @_run_sql_sql0;
    
    EXECUTE _stmt_run_sql_sql0;

    DEALLOCATE PREPARE _stmt_run_sql_sql0;
    SET @_run_sql_sql0 = NULL;
END;

-- Example:
-- CALL _.run_sql1('SELECT 1;');
DROP PROCEDURE IF EXISTS run_sql1;
CREATE PROCEDURE run_sql1(IN in_sql TEXT)
    MODIFIES SQL DATA
    COMMENT 'Run specified SQL query. Cannot be called recursively'
BEGIN
    SET @_run_sql_sql1 = in_sql;
    PREPARE _stmt_run_sql_sql1 FROM @_run_sql_sql1;
    
    EXECUTE _stmt_run_sql_sql1;

    DEALLOCATE PREPARE _stmt_run_sql_sql1;
    SET @_run_sql_sql1 = NULL;
END;

-- Example:
-- CALL _.run_sql2('SELECT 1;');
DROP PROCEDURE IF EXISTS run_sql2;
CREATE PROCEDURE run_sql2(IN in_sql TEXT)
    MODIFIES SQL DATA
    COMMENT 'Run specified SQL query. Cannot be called recursively'
BEGIN
    SET @_run_sql_sql2 = in_sql;
    PREPARE _stmt_run_sql_sql2 FROM @_run_sql_sql2;
    
    EXECUTE _stmt_run_sql_sql2;

    DEALLOCATE PREPARE _stmt_run_sql_sql2;
    SET @_run_sql_sql2 = NULL;
END;

-- Example:
-- CALL _.run_sql3('SELECT 1;');
DROP PROCEDURE IF EXISTS run_sql3;
CREATE PROCEDURE run_sql3(IN in_sql TEXT)
    MODIFIES SQL DATA
    COMMENT 'Run specified SQL query. Cannot be called recursively'
BEGIN
    SET @_run_sql_sql3 = in_sql;
    PREPARE _stmt_run_sql_sql3 FROM @_run_sql_sql3;
    
    EXECUTE _stmt_run_sql_sql3;

    DEALLOCATE PREPARE _stmt_run_sql_sql3;
    SET @_run_sql_sql3 = NULL;
END;

-- Example:
-- CALL _.run_sql4('SELECT 1;');
DROP PROCEDURE IF EXISTS run_sql4;
CREATE PROCEDURE run_sql4(IN in_sql TEXT)
    MODIFIES SQL DATA
    COMMENT 'Run specified SQL query. Cannot be called recursively'
BEGIN
    SET @_run_sql_sql4 = in_sql;
    PREPARE _stmt_run_sql_sql4 FROM @_run_sql_sql4;
    
    EXECUTE _stmt_run_sql_sql4;

    DEALLOCATE PREPARE _stmt_run_sql_sql4;
    SET @_run_sql_sql4 = NULL;
END;

-- Example:
-- CALL _.run_sql('SELECT 1;');
DROP PROCEDURE IF EXISTS run_sql;
CREATE PROCEDURE run_sql(IN in_sql TEXT)
    MODIFIES SQL DATA
    COMMENT 'Run specified SQL query. Support 5 levels of recursion'
BEGIN
    -- Normally, prepared statements cannot be called recursively in a dynamic
    -- way, because the following must have unique names:
    --   - Prepared statement name
    --   - User variable containing the query
    -- As a workaround, we provide several run_sql*() procedures,
    -- each using a different suffix for these elements.
    -- As a consequence, this generic run_sql() must be able to find
    -- the lowest prefix currently not in use.
    -- For this purpose, we create a temporary tables with the id's
    -- and a boolean flag which indicates if they are currently in use.
    -- The number of max concurrent prepared statements is still
    -- an arbitrary limit.
    BEGIN
        DECLARE error_message TEXT DEFAULT NULL;

        -- If the table exists, assume it is already populated.
        DECLARE CONTINUE HANDLER
            FOR 1146
        BEGIN END;

        CREATE TEMPORARY TABLE IF NOT EXISTS _.prepared_statement_namespaces (
            id TINYINT UNSIGNED NOT NULL,
            in_use BOOL NOT NULL DEFAULT FALSE,
            PRIMARY KEY (id)
        ) ENGINE MEMORY;
        INSERT IGNORE INTO _.prepared_statement_namespaces (id) VALUES (0), (1), (2), (3), (4);
    END;

    -- Now that we are sure that we have the table
    -- prepared_statement_namespaces we need to:
    --   - Check if a suffix is available, if not exit with an error;
    --   - Lock the suffix;
    --   - Run the SQL statement;
    --   - Unlock the suffix.
    BEGIN
        DECLARE next_id TINYINT UNSIGNED DEFAULT NULL;
        DECLARE error_message TEXT DEFAULT NULL;

        SET next_id := (
            SELECT MIN(id)
                FROM _.prepared_statement_namespaces
                WHERE in_use = 0
        );

        IF next_id IS NULL THEN
            SET error_message := CONCAT_WS('',
                'No namespace available for prepared statement: ',
                in_sql
            );
            CALL raise_exception(32001, error_message);
        END IF;

        -- lock
        UPDATE _.prepared_statement_namespaces
            SET in_use = TRUE
            WHERE id = next_id;

        -- To run the ps with the proper suffix we rely on the relevant procedure.
        -- We cannot do this step dynamically for the reasons stated above.
        -- We keep the lock/unlock logic here to have it in a centralized place.
        -- This means that the used should not call specific functions directly,
        -- or she shouldn't rely on this procedure.
        CASE next_id
            WHEN 0 THEN BEGIN
                CALL _.run_sql0(in_sql);
            END;
            WHEN 1 THEN BEGIN
                CALL _.run_sql1(in_sql);
            END;
            WHEN 2 THEN BEGIN
                CALL _.run_sql2(in_sql);
            END;
            WHEN 3 THEN BEGIN
                CALL _.run_sql3(in_sql);
            END;
            WHEN 4 THEN BEGIN
                CALL _.run_sql4(in_sql);
            END;
        END CASE;

        -- release lock
        UPDATE _.prepared_statement_namespaces
            SET in_use = FALSE
            WHERE id = next_id;
    END;
END;


/*
    METADATA
    ========

    Various information about metadata.
*/

-- Example:
-- SELECT _.database_exists('test');
DROP FUNCTION IF EXISTS database_exists;
CREATE FUNCTION database_exists(p_name VARCHAR(64))
    RETURNS BOOL
    NOT DETERMINISTIC
    READS SQL DATA
    COMMENT 'Return if specified database exists'
BEGIN
    RETURN EXISTS (
        SELECT SCHEMA_NAME
            FROM information_schema.SCHEMATA
            WHERE SCHEMA_NAME = p_name
    );
END;

-- Example:
-- SELECT _.schema_exists('test');
DROP FUNCTION IF EXISTS schema_exists;
CREATE FUNCTION schema_exists(p_name VARCHAR(64))
    RETURNS BOOL
    NOT DETERMINISTIC
    READS SQL DATA
    COMMENT 'Synonym for database_exists()'
BEGIN
    RETURN database_exists(p_name);
END;


# release MDL, if any
COMMIT;
