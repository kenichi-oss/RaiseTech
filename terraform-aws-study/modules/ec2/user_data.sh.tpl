#!/bin/bash
exec > >(tee /var/log/user-data.log) 2>&1

# CloudWatch Agent
yum install -y amazon-cloudwatch-agent
/opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl \
  -a fetch-config -m ec2 -s \
  -c ssm:${cw_agent_config_name}

# Java 21 / Git / MySQL クライアント
dnf install -y java-21-amazon-corretto-devel.x86_64
java -version
dnf install -y git mariadb105
git --version

# アプリを clone
sudo -u ec2-user git clone ${app_repo_url} /home/ec2-user/aws-study
chmod +x /home/ec2-user/aws-study/gradlew

# DB 接続情報を書き換え
PROPS=/home/ec2-user/aws-study/src/main/resources/application.properties
if [ -f "$PROPS" ]; then
  sed -i "s#^spring.datasource.url=.*#spring.datasource.url=jdbc:mysql://${db_endpoint}:3306/${db_name}#" "$PROPS"
  sed -i "s#^spring.datasource.username=.*#spring.datasource.username=${db_username}#" "$PROPS"
  sed -i "s#^spring.datasource.password=.*#spring.datasource.password=${db_password}#" "$PROPS"
  chown ec2-user:ec2-user "$PROPS"
fi

# create.sql があれば、RDS の起動を待って実行
SQL_FILE=/home/ec2-user/aws-study/src/main/resources/create.sql
if [ -f "$SQL_FILE" ]; then
  for i in $(seq 1 30); do
    if mysql -h ${db_endpoint} -u ${db_username} -p${db_password} ${db_name} -e "SELECT 1" >/dev/null 2>&1; then
      mysql -h ${db_endpoint} -u ${db_username} -p${db_password} ${db_name} < "$SQL_FILE"
      break
    fi
    sleep 10
  done
fi

# アプリを systemd サービス化して自動起動
cat <<'EOF' > /etc/systemd/system/aws-study.service
[Unit]
Description=aws-study app
After=network.target

[Service]
WorkingDirectory=/home/ec2-user/aws-study
ExecStart=/home/ec2-user/aws-study/gradlew bootRun
User=ec2-user
StandardOutput=append:/home/ec2-user/aws-study/app.log
StandardError=append:/home/ec2-user/aws-study/app.log
Restart=always

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable --now aws-study