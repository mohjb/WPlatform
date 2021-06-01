-- create database wplatform;

CREATE TABLE `usr` (
   `id` int(11) NOT NULL PRIMARY KEY AUTO_INCREMENT,
   `Name` varchar(255) NOT NULL,
   `pw` varchar(255) NOT NULL,
   `profile` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`profile`)),
   `state` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`state`)),
   `creaTime` timestamp NOT NULL DEFAULT current_timestamp(),
   -- lm is short for `lastModified`
   `lm` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
   KEY `Name` (`Name`),
   KEY `lm` (`lm`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

insert into usr ( Name, pw, profile, state)values
 ('m',md5('m'),'{"display":"mohjb","gender":"male","dob":"1973/04/07","tels":["99876454"],"emails":["mohamadjb@gmail.com"]}','{"active":1,"admin":1}')
,('u',md5('u'),'{"display":"user1"}','{"active":1}')
,('z',md5('z'),'{"display":"user1"}','{}');

CREATE TABLE `bank` (
    `id` int(11) NOT NULL PRIMARY KEY AUTO_INCREMENT,
    `Name` varchar(255) NOT NULL,
    `profile` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`profile`)),
    `state` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`state`)),
    `creaTime` timestamp NOT NULL DEFAULT current_timestamp(),
    -- lm is short for `lastModified`
    `lm` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
    KEY `Name` (`Name`),
    KEY `lm` (`lm`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

insert into bank ( Name, profile, state)values
('nbk','{"display":"NBK","address":{"county":"Kuwait"},"tels":["1801801"],"emails":[],"urls":["nbk.com.kw"]}','{}')
,('rain','{"display":"rain","address":{"county":"Bahrain"},"tels":["1"],"emails":[],"urls":["rain.bh"]}','{}');

CREATE TABLE `currency` (
    `id` int(11) NOT NULL PRIMARY KEY AUTO_INCREMENT,
    `Name` varchar(255) NOT NULL,
    `profile` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`profile`)),
    `state` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`state`)),
    `creaTime` timestamp NOT NULL DEFAULT current_timestamp(),
    -- lm is short for `lastModified`
    `lm` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
    KEY `Name` (`Name`),
    KEY `lm` (`lm`)
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
    `creaTime` timestamp NOT NULL DEFAULT current_timestamp(),
    -- lm is short for `lastModified`
    `lm` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
    KEY `Sell` (`Sell`,`Buy`,`lm`),
    KEY `Buy` (`Buy`,`Sell`,`lm`),
    KEY `lm` (`lm`),
    CONSTRAINT `fk_buy` FOREIGN KEY (`Buy`) REFERENCES `currency` (`id`) ON DELETE CASCADE,
    CONSTRAINT `fk_sell` FOREIGN KEY (`Sell`) REFERENCES `currency` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

insert into `rate` ( sell, buy,amount,profile, state)values
(1,2,17500,'{"source":"test","time":"2021-05-13"}','{}')
,(2,1,0.00001,'{"source":"test","time":"2021-05-13"}','{}');

CREATE TABLE `Acc` ( -- Acc is short for user-Account
    `id` int(11) NOT NULL PRIMARY KEY AUTO_INCREMENT,
    `Name` varchar(255) NOT NULL,
    `Uid` int(11) NOT NULL,
    `bankid` int(11) NOT NULL,
    `currencyId` int(11) NOT NULL,
    `profile` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`profile`)),
    `state` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`state`)),
    `creaTime` timestamp NOT NULL DEFAULT current_timestamp(),
    -- lm is short for `lastModified`
    `lm` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
    KEY `Uid` (`Uid`),
    KEY `bankid` (`bankid`,`Uid`),
    KEY `currencyId` (`currencyId`,`Uid`),
    KEY `lm` (`lm`),
    CONSTRAINT `fk_bank` FOREIGN KEY (`bankid`) REFERENCES `bank` (`id`) ON DELETE CASCADE,
    CONSTRAINT `fk_currency` FOREIGN KEY (`currencyId`) REFERENCES `currency` (`id`) ON DELETE CASCADE,
