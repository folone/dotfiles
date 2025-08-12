# Path to your oh-my-zsh configuration.
ZSH=$HOME/.oh-my-zsh

# Set name of the theme to load.
# Look in ~/.oh-my-zsh/themes/
# Optionally, if you set this to "random", it'll load a random theme each
# time that oh-my-zsh is loaded.
# ZSH_THEME="norm"

# RPROMPT='%{%B%F{green}%}%~%{%f%k%b%}'
# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"
alias vsc="code --disable-renderer-accessibility --disable-gpu"

# Set to this to use case-sensitive completion
# CASE_SENSITIVE="true"

# Comment this out to disable bi-weekly auto-update checks
# DISABLE_AUTO_UPDATE="true"

# Uncomment to change how many often would you like to wait before auto-updates occur? (in days)
# export UPDATE_ZSH_DAYS=13

# Uncomment following line if you want to disable colors in ls
# DISABLE_LS_COLORS="true"

# Uncomment following line if you want to disable autosetting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment following line if you want red dots to be displayed while waiting for completion
# COMPLETION_WAITING_DOTS="true"

# Which plugins would you like to load? (plugins can be found in ~/.oh-my-zsh/plugins/*)
# Custom plugins may be added to ~/.oh-my-zsh/custom/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
plugins=(git)

export PATH=/opt/homebrew/bin:/opt/homebrew/sbin:/usr/local/bin:/usr/bin:/bin:/Users/george.leontiev/workspace/venv/bin:$PATH

source $ZSH/oh-my-zsh.sh

source /opt/homebrew/share/antigen/antigen.zsh

antigen use oh-my-zsh
antigen bundle arialdomartini/oh-my-git
antigen theme cloud

antigen apply

# Mac stuff
export PATH=$PATH:/Applications
# -lgmp and such
export LIBRARY_PATH=/usr/local/lib:$LIBRARY_PATH

export EDITOR=nvim

export PATH="$PATH:$HOME/go/bin"
export PATH="$PATH:$HOME/.rvm/bin" # Add RVM to PATH for scripting
export PATH="$PATH:$HOME/.cabal/bin" # Cabal stuff
export PATH="$PATH:/usr/texbin" # MacTeX
export PATH="$PATH:/Applications/Visual Studio Code.app/Contents/Resources/app/bin" # VScode
export PATH="$PATH:/Library/TeX/texbin/" # LaTeX

export AWS_SDK_LOAD_CONFIG=true
export GOPRIVATE=github.snooguts.net
export SNOODEV_DIR=~/workspace/snoodev
autoload -U compinit; compinit
export PATH="/opt/homebrew/opt/openjdk/bin:$PATH"

# opam configuration
[[ ! -r /Users/george.leontiev/.opam/opam-init/init.zsh ]] || source /Users/george.leontiev/.opam/opam-init/init.zsh  > /dev/null 2> /dev/null

# Starship prompt (if installed)
if command -v starship >/dev/null 2>&1; then
  eval "$(starship init zsh)"
fi
