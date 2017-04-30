export PATH=${PATH}:/Users/mshields/Library/Python/2.7/bin:/Users/mshields/bin
export PATH="$PATH:$HOME/.rvm/bin" # Add RVM to PATH for scripting
export JAVA_HOME=/Library/Java/JavaVirtualMachines/jdk1.8.0_72.jdk/Contents/Home
export PATH=${PATH}:${JAVA_HOME}
export FIGNORE='*.pyc'
export PYTHONDONTWRITEBYTECODE=very_yes
export PYTHONPATH=${PATH}:/Users/mshields/workspace/source/science/src/python/twitter/

if [ -f $(brew --prefix)/etc/bash_completion ]; then
  . $(brew --prefix)/etc/bash_completion
fi

test -f ~/.git-completion.bash && . $_
test -f ~/.pants-completion.bash && . $_

#test -e "${HOME}/.iterm2_shell_integration.bash" && source "${HOME}/.iterm2_shell_integration.bash"
. /Users/mshields/Library/Python/2.7/lib/python/site-packages/powerline/bindings/bash/powerline.sh
source "`brew --prefix`/etc/grc.bashrc"


# Fix tmux/powerline
/Users/mshields/Library/Python/2.7/bin/powerline-config tmux setup

# Aliases

alias dns-tool='dns-tool -s ~/.dns_credentials.yaml'
alias fastboot='/Users/mshields/Library/Android/sdk/platform-tools/fastboot'
alias less='less -R'
alias pipi='/usr/local/bin/pip install --user'
alias s='ssh'
alias dotc="git --git-dir=${HOME}/.myconf --work-tree=${HOME}"

# Environment variables
source .homebrewrc
export EDITOR='vim'


ssh-add -l > /dev/null 2>&1 || ssh-add -K

function get_src() {
  local branch="$(git rev-parse --abbrev-ref HEAD | tr '/-' '_')"
  env | grep "^SRC_${branch}=)"
}

function get_tests() {
  local branch="$(git rev-parse --abbrev-ref HEAD | tr '/-' '_')"
  env | grep "^TESTS_${branch}=)"
}

find ~/.config/src -type f | while read -r file; do source "${file}"; done
find ~/.config/tests -type f | while read -r file; do source "${file}"; done

# functions

function set_src() {
  local branch="$(git rev-parse --abbrev-ref HEAD | tr '/-' '_')"
  local branch_file="$(echo ${HOME}/.config/src/${branch} | tr '/-' '_')"
  mkdir -p "${branch_file%/*}"

  if [[ -n "${1}" ]]; then
    printf "SRC_${branch}=${1}" > "${branch_file}"
  else
    printf "SRC_${branch}=${PWD##*/source/}" > "${branch_file}"
  fi

  source "${branch_file}"
}

function set_tests() {
  local branch="$(git rev-parse --abbrev-ref HEAD | tr '/-' '_')"
  local branch_file="$(echo ${branch} | tr '/-' '_')"
  base_tests_dir="${HOME}/.config/tests"
  mkdir -p "${branch_file%/*}"

  if [[ -n "${1}" ]]; then
    printf "TESTS_${branch}=${1}" > "${branch_file}"
  else
    local tests_dir="${PWD##*/source/}"
    tests_dir="${tests_dir/src/tests}"
    printf "TESTS_${branch}=${tests_dir}" > "${branch_file}"
  fi

  source "${branch_file}"
}

function get_coverage() {
  [[ -n "${COVERAGE}" && "${COVERAGE}" -eq 1 ]] && printf -- '--coverage=1'
}

function get_failfast() {
  [[ -n "${FAILFAST}" && "${FAILFAST}" -eq 1 ]] && printf -- '--options="-xvv"'
}

function get_verbose() {
  if [[ -n "${VERBOSE}" && "${VERBOSE}" -ne 0 ]]; then
    printf -- '-'
    if [[ "${VERBOSE}" -lt 0 ]]; then
        printf -- 'q'
    else
      for i in $(seq 1 "${VERBOSE}"); do
        printf -- 'v'
      done
    fi
  fi
}

function verbose_option() {
  if [[ -n "$(get_verbose)" ]]; then
    printf -- '--options="%s"' $(get_verbose)
  fi
}


function jeans() {
  #set -x
  SOURCE_DIR=$(git rev-parse --show-toplevel)

  case "${1}" in
    'binary')
      ( shift ; cd "${SOURCE_DIR}" && ./pants binary "${OLDPWD}"$@ )
      ;;
    'qbinary')
      ( shift ; cd "${SOURCE_DIR}" && ./pants -q binary "${OLDPWD}"$@ )
      ;;
    'list')
      ( cd "${SOURCE_DIR}" && ./pants list "${OLDPWD}:" | ggrep -oP '(?=:).+' )
      ;;
    'test')
      ( shift ; cd "${SOURCE_DIR}" && ./pants test.pytest $(verbose_option) $(get_failfast) $(get_coverage)  "${OLDPWD}"$@ )
      ;;
    'testall')
      ( cd "${SOURCE_DIR}" && ./pants test.pytest $(verbose_option) $(get_failfast) $(get_coverage) "${TESTS}::" )
      ;;
    'repl')
      ( shift; cd "${SOURCE_DIR}" && ./pants repl --repl-py-ipython "${OLDPWD}"$@ )
      ;;
    'run')
      ( shift; cd "${SOURCE_DIR}" && ./pants run "${OLDPWD}"$@ )
      ;;
    'qrun')
      ( shift; cd "${SOURCE_DIR}" && ./pants -q run "${OLDPWD}"$@ )
      ;;
  esac
  #set +x
}

function work() {
  if [[ -n "${1}" && "${1}" == 'source' ]]; then
    cd "${HOME}/workspace/${1}"
  else
    cd "${HOME}"/workspace/"${1}"
  fi

  if git rev-parse --abbrev-ref HEAD > /dev/null 2>&1; then
    get_src
    get_tests
  fi
}

function src() {
  local branch="$(git rev-parse --abbrev-ref HEAD | tr '-' '_')"
  local src_dir="$(get_src | awk -F= '{printf $NF}')"
  work source/"${src_dir}"
}

function tests() {
  local branch="$(git rev-parse --abbrev-ref HEAD | tr '-' '_')"
  local tests_dir="$(get_tests | awk -F= '{printf $NF}')"
  work source/"${tests_dir}"
}

function all_zones() {
  printf -- ' -D %s' $(cat zones)
}

function svn_branch_diff() {
  if [[ -n "{$1}" ]]; then
    local file="${1}"
    shift
    local head="$PWD/${file}"
    local testing="${PWD/twitter-ops/twitter-ops/branches/puppet-testing}/${file}"
    local production="${PWD/twitter-ops/twitter-ops/branches/puppet-production}/${file}"
    diff -u "${head}" "${testing}" $@
    if [[ $? -ne 0 ]]; then
      svn info "${testing}"  | ggrep -oP 'Author: \S+|Date: \S+'
    fi
    diff -u "${head}" "${production}" $@
    if [[ $? -ne 0 ]]; then
      svn info "${production}"  | ggrep -oP 'Author: \S+|Date: \S+'
    fi
  fi
}

function = () {
  /opt/twitter/bin/most "$*"
}

function webbmc() {
  if [[ -n "${2}" ]]; then
    ssh -L 8443:"${1}":443 "${2}"
  fi
}

function mostdiff() {
  if [[ -n "${1}" ]]; then
    colordiff -u "$@" |& most
  fi
}

function vim-plugin() {
  if [[ -n "${1}" ]]; then
    git clone "${1}" ~/.vim/bundle/"${1##*/}"
  fi
}
