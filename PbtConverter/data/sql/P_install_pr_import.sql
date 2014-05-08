DROP PROCEDURE IF EXISTS `pr_import` $$
CREATE PROCEDURE `pr_import`()
    MODIFIES SQL DATA
    SQL SECURITY INVOKER
BEGIN
  CALL pr_start_import_log(); 
  CALL pr_import_product_attribute_group(); 
  CALL pr_import_product_attributes();
  CALL pr_customer() ; 
  CALL pr_address() ; 
  CALL pr_cart() ;
  CALL pr_cart_product(); 
  CALL pr_orders(); 
  CALL pr_order_invoice();
  CALL pr_order_payment();
  CALL pr_order_carrier();
  CALL pr_order_detail();
  CALL pr_stop_import_log();
END $$