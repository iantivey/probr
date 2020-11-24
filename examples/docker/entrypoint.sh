#!/bin/sh
cd /probr
./probr --outputType=IO --varsFile=./config.yml
node internal/view/index.js ./cucumber_output
