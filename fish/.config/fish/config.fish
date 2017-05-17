set fish_greeting ""

# because fish complains if a path doesn't exist

for path in /opt/twitter_mde/bin /opt/twitter/bin $HOME/Library/Python/2.7/bin $HOME/.local/bin
  if test -d $path
    set -x PATH $PATH $path
  end
end

# Environment variables

set -x EDITOR 'vim'
set -x FIGNORE '*.pyc'
set -x PYTHONDONTWRITEBYTECODE 'very_yes'

# Aliases
alias s ssh
alias vim /opt/twitter/bin/vim
alias svn /opt/twitter_mde/bin/svn
alias git /opt/twitter_mde/bin/git
alias grep ggrep

# Powerline config
set fish_function_path $fish_function_path "$HOME/Library/Python/2.7/lib/python/site-packages/powerline/bindings/fish" "$HOME/.local/lib/python2.7/site-packages/powerline/bindings/fish"
powerline-setup

# Functions
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
  if [ $target_workdir = 'source' ]
    cd $HOME/workspace/source/$SRC
  else
    cd $HOME/workspace/$target_workdir
  end

  if git rev-parse --abbrev-ref HEAD > /dev/null 2>&1
    if [ $target_workdir = 'source' ]
      get_src
      get_tests
    end
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
  echo -e "SRC:\t$SRC"
end

function get_tests
  echo -e "TESTS:\t$TESTS"
end
