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

set -g async_prompt_inherit_variables all

# Secret environment variables and other values
# Set with: set-keychain-environment-variable ENV_VAR_NAME
# example - set initial value with set-keychain-environment-variable ENV_VAR_NAME
#set -x GITHUB_TOKEN (keychain-environment-variable GITHUB_TOKEN)
set -x HOMEBRIDGE_NEST_SDM_AUTH_URL (keychain-environment-variable HOMEBRIDGE_NEST_SDM_AUTH_URL 2>/dev/null)
set -x GOPRIVATE (keychain-environment-variable GOPRIVATE 2>/dev/null)

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
if type -q kubectl
  k completion fish | sed 's/kubectl/k/g' | source
end

# pnpm
set -gx PNPM_HOME "/Users/mark/Library/pnpm"
set -gx PATH "$PNPM_HOME" $PATH
# pnpm end
set -gx VOLTA_HOME "$HOME/.volta"
set -gx PATH "$VOLTA_HOME/bin" $PATH
# Direnv
if type -q direnv
    direnv hook fish | source
end

### MANAGED BY RANCHER DESKTOP START (DO NOT EDIT)
set --export --prepend PATH "/Users/markshields/.rd/bin"
### MANAGED BY RANCHER DESKTOP END (DO NOT EDIT)

# The next line updates PATH for the Google Cloud SDK.
if [ -f '/Users/markshields/.dotfiles/google-cloud-sdk/path.fish.inc' ]; . '/Users/markshields/.dotfiles/google-cloud-sdk/path.fish.inc'; end

#function auto_pre_commit --on-variable PWD
#    if not command -q git; or not git rev-parse --is-inside-work-tree >/dev/null 2>&1
#        return
#    end
#    if not command -q pre-commit
#        return
#    end
#    set -l repo_root (git rev-parse --show-toplevel)
#    set -l git_dir (git rev-parse --git-dir)
#    if test -f "$repo_root/.pre-commit-config.yaml"
#        if not test -f "$git_dir/hooks/pre-commit"
#            pre-commit install --overwrite --install-hooks >/dev/null
#        end
#        pre-commit --jobs 8 autoupdate >/dev/null
#    end
#
#    # Handle global template directory for automatic hook setup in new repos (synchronous, as it's typically fast and rare)
#    set -l template_dir (git config --get init.templateDir)
#    if test -n "$template_dir" -a -d "$template_dir"
#        if not test -f "$template_dir/hooks/pre-commit"
#            pre-commit init-templatedir "$template_dir" >/dev/null
#        end
#    end
#end
#

