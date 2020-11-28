#!/usr/bin/env bash

set -euo pipefail

# upstream translation
UPSTREAM='https://raw.githubusercontent.com/Zettlr/Zettlr/develop/source/common/lang/en-US.json'
OUTPUT='en-US.json'

curl -Ss "$UPSTREAM" >"$OUTPUT"
