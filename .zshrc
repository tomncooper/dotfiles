# Load Plugins
source $HOME/tools/scripts/zsh_plugins.sh

autoload -Uz compinit 
compinit

COMPLETION_WAITING_DOTS="true"

# History file settings
HISTFILE=$HOME/.zsh_history
HISTSIZE=5000000
SAVEHIST=$HISTSIZE
HIST_STAMPS="yyyy-mm-dd"

setopt EXTENDED_HISTORY          # Write the history file in the ':start:elapsed;command' format.
setopt HIST_EXPIRE_DUPS_FIRST    # Expire a duplicate event first when trimming history.
setopt HIST_FIND_NO_DUPS         # Do not display a previously found event.
setopt HIST_IGNORE_ALL_DUPS      # Delete an old recorded event if a new event is a duplicate.
setopt HIST_IGNORE_DUPS          # Do not record an event that was just recorded again.
setopt HIST_IGNORE_SPACE         # Do not record an event starting with a space.
setopt HIST_SAVE_NO_DUPS         # Do not write a duplicate event to the history file.

# Stop zsh recommending stupid things!
ENABLE_CORRECTION="false"
unsetopt correct_all

# Use Vim keybindings
bindkey -v
autoload edit-command-line
zle -N edit-command-line
bindkey -M vicmd v edit-command-line

# Set the keys for the substring search
bindkey "^[[A" history-substring-search-up
bindkey "^[OA" history-substring-search-up
bindkey "^[[B" history-substring-search-down
bindkey "^[OB" history-substring-search-down

#bindkey "$terminfo[kcuu1]" history-substring-search-up
#bindkey "$terminfo[kcud1]" history-substring-search-down

# Stop Home and End keys doing weird things
bindkey "${terminfo[khome]}" beginning-of-line
bindkey "${terminfo[kend]}" end-of-line
# Make the delete key do sensible things
bindkey "^[[3~" delete-char

# Read all the aliases
source $HOME/.zsh_aliases

alias zshconfig="vim ~/.zshrc"

#Stop Ctrl+S killing the screen updates in vim
stty -ixon

#Set default apps
export VISUAL=vim
export EDITOR=vim
export BROWSER=firefox

# Set the default wallpaper directory
export WALLPAPERS=$HOME/SynologyDrive/Photos/Wallpaper/

# Add user binaries to the path
export PATH=$PATH:$HOME/bin

# Add Kafka Tools
export KAFKA_HOME=$HOME/tools/kafka
export PATH=$PATH:$KAFKA_HOME/bin

# Add PIP installed binaries to the path
export PATH=$PATH:$HOME/.local/bin
export PYENVS=$HOME/.pyenvs

# GO variables
export GOPATH=$HOME/repos/go
export PATH=$PATH:$GOPATH/bin

# Kubernetes
[[ $commands[kubectl] ]] && source <(kubectl completion zsh)

# Minikube
source <(minikube completion zsh)

# FZF
source <(fzf --zsh)
source $HOME/tools/fzf-git.sh
export FZF_ALT_C_OPTS="--walker=file,dir,follow --walker-skip=Games"

# Podman 
# This lets testcontainers run using podman
export TESTCONTAINERS_RYUK_DISABLED=true
# This lets the fabric8 docker plugin build using podman
#export DOCKER_HOST="unix:/run/user/$(id -u)/podman/podman.sock"
export DOCKER_HOST="unix://$XDG_RUNTIME_DIR/podman/podman.sock"

# Read the local config file -- This is not stored in yadm so use for system specific config
source $HOME/.zsh_local

# Load Startship prompt - configured via $HOME/.config/starship.toml
eval "$(starship init zsh)"

#THIS MUST BE AT THE END OF THE FILE FOR SDKMAN TO WORK!!!
export SDKMAN_DIR="$HOME/.sdkman"
[[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]] && source "$HOME/.sdkman/bin/sdkman-init.sh"

