# Path to your oh-my-zsh configuration.
ZSH=$HOME/.oh-my-zsh

# Set name of the theme to load.
# Look in ~/.oh-my-zsh/themes/
# Optionally, if you set this to "random", it'll load a random theme each
# time that oh-my-zsh is loaded.
ZSH_THEME="norm"

# RPROMPT='%{%B%F{green}%}%~%{%f%k%b%}'
# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"

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

source $ZSH/oh-my-zsh.sh

source "$HOME/.antigen/antigen.zsh"

antigen-use oh-my-zsh
antigen-bundle arialdomartini/oh-my-git
antigen theme arialdomartini/oh-my-git-themes arialdo-pathinline

antigen-apply

# My typical linux setup
export PYTHONPATH=/home/folone/workspace/backend
export SCALA_HOME=/usr/bin/scala/
export ANT_OPTS="-Xms1536m -Xmx1536m -XX:PermSize=1024m -XX:MaxPermSize=2048m"
#export SBT_OPTS=$ANT_OPTS
export TYPELEVEL_HOME=/home/folone/bin/typelevel-repl
export PATH=/home/folone/perl5/bin:/home/folone/perl5/bin:/usr/local/bin:/usr/bin:/bin:/usr/local/sbin:/usr/sbin:/sbin:/usr/bin/core_perl:/opt/qt/bin:/opt/maven/bin/:/home/folone/.cabal/bin:/home/folone/node_modules/roy:/home/folone/bin/:/home/folone/bin/play/:/opt/maven/bin/:/home/folone/.cabal/bin:/home/folone/node_modules/roy:/home/folone/bin/:/home/folone/bin/play/:$SCALA_HOME:/home/folone/bin/:$TYPELEVEL_HOME

# Mac stuff
export PATH=$PATH:/Applications
# -lgmp and such
export LIBRARY_PATH=/usr/local/lib:$LIBRARY_PATH

export EDITOR=emacs

eval "$(rbenv init -)"

export PATH="$PATH:$HOME/.rvm/bin" # Add RVM to PATH for scripting
export PATH="$PATH:$HOME/.cabal/bin" # Cabal stuff
export PATH="$PATH:/usr/texbin" # MacTeX
