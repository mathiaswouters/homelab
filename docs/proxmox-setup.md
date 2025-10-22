# Proxmox Setup Manual

## 1) Disable enterprise repos:

1) Disable enterprise debian pve repo
2) Disable enterprise ceph-squid repo
3) Enable No-Subscription repo
4) Enable Ceph Squid No-Subscription repo

## 2) Update proxmox

- Update in GUI or run `apt update & upgrade` in cli

## 3) Set correct time

1) Select time menu
2) Set the correct time zone and time

## 4) Add new storage

1) Access the Shell
2) Prepare and Create Physical Volumes (PV)
    - `wipefs -a /dev/sda`
    - `wipefs -a /dev/sdb`
    - `pvcreate /dev/sda /dev/sdb`
    - `pvs`
3) Create the Volume Group (VG)
    - `vgcreate vg-data /dev/sda /dev/sdb`
    - `vgs`
4) Create the LVM-Thin Pool
    - `lvcreate -l 100%FREE -n thin-data vg-data --type thin-pool`
    - `lvs`
5) Add Storage to Proxmox (Web UI)
    - Navigate to Datacenter --> Storage
    - Click Add --> LVM-Thin
    - Configure the settings:
        - ID: lvm-thin-storage
        - Volume Group: Select vg-data
        - Thin Pool: Select thin-data
        - Content: Check Disk Image and Container
    - Click Create

## 5) Configure Notifications

1) Go to Notifications
2) Add SMTP Notification
3) Configure SMTP Notification
4) Modify Notification Matcher

## 6) ...

...
