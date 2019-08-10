# rarecoil dotfile
# https://github.com/rarecoil/dotfiles

export PATH="/usr/local/opt/ruby/bin:/opt/metasploit-framework/bin:$PATH"
export GOPATH=$HOME/go;

if [[ "$OSTYPE" == "darwin"* ]]; then
    if [ -f "$HOME/.dotfiles/profile_darwin" ]; then
        source "$HOME/.dotfiles/profile_darwin"
    fi
fi
if [[ "$OSTYPE" == "linux-gnu" ]]; then
    if [ -f "$HOME/.dotfiles/profile_linux" ]; then
        source "$HOME/.dotfiles/profile_linux"
    fi
fi

# private env vars
if [ -f "$HOME/.profile_private" ]; then
    source $HOME/.profile_private;
fi

# aliases
alias genpass="LC_CTYPE=C tr -dc '[:alnum:]' < /dev/urandom | fold -w 40 | head -n 1"
alias zerodisk="gdd if=/dev/zero of=$1 bs=4M conv=fdatasync status=progress"
alias dockershell="docker run --rm -i -t --entrypoint=/bin/bash"

function cloneall() {
    ORG_URL="https://api.github.com/orgs/${1}/repos?per_page=200";
    ALL_REPOS=$(curl -u $GITHUB_API_TOKEN:x-oauth-basic -s ${ORG_URL} | grep html_url | awk 'NR%2 == 0' \
        $i | cut -d ':' -f 2-3 | tr -d '",');
    echo $ALL_REPOS;
    for ORG_REPO in ${ALL_REPOS}; do
        git clone ${ORG_REPO}.git;
    done
}

function gi() { curl -sL https://www.gitignore.io/api/$@ ; }

# powerline-go
function _update_ps1() {
    PS1="$($GOPATH/bin/powerline-go -error $?)"
}

if [ "$TERM" != "linux" ] && [ -f "$GOPATH/bin/powerline-go" ]; then
    PROMPT_COMMAND="_update_ps1; $PROMPT_COMMAND"
fi

# homebrew-specific
export HOMEBREW_NO_ANALYTICS=1
export HOMEBREW_NO_INSECURE_REDIRECT=1
export HOMEBREW_CASK_OPTS=--require-sha

HOMEBREW_PREFIX=$(brew --prefix)
if type brew &>/dev/null; then
  for COMPLETION in "$HOMEBREW_PREFIX"/etc/bash_completion.d/*
  do
    [[ -f $COMPLETION ]] && source "$COMPLETION"
  done
  if [[ -f ${HOMEBREW_PREFIX}/etc/profile.d/bash_completion.sh ]];
  then
    source "${HOMEBREW_PREFIX}/etc/profile.d/bash_completion.sh"
  fi
fi
