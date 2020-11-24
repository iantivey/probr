#!/bin/sh

/probr/probr -outputType=IO -outputDir=./cucumber_output -varsFile=/probr/config.yml
node internal/view/index.js ./cucumber_output
