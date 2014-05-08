DROP PROCEDURE IF EXISTS `pr_address` $$
CREATE PROCEDURE `pr_address`()
    MODIFIES SQL DATA
    SQL SECURITY INVOKER
BEGIN
  DECLARE var_db_name varchar(50); 
  DECLARE var_nb_address int; 
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

  INSERT INTO `tmp_address`(
    `email`,
    `alias`,
    `company`,
    `lastname`,
    `firstname`,
    `address1`,
    `address2`,
    `postcode`,
    `city`,
    `phone`,
    `phone_mobile`,
    `date_add`,
    `date_upd`,
    `iso_pays` ) 
  SELECT DISTINCT  
    `COL 28`, 
    'Adresse de facturation',
    `COL 88`, 
    `COL 64`,
    `COL 83`,
    `COL 4`,  
    `COL 5`,  
    `COL 18`,  
    `COL 100`,  
    CONCAT('0',`COL 70`),  
    CONCAT('0',`COL 74`),  
    STR_TO_DATE(`COL 24`,'%d/%m/%Y'),
    STR_TO_DATE(`COL 24`,'%d/%m/%Y'), 
    `COL 14`  
  FROM 
    `tmp_cmd_gen`; 
  
  INSERT INTO `tmp_address`(
    `email`,
    `alias`,
    `company`,
    `lastname`,
    `firstname`,
    `address1`,
    `address2`,
    `postcode`,
    `city`,
    `phone`,
    `phone_mobile`,
    `date_add`,
    `date_upd`,
    `iso_pays` ) 
  SELECT DISTINCT  
    `COL 28`, 
    'Adresse de livraison',
    `COL 88`, 
    `COL 68`,
    `COL 84`,  
    `COL 9`,  
    `COL 6`,  
    `COL 19`,  
    `COL 101`,  
    CONCAT('0',`COL 71`),  
    CONCAT('0',`COL 75`),  
    STR_TO_DATE(`COL 24`,'%d/%m/%Y'),
    STR_TO_DATE(`COL 24`,'%d/%m/%Y'), 
    `COL 15`  
  FROM 
    `tmp_cmd_gen`; 
    
  UPDATE  `tmp_address`, `ps_address`, `ps_customer`
  SET `tmp_address`.`id_address` = `ps_address`.`id_address`
  WHERE 
      `tmp_address`.`email` = `ps_customer`.`email` AND
      `ps_address`.`id_customer` = `ps_customer`.`id_customer` AND 
      `tmp_address`.`alias` = `ps_address`.`alias`;
      
  DELETE FROM `tmp_address` WHERE `id_address` > '0';
      
  INSERT INTO `tmp_address_ins` (
    `id_auto_address`) 
  select 
   `tmp_address`.`id_auto_address`
  from 
    `tmp_address`; 

  UPDATE  `tmp_address`, `tmp_address_ins`
  SET `tmp_address`.`id_auto_address_ins` = `tmp_address_ins`.`id_auto_address_ins`
  WHERE 
      `tmp_address`.`id_auto_address` = `tmp_address_ins`.`id_auto_address`;
    
  UPDATE  `tmp_address`, `ps_country`
  SET 
    `tmp_address`.`id_country` = `ps_country`.`id_country` 
  WHERE 
    `tmp_address`.`iso_pays` = `ps_country`.`iso_code` ; 
  
  UPDATE  `tmp_address`, `ps_country`, `ps_state`
  SET 
    `tmp_address`.`id_state` = `ps_state`.`id_state` 
  WHERE 
    `tmp_address`.`id_country` = `ps_country`.`id_country` AND 
    `ps_country`.`id_country` = `ps_state`.`id_country` AND 
    `ps_country`.`id_zone` = `ps_state`.`id_zone`; 
  
  UPDATE  `tmp_address`, `ps_customer`
  SET `tmp_address`.`id_customer` = `ps_customer`.`id_customer`
  WHERE 
      `tmp_address`.`email` = `ps_customer`.`email`   ;
  
  UPDATE `ps_address` ,`tmp_address`  
  SET 
    `ps_address`.`active` = '0' ,
    `ps_address`.`deleted` = '1'
  WHERE 
    `ps_address`.`id_customer` = `tmp_address`.`id_customer` AND 
    `ps_address`.`alias` in ('Adresse de facturation', 'Adresse de livraison' ) ; 
  
  SET var_db_name = DATABASE(); 
  SET var_nb_address = (
    SELECT IFNULL(MAX(`id_address`),0) FROM `ps_address`
  );
  
  
  UPDATE `tmp_address`  
  SET 
    `tmp_address`.`id_address` = var_nb_address +  `tmp_address`.`id_auto_address_ins`; 
  
  INSERT INTO `ps_address` (
    `id_address`, 
    `id_country`, 
    `id_state`, 
    `id_customer`, 
    `id_manufacturer`, 
    `id_supplier`, 
    `id_warehouse`, 
    `alias`, 
    `company`, 
    `lastname`, 
    `firstname`, 
    `address1`, 
    `address2`, 
    `postcode`, 
    `city`, 
    `other`, 
    `phone`, 
    `phone_mobile`, 
    `vat_number`, 
    `dni`, 
    `date_add`, 
    `date_upd`, 
    `active`, 
    `deleted`)
   SELECT 
    `id_address`, 
    `id_country`, 
    `id_state`, 
    `id_customer`, 
    `id_manufacturer`, 
    `id_supplier`, 
    `id_warehouse`, 
    `alias`, 
    `company`, 
    `lastname`, 
    `firstname`, 
    `address1`, 
    `address2`, 
    LEFT(TRIM(`postcode`),12), 
    `city`, 
    `other`, 
    `phone`, 
    `phone_mobile`, 
    `vat_number`, 
    `dni`, 
    `date_add`, 
    `date_upd`, 
    `active`, 
    `deleted`
  FROM 
    `tmp_address`; 
    
END $$