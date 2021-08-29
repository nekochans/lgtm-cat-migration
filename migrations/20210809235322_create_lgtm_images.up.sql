CREATE TABLE `lgtm_images` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `filename` varchar(255) NOT NULL COMMENT '画像ファイル名になっているuniqueな文字列が格納される .e.g. aaaaaaaa-aaaa-aaaa-aaaa-123456788qqq',
  `path` varchar(255) NOT NULL COMMENT 'S3に保存されているパス .e.g. YYYY/MM/DD/H',
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_lgtm_images_01` (`uuid`),
  KEY `idx_lgtm_images_01` (`path`),
  KEY `idx_lgtm_images_02` (`created_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin ROW_FORMAT=DYNAMIC;
