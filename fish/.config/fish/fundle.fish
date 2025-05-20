# Fundle plugin installs
if functions fundle > /dev/null 2>&1
  #  fundle plugin 'fisherman/fzy'
  fundle plugin 'Markcial/upto'
  fundle plugin 'danhper/fish-ssh-agent'
  fundle plugin 'edc/bass'
  fundle plugin 'evanlucas/fish-kubectl-completions'
  fundle plugin 'fisherman/spin'
  fundle plugin 'halostatue/fish-direnv'
  fundle plugin 'jethrokuan/z'
  fundle plugin 'joseluisq/gitnow'
  fundle plugin 'laughedelic/pisces'
  fundle plugin 'oh-my-fish/plugin-bang-bang'
  fundle plugin 'oh-my-fish/plugin-expand'
  fundle plugin 'oh-my-fish/theme-bobthefish'  # won't work without installing ohmyfish framework then using omf to install
  fundle plugin 'tuvistavie/fish-fastdir'
  fundle plugin 'z11i/github-copilot-cli.fish'
  fundle plugin 'jorgebucaran/nvm.fish'

  fundle init
end
