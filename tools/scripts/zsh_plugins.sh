# assumes github and slash separated plugin names
github_plugins=(
  zsh-users/zsh-autosuggestions
  zsh-users/zsh-completions
  zsh-users/zsh-syntax-highlighting
  zsh-users/zsh-history-substring-search
)

for plugin in $github_plugins; do
  # clone the plugin from github if it doesn't exist
  if [[ ! -d ${ZDOTDIR:-$HOME}/.zsh_plugins/$plugin ]]; then
    mkdir -p "${ZDOTDIR:-$HOME}/.zsh_plugins/${plugin%/*}"
    git clone --depth 1 --recursive https://github.com/$plugin.git ${ZDOTDIR:-$HOME}/.zsh_plugins/$plugin
  fi
  # load the plugin
  for initscript in ${plugin#*/}.zsh ${plugin#*/}.plugin.zsh ${plugin#*/}.sh; do
    if [[ -f ${ZDOTDIR:-$HOME}/.zsh_plugins/$plugin/$initscript ]]; then
      echo "Loading: ${ZDOTDIR:-$HOME}/.zsh_plugins/$plugin/$initscript"
      source ${ZDOTDIR:-$HOME}/.zsh_plugins/$plugin/$initscript
      break
    fi
  done
done

# clean up
unset github_plugins
unset plugin
unset initscript
