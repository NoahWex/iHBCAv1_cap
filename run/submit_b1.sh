#!/bin/bash
# Helper wrapper: passes script arguments through to B1_package_external.sh
set -euo pipefail
SCRIPT="/path/to/iHBCAv1_upload/run/B1_package_external.sh"
mkdir -p /path/to/iHBCAv1_upload/logs
mkdir -p /path/to/iHBCAv1_upload/outputs/source_datasets/intermediates
bash "$SCRIPT" submit
