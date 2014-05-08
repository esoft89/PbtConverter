DROP PROCEDURE IF EXISTS `pr_order_invoice` $$
CREATE PROCEDURE `pr_order_invoice`()
    MODIFIES SQL DATA
    SQL SECURITY INVOKER
BEGIN
  DECLARE var_db_name varchar(50); 
  DECLARE var_nb_order_invoice int;
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
  
  INSERT INTO `tmp_order_invoice` (
    `id_order_invoice`, 
    `id_order`, 
    `number`, 
    `delivery_number`, 
    `delivery_date`, 
    `total_discount_tax_excl`, 
    `total_discount_tax_incl`, 
    `total_paid_tax_excl`, 
    `total_paid_tax_incl`, 
    `total_products`, 
    `total_products_wt`, 
    `total_shipping_tax_excl`, 
    `total_shipping_tax_incl`, 
    `shipping_tax_computation_method`, 
    `total_wrapping_tax_excl`, 
    `total_wrapping_tax_incl`, 
    `note`, 
    `date_add`,
    `carrier_tax_rate`) 
  SELECT 
    '0', 
    `id_order`, 
    '0', 
    `delivery_number`, 
    `delivery_date`, 
    '0', 
    '0', 
    `total_paid_tax_excl`, 
    `total_paid_tax_incl`, 
    `total_products`, 
    `total_products_wt`, 
    `total_shipping_tax_excl`, 
    `total_shipping_tax_incl`, 
    '0', 
    `total_wrapping_tax_excl`, 
    `total_wrapping_tax_incl`,
    '',
    `date_add`,
    `carrier_tax_rate`
  from 
     `tmp_orders`  ;
      
  SET var_db_name = DATABASE(); 
  SET var_nb_order_invoice = (
    SELECT IFNULL(MAX(`id_order_invoice`),0) FROM `ps_order_invoice`
  );
  
  UPDATE `tmp_order_invoice`  
  SET 
    `tmp_order_invoice`.`id_order_invoice` = var_nb_order_invoice +  `tmp_order_invoice`.`id_auto_order_invoice`,
    `tmp_order_invoice`.`number` = var_nb_order_invoice +  `tmp_order_invoice`.`id_auto_order_invoice` ; 
    
INSERT `tmp_order_invoice_tax` (
    `id_order_invoice`,
    `type` ,
    `id_tax` ,
    `amount`,
    `tax_rate` ) 
  SELECT 
    `id_order_invoice`,
    'shipping' ,
    '0',
    `total_shipping_tax_incl` - `total_shipping_tax_excl`,
    `carrier_tax_rate`
  FROM 
     `tmp_order_invoice`
  WHERE 
     `carrier_tax_rate` > '0.000' ;   
  
  UPDATE  `tmp_order_invoice_tax`, `ps_tax`
  SET  `tmp_order_invoice_tax`.`id_tax`= `ps_tax`.`id_tax` 
  WHERE `tmp_order_invoice_tax`.`tax_rate` =  `ps_tax`.`rate`  AND 
        `ps_tax`.`active` = '1' ;
         
  INSERT  `ps_tax` ( 
    `rate`,
    `active`,
    `deleted`)
  SELECT DISTINCT 
     `tax_rate`,
     '1',
     '0'
  FROM 
     `tmp_order_invoice_tax`
  WHERE 
     `id_tax` = '0' ;
     
  INSERT  `ps_tax_lang` ( 
    `id_tax`,
    `id_lang`,
    `name`) 
  SELECT DISTINCT
     `ps_tax`.`id_tax`,
     var_id_lang, 
     CONCAT('TVA FR ',`ps_tax`.`rate`, '%')
  FROM 
     `ps_tax`,`tmp_order_invoice_tax` 
  WHERE 
     `tmp_order_invoice_tax`.`id_tax` = '0' AND
     `tmp_order_invoice_tax`.`tax_rate` =  `ps_tax`.`rate`  AND 
     `ps_tax`.`active` = '1'  ;
      
  UPDATE  `tmp_order_invoice_tax`, `ps_tax`
  SET  
    `tmp_order_invoice_tax`.`id_tax`= `ps_tax`.`id_tax` 
  WHERE 
    `tmp_order_invoice_tax`.`id_tax` = '0' AND
    `tmp_order_invoice_tax`.`tax_rate` =  `ps_tax`.`rate`  AND 
    `ps_tax`.`active` = '1' ;     
  
  INSERT INTO `ps_order_invoice` (
    `id_order_invoice`, 
    `id_order`, 
    `number`, 
    `delivery_number`, 
    `delivery_date`, 
    `total_discount_tax_excl`, 
    `total_discount_tax_incl`, 
    `total_paid_tax_excl`, 
    `total_paid_tax_incl`, 
    `total_products`, 
    `total_products_wt`, 
    `total_shipping_tax_excl`, 
    `total_shipping_tax_incl`, 
    `shipping_tax_computation_method`, 
    `total_wrapping_tax_excl`, 
    `total_wrapping_tax_incl`, 
    `note`, 
    `date_add`) 
   SELECT 
    `id_order_invoice`, 
    `id_order`, 
    `number`, 
    `delivery_number`, 
    `delivery_date`, 
    `total_discount_tax_excl`, 
    `total_discount_tax_incl`, 
    `total_paid_tax_excl`, 
    `total_paid_tax_incl`, 
    `total_products`, 
    `total_products_wt`, 
    `total_shipping_tax_excl`, 
    `total_shipping_tax_incl`, 
    `shipping_tax_computation_method`, 
    `total_wrapping_tax_excl`, 
    `total_wrapping_tax_incl`, 
    `note`, 
    `date_add` 
  FROM 
    `tmp_order_invoice` ;
      
   INSERT INTO `ps_order_invoice_tax` (
    `id_order_invoice`, 
    `type`, 
    `id_tax`, 
    `amount`) 
  SELECT 
    `id_order_invoice`, 
    `type`, 
    `id_tax`, 
    `amount`
  FROM 
     `tmp_order_invoice_tax` ;

END $$