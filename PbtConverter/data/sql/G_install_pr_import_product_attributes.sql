DROP PROCEDURE IF EXISTS `pr_import_product_attributes` $$
CREATE PROCEDURE `pr_import_product_attributes`()
    MODIFIES SQL DATA
    SQL SECURITY INVOKER
BEGIN
  DECLARE var_nb_att_list int;
  DECLARE var_nb_bcl1 int;
  DECLARE var_nb_bcl2 int;
  DECLARE var_db_name varchar(50); 
  DECLARE var_nb_attribute int;
  DECLARE var_id_lang int;
  DECLARE var_id_shop int;
  DECLARE var_id_max_position int;
  DECLARE var_indx int;           
  DECLARE var_slice varchar(255);
  DECLARE var_ref_commande varchar(12);
  DECLARE var_attribute_list varchar (255); 
  DECLARE var_id_attribute_group int  ;
  DECLARE var_group_name varchar(128) ;
  DECLARE var_finished int DEFAULT 0;
  DECLARE var_exist_attribute_name int DEFAULT 0;
  DEClARE attribute_list_cursor CURSOR FOR  SELECT `ref_commande`, `id_attribute_group`,`group_name`,`attribute_list` FROM `tmp_attribute_list`;
  DECLARE CONTINUE HANDLER FOR NOT FOUND SET var_finished = 1;
 
  
  SET var_nb_bcl1 = 1;
  SET  var_id_shop = (
    SELECT cast(`value` AS UNSIGNED INT)
    FROM `tmp_param`
    WHERE `tmp_param`.`name` = 'id_shop'
  ); 
  
  SET var_id_lang = (
    SELECT cast(`value` AS UNSIGNED INT)
    FROM `tmp_param`
    WHERE `tmp_param`.`name` = 'id_lang'
  );
   
  SET var_db_name = DATABASE(); 
  SET var_nb_attribute = (
    SELECT IFNULL(MAX(`id_attribute`),0) FROM `ps_attribute`
  );
  
  SET  var_id_max_position = (
    SELECT MAX(position)
    FROM `ps_attribute_group`
  );

  INSERT INTO  `tmp_attribute_list` (
    `ref_commande`,
    `id_attribute_group` ,
    `group_name`  ,
    `attribute_list` ) 
  SELECT DISTINCT  
     `tmp_cmd_det`.`COL 1`,
     `ps_attribute_group`.`id_attribute_group`,
     `ps_attribute_group_lang`.`name`,
     TRIM(`tmp_cmd_det`.`COL 15`)
   FROM 
     `tmp_cmd_det`, `ps_attribute_group`, `ps_attribute_group_lang`
   WHERE 
      `tmp_cmd_det`.`COL 53` <> '' AND
      `tmp_cmd_det`.`COL 15` <> '' AND 
      LOWER(LEFT(`tmp_cmd_det`.`COL 53`,2)) = LOWER(LEFT(`ps_attribute_group_lang`.`name`,2)) AND 
      `ps_attribute_group_lang`.`id_lang` =  var_id_lang AND
      `ps_attribute_group`.`id_attribute_group` =  `ps_attribute_group_lang`.`id_attribute_group` ;
      
  SET  var_nb_att_list = (
    SELECT COUNT(*)
    FROM `tmp_attribute_list`
  );       
 
    OPEN attribute_list_cursor;
 
    get_attribute_list: LOOP
      FETCH attribute_list_cursor INTO var_ref_commande, var_id_attribute_group,var_group_name,var_attribute_list  ;
      IF var_nb_bcl1 > var_nb_bcl1 + 2 THEN 
          LEAVE get_attribute_list;
      END IF;
     SET var_nb_bcl1 = var_nb_bcl1 + 1;
      
      IF var_finished = 1 THEN 
          LEAVE get_attribute_list;
      END IF;
     SET var_indx = 1;
     SET var_nb_bcl2 = 1;
     
     MyLoop: WHILE var_indx != 0 DO
       SET var_indx = LOCATE(',',var_attribute_list);
       SET var_nb_bcl2 = var_nb_bcl2 + 1;
       
       IF (var_nb_bcl2 > 20 ) THEN 
        LEAVE MyLoop;
       END IF;
       
       
       IF var_indx !=0 THEN
        SET var_slice = LEFT(var_attribute_list,var_indx - 1);
       ELSE
        SET var_slice = var_attribute_list;
       END IF;
       
       IF NOT EXISTS ( 
          SELECT `ps_attribute`.`id_attribute`    
          FROM `ps_attribute`, `ps_attribute_lang`
          WHERE
            `ps_attribute`.`id_attribute_group` =  var_id_attribute_group AND 
            `ps_attribute`.`id_attribute` =  `ps_attribute_lang`.`id_attribute` AND 
            `ps_attribute_lang`.`id_lang` = var_id_lang AND 
            `ps_attribute_lang`.`name` = TRIM(var_slice))    THEN
         INSERT INTO `tmp_attribute_name`(
          `ref_commande`, 
          `id_attribute_group`, 
          `group_name`,
          `attribute_name`,
          `existing_attribute`) 
         VALUES (
           var_ref_commande,
           var_id_attribute_group,
           var_group_name,
           TRIM(var_slice),
           '0');
       ELSE 
         INSERT INTO `tmp_attribute_name`(
          `ref_commande`, 
          `id_attribute_group`, 
          `group_name`,
          `attribute_name`,
          `existing_attribute`) 
         VALUES (
           var_ref_commande,
           var_id_attribute_group,
           var_group_name,
           TRIM(var_slice),
           '1');
       END IF;
         
       SET var_attribute_list = RIGHT(var_attribute_list,CHAR_LENGTH(var_attribute_list) - var_indx);
       IF CHAR_LENGTH(var_attribute_list) = 0 THEN
        LEAVE MyLoop;
       END IF;
     END WHILE;
    END LOOP get_attribute_list;
    CLOSE attribute_list_cursor;

    INSERT INTO `tmp_attribute` (
      `id_attribute` ,
      `id_attribute_group`,
      `id_shop`,
      `id_lang`,
      `name` ) 
    SELECT DISTINCT 
      '0', 
      `id_attribute_group`,
      var_id_shop, 
      var_id_lang,
      `attribute_name` 
    FROM 
      `tmp_attribute_name`
    WHERE 
       `existing_attribute` = '0'
    ORDER BY 
       `id_attribute_group`,`attribute_name` ;
    
    UPDATE `tmp_attribute`
    SET 
       `tmp_attribute`.`id_attribute` = var_nb_attribute +  `tmp_attribute`.`id_auto_attribute`;
      
    UPDATE `tmp_attribute` x 
    JOIN (
    SELECT o.`id_attribute_group`, max( o.`position` ) max_auto_pos 
    FROM `ps_attribute` o
    GROUP BY o.`id_attribute_group`
    )y
    ON x.id_attribute_group = y.id_attribute_group
    SET x.min_auto_attribute_in_group = max_auto_pos;
      
    UPDATE `tmp_attribute`
    SET 
       `tmp_attribute`.`position` = `tmp_attribute`.`id_auto_attribute` +  `tmp_attribute`.`min_auto_attribute_in_group`;
     
    INSERT INTO `ps_attribute` (`id_attribute`, `id_attribute_group`, `color`, `position`) 
    SELECT `id_attribute`, `id_attribute_group`, `color`, `position` 
    FROM `tmp_attribute` ;
    
    INSERT INTO `ps_attribute_lang` (`id_attribute`, `id_lang`, `name`) 
    SELECT  `id_attribute`, `id_lang`, `name` 
    FROM `tmp_attribute` ;
  
    INSERT INTO `ps_attribute_shop` ( `id_attribute`,`id_shop`) 
    SELECT `id_attribute`, `id_shop`
    FROM   `tmp_attribute`;
     
END $$