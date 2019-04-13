#!/bin/bash

# Load up .env
cp env/testing.env .env
set -o allexport
[[ -f .env ]] && source .env
set +o allexport

yarn test;
