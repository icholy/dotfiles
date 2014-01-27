# Path to your oh-my-zsh configuration.
ZSH=$HOME/.oh-my-zsh

# Set name of the theme to load.
# Look in ~/.oh-my-zsh/themes/
ZSH_THEME="robbyrussell"

# Aliases
alias zshconfig="vim ~/.zshrc; source ~/.zshrc"
alias lg="ls | grep -i"
alias sagi="sudo apt-get install"
alias mixer="alsamixer"
alias now='date +"%r"'
alias tmux='tmux -2'

export TERM=xterm-256color

# screen-256color if tmux is running
if [ -n "$TMUX" ]; then
  export TERM=screen-256color
fi

export GOROOT=/opt/go
export GOPATH=/home/icholy/code/go
export GOBIN=$GOPATH/bin
export ARTI=/usr/local/arti
export EDITOR=vim

# Go stuff that should not be here ...
gow () {
  while true; do
    clear
    echo "go $@"
    go "$@"
    if [ $? -eq 0 ]; then break; fi
    inotifywait -re modify *.go 2> /dev/null
  done
}

gdbb () {
  go build -gcflags "-N -l" -o out
  if [ $? != 0 ]; then return; fi
  gdbb-extract "*.go" > .breakpoints
  if [ ! -s .breakpoints ]; then echo "break main.main" > .breakpoints; fi
  gdb -x .breakpoints -ex run -tui --args out "$@"
  rm .breakpoints out
}

# test
gdbbtest () {
  go test -c -gcflags "-N -l" "$@"
  if [ $? != 0 ]; then return; fi
  gdbb-extract "*.go" > .breakpoints
  if [ -s .breakpoints ]; then
    gdb -x .breakpoints -ex run *.test
  else
    gdb *.test
  fi
  rm .breakpoints *.test
}

# Uncomment following line if you want to disable command autocorrection
DISABLE_CORRECTION="true"

# Uncomment following line if you want red dots to be displayed while waiting for completion
COMPLETION_WAITING_DOTS="true"

# Enabled plugins
plugins=(git godoc gdoc pip grunt vi-mode)

source $ZSH/oh-my-zsh.sh
source /usr/local/bin/z.sh

# Customize to your needs...
export PATH=$PATH:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games:$GOBIN:$GOROOT/bin:/usr/java/jre1.7.0_25/bin:$ARTI/bin:$HOME/.rvm/bin:/opt/extras.ubuntu.com/uberwriter/bin

export CDPATH=$CDPATH:/usr/local/arti:~:~/code/repositories:~/code/projects

source ~/.profile

# vi mode
set -o vi
bindkey -M vicmd '/' history-incremental-search-backward

