DROP PROCEDURE IF EXISTS `pr_undo_import` $$
CREATE PROCEDURE `pr_undo_import`()
    MODIFIES SQL DATA
    SQL SECURITY INVOKER
BEGIN
  CALL pr_del_ps_tables();
  CALL pr_create_tmp_tables() ; 
END $$