import sys


if not [m for m in sys.modules if '_pex' in m]:
  from powerline.bindings.ipython.since_5 import PowerlinePrompts
  c = get_config()
  c.TerminalInteractiveShell.simple_prompt = False
  c.TerminalInteractiveShell.prompts_class = PowerlinePrompts
