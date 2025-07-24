set fish_greeting ""
set -l configdir ~/.config/fish

set -x GOPATH $HOME/go
if command -q brew
  set -x GOROOT (brew --prefix golang)/"libexec"
end
set -x GO111MODULE on

if functions -q fish_add_path
  fish_add_path $GOPATH/bin
  fish_add_path $GOROOT/bin
  fish_add_path $HOME/.krew/bin
  fish_add_path $HOME/.local/bin
  fish_add_path $HOME/.local/go/bin
  fish_add_path $HOME/.npm-global/bin
  #fish_add_path /opt/homebrew/Cellar/go@1.17/1.17.11/bin
  fish_add_path /opt/homebrew/bin
  fish_add_path /opt/homebrew/opt/coreutils/libexec/gnubin
  fish_add_path /opt/homebrew/opt/findutils/libexec/gnubin
  fish_add_path /snap/bin
  fish_add_path /usr/local/bin
  fish_add_path /usr/local/go/bin
  fish_add_path /opt/homebrew/share/google-cloud-sdk/bin
  fish_add_path /Users/markshields/Library/Python/3.9/bin
  fish_add_path /Library/Frameworks/Python.framework/Versions/3.12/bin
end

eval (/opt/homebrew/bin/brew shellenv)

 set -q KREW_ROOT; and set -gx PATH $PATH $KREW_ROOT/.krew/bin; or set -gx PATH $PATH $HOME/.krew/bin

# Powerline config
if status is-interactive
    set fish_function_path $fish_function_path /Users/markshields/Library/Python/3.9/lib/python/site-packages/powerline/bindings/fish/powerline-setup.fish
    source /Users/markshields/Library/Python/3.9/lib/python/site-packages/powerline/bindings/fish/powerline-setup.fish
    powerline-setup
end

set -g async_prompt_inherit_variables all

# Secret environment variables and other values
# Set with: set-keychain-environment-variable ENV_VAR_NAME
if test -s $configdir/keychain-environment-variables.fish
  source $configdir/keychain-environment-variables.fish
  # example - set initial value with set-keychain-environment-variable ENV_VAR_NAME
  #set -x GITHUB_TOKEN (keychain-environment-variable GITHUB_TOKEN)
  set -x HOMEBRIDGE_NEST_SDM_AUTH_URL (keychain-environment-variable HOMEBRIDGE_NEST_SDM_AUTH_URL 2>/dev/null)
  set -x GOPRIVATE (keychain-environment-variable GOPRIVATE 2>/dev/null)
end

# Environment variables
#set -x DOCKER_HOST ssh://mark@shannara
set -x EDITOR 'vim'
set -x FIGNORE '*.pyc'
set -x PYTHONDONTWRITEBYTECODE 1
set -x INFLUX_HOST http://influxdb.marax.local:8086
set -x USE_GKE_GCLOUD_AUTH_PLUGIN True
#set -x KUBECONFIG $HOME/.kube/config:$HOME/.kube/marax-config
#set -x KUBECONFIG $HOME/.kube/config:$HOME/.kube/allanon-config:$HOME/kube/rpi4-config:$HOME/kube/marax-config
#set -x XDG_DATA_HOME $HOME/Library
set -x VAULT_ADDR (keychain-environment-variable VAULT_ADDR 2>/dev/null)
#set -x HTTPS_PROXY http://localhost:9995
set -x COMPOSE_BAKE false
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
alias k "kubectl"


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
    cd $HOME/workspace/$target_workdir
  else
    cd $HOME/workspace/$BASE_WORKDIR
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


kubectl completion fish | source
k completion fish | sed 's/kubectl/k/g' | source

# pnpm
set -gx PNPM_HOME "/Users/mark/Library/pnpm"
set -gx PATH "$PNPM_HOME" $PATH
# pnpm end
set -gx VOLTA_HOME "$HOME/.volta"
set -gx PATH "$VOLTA_HOME/bin" $PATH
eval (direnv hook fish)

### MANAGED BY RANCHER DESKTOP START (DO NOT EDIT)
set --export --prepend PATH "/Users/markshields/.rd/bin"
### MANAGED BY RANCHER DESKTOP END (DO NOT EDIT)

# The next line updates PATH for the Google Cloud SDK.
if [ -f '/Users/markshields/.dotfiles/google-cloud-sdk/path.fish.inc' ]; . '/Users/markshields/.dotfiles/google-cloud-sdk/path.fish.inc'; end

function auto_pre_commit --on-variable PWD
    if not command -q git; or not git rev-parse --is-inside-work-tree >/dev/null 2>&1
        return
    end
    if not command -q pre-commit
        return
    end
    set -l repo_root (git rev-parse --show-toplevel)
    set -l git_dir (git rev-parse --git-dir)
    if test -f "$repo_root/.pre-commit-config.yaml"
        if not test -f "$git_dir/hooks/pre-commit"
            pre-commit install --overwrite --install-hooks >/dev/null
        end
        pre-commit --jobs 8 autoupdate >/dev/null
    end

    # Handle global template directory for automatic hook setup in new repos (synchronous, as it's typically fast and rare)
    set -l template_dir (git config --get init.templateDir)
    if test -n "$template_dir" -a -d "$template_dir"
        if not test -f "$template_dir/hooks/pre-commit"
            pre-commit init-templatedir "$template_dir" >/dev/null
        end
    end
end