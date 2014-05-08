DROP PROCEDURE IF EXISTS `pr_cart_product` $$
CREATE PROCEDURE `pr_cart_product`()
    MODIFIES SQL DATA
    SQL SECURITY INVOKER
BEGIN
  DECLARE var_db_name varchar(50); 
  DECLARE var_nb_product int;
  DECLARE var_nb_product_attribute int;
  DECLARE var_id_lang int;
  DECLARE var_id_shop int;
  DECLARE var_id_default_category int;
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
  
  SET  var_id_default_category = (
    SELECT `id_category`
    FROM `ps_category`
    WHERE `ps_category`.`id_shop_default` = '1' AND
    `ps_category`.`is_root_category` = '1' 
  );
  
  INSERT INTO `tmp_cart_product` (
    `ref_commande`, 
    `ref_produit`, 
    `id_cart`,
    `date_add`,
    `id_address_delivery`,
    `id_shop`,
    `quantity` ) 
  SELECT   
    `tmp_cart`.`ref_commande`, 
     LEFT(`tmp_cmd_det`.`COL 1`,12),
    `tmp_cart`.`id_cart`,
    `tmp_cart`.`date_add`, 
    `tmp_cart`.`id_address_delivery`,
    `tmp_cart`.`id_shop`,
    `tmp_cmd_det`.`COL 40`
  FROM 
    `tmp_cart`, `tmp_cmd_det` 
  WHERE 
    `tmp_cart`.`ref_commande` =  `tmp_cmd_det`.`COL 41` ;
  
  /* Mise du produit - on recherche un produit actif en 1er*/
  UPDATE `tmp_cart_product`, `ps_product`
  SET 
    `tmp_cart_product`.`id_product` =  `ps_product`.`id_product`  
  WHERE 
    `tmp_cart_product`.`ref_produit` = `ps_product`.`reference` AND 
    `ps_product`.`active` = '1' ; 
  
  /* Mise du produit - on recherche un produit desactivé*/
  UPDATE `tmp_cart_product`, `ps_product`
  SET 
    `tmp_cart_product`.`id_product` =  `ps_product`.`id_product`  
  WHERE 
    `tmp_cart_product`.`id_product` = '0' AND
    `tmp_cart_product`.`ref_produit` = `ps_product`.`reference` ;  
    
  INSERT INTO `tmp_existing_product` ( 
    `id_product`,
    `quantity`,
    `minimal_quantity`,
    `price`,
    `available_date`,
    `reference` )
  SELECT DISTINCT 
    `tmp_cart_product`.`id_product`,
    `ps_product`.`quantity`,
    `ps_product`.`minimal_quantity`,
    `ps_product`.`price`,
    `ps_product`.`available_date`,
    `ps_product`.`reference` 
  FROM 
    `tmp_cart_product`, `ps_product`  
  WHERE 
    `tmp_cart_product`.`id_product` > '0'  AND 
    `tmp_cart_product`.`id_product` = `ps_product`.`id_product`;

  INSERT INTO `tmp_product` ( 
    `reference`,
    `price`,
    `date_add`,
    `date_upd`,
    `attribute_group_name`,
    `name`, 
    `available_date` )
  SELECT  
    `tmp_cart_product`.`ref_produit`,
    (SUM(CONVERT(REPLACE(REPLACE(`tmp_cmd_det`.`COL 22`, '.', ''), ',', '.'), DECIMAL(20,6))) - 
    SUM(CONVERT(REPLACE(REPLACE(`tmp_cmd_det`.`COL 23`, '.', ''), ',', '.'), DECIMAL(20,6)))) / 
    SUM(`tmp_cmd_det`.`COL 40`),
    MIN(`tmp_cart_product`.`date_add`),
    MAX(`tmp_cart_product`.`date_add`),
    CASE LOWER(LEFT(`tmp_cmd_det`.`COL 53`,2)) WHEN "go" THEN 'Goût' WHEN "ta" THEN 'Taille' WHEN "co" THEN 'Couleur' ELSE 'Goût' END ,
    `tmp_cmd_det`.`COL 33`,
    MIN(`tmp_cart_product`.`date_add`)   
  FROM 
    `tmp_cart_product`, `tmp_cmd_det`  
  WHERE 
    `tmp_cart_product`.`id_product` = '0'  AND 
    `tmp_cmd_det`.`COL 1` = `tmp_cart_product`.`ref_produit` 
  GROUP BY
    `tmp_cart_product`.`ref_produit`; 
  
  SET var_db_name = DATABASE(); 
  SET var_nb_product = (
    SELECT IFNULL(MAX(`id_product`),0) FROM `ps_product`  
  );
  
  SET var_nb_product_attribute = (
    SELECT IFNULL(MAX(`id_product_attribute`),0) FROM `ps_product_attribute`  
  );
  
  UPDATE `tmp_product`  
  SET 
    `tmp_product`.`id_product` = var_nb_product +  `tmp_product`.`id_auto_product` ;
  
  UPDATE `tmp_cart_product`, `tmp_product`
  SET 
    `tmp_cart_product`.`id_product` =  `tmp_product`.`id_product`  
  WHERE 
    `tmp_cart_product`.`id_product` = '0' AND
    `tmp_cart_product`.`ref_produit` = `tmp_product`.`reference` ;  
  
  UPDATE `tmp_product`
  SET 
    `tmp_product`.`id_category_default` =  var_id_default_category ;
 
  UPDATE `tmp_product` , `ps_attribute_group_lang` 
  SET  
     `tmp_product`.`id_attribute_group` = `ps_attribute_group_lang`.`id_attribute_group` 
  WHERE      
     `ps_attribute_group_lang`.`id_lang` =  var_id_lang AND 
     `ps_attribute_group_lang`.`name` = `tmp_product`.`attribute_group_name` ;

  UPDATE `tmp_product` , `ps_attribute`, `ps_attribute_lang` 
  SET  
     `tmp_product`.`id_attribute` = `ps_attribute_lang`.`id_attribute` 
  WHERE 
     `tmp_product`.`id_attribute_group` > 0 AND
     `tmp_product`.`id_attribute_group` = `ps_attribute`.`id_attribute_group` AND 
     `ps_attribute`.`id_attribute`       = `ps_attribute_lang`.`id_attribute` AND      
     `ps_attribute_lang`.`id_lang` =  1  AND
     LOWER(`ps_attribute_lang`.`name`) = LOWER(RIGHT(`tmp_product`.`name`, CHAR_LENGTH(`ps_attribute_lang`.`name`)));

  UPDATE `tmp_product` , `ps_attribute_lang` 
  SET 
    `tmp_product`.`name` = REPLACE(`tmp_product`.`name`, `ps_attribute_lang`.`name`, '')
  WHERE 
     `tmp_product`.`id_attribute` = `ps_attribute_lang`.`id_attribute` ;

  INSERT INTO `tmp_product_lang` ( 
    `id_product`,
    `id_shop`,
    `id_lang`,
    `description`, 
    `name`,
    `link_rewrite`,
    `caracteristiques`,
    `your_profile`,
    `avis_fitadium`,
    `composition`,
    `utilisation`,
    `precaution`)
  SELECT     
    `tmp_product`.`id_product`, 
     var_id_shop ,
     var_id_lang , 
     `tmp_product`.`name`, 
     `tmp_product`.`name`,
     LOWER(REPLACE(`tmp_product`.`name`,' ','-')),
     '',
     '',
     '',
     '',
     '',
     ''
  FROM 
    `tmp_product`
  GROUP BY 
    `tmp_product`.`id_product`, var_id_lang ;
    
  INSERT INTO `tmp_product_sale` (
    `id_product`,
    `quantity`,
    `sale_nbr`,
    `date_upd` )
  SELECT 
    `id_product`,
     SUM(`quantity`),
     COUNT(`id_product`),
     MAX(`date_add`) 
  FROM 
    `tmp_cart_product`
  GROUP BY 
    `id_product` ;
    
  UPDATE `tmp_product_sale`, `ps_product_sale` 
  SET 
    `tmp_product_sale`.`quantity_ex` = `ps_product_sale`.`quantity`, 
    `tmp_product_sale`.`sale_nbr_ex` = `ps_product_sale`.`sale_nbr`, 
    `tmp_product_sale`.`date_upd_ex` = `ps_product_sale`.`date_upd`
  WHERE 
    `tmp_product_sale`.`id_product` =  `ps_product_sale`.`id_product` ;
    
  UPDATE `tmp_product_sale` 
  SET `quantity` =  `quantity` + `quantity_ex` , 
      `sale_nbr` =  `sale_nbr` + `sale_nbr_ex` , 
      `date_upd` = GREATEST ( `date_upd` , `date_upd_ex`) ;
         
  INSERT `tmp_product_attribute` (  
    `id_product_attribute`,
    `id_product`,
    `price` ,
    `quantity`,
    `minimal_quantity`,
    `id_attribute`,
    `available_date` ) 
  SELECT 
    '0',
    `tmp_product`.`id_product`,
    '0.00',
    `tmp_product`.`quantity`,
    `tmp_product`.`minimal_quantity`, 
    `ps_attribute_lang`.`id_attribute`,
    `tmp_product`.`available_date` 
  FROM 
     `tmp_product`, `tmp_attribute_name` , `ps_attribute_lang`, `ps_attribute` 
  WHERE 
     `tmp_product`.`id_attribute_group` > 0 AND 
     `tmp_product`.`reference` =  `tmp_attribute_name`.`ref_commande` AND 
     `ps_attribute_lang`.`name` =  `tmp_attribute_name`.`attribute_name` AND 
     `ps_attribute_lang`.`id_lang` = var_id_lang AND 
      `ps_attribute`.`id_attribute` =  `ps_attribute_lang`.`id_attribute` AND
     `ps_attribute`.`id_attribute_group` =  `tmp_attribute_name`.`id_attribute_group` ;

  INSERT `tmp_product_attribute` (  
    `id_product_attribute`,
    `id_product`,
    `price` ,
    `quantity`,
    `minimal_quantity`,
    `id_attribute`,
    `available_date` ) 
  SELECT 
    '0',
    `tmp_existing_product`.`id_product`,
    '0.00',
    `tmp_existing_product`.`quantity`,
    `tmp_existing_product`.`minimal_quantity`, 
    `ps_attribute_lang`.`id_attribute`,
    `tmp_existing_product`.`available_date` 
  FROM 
     `tmp_existing_product`, `tmp_attribute_name` , `ps_attribute_lang`, `ps_attribute` 
  WHERE 
     `tmp_existing_product`.`reference` =  `tmp_attribute_name`.`ref_commande` AND 
     `ps_attribute_lang`.`name` =  `tmp_attribute_name`.`attribute_name` AND 
     `ps_attribute_lang`.`id_lang` = var_id_lang AND 
     `ps_attribute`.`id_attribute` =  `ps_attribute_lang`.`id_attribute` AND
     `ps_attribute`.`id_attribute_group` =  `tmp_attribute_name`.`id_attribute_group` ;

  DELETE `tmp_product_attribute`  
  FROM `tmp_product_attribute` , `ps_product_attribute` , `ps_product_attribute_combination`
  WHERE  
      `tmp_product_attribute`.`id_product` = `ps_product_attribute`.`id_product` AND 
      `ps_product_attribute`.`id_product_attribute` = `ps_product_attribute_combination`.`id_product_attribute`  AND 
      `tmp_product_attribute`.`id_attribute` = `ps_product_attribute_combination`.`id_attribute`;

  INSERT `tmp_product_attribute_ins` ( `id_auto_product_attribute`) SELECT `id_auto_product_attribute` FROM `tmp_product_attribute`;
  
  UPDATE `tmp_product_attribute`, `tmp_product_attribute_ins` 
  SET `tmp_product_attribute`.`id_auto_product_attribute_ins` = `tmp_product_attribute_ins`.`id_auto_product_attribute_ins`
  WHERE `tmp_product_attribute`. `id_auto_product_attribute` =  `tmp_product_attribute_ins`. `id_auto_product_attribute`;
      
   UPDATE `tmp_product_attribute`  
  SET 
    `tmp_product_attribute`.`id_product_attribute` = var_nb_product_attribute +  `tmp_product_attribute`.`id_auto_product_attribute_ins` ;  
   
  INSERT INTO `ps_product` (
    `id_product`, 
    `id_supplier`, 
    `id_manufacturer`, 
    `id_category_default`, 
    `id_shop_default`, 
    `id_tax_rules_group`, 
    `on_sale`, 
    `online_only`, 
    `ean13`, 
    `upc`, 
    `ecotax`, 
    `quantity`, 
    `minimal_quantity`, 
    `price`, 
    `wholesale_price`, 
    `unity`, 
    `unit_price_ratio`, 
    `additional_shipping_cost`, 
    `reference`, 
    `supplier_reference`, 
    `location`, 
    `width`, 
    `height`, 
    `depth`, 
    `weight`, 
    `out_of_stock`, 
    `quantity_discount`, 
    `customizable`, 
    `uploadable_files`, 
    `text_fields`, 
    `active`, 
    `redirect_type`, 
    `id_product_redirected`, 
    `available_for_order`, 
    `available_date`, 
    `condition`, 
    `show_price`, 
    `indexed`, 
    `visibility`, 
    `cache_is_pack`, 
    `cache_has_attachments`, 
    `is_virtual`, 
    `cache_default_attribute`, 
    `date_add`, 
    `date_upd`, 
    `advanced_stock_management`,
    `is_bundle`, 
    `single_price`) 
  SELECT 
    `id_product`, 
    `id_supplier`, 
    `id_manufacturer`, 
    `id_category_default`, 
    `id_shop_default`, 
    `id_tax_rules_group`, 
    `on_sale`, 
    `online_only`, 
    `ean13`, 
    `upc`, 
    `ecotax`, 
    `quantity`, 
    `minimal_quantity`, 
    `price`, 
    `wholesale_price`, 
    `unity`, 
    `unit_price_ratio`, 
    `additional_shipping_cost`, 
    `reference`, 
    `supplier_reference`, 
    `location`, 
    `width`, 
    `height`, 
    `depth`, 
    `weight`, 
    `out_of_stock`, 
    `quantity_discount`, 
    `customizable`, 
    `uploadable_files`, 
    `text_fields`, 
    `active`, 
    `redirect_type`, 
    `id_product_redirected`, 
    `available_for_order`, 
    `available_date`, 
    `condition`, 
    `show_price`, 
    `indexed`, 
    `visibility`, 
    `cache_is_pack`, 
    `cache_has_attachments`, 
    `is_virtual`, 
    `cache_default_attribute`, 
    `date_add`, 
    `date_upd`, 
    `advanced_stock_management`,
    `is_bundle`, 
    `single_price`
  FROM 
    `tmp_product` ;
     
  INSERT INTO `ps_product_lang` (
    `id_product` ,
    `id_shop`,
    `id_lang`,
    `description`,
    `description_short`,
    `link_rewrite`,
    `meta_description`,
    `meta_keywords`,
    `meta_title`,
    `name`,
    `available_now` ,
    `available_later`,
    `caracteristiques`,
    `your_profile`,
    `avis_fitadium`,
    `composition`,
    `utilisation`,
    `precaution`)
  SELECT 
    `id_product` ,
    `id_shop`,
    `id_lang`,
    `description`,
    `description_short`,
    `link_rewrite`,
    `meta_description`,
    `meta_keywords`,
    `meta_title`,
    `name`,
    `available_now` ,
    `available_later`, 
    `caracteristiques`,
    `your_profile`,
    `avis_fitadium`,
    `composition`,
    `utilisation`,
    `precaution`
  FROM 
     `tmp_product_lang` ;
    
  INSERT INTO `ps_cart_product` ( 
    `id_cart`,
    `id_product`,
    `id_address_delivery`,
    `id_shop`,
    `id_product_attribute`,
    `quantity`,
    `date_add` )
  SELECT  
    `id_cart`,
    `id_product`,
    `id_address_delivery`,
    `id_shop`,
    `id_product_attribute`,
    `quantity`,
    `date_add` 
  FROM 
    `tmp_cart_product` ;
  
  
   DELETE `ps_product_sale` 
   FROM `ps_product_sale`, `tmp_product_sale`  
   WHERE `ps_product_sale`.`id_product` =  `tmp_product_sale`.`id_product` ; 
   
   INSERT INTO `ps_product_sale` ( 
    `id_product`,
    `quantity`,
    `sale_nbr`,
    `date_upd` )
  SELECT  
    `id_product`,
    `quantity`,
    `sale_nbr`,
    `date_upd` 
  FROM 
    `tmp_product_sale`; 
    
  INSERT INTO `ps_product_shop` (   
    `id_product` ,
    `id_shop` ,
    `id_category_default` ,
    `id_tax_rules_group` ,
    `price` ,
    `available_date` ,
    `date_add` ,
    `date_upd` ,
    `cache_default_attribute`) 
  SELECT 
    `id_product` ,
    `id_shop_default` ,
    `id_category_default` ,
    '1' ,
    `price`  ,
    `available_date` ,
    `date_add` ,
    `date_upd`,
    '0' 
  FROM 
    `tmp_product` ;
    
  SET  var_id_max_position = (
    SELECT MAX(position)
    FROM `ps_category_product`
    WHERE `ps_category_product`.`id_category` = var_id_default_category
  );
    
  INSERT `ps_category_product` (
    `id_category` ,
    `id_product` ,
    `position` ) 
  SELECT 
     `id_category_default` , 
     `id_product`, 
     `id_auto_product` +  var_id_max_position
  FROM 
     `tmp_product` ; 
     
  INSERT INTO `ps_product_attribute` (
      `id_product_attribute`, 
      `id_product`, 
      `reference`, 
      `supplier_reference`, 
      `location`, 
      `ean13`, 
      `upc`, 
      `wholesale_price`, 
      `price`, 
      `ecotax`, 
      `quantity`, 
      `weight`, 
      `unit_price_impact`, 
      `default_on`, 
      `minimal_quantity`, 
      `available_date`
    ) SELECT 
      `id_product_attribute`, 
      `id_product`, 
      `reference`, 
      `supplier_reference`, 
      `location`, 
      `ean13`, 
      `upc`, 
      `wholesale_price`, 
      '0.00', 
      `ecotax`, 
      `quantity`, 
      `weight`, 
      `unit_price_impact`, 
      `default_on`, 
      `minimal_quantity`, 
      `available_date`    
    FROM 
      `tmp_product_attribute` ;
      
    INSERT INTO `ps_product_attribute_combination` (`id_attribute`, `id_product_attribute`)
    SELECT `id_attribute`,`id_product_attribute`    
    FROM   `tmp_product_attribute`  ;
    
    INSERT INTO `ps_product_attribute_shop` (`id_product_attribute`, `id_shop`, `wholesale_price`, `price`, `ecotax`, `weight`, `unit_price_impact`, `default_on`, `minimal_quantity`, `available_date`) 
    SELECT`id_product_attribute`, var_id_shop , `wholesale_price`, `price`, `ecotax`, `weight`, `unit_price_impact`, `default_on`, `minimal_quantity`, `available_date`
    FROM  `tmp_product_attribute` ;

END $$   
