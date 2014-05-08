DROP PROCEDURE IF EXISTS `pr_stop_import_log` $$
CREATE PROCEDURE `pr_stop_import_log`()
    MODIFIES SQL DATA
    SQL SECURITY INVOKER
BEGIN
  DECLARE var_id_import_log int; 
  DECLARE var_finished int DEFAULT 0;
  DECLARE var_nb_loop int DEFAULT 0;
  DECLARE var_table_name varchar(50);
  DECLARE var_field_name varchar(50);
  DECLARE var_sql text;
  DEClARE import_log_cursor CURSOR FOR  
    SELECT `tmp_import_log_detail`.`id_import_log`, `tmp_import_log_detail`.`table_name`,`tmp_import_log_detail`.`field_name` 
    FROM `tmp_import_log_detail`,`tmp_import_log`  
    WHERE `tmp_import_log`.`is_last` = 1  AND 
          `tmp_import_log_detail`.`id_import_log` = `tmp_import_log`.`id_import_log`;
  DECLARE CONTINUE HANDLER FOR NOT FOUND SET var_finished = 1;
  
    OPEN import_log_cursor;
 
    get_import_log: LOOP
      SET var_nb_loop = var_nb_loop + 1; 
      IF var_nb_loop > 100 THEN 
          LEAVE get_import_log;
      END IF;
      
      FETCH import_log_cursor INTO var_id_import_log, var_table_name, var_field_name;
      IF var_finished = 1 THEN 
          LEAVE get_import_log;
      END IF;
      
      
      SET var_sql = CONCAT('UPDATE `tmp_import_log_detail`,`tmp_import_log`'); 
      SET var_sql = CONCAT(var_sql,' SET value_after = ( SELECT MAX(`',var_field_name,'`) FROM `',var_table_name,'`),');
      SET var_sql = CONCAT(var_sql,' rows_after = ( SELECT COUNT(`',var_field_name,'`) FROM `',var_table_name,'`)');
      SET var_sql = CONCAT(var_sql,' WHERE `tmp_import_log`.`is_last` = 1');
      SET var_sql = CONCAT(var_sql,' AND `tmp_import_log_detail`.`id_import_log` = `tmp_import_log`.`id_import_log`');
      SET var_sql = CONCAT(var_sql,' AND `tmp_import_log_detail`.`table_name` = ','"',var_table_name,'"'); 
      SET var_sql = CONCAT(var_sql,' AND `tmp_import_log_detail`.`field_name` = ','"',var_field_name,'"');
      
      SET @var_sql2 = var_sql;
      PREPARE stmt FROM @var_sql2;
      EXECUTE stmt;
      DEALLOCATE PREPARE stmt;  
    END LOOP get_import_log;
    CLOSE import_log_cursor;
        
END $$
