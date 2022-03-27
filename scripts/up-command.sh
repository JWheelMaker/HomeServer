#!/bin/bash
echo
echo "Hello, $USER. Let's update this system."
echo

apt-get update;
apt-get upgrade -y;
apt-get dist-upgrade -y;
apt-get autoremove -y;
apt-get autoclean -y;

echo
echo "--------------------"
echo "- Update Complete! -"
echo "--------------------"
echo
exit