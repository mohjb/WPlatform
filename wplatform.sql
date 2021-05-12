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

CREATE TABLE `rate` (
    `id` int(11) NOT NULL PRIMARY KEY AUTO_INCREMENT,
    `Sell` int(11) NOT NULL,
    `Buy` int(11) NOT NULL,
    `Amount` decimal(10,0) NOT NULL,
    `state` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`state`)),
    `createdAt` timestamp NOT NULL DEFAULT current_timestamp(),
    `updatedAt` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
    KEY `Sell` (`Sell`,`Buy`,`updatedAt`),
    KEY `Buy` (`Buy`,`Sell`,`updatedAt`),
    KEY `updatedAt` (`updatedAt`),
    CONSTRAINT `fk_buy` FOREIGN KEY (`Buy`) REFERENCES `currency` (`id`) ON DELETE CASCADE,
    CONSTRAINT `fk_sell` FOREIGN KEY (`Sell`) REFERENCES `currency` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;


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
