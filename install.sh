#!/usr/bin/env bash
# Installs Kitty + zsh + Starship + CLI tools and symlinks the configs in this repo.
# Works on macOS (Homebrew) and Arch/CachyOS (pacman + paru/yay).
# Safe to re-run: existing configs are backed up to *.bak before linking.
set -euo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OS="$(uname -s)"

say()  { printf '\n\033[1;36m==> %s\033[0m\n' "$*"; }
link() {  # link <repo file> <target>
  local src="$1" dst="$2"
  mkdir -p "$(dirname "$dst")"
  if [ -e "$dst" ] && [ ! -L "$dst" ]; then
    mv "$dst" "$dst.bak"; echo "    backed up $dst -> $dst.bak"
  fi
  ln -sfn "$src" "$dst"; echo "    $dst -> $src"
}

# ---------------------------------------------------------------- packages
case "$OS" in
  Darwin)
    say "macOS: installing with Homebrew"
    if ! command -v brew >/dev/null; then
      echo "Homebrew not found. Install it from https://brew.sh then re-run."; exit 1
    fi
    brew install --cask kitty font-meslo-lg-nerd-font
    brew install starship fzf zoxide eza bat atuin btop fastfetch \
                 zsh-autosuggestions zsh-syntax-highlighting zsh-completions
    ;;
  Linux)
    say "Linux: installing with pacman"
    sudo pacman -S --needed --noconfirm kitty zsh starship fzf zoxide eza bat atuin btop fastfetch \
      zsh-autosuggestions zsh-syntax-highlighting zsh-completions ttf-meslo-nerd
    if command -v paru >/dev/null;  then paru -S --needed --noconfirm fzf-tab-git
    elif command -v yay >/dev/null; then yay  -S --needed --noconfirm fzf-tab-git
    else echo "    no AUR helper found; fzf-tab will be cloned to ~/.zsh instead"
    fi
    ;;
  *) echo "Unsupported OS: $OS"; exit 1 ;;
esac

# fzf-tab from git when no package provided it
if [ ! -f /usr/share/zsh/plugins/fzf-tab-git/fzf-tab.plugin.zsh ]; then
  say "fzf-tab (git clone)"
  if [ -d ~/.zsh/fzf-tab ]; then git -C ~/.zsh/fzf-tab pull -q
  else mkdir -p ~/.zsh && git clone -q https://github.com/Aloxaf/fzf-tab ~/.zsh/fzf-tab
  fi
fi

# ----------------------------------------------------------------- configs
say "Linking configs"
link "$REPO/kitty/kitty.conf"         "$HOME/.config/kitty/kitty.conf"
link "$REPO/kitty/current-theme.conf" "$HOME/.config/kitty/current-theme.conf"
[ -L "$HOME/.config/starship.toml" ] || link "$REPO/starship/flat.toml" "$HOME/.config/starship.toml"   # keeps your chosen style on re-run
link "$REPO/zsh/.zshrc"               "$HOME/.zshrc"
[ -f "$HOME/.zshrc.local" ] || { touch "$HOME/.zshrc.local"; echo "    created empty ~/.zshrc.local for machine-specific settings"; }

# ------------------------------------------------------------- login shell
if [ "$OS" = Linux ] && [ "$(basename "$SHELL")" != zsh ]; then
  say "Setting zsh as login shell"
  chsh -s "$(command -v zsh)"
fi

say "Done. Open a new Kitty window."
[ "$OS" = Darwin ] && echo "    Kitty is in /Applications. If icons show as boxes, run: kitten choose-fonts"
