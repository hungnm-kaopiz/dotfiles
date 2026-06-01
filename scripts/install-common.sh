#!/bin/bash
# Shared helpers for chezmoi install scripts (sourced, not executed).

run_step() {
  local title="$1"
  shift
  echo ""
  echo "==> ${title}"
  if "$@"; then
    return 0
  fi
  echo "Warning: ${title} failed (exit $?)" >&2
  return 0
}

apt_install_packages() {
  local packages_file="$1"
  local pkg
  while IFS= read -r pkg; do
    [[ -z "$pkg" ]] && continue
    run_step "apt install ${pkg}" sudo apt-get install -y "$pkg"
  done < <(grep -v '^[[:space:]]*#' "$packages_file" | grep -v '^[[:space:]]*$')
}

install_eza() {
  command -v eza >/dev/null 2>&1 && return 0
  if apt-cache show eza >/dev/null 2>&1; then
    run_step "apt install eza" sudo apt-get install -y eza
    return 0
  fi
  run_step "install eza (gierens apt repo)" bash -c '
    command -v gpg >/dev/null 2>&1 || { sudo apt-get update && sudo apt-get install -y gpg; }
    sudo mkdir -p /etc/apt/keyrings
    curl -fsSL https://raw.githubusercontent.com/eza-community/eza/main/deb.asc \
      | sudo gpg --dearmor -o /etc/apt/keyrings/gierens.gpg
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/gierens.gpg] http://deb.gierens.de stable main" \
      | sudo tee /etc/apt/sources.list.d/gierens.list
    sudo chmod 644 /etc/apt/keyrings/gierens.gpg /etc/apt/sources.list.d/gierens.list
    sudo apt-get update
    sudo apt-get install -y eza
  '
}

install_lazygit() {
  command -v lazygit >/dev/null 2>&1 && return 0
  local version arch
  version=$(curl -fsSL "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" \
    | grep -Po '"tag_name": "v\K[^"]*')
  arch="$(dpkg --print-architecture)"
  [[ "$arch" = "amd64" ]] && arch="x86_64"
  run_step "install lazygit ${version}" bash -c '
    curl -fsSL -o /tmp/lazygit.tar.gz \
      "https://github.com/jesseduffield/lazygit/releases/download/v'"${version}"'/lazygit_'"${version}"'_Linux_'"${arch}"'.tar.gz" \
    && sudo tar xf /tmp/lazygit.tar.gz -C /usr/local/bin lazygit \
    && rm -f /tmp/lazygit.tar.gz
  '
}

install_lazydocker() {
  command -v lazydocker >/dev/null 2>&1 && return 0
  local version arch
  version=$(curl -fsSL "https://api.github.com/repos/jesseduffield/lazydocker/releases/latest" \
    | grep -Po '"tag_name": "v\K[^"]*')
  arch="$(dpkg --print-architecture)"
  [[ "$arch" = "amd64" ]] && arch="x86_64"
  run_step "install lazydocker ${version}" bash -c '
    curl -fsSL -o /tmp/lazydocker.tar.gz \
      "https://github.com/jesseduffield/lazydocker/releases/download/v'"${version}"'/lazydocker_'"${version}"'_Linux_'"${arch}"'.tar.gz" \
    && sudo tar xf /tmp/lazydocker.tar.gz -C /usr/local/bin lazydocker \
    && rm -f /tmp/lazydocker.tar.gz
  '
}
