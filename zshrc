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
alias vim='nvim'


export FZF_DEFAULT_OPTS='-x'
export NVIM_TUI_ENABLE_TRUE_COLOR=1
export TERM=xterm-256color


export GOROOT=/usr/local/go
export GOPATH=/home/icholy/Code
export GOBIN=$GOPATH/bin
export GO15VENDOREXPERIMENT=1

export ARTI=/usr/local/arti
export EDITOR=nvim

# Uncomment following line if you want to disable command autocorrection
DISABLE_CORRECTION="true"

# Uncomment following line if you want red dots to be displayed while waiting for completion
COMPLETION_WAITING_DOTS="true"

# Enabled plugins
plugins=(golang git godoc pip grunt gitfast jira)

source $ZSH/oh-my-zsh.sh


# z jump script
source /usr/local/bin/z.sh

# git z jump
gz () {
  local _ROOT=$(ghq root)
  local _REPO=$(ghq list | fzf)
  cd "$_ROOT/$_REPO"
} 

# Customize to your needs...
export PATH=$PATH:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games:$GOBIN:$GOROOT/bin:/usr/java/jre1.7.0_25/bin:$ARTI/bin:$HOME/.rvm/bin:/opt/extras.ubuntu.com/uberwriter/bin

export CDPATH=$CDPATH:/usr/local/arti:~:~/Code/repositories:~/Code/projects

source ~/.profile
