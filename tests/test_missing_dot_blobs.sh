#!/usr/bin/env bash

set -o errexit -o nounset -o pipefail

# portable version of readlink -f
ROOT_DIR=$(cd $(dirname $0)/.. && pwd)

cd tmp

export RSYNC_URL=example.com:873
! "$ROOT_DIR"/bosh-rsync-blobs
