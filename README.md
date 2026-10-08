# terminal-setup

Kitty + zsh + Starship, shared between my CachyOS gaming PC and macOS work laptop.

- **Terminal:** Kitty, Tokyo Night Storm theme, MesloLGS Nerd Font
- **Shell:** zsh with fzf-tab, autosuggestions, syntax highlighting
- **Prompt:** Starship, single line, current dir + git only
- **Tools:** eza, bat, zoxide, atuin, btop, fastfetch

## Install

```bash
git clone git@github.com:psinats/terminal-setup.git ~/workspace/projects/terminal-setup
~/workspace/projects/terminal-setup/install.sh
```

The script installs packages (Homebrew on macOS, pacman + AUR on Arch), then symlinks the
configs into place, backing up anything already there as `*.bak`. Re-run it any time.

## Layout

```
kitty/kitty.conf          -> ~/.config/kitty/kitty.conf
kitty/current-theme.conf  -> ~/.config/kitty/current-theme.conf
starship/starship.toml    -> ~/.config/starship.toml
zsh/.zshrc                -> ~/.zshrc
```

Because they are symlinks, editing the file in `~` edits the repo — `git diff` shows the change,
commit and push to sync the other machine (`git pull` there; no re-install needed).

## Machine-specific settings

`~/.zshrc.local` is sourced at the end of `.zshrc` and is git-ignored. Put work PATH exports,
company tooling, nvm/pyenv init, and anything secret there.

## Change the theme

`kitten themes` previews ~300 themes and rewrites `current-theme.conf` in place. Commit the result.
