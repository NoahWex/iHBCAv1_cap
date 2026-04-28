#!/bin/bash
#SBATCH --job-name=inspect_raw_var
#SBATCH --account=your_lab_account
#SBATCH --partition=standard
#SBATCH --time=00:10:00
#SBATCH --mem=8G
#SBATCH --cpus-per-task=1
#SBATCH --output=/path/to/iHBCAv1_upload/publication/logs/inspect_raw_var_%j.out
#SBATCH --error=/path/to/iHBCAv1_upload/publication/logs/inspect_raw_var_%j.err

set -euo pipefail

REPO=/path/to/iHBCAv1_upload
SIF=/dfs8/singularity_containers/rcic/devel/Jupyter_R_4.4.2_Giotto_Spatial_Python_2025Q2.sif

INTEGRATED="$REPO/publication/outputs/integrated_objects/all-breast-cells.h5ad"
SKETCH="$REPO/publication/outputs/integrated_objects/sketch.h5ad"

echo "=== Inspecting raw/var column-order ==="

for H5AD in "$INTEGRATED" "$SKETCH"; do
    echo ""
    echo "--- $H5AD ---"
    module load singularity
    singularity exec \
        --bind /path/to/workspace:/path/to/workspace \
        --bind /dfs8:/dfs8 \
        "$SIF" python3 -c "
import h5py
path = '$H5AD'
with h5py.File(path, 'r') as f:
    has_raw = 'raw' in f
    has_raw_var = has_raw and 'var' in f['raw']
    print('has_raw:', has_raw)
    print('has_raw_var:', has_raw_var)
    if has_raw_var:
        col_order = list(f['raw/var'].attrs.get('column-order', []))
        keys = sorted(f['raw/var'].keys())
        print('raw/var keys:', keys[:5], '...' if len(keys) > 5 else '')
        print('feature_is_filtered in keys:', 'feature_is_filtered' in keys)
        print('feature_is_filtered in column-order:', 'feature_is_filtered' in col_order)
        print('column-order length:', len(col_order))
        if 'feature_is_filtered' in col_order:
            idx = col_order.index('feature_is_filtered')
            print('position in column-order:', idx)
"
done

echo ""
echo "=== Done ==="
