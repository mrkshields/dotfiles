set fish_greeting ""
set -l configdir ~/.config

function fish_right_prompt; end

# because fish complains if a path doesn't exist

for path in $HOME/bin /opt/twitter_mde/bin /opt/twitter/bin $HOME/Library/Python/2.7/bin $HOME/Library/Python/3.6/bin $HOME/.local/bin /opt/twitter/opt/coreutils/libexec/gnubin /usr/local/opt/coreutils/libexec/gnubin
  if test -d $path
    set -x PATH $path $PATH
  end
end

if test -d /opt/twitter/opt/coreutils/libexec/gnuman
  set -x MANPATH /opt/twitter/opt/coreutils/libexec/gnuman $MANPATH
end

# Powerline config
if status is-interactive
  set fish_function_path $fish_function_path "$HOME/Library/Python/3.6/lib/python/site-packages/powerline/bindings/fish" "$HOME/.local/lib/python3.6/site-packages/powerline/bindings/fish"
  powerline-setup
  fzf_key_bindings
  source (jump shell | psub)

# Fundle plugin installs
if functions fundle > /dev/null 2>&1
  #fundle plugin 'oh-my-fish/plugin-grc'
  fundle plugin 'acomagu/fish-async-prompt'
  fundle plugin 'edc/bass'
  fundle plugin 'fisherman/get'
  fundle plugin 'fisherman/spin'
  fundle plugin 'oh-my-fish/plugin-bang-bang'
  fundle plugin 'oh-my-fish/plugin-expand'
  fundle plugin 'oh-my-fish/theme-bobthefish'
  fundle plugin 'tuvistavie/fish-fastdir'
  fundle init
end

# Fish config
#
set -g async_prompt_inherit_variables all
set -g theme_display_git_dirty no
set -g theme_display_git_untracked no


# Environment variables

set -x EDITOR 'vim'
set -x FIGNORE '*.pyc'
set -x PYTHONDONTWRITEBYTECODE 'very_yes'
set -x SBT_PROXY_REPO 'http://artifactory.local.twitter.com/repo/'

# Aliases
alias s ssh
alias stripcolor "perl -MTerm::ANSIColor=colorstrip -ne 'print colorstrip(\$_)'"
alias find gfind
#functions -e ls

#if test -x /opt/twitter/bin/vim; alias vim /opt/twitter/bin/vim; end
#if test -x /opt/twitter_mde/bin/svn; alias svn /opt/twitter_mde/bin/svn; end
#if test -x /opt/twitter_mde/bin/git; alias git /opt/twitter_mde/bin/git; end
if which ggrep > /dev/null; alias grep ggrep; end
alias git-tl "git rev-parse --show-toplevel"


end

source $configdir/fish/tmux.fish

function svn-st-awk --argument-names awk_search
  svn status | awk "/$awk_search/{print \$NF}" | sort -u
end

function svn-ship --argument-names rb reviewers awk_search
  eval $PWD/utilities/svn/svn-review -R $rb -r $reviewers commit (svn-st-awk $awk_search)
end

function svn-update --argument-names rb awk_search
  eval $PWD/utilities/svn/svn-review -R $rb update (svn-st-awk $awk_search)
end

function !d
	eval (vcprompt -f "%n") diff $argv
end
function !s
	eval (vcprompt -f "%n") status $argv
end

function work --argument-names 'target_workdir'
  if count $target_workdir > /dev/null
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
  else
    cd $HOME/workspace
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

function gc --argument-names 'repo'
  if count $repo > /dev/null
    git clone https://git.twitter.biz/$repo
  end
end
