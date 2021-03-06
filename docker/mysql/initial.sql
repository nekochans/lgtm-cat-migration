-- 'local_lgtm_cat' というデータベースを作成
-- 'local_lgtm_cat_user' というユーザー名のユーザーを作成
-- データベース 'local_lgtm_cat' への権限を付与
CREATE DATABASE IF NOT EXISTS local_lgtm_cat CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_bin;
CREATE USER local_lgtm_cat_user@'%' IDENTIFIED WITH mysql_native_password BY 'password';
GRANT ALL ON local_lgtm_cat.* TO 'local_lgtm_cat_user'@'%';
