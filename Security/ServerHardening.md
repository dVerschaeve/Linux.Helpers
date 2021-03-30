# Secure Linux Best Pracitices

Extract from Network Chuck's Youtube video on how to harden your Linux server. All credit to him!

Sources 
* Network Chuck: https://www.youtube.com/watch?v=ZhMw53Ud2tY

## Update Linux Distribution
We want to have the latest updates installed

```bash
sudo apt update
sudo apt dist-upgrade
```

To have automatic updates, install unattended-upgrades
```bash
sudo apt install unattended-upgrades
sudo dpkg-reconfigure --priority=low unattended-upgrades
```

## Don't use root SSH access
When no regular user account, create new user account and grant it sudo permissions:

```
adduser username
usermod -aG sudo username
```

## Passwordless authentication
Enable passwordless authentication using a SSH private key.

Ensure that the .ssh folder is present and permissions are set: (U)ser / owner can read, can write and can execute. (G)roup can't read, can't write and can't execute. (O)thers can't read, can't write and can't execute

```bash
mkdir ~/.ssh && chmod 700 ~/.ssh
```

Upload your public key towards the server:

```Powershell
# When you need to generate key:
ssh-keygen -b 4096

# Upload the public key towards the authorized keys
scp $env:USERPROFILE/.ssh/id_rsa.pub username@serverIP:~/.ssh/authorized_Keys
```

## Lockdown password logon

Prevent SSH logon to regular user account only. The SSH deamon herefore needs to be udpate.

```
sudo nano /etc/ssh/sshd_config
AddressFamily Any # Only allow IPv4
PermitRootLogin no # Prevent root logon
PasswordAuthentication no # Disable password authentication
# Save the file

sudo systemctl restart sshd

```

## Enable Firewall
Enable the firewall to block all ports and only allow required ports
```
sudo ss -tupln # List ports open on the system
```
Install Uncomplicated Firewall
```
sudo apt install ufw
sudo ufw status # Get the current status of the firewall
sudo ufw allow 22
sudo ufw enable
```

## Disable Ping
To have the server not respond to PING request, modify the UFW before.rules and add the following line.
```
sudo vim /etc/uwf/before.rules
-A ufw-before-input -p icmp --icmp-type echo-request -j DROP
sudo reboot
```