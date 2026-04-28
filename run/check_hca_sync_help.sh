#!/bin/bash
#SBATCH --job-name=check_sync_help
#SBATCH --account=your_lab_account
#SBATCH --partition=standard
#SBATCH --time=00:05:00
#SBATCH --mem=4G
#SBATCH --cpus-per-task=1
#SBATCH --output=/path/to/iHBCAv1_upload/publication/logs/check_sync_help_%j.out
#SBATCH --error=/path/to/iHBCAv1_upload/publication/logs/check_sync_help_%j.err

module load python/3.10.2
hca-smart-sync sync --help
