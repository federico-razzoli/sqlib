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
-- CALL _.database_exists(@r, 'test');
-- SELECT @r;
DROP PROCEDURE IF EXISTS database_exists;
CREATE PROCEDURE database_exists(OUT out_ret BOOL, IN in_name VARCHAR(64))
    READS SQL DATA
    COMMENT 'Return if specified database exists'
BEGIN
    IF in_name IS NULL THEN
        SET out_ret := NULL;
    ELSE
        SET out_ret := EXISTS (
            SELECT SCHEMA_NAME
                FROM information_schema.SCHEMATA
                WHERE SCHEMA_NAME = in_name
        );
    END IF;
END;

-- Example:
-- CALL _.schema_exists(@r, 'test');
-- SELECT @r;
DROP PROCEDURE IF EXISTS schema_exists;
CREATE PROCEDURE schema_exists(OUT out_ret BOOL, IN in_name VARCHAR(64))
    READS SQL DATA
    COMMENT 'Synonym for database_exists()'
BEGIN
    CALL database_exists(out_ret, in_name);
END;

-- Example:
-- CALL _.entity_exists(@r, 'mysql', 'user');
-- SELECT @r;
DROP PROCEDURE IF EXISTS entity_exists;
CREATE PROCEDURE entity_exists(OUT out_ret BOOL, IN in_schema VARCHAR(64), IN in_table VARCHAR(64))
    READS SQL DATA
    COMMENT 'Return wether database.table exists'
BEGIN
    DECLARE v_sql TEXT DEFAULT NULL;
    -- if the table does not exist, a query on it will return an error
    -- that we will handle, returning FALSE
    DECLARE EXIT HANDLER
        FOR 1146
    BEGIN
        SET out_ret := FALSE;
    END;

    IF in_schema IS NULL OR in_table IS NULL THEN
        SET out_ret :=  NULL;
    ELSE
        SET v_sql := CONCAT(
            'DO (SELECT 1 FROM ', QUOTE_NAME2(in_schema, in_table), ' LIMIT 1);'
        );
        CALL run_sql(v_sql);
        SET out_ret :=  TRUE;
    END IF;
END;

-- Example:
-- CALL _.column_exists(@r, 'mysql', 'user', 'host');
-- SELECT @r;
DROP PROCEDURE IF EXISTS column_exists;
CREATE PROCEDURE column_exists(
        OUT out_ret BOOL,
        IN in_schema VARCHAR(64),
        IN in_table VARCHAR(64),
        IN in_column VARCHAR(64)
    )
    READS SQL DATA
    COMMENT 'Return wether database.table exists'
BEGIN
    DECLARE v_sql TEXT DEFAULT NULL;
    -- if the table (1146) / column (1054) does not exist, a query on it will return an error
    -- that we will handle, returning FALSE
    DECLARE EXIT HANDLER
        FOR 1146, 1054
    BEGIN
        SET out_ret := FALSE;
    END;

    IF in_schema IS NULL OR in_table IS NULL OR in_column IS NULL THEN
        SET out_ret :=  NULL;
    ELSE
        SET v_sql := CONCAT(
            'DO (SELECT ', QUOTE_NAME(in_column), ' FROM ', QUOTE_NAME2(in_schema, in_table), ' LIMIT 1);'
        );
        CALL run_sql(v_sql);
        SET out_ret :=  TRUE;
    END IF;
END;

-- Example:
-- CALL _.event_exists(@r, 'test', 'test_event');
-- SELECT @r;
DROP PROCEDURE IF EXISTS event_exists;
CREATE PROCEDURE event_exists(
        OUT out_ret BOOL,
        IN in_schema VARCHAR(64),
        IN in_event VARCHAR(64)
    )
    READS SQL DATA
    COMMENT 'Return if specified event exists'
BEGIN
    IF in_schema IS NULL OR in_event IS NULL THEN
        SET out_ret := NULL;
    ELSE
        SET out_ret := EXISTS (
            SELECT EVENT_NAME
                FROM information_schema.EVENTS
                WHERE EVENT_SCHEMA = in_schema AND EVENT_NAME = in_event
        );
    END IF;
END;


/*
    TABLES INFORMATION
    ==================

    Metainformation about tables.
*/

