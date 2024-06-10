# Create install.sh file in /home/ubuntu folder



sudo chmod +x /home/ubuntu/install.sh
sudo mkdir -p /etc/boundary.d/auth_storage
sudo mkdir -p /etc/boundary.d/session_storage
sudo /home/ubuntu/install.sh worker
sudo touch /etc/boundary.d/boundary.env
sudo chown -R boundary:boundary /etc/boundary.d

# Create controller-led worker token
 
# Create boundary-worker.hcl in /etc/boundary.d/
# Update listen IP Address
# Update token
# Update upstream controller IP

sudo chown -R boundary:boundary /etc/boundary.d