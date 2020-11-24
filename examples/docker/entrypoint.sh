#!/bin/sh
/probr/probr --outputType=IO --varsFile=/probr/config.yml --outputDir=/probr/cucumber_output
node /probr/internal/view/index.js /probr/cucumber_output
