#!/bin/bash

# Disable Canonical, Inc.'s spammy adverts during login.
sed --in-place='' -e 's/ENABLED=1/ENABLED=0/' /etc/default/motd-news
systemctl stop motd-news.timer
systemctl disable motd-news.timer   # Disable the timer that triggers
systemctl disable motd-news.service # the service. Belt 'n' suspenders.

# Set up the base system.
export DEBIAN_FRONTEND=noninteractive
apt-get update && apt-get upgrade --yes
apt-get install --yes finger links talk talkd tree

# Restrict the `talk` and `ntalk` services in `inetd.conf` so that
# the `talkd` process can only respond to requests from localhost.
# Use `sed` and not `update-inetd` here to ensure the inetd entry
# always uses the package's own field values. We just prepend.
sed --in-place='' -e 's/^\\(n\\?talk\\)/127.0.0.1:\\1/' /etc/inetd.conf
systemctl restart inetd.service # Restart, don't HUP, to avoid Linux bug.

# Add some example user accounts.
users=(labadmin alice bob mallory rappinbill)
adduser --disabled-password --add_extra_groups --gecos 'Lab Administrator,401,555-523-2366,555-000-0001,Educational Services Dept.' ${users[0]}
adduser --disabled-password --add_extra_groups --gecos 'Adventurous Alice,101,555-002-5423,555-000-0002,Student Center' ${users[1]}
adduser --disabled-password --add_extra_groups --gecos 'Boring Bob,201,555-020-1262,555-000-0003,Student Center' ${users[2]}
adduser --disabled-password --add_extra_groups --gecos 'Malicious Mallory,301,555-625-5679,555-000-0004,Student Center' ${users[3]}
adduser --disabled-password --add_extra_groups --gecos 'Ricky Vaughn,202,555-555-5555,555-555-5555,Economics' ${users[4]}

# Set up users's home directories...and all that that implies.
rsync --verbose --recursive --links /vagrant/provision/home/ /home/
for user in ${users[*]}; do
    # These SSH keys were generated ahead of time and placed into
    # the host specifically so that they can be used to login via
    # a proper `login(1)` session over SSH with Vagrant. The keys
    # were generated in a loop using an invocation of the form:
    #
    # ```sh
    # ssh-keygen -t rsa -b 2048 -N '' \
    #     -C "$user@securing-shell-accounts.lab.anarchotech.invalid" \
    #     -f "provision/home/$user/.ssh/id_rsa"
    # ```
    #
    # Once generated and provisioned, you can log in to one of the
    # given user accounts with `vagrant`'s SSH feature as follows:
    #
    # ```sh
    # vagrant ssh --plain -- -l $user -i provision/home/$user/.ssh/id_rsa
    # ```
    cp "/home/$user/.ssh/id_rsa.pub" "/home/$user/.ssh/authorized_keys"
    chown -R "$user:$user" "/home/$user/"
    chmod 700 "/home/$user/.ssh"
    chmod 600 "/home/$user/.ssh/"*
done

# Install the login greeting, the "message of the day."
cp /vagrant/provision/etc/motd /etc/motd

# Give users who will be running (vulnerable!) daemons for demo
# purposes permission to have their user systemd instance linger.
loginctl enable-linger labadmin

# Create the example/student's own user account.

adduser --disabled-password --add_extra_groups --gecos '' janedoe
mkdir ~janedoe/.ssh
ssh-keygen -t rsa -b 2048 -N '' -C "Securing a Shell Account Practice Lab" \
    -f /vagrant/shell-account_rsa
cp /vagrant/shell-account_rsa.pub ~janedoe/.ssh/authorized_keys
chown -R janedoe:janedoe ~janedoe/.ssh
chmod 700 ~janedoe/.ssh