CONSTRAINT `fk_uid` FOREIGN KEY (`Uid`) REFERENCES `usr` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `trans` ( -- trans is short for accounts Transaction
    `id` int(11) NOT NULL PRIMARY KEY AUTO_INCREMENT,
    `srcAcc` int(11) NOT NULL,
    `dstAcc` int(11) NOT NULL,
    `Amount` decimal(10,0) NOT NULL,
    `Profile` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`Profile`)),
    `state` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`state`)),
    `creaTime` timestamp NOT NULL DEFAULT current_timestamp(),
    -- lm is short for `lastModified`
    `lm` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
    KEY `srcAcc` (`srcAcc`,`dstAcc`,`lm`),
    KEY `dstAcc` (`dstAcc`,`srcAcc`,`lm`),
    KEY `lm` (`lm`),
    CONSTRAINT `fk_dst` FOREIGN KEY (`dstAcc`) REFERENCES `Acc` (`id`) ON DELETE CASCADE,
    CONSTRAINT `fk_src` FOREIGN KEY (`srcAcc`) REFERENCES `Acc` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `msg` (
    `id` int(11) NOT NULL PRIMARY KEY AUTO_INCREMENT,
    `uid` int(11) NOT NULL,
    `toUsr` int(11) NOT NULL,
    -- `type` enum( 'userMessage' , 'db activity(CrUD) log' ,'system notification', ,,,
    `type` varchar(255) NOT NULL,
    `body` text NOT NULL,
    `profile` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`profile`)),
    `state` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`state`)),
    `creaTime` timestamp NOT NULL DEFAULT current_timestamp(),
    -- lm is short for `lastModified`
    `lm` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
   KEY `uid` (`uid`,`lm`),
   KEY `toUsr` (`toUsr`,`lm`),
   KEY `type` (`type`,`lm`),
   KEY `lm` (`lm`),
   CONSTRAINT `fk_2u` FOREIGN KEY (`toUsr`) REFERENCES `usr` (`id`) ON DELETE CASCADE,
   CONSTRAINT `fk_msguid` FOREIGN KEY (`uid`) REFERENCES `usr` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `at` ( -- at is short for attachments
    `id` int(11) NOT NULL PRIMARY KEY AUTO_INCREMENT,
    `Tid` int(11) NOT NULL,
    `tbl` enum('usr','bank','currency','Acc','rate','trans','msg','at','cal','tmplt') NOT NULL,
    `type` varchar(255) NOT NULL,
    `body` blob NOT NULL,
    `profile` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`profile`)),
    `state` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`state`)),
    `creaTime` timestamp NOT NULL DEFAULT current_timestamp(),
    -- lm is short for `lastModified`
    `lm` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
    KEY `tbl` (`tbl`,`Tid`,`type`,`lm`),
    KEY `tbl_2` (`tbl`,`type`,`lm`),
    KEY `type` (`type`,`lm`),
    KEY `lm` (`lm`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `cal` ( -- cal is short for calendar entries ,or, time related events
    `id` int(11) NOT NULL PRIMARY KEY AUTO_INCREMENT,
    `uid` int(11) NOT NULL,
    `Name` varchar(255) NOT NULL,
    -- type enum ('userSession & Expiry' , 'calendar event(alarm)','calendar early notification/pre-alarm' , 'calendar future schedule/planned action' ,,,
    `type` varchar(255) NOT NULL,
    `dt` timestamp NOT NULL DEFAULT current_timestamp(),
    `expire` timestamp NOT NULL DEFAULT current_timestamp(),
    `profile` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`profile`)),
    `state` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`state`)),
    `creaTime` timestamp NOT NULL DEFAULT current_timestamp(),
    -- lm is short for `lastModified`
    `lm` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
    KEY `dt` (`dt`),
    KEY `expire` (`expire`),
    KEY `lm` (`lm`),
    CONSTRAINT `fk_caluid` FOREIGN KEY (`uid`) REFERENCES `usr` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `tmplt` (
    `id` int(11) NOT NULL PRIMARY KEY AUTO_INCREMENT,
    `parent` int(11) NOT NULL,
    `Name` varchar(255) NOT NULL,
    `html` text NOT NULL,
    `profile` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`profile`)),
    `state` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`state`)),
    `creaTime` timestamp NOT NULL DEFAULT current_timestamp(),
    -- lm is short for `lastModified`
    `lm` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
    KEY `tbl` (`parent`,`lm`),
    KEY `lm` (`lm`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

Insert into `tmplt` ( id,parent, name,html,profile, state)values
 ( 1,0,'StaticWeb HtmlTemplate','Money.Download','{"owner":1,"description":""}','{}')
,( 2,0,'StaticWeb Css Template','html','{"owner":1,"description":""}','{}')
,( 3,0,'profile template fields','html','{"owner":1,"description":""}','{}')
,( 4,0,'Account template fields','html','{"owner":1,"description":""}','{}')
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


-- test cases for userAccessControl : acc , trans
insert into acc (id, Name, Uid, bankid, currencyId) VALUES
 (1,'savings',1,1,1)
,(2,'trust'  ,1,1,1)
,(3,'savings',1,2,2)
,(4,'trust'  ,1,2,2)

,(5,'savings'  ,2,1,1)
,(6,'trust'    ,2,1,1)
,(7,'savings'  ,2,2,2)
,(8,'trust'    ,2,2,2)

,(9 ,'savings'  ,3,1,1)
,(10,'trust'    ,3,1,1)
,(11,'savings'  ,3,2,2)
,(12,'trust'    ,3,2,2)
;

insert into trans (id, srcAcc, dstAcc, Amount, Profile, state) VALUES
 ( 1,1,2,1,'{}','{}')
,( 2,2,1,2,'{}','{}')
,( 3,3,4,3,'{}','{}')
,( 4,4,3,4,'{}','{}')
,( 5,5,6,5,'{}','{}')
,( 6,6,5,6,'{}','{}')
,( 7,7,8,7,'{}','{}')
,( 8,8,7,8,'{}','{}')
,( 9, 9,10, 9,'{}','{}')
,(10,10, 9,10,'{}','{}')
,(11,11,12,11,'{}','{}')
,(12,12,11,12,'{}','{}')
,(13, 1, 5,13,'{}','{}')
,(14, 5, 1,14,'{}','{}')
,(15, 1, 6,15,'{}','{}')
,(16, 6, 1,16,'{}','{}')
,(17, 1, 9,17,'{}','{}')
,(18, 9, 1,18,'{}','{}')
,(19, 1,10,19,'{}','{}')
,(20,10, 1,20,'{}','{}')
,(21, 2, 6,21,'{}','{}')
,(22, 6, 2,22,'{}','{}')
,(23, 2,10,23,'{}','{}')
,(24,10, 2,24,'{}','{}')
,(25, 5, 9,25,'{}','{}')
,(26, 9, 5,26,'{}','{}')
,(27, 5,10,27,'{}','{}')
,(28,10, 5,28,'{}','{}')
,(29, 6, 9,29,'{}','{}')
,(30, 9, 6,30,'{}','{}')
,(31, 6,10,31,'{}','{}')
,(32,10, 6,32,'{}','{}')

,(33, 3, 7,33,'{}','{}')
,(34, 7, 3,34,'{}','{}')
,(35, 3, 8,35,'{}','{}')
,(36, 8, 3,36,'{}','{}')
,(37, 3,11,37,'{}','{}')
,(38,11, 3,38,'{}','{}')
,(39, 3,12,39,'{}','{}')
,(40,12, 3,40,'{}','{}')

,(41, 4, 7,41,'{}','{}')
,(42, 7, 4,42,'{}','{}')
,(43, 4, 8,43,'{}','{}')
,(44, 8, 4,44,'{}','{}')
,(45, 4,11,45,'{}','{}')
,(46,11, 4,46,'{}','{}')
,(47, 4,12,47,'{}','{}')
,(48,12, 4,48,'{}','{}')

,(49, 7,11,49,'{}','{}')
,(50,11, 7,50,'{}','{}')
,(51, 7,12,51,'{}','{}')
,(52,12, 7,52,'{}','{}')

,(53, 8,11,53,'{}','{}')
,(54,11, 8,54,'{}','{}')
,(55, 8,12,55,'{}','{}')
,(56,12, 8,56,'{}','{}')


,(57, 1, 3,57,'{"rate":1000}','{}')
,(58, 2, 4,58,'{"rate":1000}','{}')
,(59, 5, 7,59,'{"rate":1000}','{}')
,(60, 6, 8,60,'{"rate":1000}','{}')
,(61, 9,11,61,'{"rate":1000}','{}')
,(62,10,12,62,'{"rate":1000}','{}')

,(63, 3, 1,63,'{"rate":0.001}','{}')
,(64, 4, 2,64,'{"rate":0.001}','{}')
,(65, 7, 5,65,'{"rate":0.001}','{}')
,(66, 8, 6,66,'{"rate":0.001}','{}')
,(67,11, 9,67,'{"rate":0.001}','{}')
,(68,12,10,68,'{"rate":0.001}','{}')
;
