#!/bin/bash
# Usage: ./git_first_time.sh
# Run this script and see the resultant output in the ~/.gitconfig file.

# Tell Git who you are
git config --global user.name "myName"
git config --global user.email user@domain.com

# Select your favorite text editor
git config --global core.editor vim

# Add some SVN-like aliases
git config --global alias.st status
git config --global alias.co checkout
git config --global alias.br branch
git config --global alias.up rebaseemote see url
git config --global alias.ci commit


echo -e "Then, ensure you have an SSH client installed"
echo -e "ssh -V"
echo -e "#Step 2. Set up your default identity\n
ssh-keygen"
echo -e "Check if agent is running: ps -e | grep [s]sh-agent"
echo -e "#Install the public key on your Bitbucket account copy this content\n
cat ~/.ssh/id_rsa.pub"
echo -e "#paste it in SSH keys, add a label and complete the key field, and press add #key buttom"

