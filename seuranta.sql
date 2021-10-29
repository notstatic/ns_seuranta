CREATE TABLE IF NOT EXISTS `player_tracking` (
  `hex` varchar(50) DEFAULT NULL,
  `reason` longtext CHARACTER SET utf8mb4,
  `submitter` longtext CHARACTER SET utf8mb4
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
