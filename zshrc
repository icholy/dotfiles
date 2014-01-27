# Path to your oh-my-zsh configuration.
ZSH=$HOME/.oh-my-zsh

# Set name of the theme to load.
# Look in ~/.oh-my-zsh/themes/
ZSH_THEME="robbyrussell"

# cop_cli config
export COP_HOST="http://10.200.7.43/cop_api"

# Aliases
alias zshconfig="vim ~/.zshrc; source ~/.zshrc"
alias lg="ls | grep -i"
alias sagi="sudo apt-get install"
alias mixer="alsamixer"
alias cowzen='curl https://api.github.com/zen -s | cowsay'
alias now='date +"%r"'
alias 'h?'='history | grep'
alias note=geeknote
alias tmux='tmux -2'

export TERM=xterm-256color

# screen-256color of tmux is running
if [ -n "$TMUX" ]; then
  export TERM=screen-256color
fi

export GOROOT=/opt/go
export GOPATH=/home/icholy/code/go
export GOBIN=$GOPATH/bin
export ARTI=/usr/local/arti
export EDITOR=vim

dual () {
  xrandr --output HDMI1 --auto   
  xrandr --output VGA1 --auto --left-of HDMI1
}

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

  # build with debug flags
  go build -gcflags "-N -l" -o out

  # make sure the build didn't fail
  if [ $? != 0 ]; then return; fi

  # extract debugger comments
  gdbb-extract "*.go" > .breakpoints

  # break on main if no breakpoints were found
  if [ ! -s .breakpoints ]; then echo "break main.main" > .breakpoints; fi

  # launch gdb
  gdb -x .breakpoints -ex run -tui --args out "$@"

  # clean up
  rm .breakpoints out
}

# test
gdbbtest () {

  # build with debug flags
  go test -c -gcflags "-N -l" "$@"

  # make sure the build didn't fail
  if [ $? != 0 ]; then return; fi

  # extract debugger comments
  gdbb-extract "*.go" > .breakpoints

  # if breakpoints were found, run on start
  if [ -s .breakpoints ]; then
    gdb -x .breakpoints -ex run *.test
  else
    gdb *.test
  fi

  # clean up
  rm .breakpoints *.test
}

wvim () { vim $(which $1); }

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

