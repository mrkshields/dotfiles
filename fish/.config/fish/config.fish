# PATHS
set PATH $PATH $HOME/Library/Python/2.7/bin

# Powerline config
set fish_function_path $fish_function_path "$HOME/Library/Python/2.7/lib/python/site-packages/powerline/bindings/fish"
powerline-setup

# Tmux/Powerline setup
if command -v tmux >/dev/null
  if [ $TERM != 'screen' ]
    if [ -z $TMUX ]
      exec tmux
    end
  end
end

powerline-config tmux setup
