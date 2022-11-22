#!/bin/bash

# tgz version
tar -czf radius_patch.tgz freeradius patch Dockerfile RADIUS_ATTRIBUTES.md README.md docker-entrypoint.sh
# zip version
zip radius_patch.zip -r freeradius/ patch/ Dockerfile RADIUS_ATTRIBUTES.md README.md docker-entrypoint.sh

sha256sum radius_patch.tgz radius_patch.zip >radius_patch.sha256
