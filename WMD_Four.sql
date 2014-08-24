CREATE TABLE `WMD_Four` (
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
  `row_type` varchar(45) DEFAULT NULL DEFAULT 0,
  `weight_in_minutes` numeric(11,2) DEFAULT NULL DEFAULT 0,
  PRIMARY KEY (`uniqueID`,`forum`, `row_type`),
  KEY `select_localID` (`localID`) USING BTREE,
  KEY `select_creator` (`creator`),
  KEY `select_poster` (`poster`),
  KEY `select_qid` (`qid`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;