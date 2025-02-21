#!/bin/bash

mkdir -p dist

./merge.sh dist/ustb-cli-full account balance clock speedtest
./merge.sh dist/ustb-cli-server account balance speedtest
./merge.sh dist/ustb-cli-lite account

cp dist/ustb-cli-server ustb-cli
