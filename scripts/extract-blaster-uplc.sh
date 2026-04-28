#!/usr/bin/env bash
set -euo pipefail

blueprint="${1:-plutus.json}"
output_dir="${2:-lean-blaster/generated}"

mkdir -p "$output_dir"

extract() {
  local title="$1"
  local output="$2"

  jq -er --arg title "$title" '
    .validators[]
    | select(.title == $title)
    | .compiledCode
  ' "$blueprint" | tr -d '\n\r[:space:]' > "$output"
}

extract "state.state.mint" "$output_dir/mpf_state_mint.flat"
extract "state.state.spend" "$output_dir/mpf_state_spend.flat"
extract "request.request.spend" "$output_dir/mpf_request_spend.flat"
