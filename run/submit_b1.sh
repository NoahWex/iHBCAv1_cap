#!/bin/bash
# Tiny helper — hpc shell --cmd has trouble passing script arguments
set -euo pipefail
SCRIPT="/path/to/iHBCAv1_upload/run/B1_package_external.sh"
mkdir -p /path/to/iHBCAv1_upload/logs
mkdir -p /path/to/iHBCAv1_upload/outputs/source_datasets/intermediates
bash "$SCRIPT" submit
