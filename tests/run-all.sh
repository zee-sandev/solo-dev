#!/bin/bash
# Run all solo-dev unit tests
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
TOTAL_PASS=0
TOTAL_FAIL=0

echo "=============================="
echo "  solo-dev: Running all tests"
echo "=============================="
echo ""

for test in "$SCRIPT_DIR"/test-*.sh; do
  echo "--- $(basename "$test") ---"
  if bash "$test"; then
    echo ""
  else
    TOTAL_FAIL=$((TOTAL_FAIL + 1))
    echo ""
  fi
done

echo "=============================="
if [ "$TOTAL_FAIL" -eq 0 ]; then
  echo "  ALL TEST SUITES PASSED"
else
  echo "  $TOTAL_FAIL TEST SUITE(S) FAILED"
fi
echo "=============================="

exit $TOTAL_FAIL
