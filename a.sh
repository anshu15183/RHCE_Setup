#!/bin/bash

HOST_ENTRIES=(
	    "172.25.250.10    servera.lab.example.com    node1"
	    "172.25.250.11    serverb.lab.example.com    node2"
	    "172.25.250.220   utility.lab.example.com	 node3"
	    "172.25.250.12    serverc.lab.example.com    node4"
	    "172.25.250.13    serverd.lab.example.com    node5"
		)





echo "Adding inventory and ansible.cfg files in /home/admin/ansible/"
mkdir /home/admin/ansible
mkdir /home/admin/ansible/roles
mkdir /home/admin/ansible/mycollection

wget -P /home/admin/ansible/ https://raw.githubusercontent.com/anshu15183/RHCE_Setup/refs/heads/main/inventory
wget -P /home/admin/ansible/ https://raw.githubusercontent.com/anshu15183/RHCE_Setup/refs/heads/main/ansible.cfg
wget -P /home/admin/ansible/ https://github.com/anshu15183/RHCE_Setup/raw/refs/heads/main/files.rar
mkdir /root/Downloads/files && unzip /home/admin/ansible/files.rar /root/Downloads/files/
rm -rf /root/Downloads/files.rar

wget -P /home/admin/ansible/ https://raw.githubusercontent.com/anshu15183/RHCE_Setup/refs/heads/main/repo.yml
ansible-playbook /home/student/ansible/repo.yml





echo "Backing up /etc/hosts..."
cp /etc/hosts /etc/hosts.bak

for entry in "${HOST_ENTRIES[@]}"; do
    if ! grep -q "$entry" /etc/hosts; then
          echo "Adding entry: $entry"
          echo "$entry" | sudo tee -a /etc/hosts > /dev/null
    else
          echo "Entry already exists: $entry"
    fi
done


echo "Installing ansible.posix collection..."
ansible-galaxy collection install ansible.posix


IP_ADDRESSES=(
	    "172.25.250.10"
	    "172.25.250.11"
	    "172.25.250.12"
	    "172.25.250.13"
	    "172.25.250.220"
	)

ROOT_PASSWORD="redhat"
for ip in "${IP_ADDRESSES[@]}"; do

	echo "Connecting to $ip via SSH..."

	sshpass -p "$ROOT_PASSWORD" ssh -o StrictHostKeyChecking=no root@$ip <<EOF
        	useradd -m admin
        	echo "admin:root" | chpasswd
        	echo "admin     ALL=(ALL)   NOPASSWD:ALL" > /etc/sudoers.d/admin

EOF

        if [ $? -eq 0 ]; then
	        echo "User 'admin' created and sudoers entry added on $ip"
	else
	        echo "Failed to configure $ip"
	fi
done

echo "########  Exam practice environment created  #########"

echo "Installing Apache HTTPD and copying data..."
sudo dnf update -y            
sudo dnf install -y httpd     
sudo systemctl start httpd    
sudo systemctl enable httpd   
sudo mkdir -p /var/www/html/files  
sudo cp -r ~/Downloads/* /var/www/html/files/   
sudo chown -R apache:apache /var/www/html/files 
sudo chmod -R 755 /var/www/html/files           
sudo systemctl restart httpd

echo "Opening the web page in the browser..."
xdg-open http://localhost/files

echo "Script Executed Successully"

