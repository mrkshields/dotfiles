set fish_greeting ""

# because fish complains if a path doesn't exist

for path in $PATH $HOME/Library/Python/2.7/bin $HOME/.local/bin /opt/twitter/bin /opt/twitter_mde/bin
  if test -d $path
    set -x PATH $PATH $path
  end
end

# Environment variables

set -x EDITOR 'vim'
set -x FIGNORE '*.pyc'
set -x PYTHONDONTWRITEBYTECODE 'very_yes'

# Aliases
alias s 'ssh'

# Powerline config
set fish_function_path $fish_function_path "$HOME/Library/Python/2.7/lib/python/site-packages/powerline/bindings/fish" "$HOME/.local/lib/python2.7/site-packages/powerline/bindings/fish"
powerline-setup

# Tmux/Powerline setup
if type tmux > /dev/null 2>&1
  if [ $TERM != 'screen' ]
    if [ -z $TMUX ]
      if pgrep tmux >/dev/null
        exec tmux attach
      else
        exec tmux
      end
    end
  end
  powerline-config tmux setup
end


# Functions
function work --argument-names 'target_workdir'
  if [ $target_workdir = 'source' ]
    cd $HOME/workspace/source/$SRC
  else
    cd $HOME/workspace/$target_workdir
  end

  if git rev-parse --abbrev-ref HEAD > /dev/null 2>&1
    if [ (git rev-parse --show-toplevel | awk -F'/' '{print $NF}') = 'source' ]
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

function get_src
  echo -e "SRC:\t$SRC"
end

function get_tests
  echo -e "TESTS:\t$TESTS"
end
