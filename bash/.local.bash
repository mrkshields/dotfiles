export PATH=${PATH}:/Users/mshields/Library/Python/2.7/bin:/Users/mshields/bin
export PATH="$PATH:$HOME/.rvm/bin" # Add RVM to PATH for scripting
export JAVA_HOME=/Library/Java/JavaVirtualMachines/jdk1.8.0_72.jdk/Contents/Home
export PATH=${PATH}:${JAVA_HOME}
export FIGNORE='*.pyc'
export PYTHONDONTWRITEBYTECODE=very_yes
export PYTHONPATH=${PATH}:/Users/mshields/workspace/source/src/python/twitter/

if [[ -n "$(which brew)" ]]; then
  if [ -f $(brew --prefix)/etc/bash_completion ]; then
    . $(brew --prefix)/etc/bash_completion
  fi
  source "`brew --prefix`/etc/grc.bashrc"
fi

test -f ~/.git-completion.bash && . $_
test -f ~/.pants-completion.bash && . $_

#test -e "${HOME}/.iterm2_shell_integration.bash" && source "${HOME}/.iterm2_shell_integration.bash"
powerline_files=(
  "${HOME}/Library/Python/2.7/lib/python/site-packages/powerline/bindings/bash/powerline.sh"
  "${HOME}.local/lib/python2.7/lib/python/site-packages/powerline/bindings/bash/powerline.sh"
)
for file in "${powerline_files[@]}"; do
  test -f "${file}" && source "${file}" && break
done

# Fix tmux/powerline
powerline_config_bins=( "${HOME}/.local/bin/powerline-config" "${HOME}//Library/Python/2.7/bin/powerline-config")
for powerline_config in "${powerline_config_bins[@]}"; do
  test -x "$(which tmux)" && test -x "${powerline_config}" && "${powerline_config}" tmux setup && break
done

# Aliases

alias dns-tool='dns-tool -s ~/.dns_credentials.yaml'
alias fastboot='/Users/mshields/Library/Android/sdk/platform-tools/fastboot'
alias less='less -R'
alias pipi='/usr/local/bin/pip install --user'
alias s='ssh'
alias dotc="git --git-dir=${HOME}/.myconf --work-tree=${HOME}"

# Environment variables
test -f "${HOME}"/.homebrewrc && source "${HOME}"/.homebrewrc
export EDITOR='vim'


if pgrep ssh-agent > /dev/null 2>&1; then
  ssh-add -l > /dev/null 2>&1 || ssh-add -K
fi

function get_src() {
  env | grep "^SRC="
}

function get_tests() {
  env | grep "^TESTS="
}

function set_src() {
  src_file="${HOME}/.config/source/src"
  mkdir -p "${src_file%/*}"

  if [[ -n "${1}" ]]; then
    printf "export SRC=${1}\n" > "${src_file}"
  else
    printf "export SRC=${PWD##*/source/}\n" > "${src_file}"
  fi

  source "${src_file}"
  get_src
}

function set_tests() {
  local tests_file="${HOME}/.config/source/tests"
  mkdir -p "${tests_file%/*}"

  if [[ -n "${1}" ]]; then
    printf "export TESTS=${1}\n" > "${file}"
  else
    local tests_dir="${PWD##*/source/}"
    tests_dir="${tests_dir/src/tests}"
    printf "export TESTS=${tests_dir}\n" > "${file}"
  fi

  source "${tests_file}"
  get_tests
}

get_src
get_tests

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
    cd "${HOME}"/workspace/source/"${SRC}"
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

test -f "${HOME}"/.workrc && source "${HOME}"/.workrc
