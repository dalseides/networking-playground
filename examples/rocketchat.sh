#!/bin/bash

sudo ip netns exec vpn sudo -u $USER sh -c ' \
  sudo /usr/bin/mount -t cgroup2 cgroup2 /sys/fs/cgroup; \ 
  sudo /usr/bin/mount -t securityfs securityfs /sys/kernel/security/; \
  /snap/bin/rocketchat-desktop'

