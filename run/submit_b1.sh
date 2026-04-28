#!/bin/bash
# Tiny helper — hpc shell --cmd has trouble passing script arguments
set -euo pipefail
SCRIPT="/path/to/iHBCAv1_upload/publication/run/B1_package_external.sh"
mkdir -p /path/to/iHBCAv1_upload/publication/logs
mkdir -p /path/to/iHBCAv1_upload/publication/outputs/source_datasets/intermediates
bash "$SCRIPT" submit
