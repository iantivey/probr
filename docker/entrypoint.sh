#!/bin/sh

go run cmd/main.go -outputType=IO -outputDir=./cucumber_output
node internal/view/index.js ./cucumber_output
