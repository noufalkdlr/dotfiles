# =============================================================================
# .zshrc Configuration
# =============================================================================

# --- Plugins & Tools ---
source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# ---- Environment Variables & PATH ----

# --- Default Browser ---
export BROWSER=firefox

# Local bin directory for custom scripts
export PATH="$HOME/.local/bin:$PATH"

# Android Studio Configuration
export ANDROID_HOME=$HOME/Android/Sdk
export PATH=$PATH:$ANDROID_HOME/emulator
export PATH=$PATH:$ANDROID_HOME/platform-tools

# ---- Starship ----
eval "$(starship init zsh)"

# --- NVM Configuration ---
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && source "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && source "$NVM_DIR/bash_completion"


# --- Yazi Wrapper Function ---
function y() {
	local tmp="$(mktemp -t "yazi-cwd.XXXXXX")"
	yazi "$@" --cwd-file="$tmp"
	if cwd="$(cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
		builtin cd -- "$cwd"
	fi
	rm -f -- "$tmp"
}

# --- Basic Completion Config ---
autoload -Uz compinit
compinit

# Case Insensitive Matching (read -> README)
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'

# Menu Selection
zstyle ':completion:*' menu select

# Autosuggestion color change (Grey)
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=242'

# --- Aliases ---
# --- Color Aliases ---
alias ls='ls --color=auto'
alias grep='grep --color=auto'
alias diff='diff --color=auto'

# Activate Python virtual environment
alias env='source .venv/bin/activate'

# Hyprland Config
alias hypr='nvim ~/dotfiles/hypr/.config/hypr'

# Cashevide Server
alias cashevide-server='ssh root@46.225.234.48'

# Github Copilot
alias ai="gh copilot"

# zoxide
eval "$(zoxide init zsh)"

# --- Enable Vi Mode ---
bindkey -v
export KEYTIMEOUT=1

# Fix Backspace in vi-insert mode
bindkey '^?' backward-delete-char
bindkey '^H' backward-delete-char

# --- Startup ---
if [ $(ls /dev/pts | grep -c '^[0-9]') -eq 1 ]; then
    fastfetch
fi

