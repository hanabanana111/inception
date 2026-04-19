#!/bin/bash
set -e

# 1. データベースの初期化（未初期化の場合のみ）
if [ ! -d "/var/lib/mysql/mysql" ]; then
    mariadb-install-db --datadir=/var/lib/mysql --user=mysql --rpm
fi

# 2. 一時的にMariaDBを起動（初期設定用）
# & をつけてバックグラウンドで動かします
mysqld_safe --datadir=/var/lib/mysql --skip-networking &

# サーバーが起動するまで待機
until mysqladmin ping >/dev/null 2>&1; do
    echo "Waiting for MariaDB..."
    sleep 2
done

# 3. 環境変数を使用してSQLを実行
# $MYSQL_DATABASE, $MYSQL_USER, $MYSQL_PASSWORD などは .env から渡される想定
mysql -u root <<EOF
-- rootパスワードの設定（必要に応じて）
ALTER USER 'root'@'localhost' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';

-- データベースと一般ユーザーの作成
CREATE DATABASE IF NOT EXISTS ${MYSQL_DATABASE};
CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';
GRANT ALL PRIVILEGES ON ${MYSQL_DATABASE}.* TO '${MYSQL_USER}'@'%';

FLUSH PRIVILEGES;
EOF

# 4. 一時サーバーを停止
mysqladmin -u root -p${MYSQL_ROOT_PASSWORD} shutdown

# 5. メインプロセスをフォアグラウンドで起動（コンテナを維持するため）
# execを使うことで、このプロセスがPID 1を継承します
exec mysqld_safe --datadir=/var/lib/mysql
