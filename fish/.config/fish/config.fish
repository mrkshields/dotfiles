set fish_greeting ""
set -l configdir ~/.config/fish

fish_add_path $GOPATH/bin
fish_add_path $HOME/.foundry/bin
fish_add_path $HOME/.krew
fish_add_path $HOME/.krew/bin
fish_add_path $HOME/.local/bin
fish_add_path $HOME/.local/go/bin
fish_add_path $HOME/.npm-global/bin
fish_add_path $HOME/Library/Android/sdk/platform-tools
fish_add_path $HOME/bin
fish_add_path /opt/homebrew/Cellar/go@1.17/1.17.11/bin
fish_add_path /opt/homebrew/bin
fish_add_path /opt/homebrew/opt/coreutils/libexec/gnubin
fish_add_path /opt/homebrew/opt/findutils/libexec/gnubin
fish_add_path /snap/bin
fish_add_path /usr/local/bin

eval (/opt/homebrew/bin/brew shellenv)

set -x GOPATH $HOME/Documents/workspace/go

# Powerline config
if status is-interactive
    set fish_function_path $fish_function_path /opt/homebrew/lib/python3.9/site-packages/powerline/bindings/fish
    powerline-setup
end

source $configdir/fundle.fish
#source $configdir/tmux.fish

set -g async_prompt_inherit_variables all


# Secret environment variables and other values
# Set with: set-keychain-environment-variable ENV_VAR_NAME
if test -s $configdir/keychain-environment-variables.fish
  source $configdir/keychain-environment-variables.fish
  # example - set initial value with set-keychain-environment-variable ENV_VAR_NAME
  set -x GITHUB_TOKEN (keychain-environment-variable GITHUB_TOKEN)
  #set -x ETH_RPC_URL (keychain-environment-variable ETH_RPC_URL)
  set -x CLONE_ORG_GITHUB_TOKEN (keychain-environment-variable CLONE_ORG_GITHUB_TOKEN)
  set -x NPM_TOKEN (keychain-environment-variable NPM_TOKEN)
  set -x SIGNADOT_API_KEY (keychain-environment-variable SIGNADOT_API_KEY)
  set -x CLOUDFLARE_API_TOKEN (keychain-environment-variable CLOUDFLARE_API_TOKEN)
  set -x GOOGLE_ENCRYPTION_KEY (keychain-environment-variable GOOGLE_ENCRYPTION_KEY)
  set -x VERCEL_API_TOKEN (keychain-environment-variable VERCEL_API_TOKEN)
  alias gcpdiag-lint "gcpdiag lint --config "(keychain-environment-variable GCPDIAG_CONFIG_PATH)
end

# Environment variables
#set -x DOCKER_HOST ssh://mark@shannara
#set -x SSH_AUTH_SOCK "$XDG_RUNTIME_DIR/ssh-agent.sock"
set -x EDITOR 'vim'
set -x FIGNORE '*.pyc'
set -x PYTHONDONTWRITEBYTECODE 1
set -x GL_REPOS_DIR $HOME/workspace
set -x INFLUX_HOST http://influxdb.marax.local:8086
set -x USE_GKE_GCLOUD_AUTH_PLUGIN True
set -x BASE_WORKDIR EnsoFinance
set -x PROJECT_ID enso-finance
set -x SIGNADOT_ORG ensofinanc
set -x KUBECTL_EXTERNAL_DIFF '/Users/mark/Documents/workspace/go/bin/kubectl-neat-diff --diff=colordiff'
set -x ETH_RPC_URL https://mainnet.ensofinance.dev
set -x KUBECONFIG $HOME/.kube/config:$HOME/.kube/macmini-config
# Aliases
alias ipython "python3 -m IPython"
alias pip "python3 -m pip"
alias s ssh
alias m mosh
alias stripcolor "perl -MTerm::ANSIColor=colorstrip -ne 'print colorstrip(\$_)'"
if which ggrep > /dev/null; alias grep ggrep; end
if which gfind > /dev/null; alias find gfind; end
if which gls > /dev/null; alias ls gls; end
if which tmux > /dev/null; alias t tmux; end
alias git-tl "git rev-parse --show-toplevel"
alias cert-manager "kubectl cert-manager"
alias krew "kubectl krew"
alias kns "kubectl ns"
alias neat "kubectl neat"
alias match-name "kubectl match-name"
alias argocd "argocd --grpc-web"
alias gss "gcloud compute ssh --zone"

function cf-hosted
  work codefresh-runtime-applications
end

function gs --argument-names vm zone
  if count $zone >/dev/null
    gcloud compute ssh --zone $zone $vm
  else
    gcloud compute ssh --zone europe-west6-a $vm
    end
end

function dotfiles
  cd ~/.dotfiles
end

alias kctx "kubectl ctx"

function kenv --argument-names 'ctx'
  if count $ctx >/dev/null
    kubectl ctx | grep $ctx | xargs kubectl ctx
    echo $ctx | grep -oP '(dev|int|prod)' | xargs kubectl ns # switch to matching Namespace
  else
    echo -e '\e[1m\e[33mContext: \e[0m\e[37m'(kubectl ctx -c)'\e[0m'
    echo -e '\e[1m\e[33mNamespace: \e[0m\e[37m'(kubectl ns -c)'\e[0m'
  end
end

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

function argocd-app-match --argument-names 'match' 'op'
  if count $op >/dev/null
    argocd app list -o name | grep $match | xargs -P0 -n1 argocd app $op
  else
    argocd app list -o name | grep $match
  end
end

function work --argument-names 'target_workdir'
  if count $BASE_WORKDIR > /dev/null
    set target_workdir $BASE_WORKDIR/$target_workdir
  end
  if count $target_workdir > /dev/null
    cd $HOME/Documents/workspace/$target_workdir
  else
    cd $HOME/Documents/workspace/$BASE_WORKDIR
  end
end


function vsc --argument-names 'target_workdir'
  if count $target_workdir > /dev/null
    work $target_workdir
  end
    open -a 'Visual Studio Code' .
end

function ipmitool
  /opt/local/bin/ipmitool -I lanplus -U root -P root -H $argv
end

function kgetall --argument-names 'namespace'
  kubectl api-resources --verbs=list --namespaced -o name | grep -vP 'events(\.events\.k8s\.io)*' | sort -u | while read resource
    kubectl -n $namespace get --ignore-not-found $resource | while read res
      if count $res > /dev/null
        echo "> resource: $resource"
      end
    end
  end
end

function nvm
    bass source ~/.nvm/nvm.sh --no-use ';' nvm $argv
end

kubectl completion fish | source
k completion fish | sed 's/kubectl/k/g' | source

# The next line updates PATH for the Google Cloud SDK.
if [ -f '/Users/mark/.local/google-cloud-sdk/path.fish.inc' ]; . '/Users/mark/.local/google-cloud-sdk/path.fish.inc'; end

# pnpm
set -gx PNPM_HOME "/Users/mark/Library/pnpm"
set -gx PATH "$PNPM_HOME" $PATH
# pnpm end
