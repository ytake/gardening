#!/usr/bin/env bash

GardeningRoot=~/.gardening

mkdir -p "$GardeningRoot"

cp -i src/stub/vagrant.yaml.dist "$GardeningRoot/vagrant.yaml"
cp -i src/stub/append.sh "$GardeningRoot/append.sh"
cp -i src/stub/aliases "$GardeningRoot/aliases"

printf "\033[0;33mInitialized.${NC}\n"