-- Example:
-- SELECT _.get_dataset_size();
DROP FUNCTION IF EXISTS get_dataset_size;
CREATE FUNCTION get_dataset_size()
    RETURNS BIGINT UNSIGNED
    NOT DETERMINISTIC
    READS SQL DATA
    COMMENT 'Return the sum of all database sizes, in bytes'
BEGIN
    RETURN (
        SELECT
            SUM(DATA_LENGTH + INDEX_LENGTH + DATA_FREE)
            FROM information_schema.TABLES
    );
END;

CREATE OR REPLACE VIEW TABLES_BY_DATABASE AS
    SELECT
            TABLE_SCHEMA AS `DATABASE`,
            COUNT(*) AS TABLE_COUNT,
            SUM(TABLE_ROWS) AS TABLE_ROWS,
            FORMAT(SUM(DATA_LENGTH)  / 1024 / 1024 / 1024, 2) AS DATA_LENGTH_GB,
            FORMAT(SUM(INDEX_LENGTH) / 1024 / 1024 / 1024, 2) AS INDEX_LENGTH_GB,
            FORMAT(SUM(DATA_FREE)    / 1024 / 1024 / 1024, 2) AS DATA_FREE_GB,
            FORMAT(SUM(DATA_LENGTH + INDEX_LENGTH + DATA_FREE)
                                     / 1024 / 1024 / 1024, 2) AS TOTAL_SIZE_GB
        FROM information_schema.TABLES
        WHERE ENGINE IS NOT NULL
        GROUP BY TABLE_SCHEMA
        ORDER BY TABLE_SCHEMA
;

CREATE OR REPLACE VIEW TABLES_BY_ENGINE AS
    SELECT
            ENGINE,
            COUNT(*) AS TABLE_COUNT,
            SUM(TABLE_ROWS) AS TABLE_ROWS,
            FORMAT(SUM(DATA_LENGTH)  / 1024 / 1024 / 1024, 2) AS DATA_LENGTH_GB,
            FORMAT(SUM(INDEX_LENGTH) / 1024 / 1024 / 1024, 2) AS INDEX_LENGTH_GB,
            FORMAT(SUM(DATA_FREE)    / 1024 / 1024 / 1024, 2) AS DATA_FREE_GB,
            FORMAT(SUM(DATA_LENGTH + INDEX_LENGTH + DATA_FREE)
                                     / 1024 / 1024 / 1024, 2) AS TOTAL_SIZE_GB
        FROM information_schema.TABLES
        WHERE ENGINE IS NOT NULL
        GROUP BY ENGINE
        ORDER BY ENGINE
;

CREATE OR REPLACE VIEW TABLES_BY_DATABASE_AND_ENGINE AS
    SELECT
            TABLE_SCHEMA AS `DATABASE`,
            ENGINE,
            COUNT(*) AS TABLE_COUNT,
            SUM(TABLE_ROWS) AS TABLE_ROWS,
            FORMAT(SUM(DATA_LENGTH)  / 1024 / 1024 / 1024, 2) AS DATA_LENGTH_GB,
            FORMAT(SUM(INDEX_LENGTH) / 1024 / 1024 / 1024, 2) AS INDEX_LENGTH_GB,
            FORMAT(SUM(DATA_FREE)    / 1024 / 1024 / 1024, 2) AS DATA_FREE_GB,
            FORMAT(SUM(DATA_LENGTH + INDEX_LENGTH + DATA_FREE)
                                     / 1024 / 1024 / 1024, 2) AS TOTAL_SIZE_GB
        FROM information_schema.TABLES
        WHERE ENGINE IS NOT NULL
        GROUP BY TABLE_SCHEMA, ENGINE
        ORDER BY TABLE_SCHEMA, ENGINE
;

CREATE OR REPLACE VIEW UNUSED_ENGINES AS
    SELECT ENGINE
        FROM information_schema.ENGINES
        WHERE ENGINE NOT IN (
            SELECT ENGINE FROM information_schema.TABLES
        )
        ORDER BY ENGINE
;

CREATE OR REPLACE VIEW EMPTY_DATABASES AS
    SELECT SCHEMA_NAME
        FROM information_schema.SCHEMATA
        WHERE
            -- an empty schema is a schema which contains
            -- no tables, no routines, no events
            -- and implicitly, no triggers
            SCHEMA_NAME NOT IN (
                SELECT TABLE_SCHEMA FROM information_schema.TABLES
            )
            AND SCHEMA_NAME NOT IN (
                SELECT ROUTINE_SCHEMA FROM information_schema.ROUTINES
            )
            AND SCHEMA_NAME NOT IN (
                SELECT EVENT_SCHEMA FROM information_schema.EVENTS
            )
        ORDER BY SCHEMA_NAME
