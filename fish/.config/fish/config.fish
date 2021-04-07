set fish_greeting ""
set -l configdir ~/.config/fish

# because fish complains if a path doesn't exist

for path in \
  $HOME/.gem/ruby/2.6.0/bin \
  $HOME/.krew/bin \
  $HOME/.local/bin \
  $HOME/.npm-global/bin \
  $HOME/bin \
  $HOME/go/bin \
  $HOME/macports/Library/Frameworks/Python.framework/Versions/3.7/bin \
  $HOME/macports/bin \
  $HOME/macports/sbin \
  /opt/local/bin \
  /snap/bin \
  /usr/local/bin \
  $HOME/.local/go/bin
  if test -d $path
    set -x PATH $path $PATH
  end
end

#set -x PATH $HOME/macports/Library/Frameworks/Python.framework/Versions/3.7/bin $PATH


set -x GOPATH $HOME/go

# direnv
#direnv hook fish | source

# Powerline config
if status is-interactive
  for path in $HOME/.local/lib/python3.7/site-packages/powerline/bindings/fish $HOME/macports/Library/Frameworks/Python.framework/Versions/3.7/lib/python3.7/site-packages/powerline/bindings/fish
    if test -d $path
      set fish_function_path $fish_function_path $path
      powerline-setup
    end
  end
end

source $configdir/fundle.fish

# Fish config
#
set -g async_prompt_inherit_variables all
#set -g theme_display_git_dirty no
#set -g theme_display_git_untracked no


# Environment variables

#set -x DOCKER_HOST ssh://mark@shannara
#set -x SSH_AUTH_SOCK "$XDG_RUNTIME_DIR/ssh-agent.sock"
set -x EDITOR 'vim'
set -x FIGNORE '*.pyc'
set -x PYTHONDONTWRITEBYTECODE 1
set -x SSL_CERT_FILE '/etc/ssl/cert.pem'
#set -x SSL_CERT_FILE '/opt/local/etc/openssl/cert.pem'

# Aliases
alias ipython "python3 -m IPython"
alias pip "python3 -m pip"
alias f fluxctl
alias k kubectl
alias s ssh
alias m mosh
alias stripcolor "perl -MTerm::ANSIColor=colorstrip -ne 'print colorstrip(\$_)'"
alias pamm $HOME/workspace/source/ammonite/repl
if which ggrep > /dev/null; alias grep ggrep; end
if which gfind > /dev/null; alias find gfind; end
if which gls > /dev/null; alias ls gls; end
if which cpair > /dev/null; alias c cpair; end
if which tmux > /dev/null; alias t tmux; end
alias git-tl "git rev-parse --show-toplevel"
alias pip "python3 -m pip"


#source $configdir/tmux.fish
#powerline-config tmux setup
#source $configdir/flux.fish

function git-master
  git remote show origin | awk '/HEAD branch:/{printf $NF}'
end

function get-shannara
  get-passwd-from-tag-per-session shannara marks | wl-copy
end

function get-ldap
  get-passwd-from-tag-per-session ldap braintree | pbcopy
end

function get-corp
  get-passwd-from-tag-per-session corp braintree | pbcopy
end

function unzip-to --argument-names 'file' 'parentdir'
	set dir (echo $file | awk -F'.zip' '{print $1}')
	unzip $file -d $parentdir/$dir
end

function get-passwd-from-tag-per-session --argument-names 'tags' 'session'
  eval (op signin --session $session); and op list items --tags $tags | op get item --fields password -
end

function cpair-tmux --argument-names 'account'
  set query (tmux list-windows -F '#{window_active} #W' | awk '/^1/{printf $NF}')
  cpair-select $account $query
end

function cpair-window --argument-names 'account'
  set query (tmux list-windows -F '#{window_active} #W' | awk '/^1/{printf $NF}')
  cpair-select $account $query
end

function cpair-select --argument-names 'account' 'query'
  if count $query > /dev/null
    set selected (env CPAIR_ACCOUNT=$account cpair list | fzf --header-lines=1 --query $query)
  else
    set selected (env CPAIR_ACCOUNT=$account cpair list | fzf --header-lines=1)
  end
  echo $selected
  env CPAIR_ACCOUNT=$account cpair ssh -p (echo $selected | awk '{printf $1}')
end

function bt --argument-names 'target_workdir'
  if count $target_workdir > /dev/null
    cd $HOME/bt/$target_workdir
  else
    cd $HOME/bt
  end
end

function work --argument-names 'target_workdir'
  if count $target_workdir > /dev/null
    cd $HOME/workspace/$target_workdir
  else
    cd $HOME/workspace
  end
end

function ipmitool
  /usr/bin/ipmitool -I lanplus -U root -P root -H $argv
end

# Extraterm extra integration
#if test -f $configdir/extraterm/setup_extraterm_fish.fish
#  source $configdir/extraterm/setup_extraterm_fish.fish
#end
