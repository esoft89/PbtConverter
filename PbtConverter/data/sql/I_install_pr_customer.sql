DROP PROCEDURE IF EXISTS `pr_customer` $$
CREATE PROCEDURE `pr_customer`()
    MODIFIES SQL DATA
    SQL SECURITY INVOKER
BEGIN
  DECLARE var_db_name varchar(50); 
  DECLARE var_cookies_key varchar(128); 
  DECLARE var_nb_customer int; 
  DECLARE var_id_lang int; 
  DECLARE var_id_shop int; 

 
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

  SET var_cookies_key = (
    SELECT LEFT(`value`,128)
    FROM `tmp_param`
    WHERE `tmp_param`.`name` = 'cookies_key'
  );

  INSERT INTO `tmp_customer`(
    `id_customer`,
    `id_gender` ,
    `id_lang` ,
    `email` ,
    `passwd`,
    `active`,
    `id_default_group`,
    `secure_key`,
    `date_add`,
    `date_upd`)
  SELECT DISTINCT  
    0,
    CASE `COL 10` WHEN "Mlle" THEN 2 WHEN "Mme" THEN 2 WHEN "M." THEN 1 ELSE 0 END, 
    var_id_lang,
    `COL 28`, 
    md5(concat(var_cookies_key, `COL 63`)), 
    1, 
    3,
    md5(concat(var_cookies_key, `COL 63`)),
    STR_TO_DATE(`COL 24`,'%d/%m/%Y'),
    STR_TO_DATE(`COL 24`,'%d/%m/%Y') 
  FROM 
    `tmp_cmd_gen`; 
    
  UPDATE  `tmp_customer`, `tmp_cmd_gen`
  SET 
    `tmp_customer`.`company` = `tmp_cmd_gen`.`COL 88`,
    `tmp_customer`.`siret` = `tmp_cmd_gen`.`COL 87`,
    `tmp_customer`.`firstname` = `tmp_cmd_gen`.`COL 83`,
    `tmp_customer`.`lastname` = `tmp_cmd_gen`.`COL 64`,
    `tmp_customer`.`newsletter` = CASE `tmp_cmd_gen`.`COL 3` WHEN "on" THEN 1 ELSE 0 END ,
    `tmp_customer`.`ip_registration_newsletter` = `tmp_cmd_gen`.`COL 8`  ,
    `tmp_customer`.`optin` = CASE `tmp_cmd_gen`.`COL 2` WHEN "on" THEN 1 ELSE 0 END 
  WHERE 
      `tmp_customer`.`email` = `tmp_cmd_gen`.`COL 28`   ;
   
  UPDATE  `tmp_customer`, `ps_customer`
  SET `tmp_customer`.`id_customer` = `ps_customer`.`id_customer`
  WHERE 
      `tmp_customer`.`email` = `ps_customer`.`email`   ;
  
  INSERT INTO `tmp_customer_ins` (
    `id_auto_customer`,
    `id_customer`) 
  select 
   `tmp_customer`.`id_auto`, 
   `tmp_customer`.`id_customer`
  from 
    `tmp_customer` 
  where 
     `tmp_customer`.`id_customer` = 0  ;
  
  SET var_db_name = DATABASE(); 
  SET var_nb_customer = (
    SELECT IFNULL(MAX(`id_customer`),0) FROM `ps_customer`
  );
  
  UPDATE  `tmp_customer_ins`
  SET `tmp_customer_ins`.`id_customer` = var_nb_customer + `tmp_customer_ins`.`id_auto_ins` ;
  
  UPDATE  `tmp_customer` , `tmp_customer_ins`
  SET `tmp_customer`.`id_customer` = `tmp_customer_ins`.`id_customer` 
  WHERE  `tmp_customer`.`id_auto` = `tmp_customer_ins`.`id_auto_customer` 
  AND `tmp_customer`.`id_customer` = '0';
  
  INSERT INTO ps_customer (
    `id_customer`,
    `id_gender` ,
    `id_lang` ,
    `company` ,
    `siret` ,
    `firstname` ,
    `lastname` ,
    `email` ,
    `passwd`,
    `newsletter`,
    `ip_registration_newsletter`,
    `optin`,
    `active`,
    `id_default_group`,
    `secure_key`,  
    `date_add`,
    `date_upd`)
  SELECT 
    `tmp_customer_ins`.`id_customer`,
    `tmp_customer`.`id_gender` ,
    `tmp_customer`.`id_lang` ,
    `tmp_customer`.`company` ,
    `tmp_customer`.`siret` ,
    `tmp_customer`.`firstname` ,
    `tmp_customer`.`lastname` ,
    `tmp_customer`.`email` ,
    `tmp_customer`.`passwd`,
    `tmp_customer`.`newsletter`,
    `tmp_customer`.`ip_registration_newsletter`,
    `tmp_customer`.`optin`,
    `tmp_customer`.`active`,
    `tmp_customer`.`id_default_group`,
    `tmp_customer`.`secure_key`,
    `tmp_customer`.`date_add`,
    `tmp_customer`.`date_upd`
  FROM 
    `tmp_customer_ins`, `tmp_customer`
  WHERE 
     `tmp_customer_ins`.`id_auto_customer` = `tmp_customer`.`id_auto` ;  
  
  UPDATE  
    `ps_customer`, `tmp_customer`
  SET 
    `ps_customer`.`id_gender`                   = `tmp_customer`.`id_gender` ,                 
    `ps_customer`.`id_lang`                     = `tmp_customer`.`id_lang`,                     
    `ps_customer`.`company`                     = `tmp_customer`.`company`,                     
    `ps_customer`.`siret`                       = `tmp_customer`.`siret` ,                     
    `ps_customer`.`firstname`                   = `tmp_customer`.`firstname` ,                 
    `ps_customer`.`lastname`                    = `tmp_customer`.`lastname` ,                  
    `ps_customer`.`newsletter`                  = `tmp_customer`.`newsletter`,                 
    `ps_customer`.`ip_registration_newsletter`  = `tmp_customer`.`ip_registration_newsletter`, 
    `ps_customer`.`optin`                       = `tmp_customer`.`optin`, 
    `ps_customer`.`active`                      = `tmp_customer`.`active`,
    `ps_customer`.`id_default_group`            = `tmp_customer`.`id_default_group`,
    `ps_customer`.`date_add`                    = `tmp_customer`.`date_add`,                   
    `ps_customer`.`date_upd`                    = `tmp_customer`.`date_upd`                   
  WHERE 
      `ps_customer`.`id_customer` = `tmp_customer`.`id_customer`   ;

END $$