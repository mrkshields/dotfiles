" =============== Vundle Initialization ===============
" This loads all the plugins specified in ~/.vim/vundle.vim
" Use Vundle plugin to manage all other plugins
set nocompatible
filetype off
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()

Plugin 'w0rp/ale'
Plugin 'davidhalter/jedi-vim'
Plugin 'grahamking/lintswitch'
Plugin 'tell-k/vim-autoflake'
Plugin 'tell-k/vim-autopep8'
Plugin 'altercation/vim-colors-solarized'
Plugin 'FooSoft/vim-argwrap'
Plugin 'kevints/vim-aurora-syntax'
Plugin 'airblade/vim-gitgutter'
Plugin 'pantsbuild/vim-pants'
Plugin 'Vimjas/vim-python-pep8-indent'

call vundle#end()
filetype plugin indent on

" TODO: this may not be in the correct place. It is intended to allow overriding <Leader>.
" source ~/.vimrc.before if it exists.
if filereadable(expand("~/.vimrc.before"))
  source ~/.vimrc.before
endif

" ================ General Config ====================

set number                      "Line numbers are good
set backspace=indent,eol,start  "Allow backspace in insert mode
set history=1000                "Store lots of :cmdline history
set showcmd                     "Show incomplete cmds down the bottom
set showmode                    "Show current mode down the bottom
set gcr=a:blinkon0              "Disable cursor blink
set visualbell                  "No sounds
set autoread                    "Reload files changed outside vim
set ruler
set laststatus=2

" This makes vim act like all other editors, buffers can
" exist in the background without being in a window.
" http://items.sjbach.com/319/configuring-vim-right
set hidden

"turn on syntax highlighting
syntax on

" Change leader to a comma because the backslash is too far away
" That means all \x commands turn into ,x
" The mapleader has to be set before vundle starts loading all 
" the plugins.
let mapleader=","

" ================ Turn Off Swap Files ==============

"set noswapfile
"set nobackup
"set nowb

" ================ Persistent Undo ==================
" Keep undo history across sessions, by storing in file.
" Only works all the time.
if has('persistent_undo')
  silent !mkdir ~/.vim/backups > /dev/null 2>&1
  set undodir=~/.vim/backups
  set undofile
endif

" ================ Indentation ======================

set autoindent
set smartindent
set smarttab
set shiftwidth=2
set softtabstop=2
set tabstop=2
set expandtab

" CULPRIT FOR 4 space indents!!! (shiftwidth=4)
" Next line sets back to two for Python
filetype indent plugin on
autocmd FileType python setl sw=2 sts=2 et

" Display tabs and trailing spaces visually
set list listchars=tab:\ \ ,trail:·

set nowrap       "Don't wrap lines
set linebreak    "Wrap lines at convenient points

" ================ Folds ============================

set foldmethod=indent   "fold based on indent
set foldnestmax=3       "deepest fold is 3 levels
set nofoldenable        "dont fold by default

" ================ Completion =======================

set wildmode=list:longest
set wildmenu                "enable ctrl-n and ctrl-p to scroll thru matches
set wildignore=*.o,*.obj,*~ "stuff to ignore when tab completing
set wildignore+=*vim/backups*
set wildignore+=*sass-cache*
set wildignore+=*DS_Store*
set wildignore+=vendor/rails/**
set wildignore+=vendor/cache/**
set wildignore+=*.gem
set wildignore+=log/**
set wildignore+=tmp/**
set wildignore+=*.png,*.jpg,*.gif



" ================ Scrolling ========================

set scrolloff=8         "Start scrolling when we're 8 lines away from margins
set sidescrolloff=15
set sidescroll=1


" ================ Custom Settings ========================
"so ~/.yadr/vim/settings.vim

"set textwidth=100
set et ts=2 ai
syntax on

set nocompatible
let mapleader=","
map <leader>t :w<cr>:!python %<cr>
map <leader>s :w<cr>:!style-check %<cr>
map <leader>b :w<cr>:!bpython -i %<cr>
map <leader>d :w<cr>:!git diff %<cr>
map <leader>m :w<cr>:!git diff master... %<cr>

"autocmd BufRead,BufNewFile BUILD set filetype=python
"autocmd BufWritePost *.py call Flake8()

":au BufWinEnter * let w:m1=matchadd('Search', '\%<81v.\%>77v', -1)
":au BufWinEnter * let w:m2=matchadd('ErrorMsg', '\%>80v.\+', -1)


""" NERDTree and Explorer potential source of slowness - 09/30/16, 1:30 pm
"" NERDTree
""autocmd bufenter * if (winnr("$") == 1 && exists("b:NERDTreeType") && b:NERDTreeType == "primary") | q | endif
""map <C-n> :NERDTreeToggle<CR>
"
"" Explorer
"map <C-n> :E<CR>




"au BufWritePost *.py !/Users/mshields/workspace/source/dist/check.pex %

autocmd BufNewFile,BufRead *.aurora set filetype=python
autocmd BufNewFile,BufRead BUILD set filetype=python
autocmd BufNewFile,BufRead AURORA set filetype=python
autocmd BufNewFile,BufRead *.jinja set filetype=jinja
autocmd BufNewFile,BufRead *.workflow set filetype=json

autocmd BufNewFile,BufRead **/squid**/*.conf* set filetype=squid

set statusline+=%#warningmsg#
"set statusline+=%{SyntasticStatuslineFlag()}
set statusline+=%*

"let g:syntastic_always_populate_loc_list = 1
"let g:syntastic_auto_loc_list = 0
"let g:syntastic_check_on_open = 1
"let g:syntastic_check_on_wq = 1
"let g:syntastic_loc_list_height = 5
"let g:syntastic_perl_lib_path = [ '/Users/mshields/perl5/lib/perl5' ]
"let g:syntastic_yaml_checkers = [ 'yamlxs' ]
"let g:syntastic_ignore_files = ['AURORA', 'BUILD', '*.aurora']
let g:gitgutter_realtime = 0
let g:gitgutter_eager = 0


""" Slows VIM to a crawl :( - 09/30/16, 1:37 pm ET
""" Confirms still slow after VIM 8.x upgrade, when editin Python - 12/27/16, 3:51 PM
set rtp+=/Users/mshields/Library/Python/2.7/lib/python/site-packages/powerline/bindings/vim
python from powerline.vim import setup as powerline_setup
python powerline_setup
python del powerline_setup
set t_Co=256


"set laststatus=2
"set statusline=%04n\ %t%(\ %m%r%y[%{&ff}][%{&fenc}]\ \ %{mode()}%)\ %a%=col\ %v\ \ line\ %l/%L\ %p%%
"set laststatus=2
"set statusline=%{g:NyanModoki()}

let g:nyan_modoki_select_cat_face_number = 2
let g:nayn_modoki_animation_enabled = 1



let g:pymode_lint_checkers = ['mccabe', 'pyflakes', 'pylint', 'pep8', 'pep257']

":setlocal spell spelllang=en_us

let vim_markdown_preview_toggle=2

autocmd VimEnter * @b:last_tmux_window_name = system("tmux list-windows -a | ggrep -oP '(\S+)(?=\*)'")
autocmd BufReadPost,FileReadPost,BufNewFile * call system("tmux rename-window " . expand("%"))
autocmd VimLeave * call system("tmux rename-window " . expand("%last_tmux_window_name"))

autocmd FileType python map <buffer> <F3> :call Autoflake()<CR>
