CREATE TABLE `skill` (
  `idskill` int(11) NOT NULL AUTO_INCREMENT,
  `super_skill` int(11) DEFAULT NULL,
  `sort_key` int(11) DEFAULT NULL,
  `title` varchar(100) NOT NULL,
  `short_desc` varchar(500) NOT NULL,
  `long_desc` varchar(2000) DEFAULT NULL,
  `icon_url` varchar(300) DEFAULT NULL,
  `photo_url` varchar(300) DEFAULT NULL,
  `video_url` varchar(300) DEFAULT NULL,
  `background_color` char(7) DEFAULT NULL,
  PRIMARY KEY (`idskill`)
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=utf8;
SELECT * FROM konapp.skill;