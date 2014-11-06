#!/bin/bash -e

cd $(dirname "$0")

for i; do
    i="${i//\//.}"
    i="${i%.py}"
    python -m "$i"
done
