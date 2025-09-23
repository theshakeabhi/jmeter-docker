#!/usr/bin/env bash
set -euo pipefail

# One-off runner without compose
docker build -t local/jmeter:5.6.3 .

docker run --rm \
  -e threads="${threads:-50}" \
  -e rampup="${rampup:-10}" \
  -e duration="${duration:-60}" \
  -e JMETER_HEAP="${JMETER_HEAP:--Xms512m -Xmx2048m}" \
  -v "$(pwd)/testplan:/testplan:ro" \
  -v "$(pwd)/config:/config:ro" \
  -v "$(pwd)/results:/results" \
  -v "$(pwd)/reports:/reports" \
  local/jmeter:5.6.3
