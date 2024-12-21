##
# You must create at least 2 encrypted partitions using LVM.

sudo dnf -y install nano

##
# A SSH service will be runngin on the mandatory port 4242
# in your virtual machine. For security reasons, it must not
# be possible to connet using SSH as root.

## check current configurations
systemctl status firewalld
firewall-cmd --list-all

## modify sshd
/etc/ssh/sshd_config
- # Port 22
+ Port 4242

- PermitRootLogin yes
+ PermitRootLogin no


## modify selinux
# https://shachikunbot.com/sshd-selinux/
# for semanage command
dnf -y install policycoreutils-python-utils
sudo semanage port -l | grep ssh
sudo semanage port -a -t ssh_port_t -p tcp 4242
sudo semanage port -l | grep ssh

sudo systemctl restart sshd

##
# You have to configure your operating system with the firewalld
# firewall and thus leave only port 4242 open in your virtual machine.

## modify firewalld
# https://qiita.com/fk_2000/items/019b62818e34be973227
sudo firewall-cmd --permanent --remove-service=ssh
sudo cp /usr/lib/firewalld/services/ssh.xml /etc/firewalld/services/ssh-4242.xml
sudo nano /etc/firewalld/services/ssh-4242.xml
- <port protocol="tcp" port="22" />
+ <port protocol="tcp" port="4242" />

sudo firewall-cmd --permanent --add-service=ssh-4242
sudo firewall-cmd --reload

##
# The hostname of your virtual machine must be your login ending
# with 42. In my case, it should be takitaga42.
sudo hostnamectl set-hostname takitaga42
## You don't need to reboot the machine.
## Just need to exit the current session then re-login.


##
# You have to implement a strong password policy.
# Password policy:
# - Your password has to expire every 30 days.
# - The minimum number of days allowd before the modification of
#   a password will be set to 2.
# - The user has to receice a warning message 7 days before their
#   password expires.
# - You password must be at least 10 characters long. It must contain
#   an uppercase letter, a lowercase letter, and a number. Also,
#   it must not contain more than 3 consecutive identical characters.
# - The password must not include the name of the user.
# - The following rule does not apply to the root password:
#   The password must have at least 7 characters that are not part
#   of the former password.
# - Of course, your root password has to comply with this policy.

# /etc/login.defs
## expire every 30 days
PASS_MAX_DAYS   30

## minimum days allowed before the modification
PASS_MIN_DAYS   2

## warning message 7 days before the password expires
PASS_WARN_AGE   7

sudo pwconv

# /etc/pam.d/system-auth

# /etc/security/pwquality.conf
## min len 10 charas long
minlen = 10

## contain an uppercase, a lowercase, and a number
lcredit = -1 # lowercase
ucredit = -1 # uppercase
dcredit = -1 # number

## must not contain more than 3 consecutive identical characters
maxrepeat = 3

## must not include the name of the user
reject_username

## must have at least 7 charas that are not part of the former password
difok = 7

## root password has to comply with this policy
enforce_for_root

##
# You have to install and configure sudo following strict rules.
# Requirements:
# - Authentication using sudo has to be limited to 3 attempts
#   in the event of an incorrect password.
# - A custom message of your choice has to be displayed if an error
#   due to a wrong password occurs when using sudo.
# - Each action using sudo has to be archived, both inputs and outputs.
#   The log file has to be saved in the /var/log/sudo/ folder.
# - The TTY mode has to be enabled for security reasons.
# - For security reasons too, the paths that can be used by sudo
#   must be restricted.
#   Example:
#   /usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/snap/bin
man sudoers
sudo EDITOR=nano visudo

## limited to 3 attempts
Defaults	passwd_tries=3

## custom message
Defaults	badpass_message="Password is incorrect!"

## archived both inputs and outputs
Defaults	log_input, log_output

## log file has to be saved in the /var/log/sudo/ folder
Defaults	logfile="/var/log/sudo/sudo.log"

## TTY mode has to be enabled
Defaults	requiretty

## tha paths that can be used by sudo must be restricted
Defaults	secure_path="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"

##
# In addition to the root user, a user with your login as username
# has to be present. This user has to belong to the user42 and sudo groups.
useradd takitaga42
passwd takitaga42
cat /etc/passwd | grep takitaga42
cat /etc/group | grep takitaga42

sudo groupadd user42
sudo usermod -aG user42 takitaga42
sudo usermod -aG wheel takitaga42
groups takitaga42
logout

##
# You have to create a simple script called monitoring.sh. It must be
# developed in bash. At server startup, the script will display some
# information (listed below) on all terminals every 10 minutes (take a
# look at wall). The banner is optional. No error must be visible.
# Your script must always be able to display the following information:
# - The architecture of your operating system and its kernel version.
# - The number of physical processors.
# - The number of virtual processors.
# - The current available RAM on your server and its utilization rate
#   as a percentage.
# - The current available storage on your server and its utilization rate
#   as a percentage.
# - The current utilization rate of your processors as a percentage.
# - The date and time of the last reboot.
# - Whether LVM is active or not.
# - The number of active connections.
# - The number of users using the server.
# - The IPv4 address of your server and its MAC address.
# - The number of command executed with the sudo program.

crontab crontab.txt
