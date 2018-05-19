# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH

# Path to your oh-my-zsh installation.
ZSH=$HOME/.oh-my-zsh

# Set name of the theme to load. Optionally, if you set this to "random"
# it'll load a random theme each time that oh-my-zsh is loaded.
# See https://github.com/robbyrussell/oh-my-zsh/wiki/Themes
ZSH_THEME="agnoster"

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion. Case
# sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment the following line to disable bi-weekly auto-update checks.
#DISABLE_AUTO_UPDATE="true"

# Uncomment the following line to change how often to auto-update (in days).
# export UPDATE_ZSH_DAYS=13

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# The optional three formats: "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load? (plugins can be found in ~/.oh-my-zsh/plugins/*)
# Custom plugins may be added to ~/.oh-my-zsh/custom/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(git python archlinux vi-mode history-substring-search zsh-syntax-highlighting)

source $HOME/.zsh_aliases

alias zshconfig="vim ~/.zshrc"
alias ohmyzsh="vim ~/.oh-my-zsh"

ZSH_CACHE_DIR=$HOME/.oh-my-zsh-cache
if [[ ! -d $ZSH_CACHE_DIR ]]; then
  mkdir $ZSH_CACHE_DIR
fi

source $ZSH/oh-my-zsh.sh

#Stop Ctrl+S killing the screen updates in vim
stty -ixon

#Set default apps
export VISUAL=vim
export EDITOR=vim
export BROWSER=w3m

# Add Tracer module to the python path
export PYTHONPATH=$PYTHONPATH:$HOME/repos/phd
export MYPYPATH=$MYPYPATH:$HOME/repos/phd

# GO variables
export GOPATH=$HOME/repos/go
export PATH=$PATH:$GOPATH/bin
alias gb=$GOPATH/bin/gb

# Storm binaries
export PATH=$PATH:$HOME/tools/storm/bin

# Heron client tools
export PATH=$PATH:$HOME/tools/heron/bin

# Spark binaries
export SPARK_HOME=$HOME/tools/spark
export PATH=$PATH:$SPARK_HOME/bin
export PYSPARK_PYTHON=python3

# Cassandra Binaries
export CASSANDRA_HOME=$HOME/tools/cassandra
export PATH=$PATH:$CASSANDRA_HOME/bin

# Kafka 
export KAFKA_HOME=$HOME/tools/kafka

# Proto Buffer Compiler
export PATH=$PATH:$HOME/tools/protoc/bin

# Add pico8 to path
export PATH=$PATH:$HOME/tools/pico-8

# Add bazel build directory to the path
export PATH=$PATH:$HOME/bin

# Set env vars for bazel builds
export PATH=$PATH:$HOME/tools/bazel/bazel054/bin
export JAVA_HOME=/usr/lib/jvm/java-8-openjdk
export CC=/usr/bin/gcc
export CXX=/usr/bin/g++

# Set the timewarrior data folder location
export TIMEWARRIORDB=$HOME/GDrive/Tasks/TimeWarrior
