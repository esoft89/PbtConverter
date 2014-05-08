DROP PROCEDURE IF EXISTS `pr_order_carrier` $$
CREATE PROCEDURE `pr_order_carrier`()
    MODIFIES SQL DATA
    SQL SECURITY INVOKER
BEGIN
  DECLARE var_db_name varchar(50); 
  DECLARE var_nb_order_carrier int; 
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

  INSERT INTO `tmp_order_carrier` (
    `ref_commande`,
    `id_order_carrier`,
    `id_order` )
  SELECT
    `ref_commande`,
    '0', 
    `id_order` 
  FROM 
    `tmp_orders` ;
    
  SET var_db_name = DATABASE(); 
  SET var_nb_order_carrier = (
    SELECT IFNULL(MAX(`id_order_carrier`),0) FROM `ps_order_carrier`
  );
  
  UPDATE `tmp_order_carrier`  
  SET 
    `tmp_order_carrier`.`id_order_carrier` = var_nb_order_carrier +  `tmp_order_carrier`.`id_auto_order_carrier`; 

  
  UPDATE `tmp_order_carrier` , `tmp_cmd_gen`, `ps_carrier`
  SET
    `tmp_order_carrier`.`id_carrier` =  `ps_carrier`.`id_carrier`
  WHERE 
    `tmp_order_carrier`.`ref_commande` =  `tmp_cmd_gen`.`COL 1` AND 
     LOWER(`tmp_cmd_gen`.`COL 46`) =  LOWER(`ps_carrier`.`name`) ; 
    
  UPDATE `tmp_order_carrier` , `tmp_order_invoice`
  SET
    `tmp_order_carrier`.`id_order_invoice` =  `tmp_order_invoice`.`id_order_invoice`
  WHERE 
    `tmp_order_carrier`.`id_order` =  `tmp_order_invoice`.`id_order`; 
     
  UPDATE `tmp_order_carrier` , `tmp_cmd_gen`
  SET
    `tmp_order_carrier`.`weight` =  CONVERT(REPLACE(REPLACE(`tmp_cmd_gen`.`COL 81`, '.', ''), ',', '.'), DECIMAL(20,6)), 
    `tmp_order_carrier`.`shipping_cost_tax_excl` =  CONVERT(REPLACE(REPLACE(`tmp_cmd_gen`.`COL 58`, '.', ''), ',', '.'), DECIMAL(20,6)), 
    `tmp_order_carrier`.`shipping_cost_tax_incl` =  CONVERT(REPLACE(REPLACE(`tmp_cmd_gen`.`COL 57`, '.', ''), ',', '.'), DECIMAL(20,6)),
    `tmp_order_carrier`.`tracking_number` =  `tmp_cmd_gen`.`COL 49`, 
    `tmp_order_carrier`.`date_add` =  STR_TO_DATE(`tmp_cmd_gen`.`COL 42`,'%d/%m/%Y')
  WHERE 
    `tmp_order_carrier`.`ref_commande` =  `tmp_cmd_gen`.`COL 1` ; 
    
  INSERT INTO `ps_order_carrier` (
    `id_order_carrier`, 
    `id_order`, 
    `id_carrier`, 
    `id_order_invoice`, 
    `weight`, 
    `shipping_cost_tax_excl`, 
    `shipping_cost_tax_incl`, 
    `tracking_number`, 
    `date_add`) 
  SELECT 
    `id_order_carrier`, 
    `id_order`, 
    `id_carrier`, 
    `id_order_invoice`, 
    `weight`, 
    `shipping_cost_tax_excl`, 
    `shipping_cost_tax_incl`, 
    `tracking_number`, 
    `date_add`
  FROM 
    `tmp_order_carrier` ; 

  
END $$