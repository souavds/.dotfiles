set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/tui.sh"

log_header "Setting up Language Runtimes"

if ! command -v mise &>/dev/null; then
  log_error "mise not found. Install packages first."
  exit 1
fi

log_info "Configuring mise..."
mise settings set experimental true
mise settings set legacy_version_file true

log_info "Installing language runtimes..."

runtimes=(
  "node@lts"
  "python@latest"
  "go@latest"
  "bun@latest"
)

for runtime in "${runtimes[@]}"; do
  log_info "Installing $runtime..."
  mise use -g "$runtime"
done

log_info "Activating mise in current shell..."
eval "$(mise activate bash)"

log_success "Language runtimes installed"
mise list
