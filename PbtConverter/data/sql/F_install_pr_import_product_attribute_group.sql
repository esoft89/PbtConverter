DROP PROCEDURE IF EXISTS `pr_import_product_attribute_group` $$
CREATE PROCEDURE `pr_import_product_attribute_group`()
    MODIFIES SQL DATA
    SQL SECURITY INVOKER
BEGIN
  DECLARE var_db_name varchar(50); 
  DECLARE var_nb_attribute_group int;
  DECLARE var_id_lang int;
  DECLARE var_id_shop int;
  DECLARE var_id_max_position int;
  
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
  SET var_nb_attribute_group = (
    SELECT IFNULL(MAX(`id_attribute_group`),0) FROM `ps_attribute_group`
  );
  
  SET  var_id_max_position = (
    SELECT MAX(position)
    FROM `ps_attribute_group`
  );
  
  
  IF NOT EXISTS ( 
    SELECT * from  `ps_attribute_group_lang` 
    WHERE `ps_attribute_group_lang`.`id_lang` = var_id_lang AND 
          `ps_attribute_group_lang`.`name` like 'Taille' )  THEN
    INSERT INTO  `tmp_attribute_group` (
    `id_attribute_group` ,
    `id_lang`  ,
    `id_shop`  ,
    `name` ,
    `public_name` ) 
   VALUES (   
     '0', 
     var_id_lang , 
     var_id_shop ,
     'Taille', 
     'Taille' ) ;              
  END IF;  
  
 IF NOT EXISTS ( 
    SELECT * from  `ps_attribute_group_lang` 
    WHERE `ps_attribute_group_lang`.`id_lang` = var_id_lang AND 
          `ps_attribute_group_lang`.`name` like 'Goût' )  THEN
    INSERT INTO  `tmp_attribute_group` (
    `id_attribute_group` ,
    `id_lang`  ,
    `id_shop`  ,
    `name` ,
    `public_name` ) 
   VALUES (   
     '0', 
     var_id_lang , 
     var_id_shop ,
     'Goût', 
     'Goût' ) ;              
  END IF;   
  
 IF NOT EXISTS ( 
    SELECT * from  `ps_attribute_group_lang` 
    WHERE `ps_attribute_group_lang`.`id_lang` = var_id_lang AND 
          `ps_attribute_group_lang`.`name` like 'Couleur' )  THEN
    INSERT INTO  `tmp_attribute_group` (
    `id_attribute_group` ,
    `id_lang`  ,
    `id_shop`  ,
    `name` ,
    `public_name` ) 
   VALUES (   
     '0', 
     var_id_lang , 
     var_id_shop ,
     'Couleur', 
     'Couleur' ) ;              
  END IF;    
          
  UPDATE `tmp_attribute_group`  
  SET 
    `tmp_attribute_group`.`id_attribute_group` = var_nb_attribute_group +  `tmp_attribute_group`.`id_auto_attribute_group`,
    `tmp_attribute_group`.`position` = var_id_max_position +  `tmp_attribute_group`.`id_auto_attribute_group`;

  INSERT INTO `ps_attribute_group` (
    `id_attribute_group`, 
    `is_color_group`, 
    `group_type`, 
    `position`) 
  SELECT
    `id_attribute_group`, 
    `is_color_group`, 
    `group_type`, 
    `position`
  FROM 
    `tmp_attribute_group`; 
    
  INSERT INTO `ps_attribute_group_lang` (
    `id_attribute_group`, 
    `id_lang`, 
    `name`, 
    `public_name`) 
  SELECT 
    `id_attribute_group`, 
    `id_lang`, 
    `name`, 
    `public_name`
  FROM 
    `tmp_attribute_group`; 

  INSERT INTO `ps_attribute_group_shop` (
    `id_attribute_group`, 
    `id_shop`) 
  SELECT 
    `id_attribute_group`, 
    `id_shop`
  FROM 
    `tmp_attribute_group`; 
     
END $$