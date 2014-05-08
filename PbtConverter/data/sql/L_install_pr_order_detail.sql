DROP PROCEDURE IF EXISTS `pr_order_detail` $$
CREATE PROCEDURE `pr_order_detail`()
    MODIFIES SQL DATA
    SQL SECURITY INVOKER
BEGIN
  DECLARE var_db_name varchar(50); 
  DECLARE var_nb_order_detail int;
  DECLARE var_nb_order_history int; 
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
  
  INSERT INTO `tmp_order_detail` (
    `id_order_detail` ,
    `id_order`,
    `id_order_invoice`,
    `id_shop`,
    `product_id` ,
    `product_name`,
    `product_quantity`,
    `product_quantity_in_stock`,
    `product_price` ,
    `reduction_percent` ,
    `reduction_amount` ,
    `reduction_amount_tax_incl` ,
    `reduction_amount_tax_excl` ,
    `product_quantity_discount`,
    `product_ean13` ,
    `product_upc` ,
    `product_reference` ,
    `product_supplier_reference` ,
    `product_weight`,
    `total_price_tax_incl`,
    `total_price_tax_excl`,
    `total_shipping_price_tax_incl` ,
    `total_shipping_price_tax_excl` ,
    `original_product_price`,
    `product_tax_rate`)
  SELECT    
     '0',  
     `tmp_orders`.`id_order`,
     '0',
     `tmp_orders`.`id_shop`,
     '0',
     '',
     `tmp_cmd_det`.`COL 40`, 
     `tmp_cmd_det`.`COL 40`, 
     '0.0', 
      CASE `tmp_cmd_det`.`COL 37` WHEN "off" THEN '100' ELSE '0.00' END, 
      CASE `tmp_cmd_det`.`COL 37` WHEN "off" THEN CONVERT(REPLACE(REPLACE(`tmp_cmd_det`.`COL 38`, '.', ''), ',', '.'), DECIMAL(20,6)) ELSE '0' END, 
      CASE `tmp_cmd_det`.`COL 37` WHEN "off" THEN CONVERT(REPLACE(REPLACE(`tmp_cmd_det`.`COL 38`, '.', ''), ',', '.'), DECIMAL(20,6)) + CONVERT(REPLACE(REPLACE(`tmp_cmd_det`.`COL 39`, '.', ''), ',', '.'), DECIMAL(20,6)) ELSE '0' END, 
      CASE `tmp_cmd_det`.`COL 37` WHEN "off" THEN CONVERT(REPLACE(REPLACE(`tmp_cmd_det`.`COL 38`, '.', ''), ',', '.'), DECIMAL(20,6)) ELSE '0' END, 
      CASE `tmp_cmd_det`.`COL 37` WHEN "off" THEN `tmp_cmd_det`.`COL 40` ELSE '0.000000' END, 
     '', 
     '', 
     `tmp_cmd_det`.`COL 1`, 
     '', 
      CONVERT(REPLACE(REPLACE(`tmp_cmd_det`.`COL 36`, '.', ''), ',', '.'), DECIMAL(20,6)), 
      CONVERT(REPLACE(REPLACE(`tmp_cmd_det`.`COL 22`, '.', ''), ',', '.'), DECIMAL(20,6)), 
      CONVERT(REPLACE(REPLACE(`tmp_cmd_det`.`COL 22`, '.', ''), ',', '.'), DECIMAL(20,6)) - CONVERT(REPLACE(REPLACE(`tmp_cmd_det`.`COL 23`, '.', ''), ',', '.'), DECIMAL(20,6)),
      '0.00',
      '0.00',
      '0.00', 
      CONVERT(REPLACE(REPLACE(`tmp_cmd_det`.`COL 48`, '.', ''), ',', '.'), DECIMAL(10,3)) 
  FROM 
     `tmp_orders` , `tmp_cmd_det`
  WHERE 
     `tmp_orders`.`ref_commande` = `tmp_cmd_det`.`COL 41` ;
     
  UPDATE  `tmp_order_detail`,`tmp_order_invoice` 
  SET `tmp_order_detail`.`id_order_invoice` = `tmp_order_invoice`.`id_order_invoice`
  WHERE  `tmp_order_detail`.`id_order` = `tmp_order_invoice`.`id_order` ; 
  
  UPDATE  `tmp_order_detail`,`ps_product` 
  SET 
    `tmp_order_detail`.`product_id` = `ps_product`.`id_product` , 
    `tmp_order_detail`.`product_price` =  `ps_product`.`price`,
    `tmp_order_detail`.`product_ean13` =   `ps_product`.`ean13` ,
    `tmp_order_detail`.`product_upc` =  `ps_product`.`upc` ,   
    `tmp_order_detail`.`product_supplier_reference` =  `ps_product`.`supplier_reference`, 
    `tmp_order_detail`.`original_product_price` =  `ps_product`.`price`       
  WHERE  `tmp_order_detail`.`product_reference` = `ps_product`.`reference` ;
  
  /* Utile pour recuperer attribute id */
  UPDATE `tmp_order_detail`, `tmp_cmd_det` 
  SET  `tmp_order_detail`.`product_name` =  `tmp_cmd_det`.`COL 33` 
  WHERE 
       `tmp_order_detail`.`product_reference` = `tmp_cmd_det`.`COL 1`; 
  
  UPDATE  `tmp_order_detail`,`ps_product_attribute`,`ps_product_attribute_combination`, `ps_attribute_lang`   
  SET 
    `tmp_order_detail`.`product_attribute_id` = `ps_product_attribute_combination`.`id_product_attribute`
  WHERE 
     `tmp_order_detail`.`product_id` = `ps_product_attribute`.`id_product` AND 
     `ps_product_attribute`.`id_product_attribute` = `ps_product_attribute_combination`.`id_product_attribute` AND      
     `ps_product_attribute_combination`.`id_attribute` = `ps_attribute_lang`.`id_attribute` AND      
     `ps_attribute_lang`.`id_lang` =  var_id_lang  AND
     lower(`ps_attribute_lang`.`name`) = lower(Right(`tmp_order_detail`.`product_name`, CHAR_LENGTH(`ps_attribute_lang`.`name`))); 

  UPDATE  `tmp_order_detail`,`ps_product_lang` 
  SET 
    `tmp_order_detail`.`product_name` = `ps_product_lang`.`name` 
  WHERE  
    `tmp_order_detail`.`product_id` = `ps_product_lang`.`id_product` AND 
    `ps_product_lang`.`id_lang` = var_id_lang AND 
    `ps_product_lang`.`id_shop` = var_id_shop;
  
  UPDATE  `tmp_order_detail`,`ps_product_attribute_combination`, `ps_attribute`, `ps_attribute_lang`, `ps_attribute_group`, `ps_attribute_group_lang`  
  SET 
    `tmp_order_detail`.`product_name` = concat(`tmp_order_detail`.`product_name`, ' - ' , `ps_attribute_group_lang`.`name`, ' : ', `ps_attribute_lang`.`name` ) 
  WHERE 
     `tmp_order_detail`.`product_attribute_id` = `ps_product_attribute_combination`.`id_product_attribute` AND 
     `ps_product_attribute_combination`.`id_attribute` =  `ps_attribute`.`id_attribute` AND 
     `ps_attribute`.`id_attribute` =  `ps_attribute_lang`.`id_attribute` AND 
     `ps_attribute_lang`.`id_lang` = var_id_lang AND 
     `ps_attribute`.`id_attribute_group` = `ps_attribute_group`.`id_attribute_group` AND 
     `ps_attribute_group`.`id_attribute_group` = `ps_attribute_group_lang`.`id_attribute_group`   AND
     `ps_attribute_group_lang`.`id_lang` = var_id_lang ;       

     
  SET var_db_name = DATABASE(); 
  SET var_nb_order_detail = (
    SELECT IFNULL(MAX(`id_order_detail`),0) FROM `ps_order_detail`
  );
  
  UPDATE `tmp_order_detail`  
  SET 
    `tmp_order_detail`.`id_order_detail` = var_nb_order_detail +  `tmp_order_detail`.`id_auto_order_detail`; 
    
  UPDATE `tmp_order_detail`  
  SET  `tmp_order_detail`.`unit_price_tax_incl` =  CASE `tmp_order_detail`.`product_quantity` WHEN 0 THEN '0.00' ELSE `tmp_order_detail`.`total_price_tax_incl` / `tmp_order_detail`.`product_quantity` END    
  WHERE `tmp_order_detail`.`unit_price_tax_incl`  = 0; 
  
  UPDATE `tmp_order_detail`  
  SET  `tmp_order_detail`.`unit_price_tax_excl` =  CASE `tmp_order_detail`.`product_quantity` WHEN 0 THEN '0.00' ELSE `tmp_order_detail`.`total_price_tax_excl` / `tmp_order_detail`.`product_quantity` END    
  WHERE `tmp_order_detail`.`unit_price_tax_excl`  = 0; 
  
  INSERT `tmp_order_product_price` ( 
    `id_order` , 
    `product_price_tax_incl` ,
    `product_price_tax_excl`)
  SELECT 
     `id_order`,
     SUM(total_price_tax_incl),
     SUM(total_price_tax_excl)
  FROM 
     `tmp_order_detail`
  GROUP BY 
     `id_order` ;

  UPDATE `tmp_orders`, `tmp_order_product_price` 
  SET 
    `tmp_orders`.`total_products` = `tmp_order_product_price`.`product_price_tax_excl`, 
    `tmp_orders`.`total_products_wt` = `tmp_order_product_price`.`product_price_tax_incl`   
  WHERE 
     `tmp_orders`.`id_order` = `tmp_order_product_price`.`id_order`;
     
  INSERT `tmp_order_detail_tax` (
    `id_order_detail`,
    `id_tax` ,
    `unit_amount` ,
    `total_amount` ,
    `tax_rate` ) 
  SELECT 
    `tmp_order_detail`.`id_order_detail`,
    '0' ,
    `tmp_order_detail`.`unit_price_tax_incl` - `tmp_order_detail`.`unit_price_tax_excl`,
    `tmp_order_detail`.`total_price_tax_incl` - `tmp_order_detail`.`total_price_tax_excl`,
    `tmp_order_detail`.`product_tax_rate`  
  FROM 
     `tmp_order_detail`
  WHERE 
      `tmp_order_detail`.`product_tax_rate`  > '0.000' ;   
  
  UPDATE  `tmp_order_detail_tax`, `ps_tax`
  SET  `tmp_order_detail_tax`.`id_tax`= `ps_tax`.`id_tax` 
  WHERE `tmp_order_detail_tax`.`tax_rate` =  `ps_tax`.`rate`  AND 
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
     `tmp_order_detail_tax`
  WHERE 
     `id_tax` = '0' ;
     
  INSERT  `ps_tax_lang` ( 
    `id_tax`,
    `id_lang`,
    `name`) 
  SELECT 
     `ps_tax`.`id_tax`,
     var_id_lang, 
     CONCAT('TVA FR ',`ps_tax`.`rate`, '%')
  FROM 
     `ps_tax`,`tmp_order_detail_tax` 
  WHERE 
     `tmp_order_detail_tax`.`id_tax` = '0' AND
     `tmp_order_detail_tax`.`tax_rate` =  `ps_tax`.`rate`  AND 
     `ps_tax`.`active` = '1'  ;
      
  UPDATE  `tmp_order_detail_tax`, `ps_tax`
  SET  
    `tmp_order_detail_tax`.`id_tax`= `ps_tax`.`id_tax` 
  WHERE 
    `tmp_order_detail_tax`.`id_tax` = '0' AND
    `tmp_order_detail_tax`.`tax_rate` =  `ps_tax`.`rate`  AND 
    `ps_tax`.`active` = '1' ;   
 
  INSERT INTO `ps_order_detail` (
    `id_order_detail`, 
    `id_order`, 
    `id_order_invoice`, 
    `id_warehouse`, 
    `id_shop`, 
    `product_id`, 
    `product_attribute_id`, 
    `product_name`, 
    `product_quantity`, 
    `product_quantity_in_stock`, 
    `product_quantity_refunded`, 
    `product_quantity_return`, 
    `product_quantity_reinjected`, 
    `product_price`, 
    `reduction_percent`, 
    `reduction_amount`, 
    `reduction_amount_tax_incl`, 
    `reduction_amount_tax_excl`, 
    `group_reduction`, 
    `product_quantity_discount`, 
    `product_ean13`, 
    `product_upc`, 
    `product_reference`, 
    `product_supplier_reference`, 
    `product_weight`, 
    `tax_computation_method`, 
    `tax_name`, 
    `tax_rate`, 
    `ecotax`, 
    `ecotax_tax_rate`, 
    `discount_quantity_applied`, 
    `download_hash`, 
    `download_nb`, 
    `download_deadline`, 
    `total_price_tax_incl`, 
    `total_price_tax_excl`, 
    `unit_price_tax_incl`, 
    `unit_price_tax_excl`, 
    `total_shipping_price_tax_incl`,
    `total_shipping_price_tax_excl`, 
    `purchase_supplier_price`, 
    `original_product_price`) 
  SELECT 
    `id_order_detail`, 
    `id_order`, 
    `id_order_invoice`, 
    `id_warehouse`, 
    `id_shop`, 
    `product_id`, 
    `product_attribute_id`, 
    `product_name`, 
    `product_quantity`, 
    `product_quantity_in_stock`, 
    `product_quantity_refunded`, 
    `product_quantity_return`, 
    `product_quantity_reinjected`, 
    `product_price`, 
    `reduction_percent`, 
    `reduction_amount`, 
    `reduction_amount_tax_incl`, 
    `reduction_amount_tax_excl`, 
    `group_reduction`, 
    `product_quantity_discount`, 
    `product_ean13`, 
    `product_upc`, 
    `product_reference`, 
    `product_supplier_reference`, 
    `product_weight`, 
    `tax_computation_method`, 
    `tax_name`, 
    '0', /*  sauvegardé dans ps_order_detail_tax*/ 
    `ecotax`, 
    `ecotax_tax_rate`, 
    `discount_quantity_applied`, 
    `download_hash`, 
    `download_nb`, 
    `download_deadline`, 
    `total_price_tax_incl`, 
    `total_price_tax_excl`, 
    `unit_price_tax_incl`, 
    `unit_price_tax_excl`, 
    `total_shipping_price_tax_incl`, 
    `total_shipping_price_tax_excl`, 
    `purchase_supplier_price`, 
    `original_product_price`
  FROM 
    `tmp_order_detail` ;
    
  INSERT INTO `ps_order_detail_tax` (
    `id_order_detail`, 
    `id_tax`, 
    `unit_amount`, 
    `total_amount`) 
  SELECT 
    `id_order_detail`, 
    `id_tax`, 
    `unit_amount`, 
    `total_amount`
  FROM 
     `tmp_order_detail_tax` ;
    
  INSERT INTO  `tmp_order_history` ( 
    `id_employee` ,
    `id_order` ,
    `id_order_state` ,
    `date_add` ) 
  SELECT 
    '0',
    `id_order` ,
    `tmp_orders`.`current_state`, 
    `date_upd` 
  FROM
    `tmp_orders`  ;
  
  SET var_db_name = DATABASE(); 
  SET var_nb_order_history = (
    SELECT IFNULL(MAX(`id_order_history`),0) FROM `ps_order_history`
  );
  
  UPDATE `tmp_order_history`  
  SET 
    `tmp_order_history`.`id_order_history` = var_nb_order_history +  `tmp_order_history`.`id_auto_order_history`; 
  
  INSERT INTO `ps_order_history` (
    `id_order_history`, 
    `id_employee`, 
    `id_order`, 
    `id_order_state`, 
    `date_add`)
  SELECT 
    `id_order_history`, 
    `id_employee`, 
    `id_order`, 
    `id_order_state`, 
    `date_add`
  FROM 
     `tmp_order_history` ;

  UPDATE `ps_orders`, `tmp_orders` 
  SET 
    `ps_orders`.`total_products` = `tmp_orders`.`total_products`, 
    `ps_orders`.`total_products_wt` = `tmp_orders`.`total_products_wt`
  WHERE 
     `ps_orders`.`id_order` = `tmp_orders`.`id_order`;

  UPDATE `ps_order_invoice`, `ps_orders`, `tmp_orders` 
  SET 
  `ps_order_invoice`.`total_paid_tax_excl` = `ps_orders`.`total_paid_tax_excl`,
  `ps_order_invoice`.`total_paid_tax_incl` = `ps_orders`.`total_paid_tax_incl`,
  `ps_order_invoice`.`total_products`  = `ps_orders`.`total_products`,
  `ps_order_invoice`.`total_products_wt` = `ps_orders`.`total_products_wt`,
  `ps_order_invoice`.`total_shipping_tax_excl` = `ps_orders`.`total_shipping_tax_excl`,  
  `ps_order_invoice`.`total_shipping_tax_incl` = `ps_orders`.`total_shipping_tax_incl`
  WHERE
     `ps_order_invoice`.`id_order` = `ps_orders`.`id_order` AND 
     `ps_orders`.`id_order` = `tmp_orders`.`id_order`;

END $$