#!/bin/bash

for ip in 192.168.0.11 192.168.0.12 192.168.0.13 192.168.0.14 192.168.0.15 192.168.0.16; do
  ssh-copy-id -i ~/.ssh/homelab.pub mathias@$ip
done