;

CREATE OR REPLACE VIEW EMPTY_TABLES_BY_DATABASE AS
    SELECT
            TABLE_SCHEMA AS `DATABASE`,
            COUNT(*) AS TABLE_COUNT
        FROM information_schema.TABLES
        WHERE TABLE_ROWS = 0
        GROUP BY TABLE_SCHEMA
        ORDER BY TABLE_SCHEMA
;


/*
    TABLE DESIGN
    ============

    Metainformation about tables definition.
*/

CREATE OR REPLACE VIEW tables_without_index AS
    SELECT t.TABLE_SCHEMA, t.TABLE_NAME, t.ENGINE
        FROM information_schema.TABLES t
        LEFT JOIN information_schema.STATISTICS s
            ON
                    t.TABLE_SCHEMA = s.TABLE_SCHEMA
                AND t.TABLE_NAME = s.TABLE_NAME
        WHERE
                t.ENGINE IS NOT NULL
            AND s.TABLE_NAME IS NULL
        ORDER BY t.TABLE_ROWS
;

CREATE OR REPLACE VIEW tables_without_unique AS
    SELECT t.TABLE_SCHEMA, t.TABLE_NAME, t.ENGINE
        FROM information_schema.TABLES t
        LEFT JOIN (
            SELECT TABLE_SCHEMA, TABLE_NAME
                FROM information_schema.STATISTICS
                GROUP BY TABLE_SCHEMA, TABLE_NAME, INDEX_NAME
                HAVING SUM(NON_UNIQUE = 0 AND NOT (NULLABLE = 'YES')) = COUNT(*)
        ) no_pk
            ON t.TABLE_SCHEMA = no_pk.TABLE_SCHEMA AND t.TABLE_NAME = no_pk.TABLE_NAME
        WHERE
                no_pk.TABLE_NAME IS NULL
            AND ENGINE IS NOT NULL
        ORDER BY t.TABLE_ROWS
;

CREATE OR REPLACE VIEW tables_without_pk AS
    SELECT 
        t.TABLE_SCHEMA, t.TABLE_NAME, ENGINE 
    FROM information_schema.TABLES t 
    INNER JOIN information_schema.COLUMNS c  
        ON
                t.TABLE_SCHEMA = c.TABLE_SCHEMA
            AND t.TABLE_NAME = c.TABLE_NAME 
    GROUP BY t.TABLE_SCHEMA, t.TABLE_NAME
    HAVING
        SUM(COLUMN_KEY IN ('PRI','UNI')) = 0
;


/*
    INNODB INFORMATION
    ==================

    Metainformation about InnoDB tables.
*/

CREATE OR REPLACE VIEW INNODB_TABLES_BY_ROW_FORMAT AS
    SELECT
            ROW_FORMAT,
            COUNT(*) AS TABLE_COUNT,
            SUM(TABLE_ROWS) AS TABLE_ROWS,
            FORMAT(SUM(DATA_LENGTH)  / 1024 / 1024 / 1024, 2) AS DATA_LENGTH_GB,
            FORMAT(SUM(INDEX_LENGTH) / 1024 / 1024 / 1024, 2) AS INDEX_LENGTH_GB,
            FORMAT(SUM(DATA_FREE)    / 1024 / 1024 / 1024, 2) AS DATA_FREE_GB,
            FORMAT(SUM(DATA_LENGTH + INDEX_LENGTH + DATA_FREE)
                                     / 1024 / 1024 / 1024, 2) AS TOTAL_SIZE_GB
        FROM information_schema.TABLES
        WHERE ENGINE = 'InnoDB'
        GROUP BY ROW_FORMAT
        ORDER BY ROW_FORMAT
;

