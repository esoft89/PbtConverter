DROP PROCEDURE IF EXISTS `pr_start_import_log` $$
CREATE PROCEDURE `pr_start_import_log`()
    MODIFIES SQL DATA
    SQL SECURITY INVOKER
BEGIN
  DECLARE var_id_import_log int; 
  DECLARE var_finished int DEFAULT 0;
  DECLARE var_nb_loop int DEFAULT 0;
  DECLARE var_table_name varchar(50);
  DECLARE var_field_name varchar(50);
  DECLARE var_sql text;
  DEClARE import_log_cursor CURSOR FOR  SELECT `table_name`,`field_name` FROM `tmp_import_table_list`;
  DECLARE CONTINUE HANDLER FOR NOT FOUND SET var_finished = 1;
  
  UPDATE `tmp_import_log` set `is_last` = 0 WHERE `is_last` = 1;
  INSERT INTO `tmp_import_log` (`import_date`,`user`,`database`, `is_last`) VALUES (NOW(),CURRENT_USER(), DATABASE(),1);
  
  SET  var_id_import_log = (
      SELECT MAX(`id_import_log`)
      FROM `tmp_import_log`
  );
  
  
    OPEN import_log_cursor;
 
    get_import_log: LOOP
      SET var_nb_loop = var_nb_loop + 1; 
      IF var_nb_loop > 100 THEN 
          LEAVE get_import_log;
      END IF;
      
      FETCH import_log_cursor INTO var_table_name, var_field_name;
      IF var_finished = 1 THEN 
          LEAVE get_import_log;
      END IF;
      
      SET var_sql = 'INSERT INTO `tmp_import_log_detail` (`id_import_log`,`table_name`,`field_name`, `value_before`, `value_after`,`rows_before`, `rows_after` )';
      SET var_sql = CONCAT(var_sql,' SELECT ' ,var_id_import_log,',"',var_table_name,'",','"',var_field_name,'",','MAX(`',var_field_name,'`),','0, COUNT(`',var_field_name,'`),0 ');
      SET var_sql = CONCAT(var_sql,' FROM `',var_table_name,'`');
      SET @var_sql2 = var_sql;
      PREPARE stmt FROM @var_sql2;
      EXECUTE stmt;
      DEALLOCATE PREPARE stmt;  
    END LOOP get_import_log;
    CLOSE import_log_cursor;
        
END $$ 
