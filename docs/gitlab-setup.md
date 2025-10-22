# GitLab Setup

## Step 1: Change Root password

1) Log in as `root` with the default password
2) Go to `User settings` --> `Password` and change the password

## Step 2: Create user

1) Go to `Admin area` (add /admin to the url)
2) Go to `Overview` --> `Users` and select `New user`
3) Enter the new user's details (Name, Username and Email)
4) At `Access level` choose `Administrator`
5) Select `Create user`
6) Then back in the `Users` page of the `Admin area` select the new user
7) Edit the new user and enter a password
8) Sign out of the root user and log back in with the new user

## Step 3: Change Appearance

1) Go to `Preferences` then to `Appearance`
2) At Appearance: change `Light` to `Dark`
3) At Navigation theme: change `Neutral` to `Blue`
4) At Syntax highlighting theme: change `Light` to `Dark`
5) Select `Save changes`


## Step 4: Add SSH Keys

### Generate an SSh Key pair on the master-vm:

1) `ssh-keygen -t ed25519 -C "gitlab"`
2) At `Enter file in which to save the key (/home/mathias/.ssh/id_ed25519):` enter: `gitlab`
3) At `Enter passphrase (empty for no passphrase):` just press enter
4) `vi .ssh/config`
  - Enter the following:
    ```
    Host 192.168.0.24
      PreferredAuthentications publickey
      IdentityFile ~/.ssh/gitlab
    ```

### Add the SSH Key to your GitLab account:

1) Copy this output: `cat ~/.ssh/gitlab.pub`
2) Sign in to GitLab
3) Select your avatar
4) Select Edit profile
5) Select SSH Keys
6) Select `Add new key`
7) Enter your copied key
8) At `Expiration date` press the `x` for no expiration date
9) Test the connection: `ssh -T git@192.168.0.24`

## Step 5: Create a project

1) Select `Create a project`
2) ...