CREATE OR REPLACE VIEW INNODB_COMPRESSED_TABLES_BY_DATABASE AS
    SELECT
            TABLE_SCHEMA AS `DATABASE`,
            COUNT(*) AS TABLE_COUNT,
            SUM(TABLE_ROWS) AS TABLE_ROWS,
            FORMAT(SUM(DATA_LENGTH)  / 1024 / 1024 / 1024, 2) AS DATA_LENGTH_GB,
            FORMAT(SUM(INDEX_LENGTH) / 1024 / 1024 / 1024, 2) AS INDEX_LENGTH_GB,
            FORMAT(SUM(DATA_FREE)    / 1024 / 1024 / 1024, 2) AS DATA_FREE_GB,
            FORMAT(SUM(DATA_LENGTH + INDEX_LENGTH + DATA_FREE)
                                     / 1024 / 1024 / 1024, 2) AS TOTAL_SIZE_GB
        FROM information_schema.TABLES
        WHERE ENGINE = 'InnoDB' AND ROW_FORMAT = 'Compressed'
        GROUP BY TABLE_SCHEMA
        ORDER BY TABLE_SCHEMA
;

-- Example:
-- CALL _.show_working_set_size(5, 3);
DROP PROCEDURE IF EXISTS show_working_set_size;
CREATE PROCEDURE show_working_set_size(
        IN in_observations_count INT UNSIGNED,
        IN in_observation_interval INT UNSIGNED
    )
    MODIFIES SQL DATA
    COMMENT
'Show the size of buffer pool pages based on how many times they were observed.
For example:
+--------------+-------------+----------+
| occurrencies | page_number | bytes    |
+--------------+-------------+----------+
| 3            | 34          | 557056   |
| 4            | 57          | 933888   |
| 5            | 562         | 9207808  |
| <null>       | 687         | 11255808 |
+--------------+-------------+----------+
Means that:
* 34 pages have been found 3 times,
* 57 pages have been found 4 times,
* 5 pages have been found 562 times.
* The total is 687 pages, with a size of 11255808 bytes.
The size of the total tells us how much memory we should dedicate
to the buffer pool (if our observations are meaningful).
But if we don''t have enough memory, we can look at the rows above
to get an idea of how efficient a smaller size could be.
To collect these statistics, information_schema.INNODB_BUFFER_PAGE
is read the specified number of times, at the specified interval (in seconds).

!WARNING: querying this table on a busy server can cause contention!'
BEGIN
    DROP TEMPORARY TABLE IF EXISTS innodb_used_pages;
    CREATE TEMPORARY TABLE innodb_used_pages (
        block_id INT UNSIGNED NOT NULL COMMENT 'Memory block id',
        pool_id INT UNSIGNED NOT NULL COMMENT 'Bupper pool instance id',
        occurrencies INT UNSIGNED NOT NULL COMMENT 'How many times the page was found in buffer pool',
        -- block_id is probably not unique across instances
        PRIMARY KEY (pool_id, block_id)
    )
        ENGINE MEMORY
        COMMENT 'Stats on pages found in the buffer pool'
    ;

    WHILE in_observations_count > 0 DO
        INSERT IGNORE INTO innodb_used_pages
            SELECT pool_id, block_id, 1 AS occurrencies
                FROM information_schema.INNODB_BUFFER_PAGE
                WHERE PAGE_STATE <> 'NOT_USED'
            ON DUPLICATE KEY UPDATE occurrencies := occurrencies + 1;
        DO SLEEP(in_observation_interval);
        SET in_observations_count = in_observations_count - 1;
    END WHILE;
   
    SELECT
            occurrencies,
            COUNT(*) AS page_number,
            COUNT(*) * @@innodb_page_size AS bytes
        FROM innodb_used_pages
        GROUP BY occurrencies WITH ROLLUP;
    DROP TEMPORARY TABLE innodb_used_pages;
END;


/*
    TRIGGERS
    ========

    Metainformation about triggers and tables using them.
*/

CREATE OR REPLACE VIEW TRIGGERS_BY_EVENT AS
    SELECT
            EVENT_MANIPULATION,
            COUNT(EVENT_OBJECT_TABLE) AS TABLES_WITH_TRIGGERS,
            COUNT(*) AS TRIGGER_COUNT
        FROM information_schema.TRIGGERS
        GROUP BY EVENT_MANIPULATION
        ORDER BY EVENT_MANIPULATION
;

