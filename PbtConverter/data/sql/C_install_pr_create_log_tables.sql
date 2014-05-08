DROP PROCEDURE IF EXISTS `pr_create_log_tables` $$
CREATE PROCEDURE `pr_create_log_tables`()
    MODIFIES SQL DATA
    SQL SECURITY INVOKER
BEGIN

CREATE TABLE IF NOT EXISTS `tmp_import_table_list` (
  `table_name` varchar(50) NOT NULL,
  `field_name` varchar(50) NOT NULL,
   PRIMARY KEY (`table_name`) 
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

TRUNCATE TABLE `tmp_import_table_list`;
INSERT INTO `tmp_import_table_list`(`table_name`,`field_name`) VALUES ('ps_cart','id_cart');
INSERT INTO `tmp_import_table_list`(`table_name`,`field_name`) VALUES ('ps_order_detail','id_order_detail');
INSERT INTO `tmp_import_table_list`(`table_name`,`field_name`) VALUES ('ps_order_history','id_order_history');
INSERT INTO `tmp_import_table_list`(`table_name`,`field_name`) VALUES ('ps_order_payment','id_order_payment');
INSERT INTO `tmp_import_table_list`(`table_name`,`field_name`) VALUES ('ps_order_invoice','id_order_invoice');
INSERT INTO `tmp_import_table_list`(`table_name`,`field_name`) VALUES ('ps_order_carrier','id_order_carrier');
INSERT INTO `tmp_import_table_list`(`table_name`,`field_name`) VALUES ('ps_orders','id_order');
INSERT INTO `tmp_import_table_list`(`table_name`,`field_name`) VALUES ('ps_product','id_product');
INSERT INTO `tmp_import_table_list`(`table_name`,`field_name`) VALUES ('ps_product_attribute','id_product_attribute');
INSERT INTO `tmp_import_table_list`(`table_name`,`field_name`) VALUES ('ps_address','id_address');
INSERT INTO `tmp_import_table_list`(`table_name`,`field_name`) VALUES ('ps_customer','id_customer');
INSERT INTO `tmp_import_table_list`(`table_name`,`field_name`) VALUES ('ps_attribute_group','id_attribute_group');
INSERT INTO `tmp_import_table_list`(`table_name`,`field_name`) VALUES ('ps_attribute','id_attribute');
 

CREATE TABLE IF NOT EXISTS `tmp_import_log` (
  `id_import_log` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `import_date` datetime NOT NULL,
  `user` varchar(128) NOT NULL,
  `database` varchar(127) NOT NULL,
  `is_last` tinyint NOT NULL DEFAULT '0',
  `deleted` tinyint NOT NULL DEFAULT '0',
   PRIMARY KEY (`id_import_log`), 
   KEY (`import_date`) 
) ENGINE=InnoDB DEFAULT CHARSET=utf8;


CREATE TABLE IF NOT EXISTS `tmp_import_log_detail` (
  `id_import_log` int NOT NULL,
  `table_name` varchar(50) NOT NULL,
  `field_name` varchar(50) NOT NULL,
  `value_before` int,
  `value_after` int,
  `rows_before` int,
  `rows_after` int,
   PRIMARY KEY (`id_import_log`,`table_name`, `field_name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

END $$

CALL pr_create_log_tables() $$ 
