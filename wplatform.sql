-- create database wplatform;

CREATE TABLE `usr` (
   `id` int(11) NOT NULL PRIMARY KEY AUTO_INCREMENT,
   `Name` varchar(255) NOT NULL,
   `pw` varchar(255) NOT NULL,
   `profile` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`profile`)),
   `state` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`state`)),
   `createdAt` timestamp NOT NULL DEFAULT current_timestamp(),
   `updatedAt` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
   KEY `Name` (`Name`),
   KEY `updatedAt` (`updatedAt`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

insert into usr ( Name, pw, profile, state)values
 ('m',md5('m'),'{"display":"mohjb","gender":"male","dob":"1973/04/07","tels":["99876454"],"emails":["mohamadjb@gmail.com"]}','{"active":1,"admin":1}')
,('u',md5('u'),'{"display":"user1"}','{"active":1}')
,('z',md5('z'),'{"display":"user1"}','');

CREATE TABLE `bank` (
    `id` int(11) NOT NULL PRIMARY KEY AUTO_INCREMENT,
    `Name` varchar(255) NOT NULL,
    `profile` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`profile`)),
    `state` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`state`)),
    `createdAt` timestamp NOT NULL DEFAULT current_timestamp(),
    `updatedAt` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
    KEY `Name` (`Name`),
    KEY `updatedAt` (`updatedAt`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

insert into bank ( Name, profile, state)values
('nbk','{"display":"NBK","address":{"county":"Kuwait"},"tels":["1801801"],"emails":[],"urls":["nbk.com.kw"]}','{}')
,('rain','{"display":"rain","address":{"county":"Bahrain"},"tels":["1"],"emails":[],"urls":["rain.bh"]}','{}');

CREATE TABLE `currency` (
    `id` int(11) NOT NULL PRIMARY KEY AUTO_INCREMENT,
    `Name` varchar(255) NOT NULL,
    `profile` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`profile`)),
    `state` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`state`)),
    `createdAt` timestamp NOT NULL DEFAULT current_timestamp(),
    `updatedAt` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
    KEY `Name` (`Name`),
    KEY `updatedAt` (`updatedAt`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

insert into `currency` ( Name, profile, state)values
('btc','{"display":"Bitcoin","address":{"type":"cryptocurrency"},"urls":["bitcoin.org"]}','{}')
,('kwd','{"display":"Kuwaiti Dinar","address":{"type":"fiat","county":"Kuwait"},"tels":["1"],"urls":[".kw"]}','{}');

CREATE TABLE `rate` (
    `id` int(11) NOT NULL PRIMARY KEY AUTO_INCREMENT,
    `Sell` int(11) NOT NULL,
    `Buy` int(11) NOT NULL,
    `Amount` decimal(50,30) NOT NULL,
    `profile` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`profile`)),
    `state` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`state`)),
    `createdAt` timestamp NOT NULL DEFAULT current_timestamp(),
    `updatedAt` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
    KEY `Sell` (`Sell`,`Buy`,`updatedAt`),
    KEY `Buy` (`Buy`,`Sell`,`updatedAt`),
    KEY `updatedAt` (`updatedAt`),
    CONSTRAINT `fk_buy` FOREIGN KEY (`Buy`) REFERENCES `currency` (`id`) ON DELETE CASCADE,
    CONSTRAINT `fk_sell` FOREIGN KEY (`Sell`) REFERENCES `currency` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

insert into `rate` ( sell, buy,amount,profile, state)values
(1,2,17500,'{"source":"test","time":"2021-05-13"}','{}')
,(2,1,0.00001,'{"source":"test","time":"2021-05-13"}','{}');

