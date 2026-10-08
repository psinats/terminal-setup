# ---------------------------------------------------------------------------
# Shared .zshrc — works on macOS (Homebrew) and Arch/CachyOS (pacman)
# Machine-specific or work-specific bits go in ~/.zshrc.local (not tracked)
# ---------------------------------------------------------------------------

# Homebrew (macOS; no-op on Linux)
[ -x /opt/homebrew/bin/brew ] && eval "$(/opt/homebrew/bin/brew shellenv)"
[ -x /usr/local/bin/brew ]    && eval "$(/usr/local/bin/brew shellenv)"

# Where zsh plugins live on this OS
if command -v brew >/dev/null 2>&1; then
  PLUGIN_DIR="$(brew --prefix)/share"
  fpath+=("$PLUGIN_DIR/zsh-completions")
else
  PLUGIN_DIR="/usr/share/zsh/plugins"
fi

# History
HISTFILE=~/.zsh_history
HISTSIZE=50000
SAVEHIST=50000
setopt share_history hist_ignore_dups hist_ignore_space

# Completion
autoload -Uz compinit && compinit
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'eza -1 --color=always $realpath'

# Plugins (fzf-tab first, syntax-highlighting last)
if [ -f ~/.zsh/fzf-tab/fzf-tab.plugin.zsh ]; then
  source ~/.zsh/fzf-tab/fzf-tab.plugin.zsh
elif [ -f "$PLUGIN_DIR/fzf-tab-git/fzf-tab.plugin.zsh" ]; then
  source "$PLUGIN_DIR/fzf-tab-git/fzf-tab.plugin.zsh"
fi
source "$PLUGIN_DIR/zsh-autosuggestions/zsh-autosuggestions.zsh"
source "$PLUGIN_DIR/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"

# Tools
# Repo root: follow the ~/.zshrc symlink back to the repo (zsh :A = realpath)
_zrc="$HOME/.zshrc"; TERMINAL_SETUP="${_zrc:A:h:h}"; unset _zrc
[ -d "$TERMINAL_SETUP/starship" ] || TERMINAL_SETUP="$HOME/workspace/projects/terminal-setup"
eval "$(starship init zsh)"
eval "$(zoxide init zsh --cmd cd)"
eval "$(atuin init zsh --disable-up-arrow)"   # Up = plain zsh history, Ctrl-R = atuin search
source <(fzf --zsh)

# Switch Starship prompt style:  prompt-style flat | prompt-style powerline
prompt-style() {
  local f="$TERMINAL_SETUP/starship/$1.toml"
  [ -f "$f" ] || { echo "styles: $(ls "$TERMINAL_SETUP/starship" | sed 's/\.toml$//' | tr '\n' ' ')"; return 1; }
  ln -sfn "$f" ~/.config/starship.toml && echo "prompt -> $1"
}

# Aliases
alias ls='eza --icons --group-directories-first'
alias ll='eza -l --icons --git'
alias la='eza -la --icons --git'
alias tree='eza --tree --icons'
alias cat='bat --paging=never'
alias top='btop'

# Keybinds
bindkey '^[[1;5C' forward-word    # Ctrl-Right
bindkey '^[[1;5D' backward-word   # Ctrl-Left
bindkey '^[[1;3C' forward-word    # Alt-Right (macOS)
bindkey '^[[1;3D' backward-word   # Alt-Left
bindkey '^ ' autosuggest-accept   # Ctrl-Space

# Up/Down: when something is typed, cycle only history entries starting with it
autoload -Uz up-line-or-beginning-search down-line-or-beginning-search
zle -N up-line-or-beginning-search
zle -N down-line-or-beginning-search
bindkey '^[[A' up-line-or-beginning-search
bindkey '^[[B' down-line-or-beginning-search

# Local / work overrides (PATH exports, company tooling, nvm/pyenv, secrets)
[ -f ~/.zshrc.local ] && source ~/.zshrc.local

# Splash
command -v fastfetch >/dev/null && fastfetch