CREATE OR REPLACE VIEW TRIGGERS_BY_EVENT_AND_TIMING AS
    SELECT
            EVENT_MANIPULATION,
            ACTION_TIMING,
            COUNT(EVENT_OBJECT_TABLE) AS TABLES_WITH_TRIGGERS,
            COUNT(*) AS TRIGGER_COUNT
        FROM information_schema.TRIGGERS
        GROUP BY EVENT_MANIPULATION, ACTION_TIMING
        ORDER BY EVENT_MANIPULATION, ACTION_TIMING
;

CREATE OR REPLACE VIEW TRIGGERS_BY_DATABASE AS
    SELECT
            TRIGGER_SCHEMA AS `DATABASE`,
            COUNT(EVENT_OBJECT_TABLE) AS TABLES_WITH_TRIGGERS,
            COUNT(*) AS TRIGGER_COUNT
        FROM information_schema.TRIGGERS
        GROUP BY TRIGGER_SCHEMA
        ORDER BY TRIGGER_SCHEMA
;

CREATE OR REPLACE VIEW TRIGGERS_BY_DATABASE_AND_EVENT AS
    SELECT
            TRIGGER_SCHEMA AS `DATABASE`,
            EVENT_MANIPULATION,
            COUNT(EVENT_OBJECT_TABLE) AS TABLES_WITH_TRIGGERS,
            COUNT(*) AS TRIGGER_COUNT
        FROM information_schema.TRIGGERS
        GROUP BY TRIGGER_SCHEMA, EVENT_MANIPULATION
        ORDER BY TRIGGER_SCHEMA, EVENT_MANIPULATION
;

CREATE OR REPLACE VIEW TRIGGERS_BY_DATABASE_AND_EVENT_AND_TIMING AS
    SELECT
            TRIGGER_SCHEMA AS `DATABASE`,
            EVENT_MANIPULATION,
            ACTION_TIMING,
            COUNT(EVENT_OBJECT_TABLE) AS TABLES_WITH_TRIGGERS,
            COUNT(*) AS TRIGGER_COUNT
        FROM information_schema.TRIGGERS
        GROUP BY TRIGGER_SCHEMA, EVENT_MANIPULATION, ACTION_TIMING
        ORDER BY TRIGGER_SCHEMA, EVENT_MANIPULATION, ACTION_TIMING
;


/*
    STORED PROGRAMS
    ===============

    Metainformation about triggers, routines and events as a whole.
    Specific information about triggers, for example, are in another section.
*/

CREATE OR REPLACE VIEW PROGRAMS_BY_TYPE AS
    (
        SELECT
                ROUTINE_TYPE AS PROGRAM_TYPE,
                COUNT(*) AS PROGRAM_COUNT
            FROM information_schema.ROUTINES
            GROUP BY ROUTINE_TYPE
    ) UNION ALL (
        SELECT
                'EVENT' AS PROGRAM_TYPE,
                COUNT(*) AS PROGRAM_COUNT
            FROM information_schema.EVENTS
            -- for consistency with other views,
            -- don't show a line if count = 0
            HAVING COUNT(*) > 0
    ) UNION ALL (
        SELECT
                'TRIGGER' AS PROGRAM_TYPE,
                COUNT(*) AS PROGRAM_COUNT
            FROM information_schema.TRIGGERS
    ) ORDER BY PROGRAM_TYPE
;

CREATE OR REPLACE VIEW PROGRAMS_BY_DATABASE_AND_TYPE AS
    (
        SELECT
                ROUTINE_SCHEMA AS `DATABASE`,
                ROUTINE_TYPE AS PROGRAM_TYPE,
                COUNT(*) AS PROGRAM_COUNT
            FROM information_schema.ROUTINES
            GROUP BY ROUTINE_SCHEMA, ROUTINE_TYPE
    ) UNION ALL (
        SELECT
                EVENT_SCHEMA AS `DATABASE`,
                'EVENT' AS PROGRAM_TYPE,
                COUNT(*) AS PROGRAM_COUNT
            FROM information_schema.EVENTS
            GROUP BY EVENT_SCHEMA
    ) UNION ALL (
        SELECT
                TRIGGER_SCHEMA AS `DATABASE`,
                'TRIGGER' AS PROGRAM_TYPE,
                COUNT(*) AS PROGRAM_COUNT
            FROM information_schema.TRIGGERS
            GROUP BY TRIGGER_SCHEMA
    ) ORDER BY `DATABASE`, PROGRAM_TYPE
;


# release MDL, if any
COMMIT;