CREATE TABLE `account` (
   `id` int(11) NOT NULL PRIMARY KEY AUTO_INCREMENT,
   `Name` varchar(255) NOT NULL,
   `Uid` int(11) NOT NULL,
   `bankid` int(11) NOT NULL,
   `currencyId` int(11) NOT NULL,
   `profile` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`profile`)),
   `state` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`state`)),
   `createdAt` timestamp NOT NULL DEFAULT current_timestamp(),
   `updatedAt` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
   KEY `Uid` (`Uid`),
   KEY `bankid` (`bankid`,`Uid`),
   KEY `currencyId` (`currencyId`,`Uid`),
   KEY `updatedAt` (`updatedAt`),
   CONSTRAINT `fk_bank` FOREIGN KEY (`bankid`) REFERENCES `bank` (`id`) ON DELETE CASCADE,
   CONSTRAINT `fk_currency` FOREIGN KEY (`currencyId`) REFERENCES `currency` (`id`) ON DELETE CASCADE,
   CONSTRAINT `fk_uid` FOREIGN KEY (`Uid`) REFERENCES `usr` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `trans` (
 `id` int(11) NOT NULL PRIMARY KEY AUTO_INCREMENT,
 `srcAcc` int(11) NOT NULL,
 `dstAcc` int(11) NOT NULL,
 `Amount` decimal(10,0) NOT NULL,
 `Profile` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`Profile`)),
 `state` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`state`)),
 `createdAt` timestamp NOT NULL DEFAULT current_timestamp(),
 `updatedAt` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
 KEY `srcAcc` (`srcAcc`,`dstAcc`,`updatedAt`),
 KEY `dstAcc` (`dstAcc`,`srcAcc`,`updatedAt`),
 KEY `updatedAt` (`updatedAt`),
 CONSTRAINT `fk_dst` FOREIGN KEY (`dstAcc`) REFERENCES `account` (`id`) ON DELETE CASCADE,
 CONSTRAINT `fk_src` FOREIGN KEY (`srcAcc`) REFERENCES `account` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `msg` (
   `id` int(11) NOT NULL PRIMARY KEY AUTO_INCREMENT,
   `uid` int(11) NOT NULL,
   `toUsr` int(11) NOT NULL,
   `type` varchar(255) NOT NULL,
   `body` text NOT NULL,
   `profile` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`profile`)),
   `state` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`state`)),
   `createdAt` timestamp NOT NULL DEFAULT current_timestamp(),
   `updatedAt` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
   KEY `uid` (`uid`,`updatedAt`),
   KEY `toUsr` (`toUsr`,`updatedAt`),
   KEY `type` (`type`,`updatedAt`),
   KEY `updatedAt` (`updatedAt`),
   CONSTRAINT `fk_2u` FOREIGN KEY (`toUsr`) REFERENCES `usr` (`id`) ON DELETE CASCADE,
   CONSTRAINT `fk_msguid` FOREIGN KEY (`uid`) REFERENCES `usr` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `at` (
                      `id` int(11) NOT NULL PRIMARY KEY AUTO_INCREMENT,
                      `Tid` int(11) NOT NULL,
                      `tbl` enum('usr','bank','currency','account','rate','trans','msg','at') NOT NULL,
                      `type` varchar(255) NOT NULL,
                      `body` blob NOT NULL,
                      `profile` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`profile`)),
                      `state` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`state`)),
                      `createdAt` timestamp NOT NULL DEFAULT current_timestamp(),
                      `updatedAt` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
                      KEY `tbl` (`tbl`,`Tid`,`type`,`updatedAt`),
                      KEY `tbl_2` (`tbl`,`type`,`updatedAt`),
                      KEY `type` (`type`,`updatedAt`),
                      KEY `updatedAt` (`updatedAt`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `cal` (
 `id` int(11) NOT NULL PRIMARY KEY AUTO_INCREMENT,
 `uid` int(11) NOT NULL,
 `Name` varchar(255) NOT NULL,
 `dt` timestamp NOT NULL DEFAULT current_timestamp(),
 `expire` timestamp NOT NULL DEFAULT current_timestamp(),
 `profile` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`profile`)),
 `state` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`state`)),
 `createdAt` timestamp NOT NULL DEFAULT current_timestamp(),
 `updatedAt` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
 KEY `dt` (`dt`),
 KEY `expire` (`expire`),
 KEY `updatedAt` (`updatedAt`),
 CONSTRAINT `fk_caluid` FOREIGN KEY (`uid`) REFERENCES `usr` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `config` (
  `id` int(11) NOT NULL PRIMARY KEY AUTO_INCREMENT,
  `parent` int(11) NOT NULL,
  `Name` varchar(255) NOT NULL,
  `html` text NOT NULL,
  `profile` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`profile`)),
  `state` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`state`)),
  `createdAt` timestamp NOT NULL DEFAULT current_timestamp(),
  `updatedAt` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  KEY `tbl` (`parent`,`updatedAt`),
  KEY `updatedAt` (`updatedAt`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

Insert into `config` ( id,parent, name,html,profile, state)values
 ( 1,0,'StaticWeb HtmlTemplate','Money.Download','{"owner":1,"description":""}','{}')
,( 2,0,'StaticWeb Css Template','html','{"owner":1,"description":""}','{}')
,( 3,0,'profile template fields','html','{"owner":1,"description":""}','{}')
,( 4,0,'account template fields','html','{"owner":1,"description":""}','{}')
,( 5,0,'message template fields','html','{"owner":1,"description":""}','{}')
,( 6,0,'posts','admin created articles','{"owner":1,"description":""}','{}')
,( 7,1,'Title','Money.Download','{"owner":1,"description":""}','{}')
,( 8,1,'Search','Search','{"owner":1,"description":""}','{}')
,( 9,1,'Profile','Profile','{"owner":1,"description":""}','{}')
,(10,1,'Accounts','Accounts','{"owner":1,"description":""}','{}')
,(11,1,'Messages','Messages','{"owner":1,"description":""}','{}')
,(12,1,'Admin','Admin','{"owner":1,"description":""}','{}')
,(13,1,'Logout','Logout','{"owner":1,"description":""}','{}')
,(14,1,'FooterCopyright','copyright','{"owner":1,"description":""}','{}')
,(15,1,'Login','Login','{"owner":1,"description":""}','{}')
,(16,1,'UserName','UserName','{"owner":1,"description":""}','{}')
,(17,1,'Password','Password','{"owner":1,"description":""}','{}')
,(18,1,'Languages','Languages','{"owner":1,"description":""}','{}')
,(19,18,'List','List','{"owner":1,"description":""}','{}')
,(20,19,'English','English','{"owner":1,"description":""}','{}')
,(21,19,'Arabic','Arabic','{"owner":1,"description":""}','{}')
;
