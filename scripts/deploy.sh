#!/bin/bash

# Load up .env
set -o allexport
[[ -f .env ]] && source .env
set +o allexport

eval "$(ssh-agent -s)" # Start ssh-agent cache
chmod 600 .travis/nikoyan-rsa # Allow read access to the private key
ssh-add .travis/nikoyan-rsa # Add the private key to SSH

# Skip unkown host promt
echo "Host $ADDRESS
  StrictHostKeyChecking no
  UserKnownHostsFile=/dev/null" > ~/.ssh/config

git config --global push.default matching
git remote add deploy ssh://$USER@$ADDRESS:$PORT$DEPLOY_DIR
git push deploy master

# Skip this command if you don't need to execute any additional commands after deploying.
# ssh apps@$IP -p $PORT <<EOF
#   cd $DEPLOY_DIR
#   crystal build --release --no-debug index.cr # Change to whatever commands you need!
# EOF
