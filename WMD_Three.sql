CREATE TABLE `WMD_Three` (
  `uniqueID` varchar(25) NOT NULL DEFAULT '',
  `qid` varchar(45) DEFAULT NULL,
  `localID` int(11) NOT NULL DEFAULT '0',
  `title` text,
  `poster` varchar(50) DEFAULT NULL,
  `date` datetime DEFAULT NULL,
  `replyTo` varchar(25) DEFAULT NULL,
  `content` text,
  `forum` varchar(45) NOT NULL DEFAULT '',
  `creator` varchar(45) DEFAULT NULL,
  `row_type` int(10) unsigned zerofill DEFAULT '0000000000',
  `weight_in_minutes` decimal(11,2) DEFAULT '0.00',
  PRIMARY KEY (`uniqueID`,`forum`),
  KEY `select_localID` (`localID`) USING BTREE,
  KEY `select_creator` (`creator`),
  KEY `select_poster` (`poster`),
  KEY `select_qid` (`qid`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
