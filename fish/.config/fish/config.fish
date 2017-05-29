set fish_greeting ""
set -l configdir ~/.config

# because fish complains if a path doesn't exist

for path in $HOME/bin /opt/twitter_mde/bin /opt/twitter/bin $HOME/Library/Python/2.7/bin $HOME/.local/bin /opt/twitter/opt/coreutils/libexec/gnubin /usr/local/opt/coreutils/libexec/gnubin
  if test -d $path
    set -x PATH $path $PATH
  end
end

if test -d /opt/twitter/opt/coreutils/libexec/gnuman
  set -x MANPATH /opt/twitter/opt/coreutils/libexec/gnuman $MANPATH
end

# Fundle plugin installs
if functions fundle > /dev/null 2>&1
  fundle plugin 'fisherman/get'
  fundle plugin 'fisherman/spin'
  fundle plugin 'oh-my-fish/plugin-bang-bang'
  fundle plugin 'oh-my-fish/plugin-grc'
  fundle plugin 'tuvistavie/fish-fastdir'
end

# Environment variables

set -x EDITOR 'vim'
set -x FIGNORE '*.pyc'
set -x PYTHONDONTWRITEBYTECODE 'very_yes'

# Aliases
alias s ssh
if test -x /opt/twitter/bin/vim; alias vim /opt/twitter/bin/vim; end
if test -x /opt/twitter_mde/bin/svn; alias svn /opt/twitter_mde/bin/svn; end
if test -x /opt/twitter_mde/bin/git; alias git /opt/twitter_mde/bin/git; end
if which ggrep > /dev/null; alias grep ggrep; end
alias git-tl "git rev-parse --show-toplevel"


# Powerline config
set fish_function_path $fish_function_path "$HOME/Library/Python/2.7/lib/python/site-packages/powerline/bindings/fish" "$HOME/.local/lib/python2.7/site-packages/powerline/bindings/fish"
powerline-setup

source $configdir/fish/tmux.fish

function svn-st-awk --argument-names awk_search
  svn status | awk "/$awk_search/{print \$NF}"
end

function svn-ship --argument-names rb reviewers awk_search
  eval $PWD/utilities/svn/svn-review -R $rb -r $reviewers commit (svn-st-awk $awk_search)
end

function !d
	eval (vcprompt -f "%n") diff $argv
end
function !s
	eval (vcprompt -f "%n") status $argv
end

function work --argument-names 'target_workdir'
  switch $target_workdir
    case source src
      cd $HOME/workspace/source/$SRC
      #set -x PANTS_CONFIG_OVERRIDE $HOME/workspace/source/pants.ini.daemon
      get_src
    case tests
      cd $HOME/workspace/source/$TESTS
      #set -x PANTS_CONFIG_OVERRIDE $HOME/workspace/source/pants.ini.daemon
      get_tests
    case '*'
      cd $HOME/workspace/$target_workdir
  end
end

function src --argument-names 'src_path'
  if count $src_path > /dev/null
    set -U SRC $src_path
  else
    set -U SRC (echo $PWD | awk -F'/source/' '{print $NF}')
  end
end

function tests --argument-names 'tests_path'
  if count $tests_path > /dev/null
    set -U SRC $src_path
    set -U TESTS $tests_path
  else
    set -U TESTS (echo $PWD | awk -F'/source/' '{print $NF}' | sed 's/src/tests/')
  end
end

function setup
  src
  tests
  get_src
  get_tests
end

function get_src
  echo $SRC
end

function get_tests
  echo $TESTS
end
