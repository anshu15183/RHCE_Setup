#!/bin/bash

HOST_ENTRIES=(
	    "172.25.250.10    servera.lab.example.com    node1"
	    "172.25.250.11    serverb.lab.example.com    node2"
	    "172.25.250.220   utility.lab.example.com	 node3"
	    "172.25.250.12    serverc.lab.example.com    node4"
	    "172.25.250.13    serverd.lab.example.com    node5"
		)


wget -P /root/Downloads/ https://github.com/anshu15183/RHCE_Setup/raw/refs/heads/main/files.zip
unzip /root/Downloads/files.zip -d /root/Downloads/
rm -rf /root/Downloads/files.zip


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

mkdir /home/student/ansible
mkdir /home/student/ansible/roles
mkdir /home/student/ansible/mycollection


wget -P /home/student/ansible/ https://raw.githubusercontent.com/anshu15183/RHCE_Setup/refs/heads/main/inventory
wget -P /home/student/ansible/ https://raw.githubusercontent.com/anshu15183/RHCE_Setup/refs/heads/main/ansible.cfg


dnf install -y ansible* 
dnf install -y rhel-system-roles




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




wget -P /home/student/ansible/ https://raw.githubusercontent.com/anshu15183/RHCE_Setup/refs/heads/main/repo.yml && ansible-playbook /home/student/ansible/repo.yml -i /home/student/ansible/inventory


ansible all -m ping -i /home/student/ansible/inventory


echo "Opening the web page in the browser..."
xdg-open http://localhost/files


echo "Script Executed Successully"

