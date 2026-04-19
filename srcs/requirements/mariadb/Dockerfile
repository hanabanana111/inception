# 課題指定：Debianのペンウルティメイト（一つ前）の安定版 [cite: 78]
FROM debian:bullseye

# パッケージインストールと不要ファイルの削除を1つのRUNにまとめる
RUN apt-get update && apt-get install -y \
    mariadb-server \
    && rm -rf /var/lib/apt/lists/*

# 外部接続を許可する設定ファイルを配置
COPY ./conf/50-server.cnf /etc/mysql/mariadb.conf.d/50-server.cnf

# 実行ディレクトリの作成と権限設定
RUN mkdir -p /run/mysqld && chown -R mysql:mysql /run/mysqld

# 初期化スクリプトをコピーして実行権限を付与
COPY ./tools/01-init-db.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/01-init-db.sh

# 3306番ポートを開放（MariaDBのデフォルト）
EXPOSE 3306

# スクリプトを実行（この中で設定後にmysqldを起動する）
ENTRYPOINT ["01-init-db.sh"]