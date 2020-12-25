#!/usr/bin/env bash

set -euo pipefail

# upstream translation
UPSTREAM='https://translate.zettlr.com/download/en-US.json'
OUTPUT='en-US.json'

curl -Ss "$UPSTREAM" >"$OUTPUT"
