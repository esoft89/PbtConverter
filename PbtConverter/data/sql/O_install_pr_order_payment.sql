DROP PROCEDURE IF EXISTS `pr_order_payment` $$
CREATE PROCEDURE `pr_order_payment`()
    MODIFIES SQL DATA
    SQL SECURITY INVOKER
BEGIN
  DECLARE var_db_name varchar(50); 
  DECLARE var_nb_order_payment int;
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
  
  INSERT INTO `tmp_order_payment` (
     `id_order_payment`, 
     `id_order`,
     `order_reference`, 
     `id_currency`, 
     `amount`, 
     `payment_method`, 
     `conversion_rate`, 
     `transaction_id`, 
     `date_add`) 
  SELECT
     '0',  
     `id_order`,
     `reference`, 
     `id_currency`, 
     `total_paid`, 
     `payment`, 
     '1', 
     RIGHT(`tmp_cmd_gen`.`COL 76`, CHAR_LENGTH(`tmp_cmd_gen`.`COL 76`) - 12 ), 
     `date_add`
  FROM 
     `tmp_orders` , `tmp_cmd_gen`
  WHERE 
    `tmp_orders`.`ref_commande` =  `tmp_cmd_gen`.`COL 1` ;
   
  SET var_db_name = DATABASE(); 
  SET var_nb_order_payment = (
    SELECT IFNULL(MAX(`id_order_payment`),0) FROM `ps_order_payment`
  );
  
  UPDATE `tmp_order_payment`  
  SET 
    `tmp_order_payment`.`id_order_payment` = var_nb_order_payment +  `tmp_order_payment`.`id_auto_order_payment`; 
  
  INSERT INTO `ps_order_payment` (
    `id_order_payment`, 
    `order_reference`, 
    `id_currency`, 
    `amount`, 
    `payment_method`, 
    `conversion_rate`, 
    `transaction_id`, 
    `card_number`, 
    `card_brand`, 
    `card_expiration`, 
    `card_holder`, 
    `date_add`) 
  SELECT 
    `id_order_payment`, 
    `order_reference`, 
    `id_currency`, 
    `amount`, 
    `payment_method`, 
    `conversion_rate`, 
    `transaction_id`, 
    `card_number`, 
    `card_brand`, 
    `card_expiration`, 
    `card_holder`, 
    `date_add` 
  FROM 
    `tmp_order_payment` ; 
    
  INSERT INTO `ps_order_invoice_payment` (
    `id_order_invoice`, 
    `id_order_payment`, 
    `id_order`)
  SELECT 
    `tmp_order_invoice`.`id_order_invoice`, 
    `tmp_order_payment`.`id_order_payment`, 
    `tmp_orders`.`id_order`
  FROM 
    `tmp_orders`,`tmp_order_invoice`,`tmp_order_payment`
  WHERE 
    `tmp_orders`.`id_order` = `tmp_order_invoice`.`id_order` AND 
     `tmp_order_invoice`.`id_order` = `tmp_order_payment`.`id_order` ;  
     
END $$