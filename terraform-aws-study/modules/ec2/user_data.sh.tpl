#!/bin/bash
exec > >(tee /var/log/user-data.log) 2>&1

# CloudWatch Agent(今までどおり)
yum install -y amazon-cloudwatch-agent
/opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl \
-a fetch-config -m ec2 -s \
-c ssm:${cw_agent_config_name}

# Ansible と Git
dnf install -y git
dnf install -y ansible-core || { dnf install -y python3-pip && pip3 install ansible-core; }

# Ansible に渡す変数(Terraform が値を埋め込む)
cat > /root/ansible-vars.json <<'VARS'
${ansible_vars_json}
VARS
chmod 600 /root/ansible-vars.json

# playbook を取得して、自分自身に適用
# ansible_hash: ${ansible_hash}
git clone --depth 1 --branch ${ansible_repo_branch} ${ansible_repo_url} /opt/ansible-src
ansible-playbook -c local -i localhost, /opt/ansible-src/ansible/playbook.yml -e @/root/ansible-vars.json
