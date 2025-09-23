#!/usr/bin/env bash
set -euo pipefail

# Defaults (override via environment variables or compose)
: "${JMETER_TESTPLAN:=/testplan/load-test-1.jmx}"
: "${JMETER_JTL:=/results/results.jtl}"
: "${JMETER_REPORT:=/reports/html}"

# Common performance knobs (picked up by ${__P(...)} inside JMX)
: "${threads:=50}"
: "${rampup:=10}"
: "${duration:=60}"

# JVM memory (Dockerfile default can be overridden by env)
export JVM_ARGS="${JMETER_HEAP:-"-Xms512m -Xmx2048m"}"

# Include optional properties files if present
USER_PROPS_ARGS=""
[[ -f /config/user.properties ]] && USER_PROPS_ARGS="${USER_PROPS_ARGS} -q /config/user.properties"
[[ -f /config/system.properties ]] && USER_PROPS_ARGS="${USER_PROPS_ARGS} -S /config/system.properties"

# Ensure output dirs
mkdir -p "$(dirname "${JMETER_JTL}")" "${JMETER_REPORT}"

echo ">> Running JMeter non-GUI"
echo "   Test plan : ${JMETER_TESTPLAN}"
echo "   Results   : ${JMETER_JTL}"
echo "   Report    : ${JMETER_REPORT}"
echo "   Params    : threads=${threads} rampup=${rampup} duration=${duration}"
echo "   JVM_ARGS  : ${JVM_ARGS}"

# Build CLI args
CLI_ARGS=(
  -n
  -t "${JMETER_TESTPLAN}"
  -l "${JMETER_JTL}"
  -e -o "${JMETER_REPORT}"
  -Jthreads="${threads}"
  -Jrampup="${rampup}"
  -Jduration="${duration}"
)

# Pass through any extra arguments provided to the container
# e.g. `command: ["-Jfoo=bar", "-Jusers=100"]` in compose
exec jmeter ${USER_PROPS_ARGS} "${CLI_ARGS[@]}" "$@"
