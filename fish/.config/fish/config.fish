set fish_greeting ""
set -l configdir ~/.config/fish

fish_add_path $HOME/.foundry/bin
fish_add_path $HOME/.krew
fish_add_path $HOME/.krew/bin
fish_add_path $HOME/.local/bin
fish_add_path $HOME/.local/go/bin
fish_add_path $HOME/.npm-global/bin
fish_add_path $HOME/bin
fish_add_path $HOME/go/bin
fish_add_path /snap/bin
fish_add_path /usr/local/bin
fish_add_path /usr/local/opt/go@1.16/bin
fish_add_path /usr/local/opt/mysql@5.7/bin


set -x GOPATH $HOME/Documents/workspace/go

# Powerline config
if status is-interactive
    set fish_function_path $fish_function_path /usr/local/lib/python3.9/site-packages/powerline/bindings/fish
    powerline-setup
end

source $configdir/fundle.fish

set -g async_prompt_inherit_variables all


# Secret environment variables
if test -s $configdir/keychain-environment-variables.fish
  source $configdir/keychain-environment-variables.fish
  # example - set initial value with set-keychain-environment-variable ENV_VAR_NAME
  # set -x GITHUB_TOKEN (keychain-environment-variable GITHUB_TOKEN)
end

# Environment variables
#set -x DOCKER_HOST ssh://mark@shannara
#set -x SSH_AUTH_SOCK "$XDG_RUNTIME_DIR/ssh-agent.sock"
set -x EDITOR 'vim'
set -x FIGNORE '*.pyc'
set -x PYTHONDONTWRITEBYTECODE 1
set -x GL_REPOS_DIR $HOME/workspace
set -x INFLUX_HOST http://influxdb.marax.local:8086
# Aliases
alias ipython "python3 -m IPython"
alias pip "python3 -m pip"
alias f fluxctl
alias k kubectl
alias s ssh
alias m mosh
alias stripcolor "perl -MTerm::ANSIColor=colorstrip -ne 'print colorstrip(\$_)'"
if which ggrep > /dev/null; alias grep ggrep; end
if which gfind > /dev/null; alias find gfind; end
if which gls > /dev/null; alias ls gls; end
if which tmux > /dev/null; alias t tmux; end
alias git-tl "git rev-parse --show-toplevel"
alias kctx "kubectl ctx"
alias cert-manager "kubectl cert-manager"
alias krew "kubectl krew"
alias kns "kubectl ns"


function git-master
  git remote show origin | awk '/HEAD branch:/{printf $NF}'
end

function get-shannara
  get-passwd-from-tag-per-session shannara marks | wl-copy
end

function unzip-to --argument-names 'file' 'parentdir'
	set dir (echo $file | awk -F'.zip' '{print $1}')
	unzip $file -d $parentdir/$dir
end

function get-passwd-from-tag-per-session --argument-names 'tags' 'session'
  eval (op signin --session $session); and op list items --tags $tags | op get item --fields password -
end

function get-otp-from-item-per-account --argument-names 'item' 'account'
  eval (op signin --account $account); and op item get 'AWS' --otp
end

function get-aws-enso-mfa
  get-otp-from-item-per-account AWS ensoassociation.1password.com
end

function work --argument-names 'target_workdir'
  if count $target_workdir > /dev/null
    cd $HOME/Documents/workspace/$target_workdir
  else
    cd $HOME/Documents/workspace
  end
end

function vsc
  open -a 'Visual Studio Code' .
end

function ipmitool
  /opt/local/bin/ipmitool -I lanplus -U root -P root -H $argv
end

function aws-auth --argument-names 'seconds'
  set envvars '{
    "AWS_SECRET_ACCESS_KEY": "SecretAccessKey",
    "AWS_SESSION_TOKEN": "SessionToken",
    "AWS_ACCESS_KEY_ID": "AccessKeyId"
  }'
  # clear all current envvars first to avoid auth error with invalid or expired credentials
  echo $envvars | jq -r 'keys|.[]' | while read envvar
    set -e $envvar
  end

  if count $seconds > /dev/null
    set json (aws sts get-session-token  --serial-number arn:aws:iam::614212999630:mfa/root-account-mfa-device --token-code (get-aws-enso-mfa) --duration-seconds $seconds)
  else
    set json (aws sts get-session-token  --serial-number arn:aws:iam::614212999630:mfa/root-account-mfa-device --token-code (get-aws-enso-mfa) --duration-seconds 10800)
  end
  echo $json | jq -C .
  echo $envvars | jq -r 'keys|.[]' | while read envvar
    set jsonVal (echo $envvars | jq -r .$envvar)
    set -x $envvar (echo $json | jq -r .Credentials.$jsonVal)
    set -S $envvar
  end
end

# The next line updates PATH for the Google Cloud SDK.
if [ -f '/Users/mark/.dotfiles/google-cloud-sdk/path.fish.inc' ]; . '/Users/mark/.dotfiles/google-cloud-sdk/path.fish.inc'; end
