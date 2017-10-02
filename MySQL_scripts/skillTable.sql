CREATE TABLE `skill` (
  `idskill` int(11) NOT NULL AUTO_INCREMENT,
  `title` varchar(100) NOT NULL,
  `description` varchar(500) DEFAULT NULL,
  `super_skill` int(11) DEFAULT NULL,
  `sort_key` int(11) NOT NULL,
  PRIMARY KEY (`idskill`),
  KEY `FK_superskill_idx` (`super_skill`),
  CONSTRAINT `FK_superskill` FOREIGN KEY (`super_skill`) REFERENCES `skill` (`idskill`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB AUTO_INCREMENT=9 DEFAULT CHARSET=latin1