#!/bin/bash

# Load up .env
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

git config --global push.default matching
git remote add deploy ssh://$GIT_USER@$HOST:$SSH_PORT$DEPLOY_DIR
git push deploy master

# Skip this command if you don't need to execute any additional commands after deploying.
ssh $APP_USER@$HOST -p $SSH_PORT <<EOF
  cd $DEPLOY_DIR;
  yarn;
  yarn build;
  rm -rf ../root/*
  cp -r ./build/* ../root/
EOF
