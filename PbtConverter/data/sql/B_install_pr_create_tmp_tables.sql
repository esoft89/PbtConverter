DROP PROCEDURE IF EXISTS `pr_create_tmp_tables` $$
CREATE PROCEDURE `pr_create_tmp_tables`()
    MODIFIES SQL DATA
    SQL SECURITY INVOKER
BEGIN

DROP TABLE IF EXISTS `tmp_param`;
CREATE TABLE IF NOT EXISTS `tmp_param` (
  `name` varchar(50) NOT NULL,
  `value` varchar(255) NOT NULL,
   PRIMARY KEY (`name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

DROP TABLE IF EXISTS `tmp_order_detail_tax`;
CREATE TABLE IF NOT EXISTS `tmp_order_detail_tax` (
  `id_order_detail` int(11) NOT NULL,
  `id_tax` int(11) NOT NULL,
  `unit_amount` decimal(16,6) NOT NULL DEFAULT '0.000000',
  `total_amount` decimal(16,6) NOT NULL DEFAULT '0.000000' ,
  `tax_rate` decimal(10,3) NOT NULL DEFAULT '0.000',
   PRIMARY KEY (`id_order_detail`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

DROP TABLE IF EXISTS `tmp_order_invoice_tax`;
CREATE TABLE IF NOT EXISTS `tmp_order_invoice_tax` (
  `id_order_invoice` int(11) NOT NULL,
  `type` varchar(15) NOT NULL,
  `id_tax` int(11) NOT NULL,
  `amount` decimal(10,6) NOT NULL DEFAULT '0.000000',
  `tax_rate` decimal(10,3) NOT NULL DEFAULT '0.000',
   PRIMARY KEY (`id_order_invoice`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

DROP TABLE IF EXISTS `tmp_attribute_group`;
CREATE TABLE IF NOT EXISTS `tmp_attribute_group` (
  `id_auto_attribute_group` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `id_attribute_group` int(10) unsigned NOT NULL,
  `id_lang` int(10) unsigned NOT NULL,
  `id_shop` int(11) unsigned NOT NULL,
  `is_color_group` tinyint(1) NOT NULL DEFAULT '0',
  `group_type` enum('select','radio','color') NOT NULL DEFAULT 'select',
  `position` int(10) unsigned NOT NULL DEFAULT '0',
  `name` varchar(128) NOT NULL,
  `public_name` varchar(64) NOT NULL,
  PRIMARY KEY (`id_auto_attribute_group`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 ;

DROP TABLE IF EXISTS `tmp_attribute_list`;
CREATE TABLE IF NOT EXISTS `tmp_attribute_list` (
  `ref_commande` varchar(12) NOT NULL DEFAULT '',
  `id_attribute_group` int(10) unsigned NOT NULL,
  `group_name` varchar(128) NOT NULL,
  `attribute_list` varchar(255) NOT NULL,
  KEY (`id_attribute_group`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 ;

DROP TABLE IF EXISTS `tmp_attribute_name`;
CREATE TABLE IF NOT EXISTS `tmp_attribute_name` (
  `ref_commande` varchar(12) NOT NULL DEFAULT '',
  `id_attribute_group` int(10) unsigned NOT NULL,
  `group_name` varchar(128) NOT NULL,
  `attribute_name` varchar(255) NOT NULL,
  `existing_attribute` int(10) NOT NULL DEFAULT '0',
  KEY (`id_attribute_group`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 ;

DROP TABLE IF EXISTS `tmp_attribute`;
CREATE TABLE IF NOT EXISTS `tmp_attribute` (
  `id_auto_attribute` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `id_attribute` int(10) unsigned NOT NULL,
  `id_attribute_group` int(10) unsigned NOT NULL,
  `id_shop` int(11) unsigned NOT NULL,
  `id_lang` int(10) unsigned NOT NULL,
  `name` varchar(128) NOT NULL,
  `color` varchar(32) DEFAULT NULL,
  `min_auto_attribute_in_group`  int(10) unsigned NOT NULL DEFAULT '0',
  `position` int(10) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`id_auto_attribute`),
  KEY `attribute_group` (`id_attribute`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 ;

DROP TABLE IF EXISTS `tmp_product_attribute_ins`;
CREATE TABLE IF NOT EXISTS `tmp_product_attribute_ins` (  
  `id_auto_product_attribute_ins` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `id_auto_product_attribute` int(10) unsigned NOT NULL,
  PRIMARY KEY (`id_auto_product_attribute_ins`),
  KEY  (`id_auto_product_attribute`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8;

DROP TABLE IF EXISTS `tmp_product_attribute`;
CREATE TABLE IF NOT EXISTS `tmp_product_attribute` (  
  `id_auto_product_attribute` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `id_auto_product_attribute_ins` int(10) unsigned NOT NULL DEFAULT '0',
  `id_product_attribute` int(10) unsigned NOT NULL,
  `id_product` int(10) unsigned NOT NULL,
  `reference` varchar(32) DEFAULT NULL,
  `supplier_reference` varchar(32) DEFAULT NULL,
  `location` varchar(64) DEFAULT NULL,
  `ean13` varchar(13) DEFAULT NULL,
  `upc` varchar(12) DEFAULT NULL,
  `wholesale_price` decimal(20,6) NOT NULL DEFAULT '0.000000',
  `price` decimal(20,6) NOT NULL DEFAULT '0.000000',
  `ecotax` decimal(17,6) NOT NULL DEFAULT '0.000000',
  `quantity` int(10) NOT NULL DEFAULT '0',
  `weight` decimal(20,6) NOT NULL DEFAULT '0.000000',
  `unit_price_impact` decimal(17,2) NOT NULL DEFAULT '0.00',
  `default_on` tinyint(1) unsigned NOT NULL DEFAULT '0',
  `minimal_quantity` int(10) unsigned NOT NULL DEFAULT '1',
  `available_date` date NOT NULL,
  `id_attribute` int NOT NULL DEFAULT '0',
  PRIMARY KEY (`id_auto_product_attribute`),
  KEY  (`id_product_attribute`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8;

DROP TABLE IF EXISTS `tmp_cart`;
CREATE TABLE IF NOT EXISTS `tmp_cart` (
  `id_auto_cart` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `ref_commande` varchar(12) NOT NULL DEFAULT '',
  `id_cart` int(10) unsigned NOT NULL DEFAULT '0',
  `id_currency` int(10) unsigned NOT NULL DEFAULT '0',
  `id_shop_group` int(11) unsigned NOT NULL DEFAULT '1',
  `id_shop` int(11) unsigned NOT NULL DEFAULT '1',
  `id_carrier` int(10) unsigned NOT NULL DEFAULT '1',
  `id_lang` int(10) unsigned NOT NULL DEFAULT '1',
  `id_customer` int(10) unsigned NOT NULL DEFAULT '0',
  `id_address_delivery` int(10) unsigned NOT NULL DEFAULT '0',
  `id_address_invoice` int(10) unsigned NOT NULL DEFAULT '0',
  `delivery_option` text,
  `id_guest` int(10) unsigned NOT NULL DEFAULT '0',
  `secure_key` varchar(32) NOT NULL DEFAULT '-1',
  `recyclable` tinyint(1) unsigned NOT NULL DEFAULT '0',
  `gift` tinyint(1) unsigned NOT NULL DEFAULT '0',
  `gift_message` text,
  `mobile_theme` tinyint(1) NOT NULL DEFAULT '0',
  `allow_seperated_package` tinyint(1) unsigned NOT NULL DEFAULT '0',
  `date_add` datetime NOT NULL,
  `date_upd` datetime NOT NULL, 
   PRIMARY KEY (`id_auto_cart`),
   KEY (`ref_commande`), 
   KEY (`id_cart`) 
) ENGINE=InnoDB  DEFAULT CHARSET=utf8;

DROP TABLE IF EXISTS `tmp_product_sale`;
CREATE TABLE IF NOT EXISTS `tmp_product_sale` (
  `id_product` int(10) unsigned NOT NULL,
  `quantity` int(10) unsigned NOT NULL DEFAULT '0',
  `sale_nbr` int(10) unsigned NOT NULL DEFAULT '0',
  `date_upd` date NOT NULL,
  `quantity_ex` int(10) unsigned NOT NULL DEFAULT '0',
  `sale_nbr_ex` int(10) unsigned NOT NULL DEFAULT '0',
  `date_upd_ex` date NOT NULL DEFAULT '1900-01-01',
  PRIMARY KEY (`id_product`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

DROP TABLE IF EXISTS `tmp_cart_product`;
CREATE TABLE IF NOT EXISTS `tmp_cart_product` (
  `id_auto_cart_product` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `id_cart` int(10) unsigned NOT NULL,
  `ref_commande` varchar(12) NOT NULL,
  `ref_produit` varchar(12) NOT NULL,
  `id_product` int(10) unsigned NOT NULL DEFAULT '0',
  `id_address_delivery` int(10) unsigned DEFAULT '0',
  `id_shop` int(10) unsigned NOT NULL DEFAULT '1',
  `id_product_attribute` int(10) unsigned DEFAULT NULL,
  `quantity` int(10) unsigned NOT NULL DEFAULT '0',
  `date_add` datetime NOT NULL,
  PRIMARY KEY (`id_auto_cart_product`),
  KEY (`id_product`),
  KEY (`id_cart`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

/* Creation de produits fictif desactivés pour les produits non référencés */
DROP TABLE IF EXISTS `tmp_product` ;
CREATE TABLE IF NOT EXISTS `tmp_product` (
  `id_auto_product` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `id_product` int(10) unsigned NOT NULL DEFAULT '0',
  `id_supplier` int(10) unsigned DEFAULT NULL,
  `id_manufacturer` int(10) unsigned DEFAULT NULL,
  `id_category_default` int(10) unsigned DEFAULT NULL,
  `id_shop_default` int(10) unsigned NOT NULL DEFAULT '1',
  `id_tax_rules_group` int(11) unsigned NOT NULL DEFAULT '1',
  `on_sale` tinyint(1) unsigned NOT NULL DEFAULT '0',
  `online_only` tinyint(1) unsigned NOT NULL DEFAULT '0',
  `ean13` varchar(13) DEFAULT NULL,
  `upc` varchar(12) DEFAULT NULL,
  `ecotax` decimal(17,6) NOT NULL DEFAULT '0.000000',
  `quantity` int(10) NOT NULL DEFAULT '0',
  `minimal_quantity` int(10) unsigned NOT NULL DEFAULT '1',
  `price` decimal(20,6) NOT NULL DEFAULT '0.000000',
  `wholesale_price` decimal(20,6) NOT NULL DEFAULT '0.000000',
  `unity` varchar(255) DEFAULT NULL,
  `unit_price_ratio` decimal(20,6) NOT NULL DEFAULT '0.000000',
  `additional_shipping_cost` decimal(20,2) NOT NULL DEFAULT '0.00',
  `reference` varchar(32) NOT NULL,
  `supplier_reference` varchar(32) DEFAULT NULL ,
  `location` varchar(64) DEFAULT NULL,
  `width` decimal(20,6) NOT NULL DEFAULT '0.000000',
  `height` decimal(20,6) NOT NULL DEFAULT '0.000000',
  `depth` decimal(20,6) NOT NULL DEFAULT '0.000000',
  `weight` decimal(20,6) NOT NULL DEFAULT '0.000000',
  `out_of_stock` int(10) unsigned NOT NULL DEFAULT '2',
  `quantity_discount` tinyint(1) DEFAULT '0',
  `customizable` tinyint(2) NOT NULL DEFAULT '0',
  `uploadable_files` tinyint(4) NOT NULL DEFAULT '0',
  `text_fields` tinyint(4) NOT NULL DEFAULT '0',
  `active` tinyint(1) unsigned NOT NULL DEFAULT '1',
  `redirect_type` enum('','404','301','302') NOT NULL DEFAULT '',
  `id_product_redirected` int(10) unsigned NOT NULL DEFAULT '0',
  `available_for_order` tinyint(1) NOT NULL DEFAULT '1',
  `available_date` date NOT NULL,
  `condition` enum('new','used','refurbished') NOT NULL DEFAULT 'new',
  `show_price` tinyint(1) NOT NULL DEFAULT '1',
  `indexed` tinyint(1) NOT NULL DEFAULT '0',
  `visibility` enum('both','catalog','search','none') NOT NULL DEFAULT 'both',
  `cache_is_pack` tinyint(1) NOT NULL DEFAULT '0',
  `cache_has_attachments` tinyint(1) NOT NULL DEFAULT '0',
  `is_virtual` tinyint(1) NOT NULL DEFAULT '0',
  `cache_default_attribute` int(10) unsigned DEFAULT NULL,
  `date_add` datetime NOT NULL,
  `date_upd` datetime NOT NULL,
  `advanced_stock_management` tinyint(1) NOT NULL DEFAULT '0',
  `attribute_group_name` varchar(128) NOT NULL DEFAULT '',
  `id_attribute_group` int NOT NULL DEFAULT '0', 
  `id_attribute` int NOT NULL DEFAULT '0', 
  `name` varchar(128) NOT NULL DEFAULT '',
  `is_bundle` tinyint(1) NOT NULL DEFAULT '0',
  `single_price` tinyint(1) NOT NULL DEFAULT '0',
  
  PRIMARY KEY (`id_auto_product`),
  KEY (`id_product`),
  KEY (`reference`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 ;

DROP TABLE IF EXISTS `tmp_existing_product` ;
CREATE TABLE IF NOT EXISTS `tmp_existing_product` (
  `id_product` int(10) unsigned NOT NULL DEFAULT '0',
  `quantity` int(10) NOT NULL DEFAULT '0',
  `minimal_quantity` int(10) unsigned NOT NULL DEFAULT '1',
  `price` decimal(20,6) NOT NULL DEFAULT '0.000000',
  `available_date` date NOT NULL,
  `id_attribute` int NOT NULL DEFAULT '0',
  `reference` varchar(32) NOT NULL,
  PRIMARY KEY (`id_product`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 ;

                    
DROP TABLE IF EXISTS `tmp_product_lang`; 
CREATE TABLE IF NOT EXISTS `tmp_product_lang` (
  `id_product` int(10) unsigned NOT NULL,
  `id_shop` int(11) unsigned NOT NULL DEFAULT '1',
  `id_lang` int(10) unsigned NOT NULL,
  `description` text,
  `description_short` text,
  `link_rewrite` varchar(128) NOT NULL,
  `meta_description` varchar(255) DEFAULT NULL,
  `meta_keywords` varchar(255) DEFAULT NULL,
  `meta_title` varchar(128) DEFAULT NULL,
  `name` varchar(128) NOT NULL,
  `available_now` varchar(255) DEFAULT NULL,
  `available_later` varchar(255) DEFAULT NULL,
  `caracteristiques` text,
  `your_profile` text, 
  `avis_fitadium` text,
  `composition` text,
  `utilisation` text,
  `precaution` text,
  PRIMARY KEY (`id_product`,`id_shop`,`id_lang`),
  KEY `id_lang` (`id_lang`),
  KEY `name` (`name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

DROP TABLE IF EXISTS `tmp_order_detail`;
CREATE TABLE IF NOT EXISTS `tmp_order_detail` (
  `id_auto_order_detail` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `id_order_detail` int(10) unsigned NOT NULL DEFAULT '0',
  `id_order` int(10) unsigned NOT NULL DEFAULT '0',
  `id_order_invoice` int(11) DEFAULT NULL,
  `id_warehouse` int(10) unsigned DEFAULT '0',
  `id_shop` int(11) unsigned NOT NULL,
  `product_id` int(10) unsigned NOT NULL,
  `product_attribute_id` int(10) unsigned DEFAULT NULL,
  `product_name` varchar(255) NOT NULL,
  `product_quantity` int(10) unsigned NOT NULL DEFAULT '0',
  `product_quantity_in_stock` int(10) NOT NULL DEFAULT '0',
  `product_quantity_refunded` int(10) unsigned NOT NULL DEFAULT '0',
  `product_quantity_return` int(10) unsigned NOT NULL DEFAULT '0',
  `product_quantity_reinjected` int(10) unsigned NOT NULL DEFAULT '0',
  `product_price` decimal(20,6) NOT NULL DEFAULT '0.000000',
  `reduction_percent` decimal(10,2) NOT NULL DEFAULT '0.00',
  `reduction_amount` decimal(20,6) NOT NULL DEFAULT '0.000000',
  `reduction_amount_tax_incl` decimal(20,6) NOT NULL DEFAULT '0.000000',
  `reduction_amount_tax_excl` decimal(20,6) NOT NULL DEFAULT '0.000000',
  `group_reduction` decimal(10,2) NOT NULL DEFAULT '0.00',
  `product_quantity_discount` decimal(20,6) NOT NULL DEFAULT '0.000000',
  `product_ean13` varchar(13) DEFAULT NULL,
  `product_upc` varchar(12) DEFAULT NULL,
  `product_reference` varchar(32) DEFAULT NULL,
  `product_supplier_reference` varchar(32) DEFAULT NULL,
  `product_weight` decimal(20,6) NOT NULL,
  `tax_computation_method` tinyint(1) unsigned NOT NULL DEFAULT '0',
  `tax_name` varchar(16) NOT NULL DEFAULT '',
  `tax_rate` decimal(10,3) NOT NULL DEFAULT '0.000',
  `ecotax` decimal(21,6) NOT NULL DEFAULT '0.000000',
  `ecotax_tax_rate` decimal(5,3) NOT NULL DEFAULT '0.000',
  `discount_quantity_applied` tinyint(1) NOT NULL DEFAULT '0',
  `download_hash` varchar(255) DEFAULT NULL,
  `download_nb` int(10) unsigned DEFAULT '0',
  `download_deadline` datetime DEFAULT NULL,
  `total_price_tax_incl` decimal(20,6) NOT NULL DEFAULT '0.000000',
  `total_price_tax_excl` decimal(20,6) NOT NULL DEFAULT '0.000000',
  `unit_price_tax_incl` decimal(20,6) NOT NULL DEFAULT '0.000000',
  `unit_price_tax_excl` decimal(20,6) NOT NULL DEFAULT '0.000000',
  `total_shipping_price_tax_incl` decimal(20,6) NOT NULL DEFAULT '0.000000',
  `total_shipping_price_tax_excl` decimal(20,6) NOT NULL DEFAULT '0.000000',
  `purchase_supplier_price` decimal(20,6) NOT NULL DEFAULT '0.000000',
  `original_product_price` decimal(20,6) NOT NULL DEFAULT '0.000000', 
  `product_tax_rate` decimal(10,3) NOT NULL DEFAULT '0.000',
  PRIMARY KEY (`id_auto_order_detail`),
  KEY (`id_order_detail`),
  KEY (`id_order`),
  KEY (`product_id`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 ;

DROP TABLE IF EXISTS `tmp_order_history`;
CREATE TABLE IF NOT EXISTS `tmp_order_history` (
  `id_auto_order_history` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `id_order_history` int(10) unsigned NOT NULL DEFAULT '0',
  `id_employee` int(10) unsigned NOT NULL,
  `id_order` int(10) unsigned NOT NULL,
  `id_order_state` int(10) unsigned NOT NULL,
  `date_add` datetime NOT NULL,
  PRIMARY KEY (`id_auto_order_history`) 
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 ;

DROP TABLE IF EXISTS `tmp_order_payment`;
CREATE TABLE IF NOT EXISTS `tmp_order_payment` (
  `id_auto_order_payment` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `id_order_payment` int(11) NOT NULL,
  `id_order` int(11) NOT NULL,
  `order_reference` varchar(9) DEFAULT NULL,
  `id_currency` int(10) unsigned NOT NULL,
  `amount` decimal(10,2) NOT NULL,
  `payment_method` varchar(255) NOT NULL,
  `conversion_rate` decimal(13,6) NOT NULL DEFAULT '1.000000',
  `transaction_id` varchar(254) DEFAULT NULL,
  `card_number` varchar(254) DEFAULT NULL,
  `card_brand` varchar(254) DEFAULT NULL,
  `card_expiration` char(7) DEFAULT NULL,
  `card_holder` varchar(254) DEFAULT NULL,
  `date_add` datetime NOT NULL,
  PRIMARY KEY (`id_auto_order_payment`),
  KEY (`id_order_payment`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 ;

DROP TABLE IF EXISTS `tmp_order_carrier`;
CREATE TABLE IF NOT EXISTS `tmp_order_carrier` (
  `id_auto_order_carrier` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `ref_commande` varchar(12) NOT NULL DEFAULT '',
  `id_order_carrier` int(11) NOT NULL,
  `id_order` int(11) unsigned NOT NULL,
  `id_carrier` int(11) unsigned NOT NULL DEFAULT '0',
  `id_order_invoice` int(11) unsigned DEFAULT NULL,
  `weight` decimal(20,6) DEFAULT NULL,
  `shipping_cost_tax_excl` decimal(20,6) DEFAULT NULL,
  `shipping_cost_tax_incl` decimal(20,6) DEFAULT NULL,
  `tracking_number` varchar(64) DEFAULT NULL,
  `date_add` datetime DEFAULT NULL,
  PRIMARY KEY (`id_auto_order_carrier`),
  KEY (`id_order_carrier`) 
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 ;


DROP TABLE IF EXISTS `tmp_order_invoice`;
CREATE TABLE IF NOT EXISTS `tmp_order_invoice` (
  `id_auto_order_invoice` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `id_order_invoice` int(11) unsigned NOT NULL,
  `id_order` int(11) NOT NULL,
  `number` int(11) NOT NULL,
  `delivery_number` int(11) NOT NULL,
  `delivery_date` datetime DEFAULT NULL,
  `total_discount_tax_excl` decimal(17,2) NOT NULL DEFAULT '0.00',
  `total_discount_tax_incl` decimal(17,2) NOT NULL DEFAULT '0.00',
  `total_paid_tax_excl` decimal(17,2) NOT NULL DEFAULT '0.00',
  `total_paid_tax_incl` decimal(17,2) NOT NULL DEFAULT '0.00',
  `total_products` decimal(17,2) NOT NULL DEFAULT '0.00',
  `total_products_wt` decimal(17,2) NOT NULL DEFAULT '0.00',
  `total_shipping_tax_excl` decimal(17,2) NOT NULL DEFAULT '0.00',
  `total_shipping_tax_incl` decimal(17,2) NOT NULL DEFAULT '0.00',
  `shipping_tax_computation_method` int(10) unsigned NOT NULL,
  `total_wrapping_tax_excl` decimal(17,2) NOT NULL DEFAULT '0.00',
  `total_wrapping_tax_incl` decimal(17,2) NOT NULL DEFAULT '0.00',
  `note` text,
  `date_add` datetime NOT NULL,
  `carrier_tax_rate` decimal(10,3) NOT NULL DEFAULT '0.000',
  PRIMARY KEY (`id_auto_order_invoice`),
  KEY (`id_order_invoice`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8;

DROP TABLE IF EXISTS `tmp_orders_ins`;
CREATE TABLE IF NOT EXISTS `tmp_orders_ins` (
  `id_auto_order_ins` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `id_auto_order` int(10) unsigned NOT NULL,
  PRIMARY KEY (`id_auto_order_ins`),
  KEY (`id_auto_order`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8;

DROP TABLE IF EXISTS `tmp_orders`;
CREATE TABLE IF NOT EXISTS `tmp_orders` (
  `id_auto_order` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `id_auto_order_ins` int(10) unsigned NOT NULL DEFAULT '0',
  `id_order` int(10) unsigned NOT NULL DEFAULT '0',
  `ref_commande` varchar(12) NOT NULL DEFAULT '',
  `reference` varchar(9) DEFAULT NULL,
  `id_shop_group` int(11) unsigned NOT NULL DEFAULT '1',
  `id_shop` int(11) unsigned NOT NULL DEFAULT '1',
  `id_carrier` int(10) unsigned NOT NULL,
  `id_lang` int(10) unsigned NOT NULL,
  `id_customer` int(10) unsigned NOT NULL,
  `id_cart` int(10) unsigned NOT NULL,
  `id_currency` int(10) unsigned NOT NULL,
  `id_address_delivery` int(10) unsigned NOT NULL,
  `id_address_invoice` int(10) unsigned NOT NULL,
  `current_state` int(10) unsigned NOT NULL,
  `secure_key` varchar(32) NOT NULL DEFAULT '-1',
  `payment` varchar(255) NOT NULL,
  `conversion_rate` decimal(13,6) NOT NULL DEFAULT '1.000000',
  `module` varchar(255) DEFAULT NULL,
  `recyclable` tinyint(1) unsigned NOT NULL DEFAULT '0',
  `gift` tinyint(1) unsigned NOT NULL DEFAULT '0',
  `gift_message` text,
  `mobile_theme` tinyint(1) NOT NULL DEFAULT '0',
  `shipping_number` varchar(32) DEFAULT NULL,
  `total_discounts` decimal(17,2) NOT NULL DEFAULT '0.00',
  `total_discounts_tax_incl` decimal(17,2) NOT NULL DEFAULT '0.00',
  `total_discounts_tax_excl` decimal(17,2) NOT NULL DEFAULT '0.00',
  `total_paid` decimal(17,2) NOT NULL DEFAULT '0.00',
  `total_paid_tax_incl` decimal(17,2) NOT NULL DEFAULT '0.00',
  `total_paid_tax_excl` decimal(17,2) NOT NULL DEFAULT '0.00',
  `total_paid_real` decimal(17,2) NOT NULL DEFAULT '0.00',
  `total_products` decimal(17,2) NOT NULL DEFAULT '0.00',
  `total_products_wt` decimal(17,2) NOT NULL DEFAULT '0.00',
  `total_shipping` decimal(17,2) NOT NULL DEFAULT '0.00',
  `total_shipping_tax_incl` decimal(17,2) NOT NULL DEFAULT '0.00',
  `total_shipping_tax_excl` decimal(17,2) NOT NULL DEFAULT '0.00',
  `carrier_tax_rate` decimal(10,3) NOT NULL DEFAULT '0.000',
  `total_wrapping` decimal(17,2) NOT NULL DEFAULT '0.00',
  `total_wrapping_tax_incl` decimal(17,2) NOT NULL DEFAULT '0.00',
  `total_wrapping_tax_excl` decimal(17,2) NOT NULL DEFAULT '0.00',
  `invoice_number` int(10) unsigned NOT NULL DEFAULT '0',
  `delivery_number` int(10) unsigned NOT NULL DEFAULT '0',
  `invoice_date` datetime NOT NULL,
  `delivery_date` datetime NOT NULL,
  `valid` int(1) unsigned NOT NULL DEFAULT '0',
  `date_add` datetime NOT NULL,
  `date_upd` datetime NOT NULL,
  PRIMARY KEY (`id_auto_order`),
  KEY (`id_order`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8;

DROP TABLE IF EXISTS `tmp_order_product_price`;
CREATE TABLE IF NOT EXISTS `tmp_order_product_price` (
  `id_order` int(10) unsigned NOT NULL , 
  `product_price_tax_incl` decimal(20,6) NOT NULL DEFAULT '0.000000',
  `product_price_tax_excl` decimal(20,6) NOT NULL DEFAULT '0.000000',
  PRIMARY KEY (`id_order`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8;

DROP TABLE IF EXISTS `tmp_address_ins`;
CREATE TABLE IF NOT EXISTS `tmp_address_ins` (
  `id_auto_address_ins` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `id_auto_address` int(10) unsigned NOT NULL,
  PRIMARY KEY (`id_auto_address_ins`),
  KEY (`id_auto_address`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8;

DROP TABLE IF EXISTS `tmp_address`;
CREATE TABLE IF NOT EXISTS `tmp_address` (
  `id_auto_address` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `id_auto_address_ins` int(10) unsigned NOT NULL DEFAULT '0',
  `id_address` int(10) unsigned NOT NULL DEFAULT '0',
  `id_country` int(10) unsigned NOT NULL DEFAULT '0',
  `id_state` int(10) unsigned DEFAULT NULL,
  `id_customer` int(10) unsigned NOT NULL DEFAULT '0',
  `id_manufacturer` int(10) unsigned NOT NULL DEFAULT '0',
  `id_supplier` int(10) unsigned NOT NULL DEFAULT '0',
  `id_warehouse` int(10) unsigned NOT NULL DEFAULT '0',
  `email` varchar(128) NOT NULL DEFAULT '',
  `alias` varchar(32) NOT NULL DEFAULT '',
  `company` varchar(64) DEFAULT NULL DEFAULT '',
  `lastname` varchar(32) NOT NULL DEFAULT '',
  `firstname` varchar(32) NOT NULL DEFAULT '',
  `address1` varchar(128) NOT NULL DEFAULT '',
  `address2` varchar(128) DEFAULT NULL,
  `postcode` varchar(12) DEFAULT NULL,
  `city` varchar(64) NOT NULL DEFAULT '',
  `other` text,
  `phone` varchar(32) DEFAULT NULL,
  `phone_mobile` varchar(32) DEFAULT NULL,
  `vat_number` varchar(32) DEFAULT NULL,
  `dni` varchar(16) DEFAULT NULL,
  `date_add` datetime NOT NULL,
  `date_upd` datetime NOT NULL,
  `active` tinyint(1) unsigned NOT NULL DEFAULT '1',
  `deleted` tinyint(1) unsigned NOT NULL DEFAULT '0',
  `iso_pays` varchar(2) DEFAULT NULL,
  PRIMARY KEY (`id_auto_address`), 
  KEY (`id_address`), 
  KEY (`email`) 
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 ; 

DROP TABLE IF EXISTS `tmp_customer_ins`;
CREATE TABLE IF NOT EXISTS `tmp_customer_ins` (
  `id_auto_ins` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `id_auto_customer` int(10) unsigned NOT NULL,
  `id_customer` int(10) unsigned NOT NULL,
   PRIMARY KEY (`id_auto_ins`), 
   KEY (`id_auto_customer`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8;

DROP TABLE IF EXISTS `tmp_customer`;
CREATE TABLE IF NOT EXISTS `tmp_customer` (
  `id_auto` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `id_customer` int(10) unsigned NOT NULL,
  `id_shop_group` int(11) unsigned NOT NULL DEFAULT '1',
  `id_shop` int(11) unsigned NOT NULL DEFAULT '1',
  `id_gender` int(10) unsigned NOT NULL,
  `id_default_group` int(10) unsigned NOT NULL DEFAULT '1',
  `id_lang` int(10) unsigned DEFAULT NULL,
  `id_risk` int(10) unsigned NOT NULL DEFAULT '1',
  `company` varchar(64) DEFAULT NULL,
  `siret` varchar(14) DEFAULT NULL,
  `ape` varchar(5) DEFAULT NULL,
  `firstname` varchar(32) NOT NULL DEFAULT '',
  `lastname` varchar(32) NOT NULL  DEFAULT '',
  `email` varchar(128) NOT NULL DEFAULT '',
  `passwd` varchar(32) NOT NULL DEFAULT '',
  `last_passwd_gen` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `birthday` date DEFAULT NULL,
  `newsletter` tinyint(1) unsigned NOT NULL DEFAULT '0',
  `ip_registration_newsletter` varchar(15) DEFAULT NULL,
  `newsletter_date_add` datetime DEFAULT NULL,
  `optin` tinyint(1) unsigned NOT NULL DEFAULT '0',
  `website` varchar(128) DEFAULT NULL,
  `outstanding_allow_amount` decimal(20,6) NOT NULL DEFAULT '0.000000',
  `show_public_prices` tinyint(1) unsigned NOT NULL DEFAULT '0',
  `max_payment_days` int(10) unsigned NOT NULL DEFAULT '60',
  `secure_key` varchar(32) NOT NULL DEFAULT '-1',
  `note` text,
  `active` tinyint(1) unsigned NOT NULL DEFAULT '0',
  `is_guest` tinyint(1) NOT NULL DEFAULT '0',
  `deleted` tinyint(1) NOT NULL DEFAULT '0',
  `date_add` datetime NOT NULL,
  `date_upd` datetime NOT NULL,
  PRIMARY KEY (`id_auto`), 
  KEY (`id_customer`), 
  KEY (`email`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8;
END $$

CALL pr_create_tmp_tables() $$ 
