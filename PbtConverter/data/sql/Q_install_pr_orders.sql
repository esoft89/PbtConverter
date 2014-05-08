DROP PROCEDURE IF EXISTS `pr_orders` $$
CREATE PROCEDURE `pr_orders`()
    MODIFIES SQL DATA
    SQL SECURITY INVOKER
BEGIN
  DECLARE pay_paypal varchar(50); 
  DECLARE pay_cheque varchar(50); 
  DECLARE pay_cash varchar(50); 
  DECLARE pay_systempay varchar(50); 
  DECLARE pay_cash_mandat varchar(50); 
  DECLARE pay_codfee varchar(50); 
  DECLARE pay_bankwire varchar(50);
  
  DECLARE var_db_name varchar(50); 
  DECLARE var_nb_orders int;
  DECLARE var_delivery_number int;
  DECLARE var_invoice_number int;

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
  
  SET pay_paypal = 'paypal'; 
  SET pay_cheque = 'cheque3x'; 
  SET pay_cash = 'cashondelivery'; 
  SET pay_systempay = 'systempay'; 
  SET pay_bankwire = 'bankwire'; 
  SET pay_cash_mandat = 'cash_mandat';
  SET pay_codfee = 'codfee';  
  
  
  
  
  
  INSERT INTO `tmp_orders` (
    `ref_commande` ,
    `reference` ,
    `id_shop_group` ,
    `id_shop` ,
    `id_carrier` ,
    `id_lang` ,
    `id_customer` ,
    `id_cart` ,
    `id_currency` ,
    `id_address_delivery` ,
    `id_address_invoice` ,
    `invoice_date` ,
    `delivery_date` ,
    `valid`,
    `date_add` ,
    `date_upd`,
    `current_state`,
    `payment`,
    `module`,
    `shipping_number`,
    `total_paid`,
    `total_paid_tax_incl`,
    `total_paid_tax_excl`,
    `total_shipping` ,
    `total_shipping_tax_incl` ,
    `total_shipping_tax_excl` ,
    `total_paid_real` ,
    `total_products` ,
    `total_products_wt`,
    `carrier_tax_rate` )
  SELECT 
    `tmp_cart`.`ref_commande`, 
    `tmp_cart`.`ref_commande`,
    `tmp_cart`.`id_shop_group` ,
    `tmp_cart`.`id_shop` ,
    `tmp_cart`.`id_carrier` ,
    `tmp_cart`.`id_lang` ,
    `tmp_cart`.`id_customer` ,
    `tmp_cart`.`id_cart` ,
    `tmp_cart`.`id_currency` ,
    `tmp_cart`.`id_address_delivery` ,
    `tmp_cart`.`id_address_invoice` ,
    `tmp_cart`.`date_upd`,
    `tmp_cart`.`date_add`,
     '0',
    `tmp_cart`.`date_add`,
    `tmp_cart`.`date_upd`,
     CASE `tmp_cmd_gen`.`COL 30` WHEN "Validée" THEN '5' ELSE '6' END,
    `tmp_cmd_gen`.`COL 67` ,
     CASE `tmp_cmd_gen`.`COL 67` 
        WHEN 'Carte Bancaire' THEN pay_systempay 
        WHEN 'Carte Bancaire - 3x sans frais' THEN pay_systempay 
        WHEN 'Compte PayPal / American Express / Cartes Privatives' THEN pay_paypal  
        WHEN 'Mandat Cash (Espèces)' THEN pay_cash_mandat 
        WHEN 'Virement' THEN pay_bankwire 
        WHEN 'Chèque' THEN pay_cheque 
        WHEN 'Contre Remboursement (+ 7EUR)' THEN pay_codfee
        ELSE pay_systempay 
    END, 
    `tmp_cmd_gen`.`COL 49` ,
     CONVERT(REPLACE(REPLACE(`COL 59`, '.', ''), ',', '.'), DECIMAL(17,2)), 
     CONVERT(REPLACE(REPLACE(`COL 59`, '.', ''), ',', '.'), DECIMAL(17,2)), 
     CONVERT(REPLACE(REPLACE(`COL 61`, '.', ''), ',', '.'), DECIMAL(17,2)) + CONVERT(REPLACE(REPLACE(`COL 58`, '.', ''), ',', '.'), DECIMAL(17,2)), 
     CONVERT(REPLACE(REPLACE(`COL 57`, '.', ''), ',', '.'), DECIMAL(17,2)), 
     CONVERT(REPLACE(REPLACE(`COL 57`, '.', ''), ',', '.'), DECIMAL(17,2)), 
     CONVERT(REPLACE(REPLACE(`COL 58`, '.', ''), ',', '.'), DECIMAL(17,2)), 
     CONVERT(REPLACE(REPLACE(`COL 59`, '.', ''), ',', '.'), DECIMAL(17,2)), 
     CONVERT(REPLACE(REPLACE(`COL 61`, '.', ''), ',', '.'), DECIMAL(17,2)), 
     CONVERT(REPLACE(REPLACE(`COL 59`, '.', ''), ',', '.'), DECIMAL(17,2)), 
     CONVERT(REPLACE(REPLACE(`COL 93`, '.', ''), ',', '.'), DECIMAL(10,3))
  FROM 
     `tmp_cart` , `tmp_cmd_gen`
  WHERE 
    `tmp_cart`.`ref_commande` =  `tmp_cmd_gen`.`COL 1` ;
    
  /* MAJ STATUTS */
    UPDATE `tmp_orders`,  `tmp_cmd_gen`, `tmp_transco_statuts`  
    SET
      `tmp_orders`.`current_state` = `tmp_transco_statuts`.`statut_prestashop` 
    WHERE 
      `tmp_orders`.`ref_commande` =  `tmp_cmd_gen`.`COL 1` AND
      LOWER(LEFT(`tmp_cmd_gen`.`COL 30`,8))  = LOWER(LEFT(`tmp_transco_statuts`.`etat_cmd`,8)) AND 
      LOWER(LEFT(`tmp_cmd_gen`.`COL 31`,8))  = LOWER(LEFT(`tmp_transco_statuts`.`etat_regl`,8)) AND
      LOWER(LEFT(`tmp_cmd_gen`.`COL 44`,8))  = LOWER(LEFT(`tmp_transco_statuts`.`etat_livraison`,8)) AND 
      `tmp_transco_statuts`.`test_chq` = '0';
      
    UPDATE `tmp_orders`,  `tmp_cmd_gen`, `tmp_transco_statuts`  
    SET
      `tmp_orders`.`current_state` = `tmp_transco_statuts`.`statut_prestashop` 
    WHERE 
      `tmp_orders`.`ref_commande` =  `tmp_cmd_gen`.`COL 1` AND
      LOWER(LEFT(`tmp_cmd_gen`.`COL 30`,8))  = LOWER(LEFT(`tmp_transco_statuts`.`etat_cmd`,8)) AND 
      LOWER(LEFT(`tmp_cmd_gen`.`COL 31`,8))  = LOWER(LEFT(`tmp_transco_statuts`.`etat_regl`,8)) AND
      LOWER(LEFT(`tmp_cmd_gen`.`COL 44`,8))  = LOWER(LEFT(`tmp_transco_statuts`.`etat_livraison`,8)) AND
      `tmp_transco_statuts`.`test_chq` > '0' AND
      DATE_SUB(CURDATE(),INTERVAL 3 MONTH) <= `tmp_orders`.`invoice_date` AND 
     `tmp_orders`.`payment`  in ( 'Mandat Cash (Espèces)' , 'Chèque','Contre Remboursement (+ 7EUR)','Mandat Cash (Espèces)','Virement' );   
   
  INSERT `tmp_orders_ins` ( `id_auto_order`) 
  SELECT  `id_auto_order` FROM `tmp_orders` 
  WHERE  `tmp_orders`.`current_state` <> 30; 
  
  DELETE `tmp_orders` 
  FROM `tmp_orders` 
  WHERE `tmp_orders`.`current_state` =  30 ;
  
  UPDATE `tmp_orders` , `tmp_orders_ins` 
  SET  `tmp_orders`.`id_auto_order_ins` = `tmp_orders_ins`.`id_auto_order_ins` 
  WHERE   `tmp_orders`.`id_auto_order`  = `tmp_orders_ins`.`id_auto_order`;
        
  /* ID ORDER */
  SET var_db_name = DATABASE(); 
  SET var_nb_orders = (
    SELECT IFNULL(MAX(`id_order`),0) FROM `ps_orders`  
  );
  
  UPDATE `tmp_orders`  
  SET 
    `tmp_orders`.`id_order` = var_nb_orders +  `tmp_orders`.`id_auto_order_ins` ;
  
  /* DELIVERY NUMBER */ 
  SET var_delivery_number = (
    SELECT IFNULL(MAX(delivery_number),'0') from `ps_orders` 
  ); 
  /* INVOICE NUMBER */ 
  SET var_invoice_number = (
    SELECT IFNULL(MAX(invoice_number),'0') from `ps_orders` 
  ); 
  
  UPDATE `tmp_orders`  
  SET 
    `tmp_orders`.`delivery_number` = var_delivery_number +  `tmp_orders`.`id_auto_order_ins` ,
    `tmp_orders`.`invoice_number` = var_invoice_number +  `tmp_orders`.`id_auto_order_ins` ;
  
  INSERT INTO `ps_orders` (
    `id_order`, 
    `reference`, 
    `id_shop_group`, 
    `id_shop`, 
    `id_carrier`, 
    `id_lang`, 
    `id_customer`, 
    `id_cart`, 
    `id_currency`, 
    `id_address_delivery`, 
    `id_address_invoice`, 
    `current_state`, 
    `secure_key`, 
    `payment`, 
    `conversion_rate`, 
    `module`, 
    `recyclable`, 
    `gift`, 
    `gift_message`, 
    `mobile_theme`, 
    `shipping_number`, 
    `total_discounts`, 
    `total_discounts_tax_incl`, 
    `total_discounts_tax_excl`, 
    `total_paid`, 
    `total_paid_tax_incl`, 
    `total_paid_tax_excl`, 
    `total_paid_real`, 
    `total_products`, 
    `total_products_wt`, 
    `total_shipping`, 
    `total_shipping_tax_incl`,
    `total_shipping_tax_excl`, 
    `carrier_tax_rate`, 
    `total_wrapping`, 
    `total_wrapping_tax_incl`, 
    `total_wrapping_tax_excl`, 
    `invoice_number`,
     `delivery_number`, 
     `invoice_date`, 
     `delivery_date`, 
     `valid`, 
     `date_add`, 
     `date_upd`)
   SELECT 
    `id_order`, 
    `reference`, 
    `id_shop_group`, 
    `id_shop`, 
    `id_carrier`, 
    `id_lang`, 
    `id_customer`, 
    `id_cart`, 
    `id_currency`, 
    `id_address_delivery`, 
    `id_address_invoice`, 
    `current_state`, 
    `secure_key`, 
    `payment`, 
    `conversion_rate`, 
    `module`, 
    `recyclable`, 
    `gift`, 
    `gift_message`, 
    `mobile_theme`, 
    `shipping_number`, 
    `total_discounts`, 
    `total_discounts_tax_incl`, 
    `total_discounts_tax_excl`, 
    `total_paid`, 
    `total_paid_tax_incl`, 
    `total_paid_tax_excl`, 
    `total_paid_real`, 
    `total_products`, 
    `total_products_wt`, 
    `total_shipping`, 
    `total_shipping_tax_incl`,
    `total_shipping_tax_excl`, 
    `carrier_tax_rate`, 
    `total_wrapping`, 
    `total_wrapping_tax_incl`, 
    `total_wrapping_tax_excl`, 
    `invoice_number`,
    `delivery_number`, 
    `invoice_date`, 
    `delivery_date`, 
    `valid`, 
    `date_add`, 
    `date_upd`
  FROM 
    `tmp_orders` ; 
        
END $$ 