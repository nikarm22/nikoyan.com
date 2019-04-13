#!/bin/bash

# Decryptinc ssh private key
openssl aes-256-cbc -K $encrypted_7e8b61df6307_key -iv $encrypted_7e8b61df6307_iv -in .travis/nikoyan-rsa.enc -out .travis/nikoyan-rsa -d

# Load up .env
cp env/nikoyan-com.env .env
set -o allexport
[[ -f .env ]] && source .env
set +o allexport

eval "$(ssh-agent -s)" # Start ssh-agent cache
chmod 600 .travis/nikoyan-rsa # Allow read access to the private key
ssh-add .travis/nikoyan-rsa # Add the private key to SSH

# Skip unkown host promt
echo "Host $HOST
  StrictHostKeyChecking no
  UserKnownHostsFile=/dev/null" > ~/.ssh/config

# Pushing changes to server
git config --global push.default matching
git remote add deploy ssh://$GIT_USER@$HOST:$SSH_PORT$DEPLOY_DIR
git push deploy master

# This block is going to be executed on target machine
ssh $APP_USER@$HOST -p $SSH_PORT <<EOF
  cd $DEPLOY_DIR;
  yarn;
  yarn build;
  rm -rf ../root/*
  cp -r ./build/* ../root/
EOF
