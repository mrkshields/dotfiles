# Tmux/Powerline setup
if which tmux > /dev/null
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
