DROP PROCEDURE IF EXISTS `pr_del_ps_tables` $$
CREATE PROCEDURE `pr_del_ps_tables`()
    MODIFIES SQL DATA
    SQL SECURITY INVOKER
BEGIN

  DECLARE var_is_last int DEFAULT 0;
  DECLARE var_del_last_only int DEFAULT 0;
  DECLARE var_id_import_log int DEFAULT 0;
  DECLARE nb_loop int DEFAULT 0;
  DECLARE var_finished int DEFAULT 0;
  DEClARE tmp_import_log_cursor CURSOR FOR  SELECT `id_import_log`, `is_last` FROM `tmp_import_log`;
  DECLARE CONTINUE HANDLER FOR NOT FOUND SET var_finished = 1;
  
   SET var_del_last_only = (
    SELECT cast(`value` AS UNSIGNED INT)
    FROM `tmp_param`
    WHERE `tmp_param`.`name` = 'undo_last_only'
  );

  OPEN tmp_import_log_cursor;

    get_import_log: LOOP
     SET nb_loop = nb_loop + 1;
      FETCH tmp_import_log_cursor INTO var_id_import_log,var_is_last ;
      
      IF var_finished = 1 THEN 
          LEAVE get_import_log;
      END IF;
      IF nb_loop > 100 THEN 
          LEAVE get_import_log;
      END IF;
      IF var_del_last_only = 0 THEN
        SET var_is_last = 1; 
      END IF;

      IF var_is_last = 1 THEN
        DELETE `ps_cart_product` 
        FROM   `ps_cart_product`, `tmp_import_log_detail`  
        WHERE  `tmp_import_log_detail`.`field_name` =  'id_cart' AND 
               `tmp_import_log_detail`.`id_import_log` = var_id_import_log AND 
               `tmp_import_log_detail`.`value_after` > `tmp_import_log_detail`.`value_before` AND 
               `ps_cart_product`.`id_cart` BETWEEN  `tmp_import_log_detail`.`value_before` + 1  AND
               `tmp_import_log_detail`.`value_after` ;     
        
        DELETE `ps_cart` 
        FROM   `ps_cart`, `tmp_import_log_detail`  
        WHERE  `tmp_import_log_detail`.`field_name` =  'id_cart' AND 
               `tmp_import_log_detail`.`id_import_log` = var_id_import_log AND 
               `tmp_import_log_detail`.`value_after` > `tmp_import_log_detail`.`value_before` AND 
               `ps_cart`.`id_cart` BETWEEN  `tmp_import_log_detail`.`value_before` + 1  AND
               `tmp_import_log_detail`.`value_after` ;     
      
        DELETE `ps_order_detail_tax`
        FROM   `ps_order_detail_tax`, `tmp_import_log_detail`  
        WHERE  `tmp_import_log_detail`.`field_name` =  'id_order_detail' AND 
               `tmp_import_log_detail`.`id_import_log` = var_id_import_log AND 
               `tmp_import_log_detail`.`value_after` > `tmp_import_log_detail`.`value_before` AND 
               `ps_order_detail_tax`.`id_order_detail` BETWEEN  `tmp_import_log_detail`.`value_before` + 1  AND
               `tmp_import_log_detail`.`value_after` ;     
      
        DELETE `ps_order_detail` 
        FROM   `ps_order_detail`, `tmp_import_log_detail`  
        WHERE  `tmp_import_log_detail`.`field_name` =  'id_order_detail' AND 
               `tmp_import_log_detail`.`id_import_log` = var_id_import_log AND 
               `tmp_import_log_detail`.`value_after` > `tmp_import_log_detail`.`value_before` AND 
               `ps_order_detail`.`id_order_detail` BETWEEN  `tmp_import_log_detail`.`value_before` + 1  AND
               `tmp_import_log_detail`.`value_after` ;     
      
        DELETE `ps_order_history` 
        FROM   `ps_order_history`, `tmp_import_log_detail`  
        WHERE  `tmp_import_log_detail`.`field_name` =  'id_order_history' AND 
               `tmp_import_log_detail`.`id_import_log` = var_id_import_log AND 
               `tmp_import_log_detail`.`value_after` > `tmp_import_log_detail`.`value_before` AND 
               `ps_order_history`.`id_order_history` BETWEEN  `tmp_import_log_detail`.`value_before` + 1  AND
               `tmp_import_log_detail`.`value_after` ;     
        
        DELETE `ps_order_payment` 
        FROM   `ps_order_payment`, `tmp_import_log_detail`  
        WHERE  `tmp_import_log_detail`.`field_name` =  'id_order_payment' AND 
               `tmp_import_log_detail`.`id_import_log` = var_id_import_log AND 
               `tmp_import_log_detail`.`value_after` > `tmp_import_log_detail`.`value_before` AND 
               `ps_order_payment`.`id_order_payment` BETWEEN  `tmp_import_log_detail`.`value_before` + 1  AND
               `tmp_import_log_detail`.`value_after` ;     
      
        DELETE `ps_order_invoice_payment`
        FROM   `ps_order_invoice_payment`, `tmp_import_log_detail`  
        WHERE  `tmp_import_log_detail`.`field_name` =  'id_order_invoice' AND 
               `tmp_import_log_detail`.`id_import_log` = var_id_import_log AND 
               `tmp_import_log_detail`.`value_after` > `tmp_import_log_detail`.`value_before` AND 
               `ps_order_invoice_payment`.`id_order_invoice` BETWEEN  `tmp_import_log_detail`.`value_before` + 1  AND
               `tmp_import_log_detail`.`value_after` ;     
      
        DELETE `ps_order_invoice_tax`
        FROM   `ps_order_invoice_tax`, `tmp_import_log_detail`  
        WHERE  `tmp_import_log_detail`.`field_name` =  'id_order_invoice' AND 
               `tmp_import_log_detail`.`id_import_log` = var_id_import_log AND 
               `tmp_import_log_detail`.`value_after` > `tmp_import_log_detail`.`value_before` AND 
               `ps_order_invoice_tax`.`id_order_invoice` BETWEEN  `tmp_import_log_detail`.`value_before` + 1  AND
               `tmp_import_log_detail`.`value_after` ;     
        
        DELETE `ps_order_invoice` 
        FROM   `ps_order_invoice`, `tmp_import_log_detail`  
        WHERE  `tmp_import_log_detail`.`field_name` =  'id_order_invoice' AND 
               `tmp_import_log_detail`.`id_import_log` = var_id_import_log AND 
               `tmp_import_log_detail`.`value_after` > `tmp_import_log_detail`.`value_before` AND 
               `ps_order_invoice`.`id_order_invoice` BETWEEN  `tmp_import_log_detail`.`value_before` + 1  AND
               `tmp_import_log_detail`.`value_after` ;     
        
        DELETE `ps_order_carrier` 
        FROM   `ps_order_carrier`, `tmp_import_log_detail`  
        WHERE  `tmp_import_log_detail`.`field_name` =  'id_order_carrier' AND 
               `tmp_import_log_detail`.`id_import_log` = var_id_import_log AND 
               `tmp_import_log_detail`.`value_after` > `tmp_import_log_detail`.`value_before` AND 
               `ps_order_carrier`.`id_order_carrier` BETWEEN  `tmp_import_log_detail`.`value_before` + 1  AND
               `tmp_import_log_detail`.`value_after` ;     
      
        DELETE `ps_orders` 
        FROM   `ps_orders`, `tmp_import_log_detail`  
        WHERE  `tmp_import_log_detail`.`field_name` =  'id_order' AND 
               `tmp_import_log_detail`.`id_import_log` = var_id_import_log AND 
               `tmp_import_log_detail`.`value_after` > `tmp_import_log_detail`.`value_before` AND 
               `ps_orders`.`id_order` BETWEEN  `tmp_import_log_detail`.`value_before` + 1  AND
               `tmp_import_log_detail`.`value_after` ;     
      
        DELETE `ps_category_product` 
        FROM   `ps_category_product`, `tmp_import_log_detail`  
        WHERE  `tmp_import_log_detail`.`field_name` =  'id_product' AND 
               `tmp_import_log_detail`.`id_import_log` = var_id_import_log AND 
               `tmp_import_log_detail`.`value_after` > `tmp_import_log_detail`.`value_before` AND 
               `ps_category_product`.`id_product` BETWEEN  `tmp_import_log_detail`.`value_before` + 1  AND
               `tmp_import_log_detail`.`value_after` ;     
      
        DELETE `ps_product_sale` 
        FROM   `ps_product_sale`, `tmp_import_log_detail`  
        WHERE  `tmp_import_log_detail`.`field_name` =  'id_product' AND 
               `tmp_import_log_detail`.`id_import_log` = var_id_import_log AND 
               `tmp_import_log_detail`.`value_after` > `tmp_import_log_detail`.`value_before` AND 
               `ps_product_sale`.`id_product` BETWEEN  `tmp_import_log_detail`.`value_before` + 1  AND
               `tmp_import_log_detail`.`value_after` ;     
      
        DELETE `ps_product_shop` 
        FROM   `ps_product_shop`, `tmp_import_log_detail`  
        WHERE  `tmp_import_log_detail`.`field_name` =  'id_product' AND 
               `tmp_import_log_detail`.`id_import_log` = var_id_import_log AND 
               `tmp_import_log_detail`.`value_after` > `tmp_import_log_detail`.`value_before` AND 
               `ps_product_shop`.`id_product` BETWEEN  `tmp_import_log_detail`.`value_before` + 1  AND
               `tmp_import_log_detail`.`value_after` ;     
        
        DELETE `ps_product_attribute`
        FROM   `ps_product_attribute`, `tmp_import_log_detail`  
        WHERE  `tmp_import_log_detail`.`field_name` =  'id_product_attribute' AND 
               `tmp_import_log_detail`.`id_import_log` = var_id_import_log AND 
               `tmp_import_log_detail`.`value_after` > `tmp_import_log_detail`.`value_before` AND 
               `ps_product_attribute`.`id_product_attribute` BETWEEN  `tmp_import_log_detail`.`value_before` + 1  AND
               `tmp_import_log_detail`.`value_after` ;     
      
        DELETE `ps_product_attribute_combination`
        FROM   `ps_product_attribute_combination`, `tmp_import_log_detail`  
        WHERE  `tmp_import_log_detail`.`field_name` =  'id_product_attribute' AND 
               `tmp_import_log_detail`.`id_import_log` = var_id_import_log AND 
               `tmp_import_log_detail`.`value_after` > `tmp_import_log_detail`.`value_before` AND 
               `ps_product_attribute_combination`.`id_product_attribute` BETWEEN  `tmp_import_log_detail`.`value_before` + 1  AND
               `tmp_import_log_detail`.`value_after` ;     
      
        DELETE `ps_product_attribute_shop`
        FROM   `ps_product_attribute_shop`, `tmp_import_log_detail`  
        WHERE  `tmp_import_log_detail`.`field_name` =  'id_product_attribute' AND 
               `tmp_import_log_detail`.`id_import_log` = var_id_import_log AND 
               `tmp_import_log_detail`.`value_after` > `tmp_import_log_detail`.`value_before` AND 
               `ps_product_attribute_shop`.`id_product_attribute` BETWEEN  `tmp_import_log_detail`.`value_before` + 1  AND
               `tmp_import_log_detail`.`value_after` ;     
        
        DELETE `ps_product` 
        FROM   `ps_product`, `tmp_import_log_detail`  
        WHERE  `tmp_import_log_detail`.`field_name` =  'id_product' AND 
               `tmp_import_log_detail`.`id_import_log` = var_id_import_log AND 
               `tmp_import_log_detail`.`value_after` > `tmp_import_log_detail`.`value_before` AND 
               `ps_product`.`id_product` BETWEEN  `tmp_import_log_detail`.`value_before` + 1  AND
               `tmp_import_log_detail`.`value_after` ;     
        
        DELETE `ps_product_lang` 
        FROM   `ps_product_lang`, `tmp_import_log_detail`  
        WHERE  `tmp_import_log_detail`.`field_name` =  'id_product' AND 
               `tmp_import_log_detail`.`id_import_log` = var_id_import_log AND 
               `tmp_import_log_detail`.`value_after` > `tmp_import_log_detail`.`value_before` AND 
               `ps_product_lang`.`id_product` BETWEEN  `tmp_import_log_detail`.`value_before` + 1  AND
               `tmp_import_log_detail`.`value_after` ;     
      
        
        DELETE `ps_address` 
        FROM   `ps_address`, `tmp_import_log_detail`  
        WHERE  `tmp_import_log_detail`.`field_name` =  'id_address' AND 
               `tmp_import_log_detail`.`id_import_log` = var_id_import_log AND 
               `tmp_import_log_detail`.`value_after` > `tmp_import_log_detail`.`value_before` AND 
               `ps_address`.`id_address` BETWEEN  `tmp_import_log_detail`.`value_before` + 1  AND
               `tmp_import_log_detail`.`value_after` ;     
        
        DELETE `ps_customer` 
        FROM   `ps_customer`, `tmp_import_log_detail`  
        WHERE  `tmp_import_log_detail`.`field_name` =  'id_customer' AND 
               `tmp_import_log_detail`.`id_import_log` = var_id_import_log AND 
               `tmp_import_log_detail`.`value_after` > `tmp_import_log_detail`.`value_before` AND 
               `ps_customer`.`id_customer` BETWEEN  `tmp_import_log_detail`.`value_before` + 1  AND
               `tmp_import_log_detail`.`value_after` ;     
        
        DELETE `ps_attribute_group_shop` 
        FROM   `ps_attribute_group_shop`, `tmp_import_log_detail`  
        WHERE  `tmp_import_log_detail`.`field_name` =  'id_attribute_group' AND 
               `tmp_import_log_detail`.`id_import_log` = var_id_import_log AND 
               `tmp_import_log_detail`.`value_after` > `tmp_import_log_detail`.`value_before` AND 
               `ps_attribute_group_shop`.`id_attribute_group` BETWEEN  `tmp_import_log_detail`.`value_before` + 1  AND
               `tmp_import_log_detail`.`value_after` ;     
      
        
        DELETE `ps_attribute_group_lang` 
        FROM   `ps_attribute_group_lang`, `tmp_import_log_detail`  
        WHERE  `tmp_import_log_detail`.`field_name` =  'id_attribute_group' AND 
               `tmp_import_log_detail`.`id_import_log` = var_id_import_log AND 
               `tmp_import_log_detail`.`value_after` > `tmp_import_log_detail`.`value_before` AND 
               `ps_attribute_group_lang`.`id_attribute_group` BETWEEN  `tmp_import_log_detail`.`value_before` + 1  AND
               `tmp_import_log_detail`.`value_after` ;     
        
        DELETE `ps_attribute_group` 
        FROM   `ps_attribute_group`, `tmp_import_log_detail`  
        WHERE  `tmp_import_log_detail`.`field_name` =  'id_attribute_group' AND 
               `tmp_import_log_detail`.`id_import_log` = var_id_import_log AND 
               `tmp_import_log_detail`.`value_after` > `tmp_import_log_detail`.`value_before` AND 
               `ps_attribute_group`.`id_attribute_group` BETWEEN  `tmp_import_log_detail`.`value_before` + 1  AND
               `tmp_import_log_detail`.`value_after` ;     
         
        DELETE `ps_attribute_shop` 
        FROM   `ps_attribute_shop`, `tmp_import_log_detail`  
        WHERE  `tmp_import_log_detail`.`field_name` =  'id_attribute' AND 
               `tmp_import_log_detail`.`id_import_log` = var_id_import_log AND 
               `tmp_import_log_detail`.`value_after` > `tmp_import_log_detail`.`value_before` AND 
               `ps_attribute_shop`.`id_attribute` BETWEEN  `tmp_import_log_detail`.`value_before` + 1  AND
               `tmp_import_log_detail`.`value_after` ;     
        
        DELETE `ps_attribute_lang` 
        FROM   `ps_attribute_lang`, `tmp_import_log_detail`  
        WHERE  `tmp_import_log_detail`.`field_name` =  'id_attribute' AND 
               `tmp_import_log_detail`.`id_import_log` = var_id_import_log AND 
               `tmp_import_log_detail`.`value_after` > `tmp_import_log_detail`.`value_before` AND 
               `ps_attribute_lang`.`id_attribute` BETWEEN  `tmp_import_log_detail`.`value_before` + 1  AND
               `tmp_import_log_detail`.`value_after` ;     
        
        DELETE `ps_attribute` 
        FROM   `ps_attribute`, `tmp_import_log_detail`  
        WHERE  `tmp_import_log_detail`.`field_name` =  'id_attribute' AND 
               `tmp_import_log_detail`.`id_import_log` = var_id_import_log AND 
               `tmp_import_log_detail`.`value_after` > `tmp_import_log_detail`.`value_before` AND 
               `ps_attribute`.`id_attribute` BETWEEN  `tmp_import_log_detail`.`value_before` + 1  AND
               `tmp_import_log_detail`.`value_after` ;
               
        UPDATE `tmp_import_log`
        SET `deleted` = 1
        WHERE `tmp_import_log`.`id_import_log` = var_id_import_log;
         
      END IF;
    END LOOP get_import_log;
    CLOSE tmp_import_log_cursor;

    DELETE `tmp_import_log_detail` 
    FROM  `tmp_import_log_detail`, `tmp_import_log`
    WHERE `tmp_import_log_detail`.`id_import_log` = `tmp_import_log`.`id_import_log` AND 
    `tmp_import_log`.`deleted`  = 1;

    DELETE `tmp_import_log` 
    FROM `tmp_import_log`
    WHERE `deleted`  = 1;
    
    UPDATE `tmp_import_log` a
    JOIN   (SELECT MAX(`id_import_log`) AS id FROM `tmp_import_log`) b
           ON a.`id_import_log` = b.id
    SET    `is_last` = 1 ;
    
END $$ 
