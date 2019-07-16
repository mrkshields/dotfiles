set fish_greeting ""
set -l configdir ~/.config

# because fish complains if a path doesn't exist

for path in $HOME/bin $HOME/go/bin /opt/local/bin /usr/local/bin /opt/twitter_mde/bin $HOME/Library/Python/2.7/bin $HOME/Library/Python/3.6/bin $HOME/.local/bin /usr/local/opt/coreutils/libexec/gnubin /opt/local/Library/Frameworks/Python.framework/Versions/3.7/bin $HOME/Library/Python/3.7/bin $HOME/workspace/source $HOME/workspace/source/bin $HOME/.npm-global/bin
  if test -d $path
    set -x PATH $path $PATH
  end
end

set -x GOPATH $HOME/go

# Powerline config
if status is-interactive
  set fish_function_path $fish_function_path "$HOME/Library/Python/3.7/lib/python/site-packages/powerline/bindings/fish"
  powerline-setup
  #fzf_key_bindings
  #source (jump shell | psub)
end

source $configdir/fish/fundle.fish

# Fish config
#
set -g async_prompt_inherit_variables all
#set -g theme_display_git_dirty no
#set -g theme_display_git_untracked no


# Environment variables

set -x EDITOR 'vim'
set -x FIGNORE '*.pyc'
set -x PYTHONDONTWRITEBYTECODE 'very_yes'
set -x SBT_PROXY_REPO 'http://artifactory.local.twitter.com/repo/'

# Aliases
alias s ssh
alias stripcolor "perl -MTerm::ANSIColor=colorstrip -ne 'print colorstrip(\$_)'"
#alias find gfind
alias pamm $HOME/workspace/source/ammonite/repl
#functions -e ls

if which ggrep > /dev/null; alias grep ggrep; end
if which gfind > /dev/null; alias find gfind; end
alias git-tl "git rev-parse --show-toplevel"
alias pip "python3.7 -m pip"


source $configdir/fish/tmux.fish

function work --argument-names 'target_workdir'
  if count $target_workdir > /dev/null
    cd $HOME/workspace/$target_workdir
  else
    cd $HOME/workspace
  end
end

function projdir --argument-names 'name'
  if count $name > /dev/null
    mkdir -pv $name
    touch $name/PROJECT
  end
end
