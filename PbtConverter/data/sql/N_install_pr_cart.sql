DROP PROCEDURE IF EXISTS `pr_cart` $$
CREATE PROCEDURE `pr_cart`()
    MODIFIES SQL DATA
    SQL SECURITY INVOKER
BEGIN
  DECLARE var_db_name varchar(50); 
  DECLARE var_nb_cart int;
  DECLARE var_id_shop int;
  DECLARE var_id_lang int;
  
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
  
            
  INSERT INTO `tmp_cart` (
    `ref_commande`, 
    `date_add`,
    `date_upd`,
    `delivery_option`) 
  SELECT   
    `COL 1`,
    CASE `COL 25` WHEN "" THEN STR_TO_DATE(`COL 24`,'%d/%m/%Y') ELSE STR_TO_DATE(`COL 25`,'%d/%m/%Y') END, 
    CASE `COL 26` WHEN "" THEN STR_TO_DATE(`COL 24`,'%d/%m/%Y') ELSE STR_TO_DATE(`COL 26`,'%d/%m/%Y') END,
    '' 
  FROM 
    `tmp_cmd_gen`;
    
  UPDATE  `tmp_cart`, `ps_currency`
  SET 
    `tmp_cart`.`id_currency` =  `ps_currency`.`id_currency`  
  WHERE 
    `ps_currency`.`iso_code` = 'EUR'  ; 
    
  UPDATE  `tmp_cart`, `ps_shop_group`
  SET 
    `tmp_cart`.`id_shop_group` =  `ps_shop_group`.`id_shop_group`
  where 
    `ps_shop_group`.`active` = '1';
  
  UPDATE  `tmp_cart`, `ps_shop`
  SET 
    `tmp_cart`.`id_shop` =  `ps_shop`.`id_shop`
  where 
    `tmp_cart`.`id_shop_group` = `ps_shop`.`id_shop_group` AND 
    `ps_shop`.`active` = '1' ;
    
  
  UPDATE  `tmp_cart`, `tmp_cmd_gen`, `ps_carrier`
  SET 
    `tmp_cart`.`id_carrier` =  `ps_carrier`.`id_carrier`
  WHERE
    `tmp_cart`.`ref_commande` = `tmp_cmd_gen`.`COL 1` AND
    `ps_carrier`.`name` =   `tmp_cmd_gen`.`COL 46` and 
    `ps_carrier`.`active` = '1' AND
    `ps_carrier`.`deleted` = '0';  
    
  UPDATE  `tmp_cart`, `ps_lang`
  SET 
    `tmp_cart`.`id_lang` =  `ps_lang`.`id_lang`  
  WHERE 
    `ps_lang`.`iso_code` = 'fr'; 
  
  UPDATE  `tmp_cart`, `ps_carrier`
  SET 
    `tmp_cart`.`id_carrier` =  `ps_carrier`.`id_carrier`
  where 
    `tmp_cart`.`id_carrier` = '0' AND
    `ps_carrier`.`active` = '1' AND
    `ps_carrier`.`deleted` = '0';
  
  UPDATE  `tmp_cart`, `tmp_cmd_gen`,  `ps_customer`
  SET 
    `tmp_cart`.`id_customer` =  `ps_customer`.`id_customer`  
  WHERE
    `tmp_cart`.`ref_commande` = `tmp_cmd_gen`.`COL 1` AND
    `ps_customer`.`email` =  `tmp_cmd_gen`.`COL 28`;
  
  UPDATE  `tmp_cart`, `ps_address`
  SET 
    `tmp_cart`.`id_address_delivery` =  `ps_address`.`id_address`  
  WHERE
    `tmp_cart`.`id_customer` =  `ps_address`.`id_customer` and
    `ps_address`.`alias` = 'Adresse de livraison';
  
  UPDATE  `tmp_cart`, `ps_address`
  SET 
    `tmp_cart`.`id_address_invoice` =  `ps_address`.`id_address`  
  WHERE
    `tmp_cart`.`id_customer` =  `ps_address`.`id_customer` and
    `ps_address`.`alias` = 'Adresse de facturation';
    
  SET var_db_name = DATABASE(); 
  SET var_nb_cart = (
    SELECT IFNULL(MAX(`id_cart`),0) FROM `ps_cart`
  );
  
  UPDATE `tmp_cart`  
  SET 
    `tmp_cart`.`id_cart` = var_nb_cart +  `tmp_cart`.`id_auto_cart` ;
  
  INSERT INTO `ps_cart` (
    `id_cart`, 
    `id_shop_group`, 
    `id_shop`, 
    `id_carrier`, 
    `delivery_option`, 
    `id_lang`, 
    `id_address_delivery`, 
    `id_address_invoice`, 
    `id_currency`, 
    `id_customer`, 
    `id_guest`, 
    `secure_key`, 
    `recyclable`, 
    `gift`, 
    `gift_message`, 
    `mobile_theme`, 
    `allow_seperated_package`, 
    `date_add`, 
    `date_upd` ) 
  SELECT 
    `id_cart`, 
    `id_shop_group`, 
    `id_shop`, 
    `id_carrier`, 
    `delivery_option`, 
    `id_lang`, 
    `id_address_delivery`, 
    `id_address_invoice`, 
    `id_currency`, 
    `id_customer`, 
    `id_guest`, 
    `secure_key`, 
    `recyclable`, 
    `gift`, 
    `gift_message`, 
    `mobile_theme`, 
    `allow_seperated_package`, 
    `date_add`, 
    `date_upd`
  FROM 
    `tmp_cart` ;
    
END $$