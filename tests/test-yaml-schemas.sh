#!/bin/bash
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PLUGIN_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
source "$SCRIPT_DIR/helpers.sh"

echo "--- test-yaml-schemas ---"

# Test each YAML file parses correctly
for yaml_file in "$PLUGIN_DIR/docs/yaml/"*.yaml; do
  basename=$(basename "$yaml_file")
  result=$(python3 -c "import yaml; yaml.safe_load(open('$yaml_file'))" 2>&1)
  assert_exit_code $? 0 "$basename should parse as valid YAML"
done

# Test features.yaml has correct structure
result=$(python3 -c "
import yaml
data = yaml.safe_load(open('$PLUGIN_DIR/docs/yaml/features.yaml'))
assert data['version'] == 1, 'version should be 1'
assert isinstance(data['features'], list), 'features should be a list'
print('OK')
" 2>&1)
assert_contains "$result" "OK" "features.yaml structure"

# Test specs.yaml
result=$(python3 -c "
import yaml
data = yaml.safe_load(open('$PLUGIN_DIR/docs/yaml/specs.yaml'))
assert data['version'] == 1
assert isinstance(data['specs'], list)
print('OK')
" 2>&1)
assert_contains "$result" "OK" "specs.yaml structure"

# Test contracts.yaml
result=$(python3 -c "
import yaml
data = yaml.safe_load(open('$PLUGIN_DIR/docs/yaml/contracts.yaml'))
assert data['version'] == 1
assert isinstance(data['contracts'], list)
print('OK')
" 2>&1)
assert_contains "$result" "OK" "contracts.yaml structure"

# Test demos.yaml
result=$(python3 -c "
import yaml
data = yaml.safe_load(open('$PLUGIN_DIR/docs/yaml/demos.yaml'))
assert data['version'] == 1
assert isinstance(data['demos'], list)
print('OK')
" 2>&1)
assert_contains "$result" "OK" "demos.yaml structure"

# Test sprints.yaml
result=$(python3 -c "
import yaml
data = yaml.safe_load(open('$PLUGIN_DIR/docs/yaml/sprints.yaml'))
assert data['version'] == 1
assert isinstance(data['sprints'], list)
print('OK')
" 2>&1)
assert_contains "$result" "OK" "sprints.yaml structure"

# Test changelog.yaml
result=$(python3 -c "
import yaml
data = yaml.safe_load(open('$PLUGIN_DIR/docs/yaml/changelog.yaml'))
assert data['version'] == 1
assert isinstance(data['entries'], list)
print('OK')
" 2>&1)
assert_contains "$result" "OK" "changelog.yaml structure"

# Test memory-index.yaml
result=$(python3 -c "
import yaml
data = yaml.safe_load(open('$PLUGIN_DIR/docs/yaml/memory-index.yaml'))
assert data['version'] == 1
assert isinstance(data['files'], dict)
assert 'decisions' in data['files']
assert 'patterns' in data['files']
print('OK')
" 2>&1)
assert_contains "$result" "OK" "memory-index.yaml structure"

# Test backlog.yaml
result=$(python3 -c "
import yaml
data = yaml.safe_load(open('$PLUGIN_DIR/docs/yaml/backlog.yaml'))
assert data['version'] == 1
assert isinstance(data['items'], list)
print('OK')
" 2>&1)
assert_contains "$result" "OK" "backlog.yaml structure"

report "test-yaml-schemas"
