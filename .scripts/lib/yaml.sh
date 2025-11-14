#!/usr/bin/env bash

source "$(dirname "${BASH_SOURCE[0]}")/core.sh"

require_yq() {
  if ! command_exists yq; then
    error "yq is required but not installed. Please run bootstrap first."
  fi
}

yaml_get() {
  local file="$1"
  local key="$2"

  if [[ ! -f "$file" ]]; then
    log_error "YAML file not found: $file"
    return 1
  fi

  require_yq

  [[ "$key" != .* ]] && key=".$key"

  yq eval "$key" "$file" 2>/dev/null || true
}

yaml_array() {
  local file="$1"
  local path="$2"

  require_yq

  [[ "$path" != .* ]] && path=".$path"

  yq eval "${path}[]" "$file" 2>/dev/null | grep -v '^null$' | grep -v '^$' || true
}

yaml_has() {
  local file="$1"
  local key="$2"

  require_yq

  [[ "$key" != .* ]] && key=".$key"

  yq eval "has(\"$key\")" "$file" 2>/dev/null | grep -q "true"
}

get_packages() {
  local category="$1"
  local platform="${2:-common}"
  local yaml_file="$CONFIG_DIR/packages.yml"

  if [[ "$platform" == "common" ]]; then
    yaml_array "$yaml_file" "common.${category}"
  else
    yaml_array "$yaml_file" "${platform}.${category}"
  fi
}

get_all_packages() {
  local category="$1"
  local platform="${DISTRO:-$PLATFORM}"

  {
    get_packages "$category" "common"
    get_packages "$category" "$platform"
  } | sort -u
}

get_service_field() {
  local platform="$1"
  local device="$2"
  local index="$3"
  local field="$4"
  local yaml_file="$CONFIG_DIR/services.yml"

  if [[ -n "$device" ]]; then
    yaml_get "$yaml_file" "${platform}.${device}.services[$index].$field"
  else
    yaml_get "$yaml_file" "${platform}.services[$index].$field"
  fi
}

process_services() {
  local platform="$1"
  local device="$2"
  local callback="$3"
  local yaml_file="$CONFIG_DIR/services.yml"

  require_yq

  local count
  count=$(yq eval ".${platform}.${device}.services | length" "$yaml_file" 2>/dev/null || echo "0")

  if [[ "$count" == "0" || "$count" == "null" ]]; then
    return 0
  fi

  for ((i = 0; i < count; i++)); do
    local name
    name=$(get_service_field "$platform" "$device" "$i" "name")
    local package
    package=$(get_service_field "$platform" "$device" "$i" "package")
    local enable
    enable=$(get_service_field "$platform" "$device" "$i" "enable")
    local config_src
    config_src=$(get_service_field "$platform" "$device" "$i" "config_src")
    local config_dest
    config_dest=$(get_service_field "$platform" "$device" "$i" "config_dest")

    [[ -z "$name" || "$name" == "null" ]] && continue

    "$callback" "$name" "$package" "$enable" "$config_src" "$config_dest"
  done
}

get_firewall_config() {
  local platform="$1"
  local field="$2"
  local yaml_file="$CONFIG_DIR/services.yml"

  yaml_get "$yaml_file" "${platform}.firewall.${field}"
}

get_firewall_rules() {
  local platform="$1"
  local yaml_file="$CONFIG_DIR/services.yml"

  yaml_get "$yaml_file" "${platform}.firewall.rules[]"
}

get_laptop_config() {
  local platform="$1"
  local section="$2"
  local field="$3"
  local yaml_file="$CONFIG_DIR/services.yml"

  yaml_get "$yaml_file" "${platform}.laptop.${section}.${field}"
}

get_pam_files() {
  local platform="$1"
  local yaml_file="$CONFIG_DIR/services.yml"

  require_yq

  yq eval ".${platform}.laptop.fingerprint.pam_files[] | (.src + \" \" + .dest)" "$yaml_file" 2>/dev/null
}
