DROP PROCEDURE IF EXISTS `pr_create_transco_tables` $$
CREATE PROCEDURE `pr_create_transco_tables`()
    MODIFIES SQL DATA
    SQL SECURITY INVOKER
BEGIN
  DROP TABLE IF EXISTS `tmp_transco_statuts`;
  CREATE TABLE IF NOT EXISTS `tmp_transco_statuts` (
    `etat_cmd` varchar(9) DEFAULT NULL,
    `etat_regl` varchar(9) DEFAULT NULL,
    `etat_livraison` varchar(34) DEFAULT NULL,
    `test_chq` int not null DEFAULT '0',       
    `statut_prestashop` int not null DEFAULT '30' 
  );
  
  insert `tmp_transco_statuts` ( `etat_regl`, `etat_cmd`, `etat_livraison`,`test_chq`,  `statut_prestashop`) 
  VALUES ('A valider', 	'A valider', '', '1',	21 );
  insert `tmp_transco_statuts` ( `etat_regl`, `etat_cmd`, `etat_livraison`, `statut_prestashop`) 
  VALUES ('A valider', 	'A valider', '',	30 );
  insert `tmp_transco_statuts` ( `etat_regl`, `etat_cmd`, `etat_livraison`, `statut_prestashop`) 
  VALUES ('Anomalie',	'A valider','',		25  ); 
  insert `tmp_transco_statuts` ( `etat_regl`, `etat_cmd`, `etat_livraison`, `statut_prestashop`) 
  VALUES ('Refusée',	'A valider','',		30 );
  insert `tmp_transco_statuts` ( `etat_regl`, `etat_cmd`, `etat_livraison`, `statut_prestashop`) 
  VALUES ('Validée',	'A valider','',		2 ); 
  insert `tmp_transco_statuts` ( `etat_regl`, `etat_cmd`, `etat_livraison`, `statut_prestashop`) 
  VALUES ('A valider',	'Anomalie','',		25 ); 
  insert `tmp_transco_statuts` ( `etat_regl`, `etat_cmd`, `etat_livraison`, `statut_prestashop`) 
  VALUES ('Anomalie',	'Anomalie','',		25 ); 
  insert `tmp_transco_statuts` ( `etat_regl`, `etat_cmd`, `etat_livraison`, `statut_prestashop`) 
  VALUES ('Refusée',	'Anomalie','',		25 ) ;
  insert `tmp_transco_statuts` ( `etat_regl`, `etat_cmd`, `etat_livraison`, `statut_prestashop`) 
  VALUES ('Validée',	'Anomalie','',		25 ) ;
  insert `tmp_transco_statuts` ( `etat_regl`, `etat_cmd`, `etat_livraison`, `statut_prestashop`) 
  VALUES ('A valider',	'Refusé','',		26 ) ;
  insert `tmp_transco_statuts` ( `etat_regl`, `etat_cmd`, `etat_livraison`, `statut_prestashop`) 
  VALUES ('Anomalie',	'Refusé','',		26 ) ;
  insert `tmp_transco_statuts` ( `etat_regl`, `etat_cmd`, `etat_livraison`, `statut_prestashop`) 
  VALUES ('Refusée',	'Refusé','',		26 ); 
  insert `tmp_transco_statuts` ( `etat_regl`, `etat_cmd`, `etat_livraison`, `statut_prestashop`) 
  VALUES ('Validée',	'Refusé','',		26 ); 
  insert `tmp_transco_statuts` ( `etat_regl`, `etat_cmd`, `etat_livraison`, `statut_prestashop`) 
  VALUES ('A valider',	'Validé','',		6 ) ;
  insert `tmp_transco_statuts` ( `etat_regl`, `etat_cmd`, `etat_livraison`, `statut_prestashop`) 
  VALUES ('A valider',	'Validé', 	'A expédier',	25 );
  insert `tmp_transco_statuts` ( `etat_regl`, `etat_cmd`, `etat_livraison`, `statut_prestashop`) 
  VALUES ('A valider',	'Validé', 	'Expédiée / Disponible en magasin', 4 ); 
  insert `tmp_transco_statuts` ( `etat_regl`, `etat_cmd`, `etat_livraison`, `statut_prestashop`) 
  VALUES ('A valider',	'Validé', 	'Anomalie' , 	25 );
  insert `tmp_transco_statuts` ( `etat_regl`, `etat_cmd`, `etat_livraison`, `statut_prestashop`) 
  VALUES ('Anomalie',	'Validé','',		6 );
  insert `tmp_transco_statuts` ( `etat_regl`, `etat_cmd`, `etat_livraison`, `statut_prestashop`) 
  VALUES ('Anomalie',	'Validé', 	'A expédier' , 	25 ); 
  insert `tmp_transco_statuts` ( `etat_regl`, `etat_cmd`, `etat_livraison`, `statut_prestashop`) 
  VALUES ('Anomalie',	'Validé', 	'Expédiée / Disponible en magasin' , 25 ); 
  insert `tmp_transco_statuts` ( `etat_regl`, `etat_cmd`, `etat_livraison`, `statut_prestashop`) 
  VALUES ('Anomalie',	'Validé', 	'Anomalie' , 	25 );  
  insert `tmp_transco_statuts` ( `etat_regl`, `etat_cmd`, `etat_livraison`, `statut_prestashop`) 
  VALUES ('Refusée',	'Validé','',		6 ); 
  insert `tmp_transco_statuts` ( `etat_regl`, `etat_cmd`, `etat_livraison`, `statut_prestashop`) 
  VALUES ('Refusée',	'Validé', 'A expédier' ,25  ); 
  insert `tmp_transco_statuts` ( `etat_regl`, `etat_cmd`, `etat_livraison`, `statut_prestashop`) 
  VALUES ('Refusée',	'Validé', 'Expédiée / Disponible en magasin' , 	25 ); 
  insert `tmp_transco_statuts` ( `etat_regl`, `etat_cmd`, `etat_livraison`, `statut_prestashop`) 
  VALUES ('Refusée',	'Validé', 'Anomalie' , 	25 ); 
  insert `tmp_transco_statuts` ( `etat_regl`, `etat_cmd`, `etat_livraison`, `statut_prestashop`) 
  VALUES ('Validée',	'Validé','',		14 ); 
  insert `tmp_transco_statuts` ( `etat_regl`, `etat_cmd`, `etat_livraison`, `statut_prestashop`) 
  VALUES ('Validée',	'Validé', 'A expédier' , 	27 ); 
  insert `tmp_transco_statuts` ( `etat_regl`, `etat_cmd`, `etat_livraison`, `statut_prestashop`) 
  VALUES ('Validée',	'Validé', 'Expédiée / Disponible en magasin' , 	4 ); 
  insert `tmp_transco_statuts` ( `etat_regl`, `etat_cmd`, `etat_livraison`, `statut_prestashop`) 
  VALUES ('Validée',	'Validé', 'Anomalie', 25 );

END $$

CALL pr_create_transco_tables() $$ 
