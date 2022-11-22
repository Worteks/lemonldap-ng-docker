#!/bin/bash

# tgz version
tar -czf radius_patch.tgz freeradius patch Dockerfile RADIUS_ATTRIBUTES.md README.md
# zip version
zip radius_patch.zip -r freeradius/ patch/ Dockerfile RADIUS_ATTRIBUTES.md README.md