# Tide prompt configuration — fully portable across machines
if not set -q tide_left_prompt_items
    set -U tide_aws_bg_color FF9900
    set -U tide_aws_color 232F3E
    set -U tide_aws_icon 

    set -U tide_bun_bg_color FBF0DF
    set -U tide_bun_color 14151A
    set -U tide_bun_icon 󰳓

    set -U tide_character_color 5FD700
    set -U tide_character_color_failure FF0000
    set -U tide_character_icon ❯
    set -U tide_character_vi_icon_default ❮
    set -U tide_character_vi_icon_replace ▶
    set -U tide_character_vi_icon_visual V

    set -U tide_cmd_duration_bg_color C4A000
    set -U tide_cmd_duration_color 000000
    set -U tide_cmd_duration_decimals 0
    set -U tide_cmd_duration_icon 
    set -U tide_cmd_duration_threshold 3000

    set -U tide_context_always_display false
    set -U tide_context_bg_color 444444
    set -U tide_context_color_default D7AF87
    set -U tide_context_color_root D7AF00
    set -U tide_context_color_ssh D7AF87
    set -U tide_context_hostname_parts 1

    set -U tide_crystal_bg_color FFFFFF
    set -U tide_crystal_color 000000
    set -U tide_crystal_icon 

    set -U tide_direnv_bg_color D7AF00
    set -U tide_direnv_bg_color_denied FF0000
    set -U tide_direnv_color 000000
    set -U tide_direnv_color_denied 000000
    set -U tide_direnv_icon ▼

    set -U tide_distrobox_bg_color FF00FF
    set -U tide_distrobox_color 000000
    set -U tide_distrobox_icon 󰆧

    set -U tide_docker_bg_color 2496ED
    set -U tide_docker_color 000000
    set -U tide_docker_default_contexts default colima
    set -U tide_docker_icon 

    set -U tide_elixir_bg_color 4E2A8E
    set -U tide_elixir_color 000000
    set -U tide_elixir_icon 

    set -U tide_gcloud_bg_color 4285F4
    set -U tide_gcloud_color 000000
    set -U tide_gcloud_icon 󰊭

    set -U tide_git_bg_color 4E9A06
    set -U tide_git_bg_color_unstable C4A000
    set -U tide_git_bg_color_urgent CC0000
    set -U tide_git_color_branch 000000
    set -U tide_git_color_conflicted 000000
    set -U tide_git_color_dirty 000000
    set -U tide_git_color_operation 000000
    set -U tide_git_color_staged 000000
    set -U tide_git_color_stash 000000
    set -U tide_git_color_untracked 000000
    set -U tide_git_color_upstream 000000
    set -U tide_git_icon 
    set -U tide_git_truncation_length 24
    set -U tide_git_truncation_strategy ''

    set -U tide_go_bg_color 00ACD7
    set -U tide_go_color 000000
    set -U tide_go_icon 

    set -U tide_java_bg_color ED8B00
    set -U tide_java_color 000000
    set -U tide_java_icon 

    set -U tide_jobs_bg_color 444444
    set -U tide_jobs_color 4E9A06
    set -U tide_jobs_icon 
    set -U tide_jobs_number_threshold 1000

    set -U tide_kubectl_bg_color 326CE5
    set -U tide_kubectl_color 000000
    set -U tide_kubectl_icon 󱃾

    set -U tide_left_prompt_frame_enabled true
    set -U tide_left_prompt_items os pwd git newline character
    set -U tide_left_prompt_prefix ''
    set -U tide_left_prompt_separator_diff_color 
    set -U tide_left_prompt_separator_same_color 
    set -U tide_left_prompt_suffix 

    set -U tide_nix_shell_bg_color 7EBAE4
    set -U tide_nix_shell_color 000000
    set -U tide_nix_shell_icon 

    set -U tide_node_bg_color 44883E
    set -U tide_node_color 000000
    set -U tide_node_icon 

    set -U tide_os_bg_color 333333
    set -U tide_os_color D6D6D6
    set -U tide_os_icon 

    set -U tide_php_bg_color 617CBE
    set -U tide_php_color 000000
    set -U tide_php_icon 

    set -U tide_private_mode_bg_color F1F3F4
    set -U tide_private_mode_color 000000
    set -U tide_private_mode_icon 󰗹

    set -U tide_prompt_add_newline_before true
    set -U tide_prompt_color_frame_and_connection 444444
    set -U tide_prompt_color_separator_same_color 949494
    set -U tide_prompt_icon_connection ─
    set -U tide_prompt_min_cols 34
    set -U tide_prompt_pad_items true
    set -U tide_prompt_transient_enabled true

    set -U tide_pulumi_bg_color F7BF2A
    set -U tide_pulumi_color 000000
    set -U tide_pulumi_icon 

    set -U tide_pwd_bg_color 3465A4
    set -U tide_pwd_color_anchors E4E4E4
    set -U tide_pwd_color_dirs E4E4E4
    set -U tide_pwd_color_truncated_dirs BCBCBC
    set -U tide_pwd_icon 
    set -U tide_pwd_icon_home 
    set -U tide_pwd_icon_unwritable 
    set -U tide_pwd_markers .bzr .citc .git .hg .node-version .python-version .ruby-version .shorten_folder_marker .svn .terraform Cargo.toml composer.json go.mod package.json

    set -U tide_python_bg_color 444444
    set -U tide_python_color 00AFAF
    set -U tide_python_icon 󰌠

    set -U tide_right_prompt_frame_enabled false
    set -U tide_right_prompt_items status cmd_duration context jobs direnv bun node python ruby java php rust go gcloud pulumi toolbox crystal nix_shell shlvl vi_mode
    set -U tide_right_prompt_prefix 
    set -U tide_right_prompt_separator_diff_color 
    set -U tide_right_prompt_separator_same_color 
    set -U tide_right_prompt_suffix ''

    set -U tide_ruby_bg_color B31209
    set -U tide_ruby_color 000000
    set -U tide_ruby_icon 

    set -U tide_rustc_bg_color F74C00
    set -U tide_rustc_color 000000
    set -U tide_rustc_icon 

    set -U tide_shlvl_bg_color 808000
    set -U tide_shlvl_color 000000
    set -U tide_shlvl_icon 
    set -U tide_shlvl_threshold 1

    set -U tide_status_bg_color 2E3436
    set -U tide_status_bg_color_failure CC0000
    set -U tide_status_color 4E9A06
    set -U tide_status_color_failure FFFF00
    set -U tide_status_icon ✔
    set -U tide_status_icon_failure ✘

    set -U tide_terraform_bg_color 800080
    set -U tide_terraform_color 000000
    set -U tide_terraform_icon 󱁢

    set -U tide_time_bg_color D3D7CF
    set -U tide_time_color 000000
    set -U tide_time_format %r

    set -U tide_toolbox_bg_color 613583
    set -U tide_toolbox_color 000000
    set -U tide_toolbox_icon 

    set -U tide_vi_mode_bg_color_default 949494
    set -U tide_vi_mode_bg_color_insert 87AFAF
    set -U tide_vi_mode_bg_color_replace 87AF87
    set -U tide_vi_mode_bg_color_visual FF8700
    set -U tide_vi_mode_color_default 000000
    set -U tide_vi_mode_color_insert 000000
    set -U tide_vi_mode_color_replace 000000
    set -U tide_vi_mode_color_visual 000000
    set -U tide_vi_mode_icon_default D
    set -U tide_vi_mode_icon_insert I
    set -U tide_vi_mode_icon_replace R
    set -U tide_vi_mode_icon_visual V

    set -U tide_zig_bg_color F7A41D
    set -U tide_zig_color 000000
    set -U tide_zig_icon 
end
