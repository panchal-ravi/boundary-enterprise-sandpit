#!/bin/bash
# Installs the boundary as a service for systemd on linux
# Usage: ./install.sh <worker|controller>

TYPE=$1
NAME=boundary

sudo cat << EOF > /etc/systemd/system/${NAME}-${TYPE}.service
[Unit]
Description=${NAME} ${TYPE}

[Service]
ExecStart=/usr/local/bin/${NAME} server -config /etc/boundary.d/${NAME}-${TYPE}.hcl -config /etc/boundary.d/boundary-recovery-kms.hcl
EnvironmentFile=/etc/boundary.d/boundary.env
User=boundary
Group=boundary
LimitMEMLOCK=infinity
Capabilities=CAP_IPC_LOCK+ep
CapabilityBoundingSet=CAP_SYSLOG CAP_IPC_LOCK

[Install]
WantedBy=multi-user.target
EOF

# Add the boundary system user and group to ensure we have a no-login
# user capable of owning and running Boundary
sudo adduser --system --group boundary || true
sudo chown -R boundary:boundary /etc/boundary.d
sudo chown boundary:boundary /usr/local/bin/${NAME}
sudo mkdir -p /var/log/boundary
sudo chown -R boundary:boundary /var/log/boundary

# Make sure to initialize the DB before starting the service. This will result in
# a database already initialized warning if another controller or worker has done this
# already, making it a lazy, best effort initialization
#if [ "${TYPE}" = "controller" ]; then
#  sudo -E /usr/local/bin/${NAME} database init -skip-host-resources-creation -skip-scopes-creation -skip-target-creation -config /etc/boundary.d/${NAME}-${TYPE}.hcl || true
    # sudo /usr/local/bin/boundary database init -skip-auth-method-creation -skip-host-resources-creation -skip-target-creation -config /etc/${NAME}-${TYPE}.hcl || true
#fi

sudo chmod 664 /etc/systemd/system/${NAME}-${TYPE}.service
sudo systemctl daemon-reload
sudo systemctl enable ${NAME}-${TYPE}
# sudo systemctl start ${NAME}-${TYPE}

