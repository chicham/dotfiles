if has('vim_starting')
  " ensure that we always start with Vim defaults (as opposed to those set by the current system)
  set all&
endif

" if has("gui_running")
"   " GUI is running or is about to start.
"   set lines=999 columns=999
" else
"   " This is console Vim.
"   if exists("+lines")
"     set lines=55
"   endif
"   if exists("+columns")
"     set columns=166
"   endif
" endif


if has('nvim')
  let g:home=expand('~/.config/nvim/', 1)
else
  let g:home=expand('~/.vim/', 1)
endif

if !filereadable(g:home . '/autoload/plug.vim')
  if !executable("curl")
    echo "You have to install curl or first install plug yourself"
  else
    silent !\curl -fLo g:home . /autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  endif
endif

let g:mapleader=' '
let g:maplocalleader='\'
let g:python3_host_prog = 'python3'
let g:python2_host_prog = 'python2'

let g:bundle = g:home . '/bundle/'
call plug#begin(g:bundle)

" Better defaults settings
Plug 'https://github.com/tpope/vim-sensible'
Plug 'https://github.com/rstacruz/vim-opinion/'
" automatic indentation
Plug 'https://github.com/tpope/vim-sleuth'
" Improved Search/Substitute, typo
Plug 'https://github.com/tpope/vim-abolish' | Plug 'https://github.com/nelstrom/vim-americanize', {'on': ['Abolish', 'Americanize']}
" Unix shell command
Plug 'https://github.com/tpope/vim-eunuch'
" Git plugin
Plug 'https://github.com/tpope/vim-fugitive'
Plug 'https://github.com/tpope/vim-rhubarb'
" Plug 'https://github.com/shumphrey/fugitive-gitlab.vim'
" fugitive git bindings
nnoremap <silent><leader>ga :<C-u>Git add %:p<CR><CR>
nnoremap <silent><leader>gs :<C-u>Gstatus<CR>
nnoremap <silent><leader>gc :<C-u>Gcommit -v -q %:p<CR>
nnoremap <silent><leader>gw :<C-u>Gwrite<CR><CR>
nnoremap <silent><leader>gg :<C-u>Ggrep<Space>
nnoremap <silent><leader>gb :<C-u>Git branch<Space>
nnoremap <silent><leader>go :<C-u>Git checkout<Space>
nnoremap <silent><leader>gd :<C-u>Gvdiff<Space>
nnoremap <Leader>g+ :Silent Git stash<CR>:e<CR>
nnoremap <Leader>g- :Silent Git stash pop<CR>:e<CR>
nnoremap <Leader>gp :Gpush --all<cr>

let g:fugitive_gitlab_domains = ['https://git.qwant.ninja/']

" Improved dot command
Plug 'https://github.com/tpope/vim-repeat'
" Surround
Plug 'https://github.com/machakann/vim-sandwich'
" Automatically end some structures
Plug 'https://github.com/tpope/vim-endwise'
" Better syntax for languages
Plug 'https://github.com/sheerun/vim-polyglot'
let g:polyglot_disabled = ['latex', 'tex', 'tex_LatexBox', 'markdown']
Plug 'https://github.com/dzeban/vim-log-syntax'
" Pairs mappings
Plug 'https://github.com/tpope/vim-unimpaired'
" Automatically comments
Plug 'https://github.com/tpope/vim-commentary'
" Show trailling white space
Plug 'https://github.com/ntpeters/vim-better-whitespace'
" Reopen file at last place edited
Plug 'https://github.com/dietsche/vim-lastplace'
" In buffer navigation
Plug 'https://github.com/justinmk/vim-sneak'
let g:sneak#streak     = 1
let g:sneak#s_next     = 1
let g:sneak#use_ic_scs = 1
" 2-character Sneak (default)
nmap , <Plug>Sneak_s
nmap ; <Plug>Sneak_S
" visual-mode
xmap , <Plug>Sneak_s
xmap ; <Plug>Sneak_S
" operator-pending-mode
omap , <Plug>Sneak_s
omap ; <Plug>Sneak_S
"replace 'f' with 1-char Sneak
nmap f <Plug>Sneak_f
nmap F <Plug>Sneak_F
xmap f <Plug>Sneak_f
xmap F <Plug>Sneak_F
"replace 't' with 1-char Sneak
nmap t <Plug>Sneak_t
nmap T <Plug>Sneak_T
xmap t <Plug>Sneak_t
xmap T <Plug>Sneak_T
omap T <Plug>Sneak_T
let g:sneak#target_labels = "etiscuranmovpdélbjzwqkxgyhàfç/ETISCURANMOVPDÉLBJZWQKXGYHÀFÇ"
" Automatically close pairs
Plug 'https://github.com/jiangmiao/auto-pairs'
let g:AutoPairsShortcutFastWrap = '<C-w>'
let g:AutoPairs = {'(':')', '[':']', '{':'}',"'":"'",'"':'"', '`':'`'}

Plug 'https://github.com/wellle/targets.vim'
Plug 'https://github.com/wellle/line-targets.vim'

"" New textobjects
"Plug 'https://github.com/kana/vim-textobj-user'
"" map ab, ib
"Plug 'https://github.com/rhysd/vim-textobj-anyblock'
"" map ac, ic, aC
"Plug 'https://github.com/glts/vim-textobj-comment'
"let g:textobj_comment_no_default_key_mappings = 1
"xmap a$ <Plug>(textobj-comment-a)
"omap a$ <Plug>(textobj-comment-a)
"xmap i$ <Plug>(textobj-comment-i)
"omap i$ <Plug>(textobj-comment-i)

"xmap a# <Plug>(textobj-comment-big-a)
"omap a# <Plug>(textobj-comment-big-a)
"xmap i# <Plug>(textobj-comment-big-i)
"omap i# <Plug>(textobj-comment-big-i)

""map ii, ai, iI, aI
"Plug 'https://github.com/kana/vim-textobj-indent'
""map a/, i/
"Plug 'https://github.com/kana/vim-textobj-lastpat'
"" map al, il
"Plug 'https://github.com/kana/vim-textobj-line'
"" map a%, i%
"Plug 'https://github.com/adriaanzon/vim-textobj-matchit'
"" map a,, i,
"Plug 'https://github.com/sgur/vim-textobj-parameter'
""map as, is
"Plug 'https://github.com/kana/vim-textobj-syntax'
"let g:textobj_syntax_no_default_key_mappings = 1
"xmap as  <Plug>(textobj-syntax-a)
"omap as  <Plug>(textobj-syntax-a)
"xmap is  <Plug>(textobj-syntax-i)
"omap is  <Plug>(textobj-syntax-i)
"" map av, iv
"Plug 'https://github.com/Julian/vim-textobj-variable-segment'

Plug 'https://github.com/kana/vim-operator-user'
Plug 'https://github.com/kana/vim-operator-replace'
nmap gr <Plug>(operator-replace)
"Intuitive visual blocks
Plug 'https://github.com/kana/vim-niceblock/'
" Better visual mode move
Plug 'https://github.com/bruno-/vim-vertical-move'
" Highlight when yanking
Plug 'https://github.com/haya14busa/vim-operator-flashy'
map y <Plug>(operator-flashy)
nmap Y <Plug>(operator-flashy)$
" Better incsearch
Plug 'https://github.com/haya14busa/is.vim'
" Better search word under cursor
Plug 'https://github.com/haya14busa/vim-asterisk'
map *  <Plug>(asterisk-z*)<Plug>(is-nohl-1)<Plug>Pulse
map #  <Plug>(asterisk-z#)<Plug>(is-nohl-1)<Plug>Pulse
map g* <Plug>(asterisk-gz*)<Plug>(is-nohl-1)<Plug>Pulse
map g# <Plug>(asterisk-gz#)<Plug>(is-nohl-1)<Plug>Pulse
" Highlight when searching
Plug 'https://github.com/inside/vim-search-pulse'
let g:vim_search_pulse_disable_auto_mappings = 1
let g:vim_search_pulse_mode = 'pattern'
nmap n :norm! nzzzv<Plug>Pulse<CR>
nmap N :norm! Nzzzv<Plug>Pulse<CR>
" Align plugin
Plug 'https://github.com/tommcdo/vim-lion'
let b:lion_squeeze_spaces = 1
" Display navigation marks
Plug 'https://github.com/kshenoy/vim-signature.git'
" Show diff with git head
Plug 'https://github.com/mhinz/vim-signify'
" Show indentation
Plug 'https://github.com/nathanaelkane/vim-indent-guides'
let g:indent_guides_enable_on_vim_startup = 1
let g:indent_guides_guide_size            = 1
let g:indent_guides_auto_colors           = 0
"
" Better undo tree
Plug 'https://github.com/mbbill/undotree'
nnoremap <silent> <leader>uu :<C-u>UndotreeShow<CR>:<C-u>UndotreeFocus<CR>
nnoremap <silent> <leader>uf :<C-u>UndotreeFocus<CR>
nnoremap <silent> <leader>uh :<C-u>UndotreeHide<CR>
nnoremap <silent> <leader>ut :<C-u>UndotreeToggle<CR>

if has("persistent_undo")
    set undodir=~/.undodir/
    set undofile
endif

" Operator that exchange text with content of buffer
Plug 'https://github.com/tommcdo/vim-exchange'
let g:exchange_no_mappings=1
nmap cx <Plug>(Exchange)
vmap X <Plug>(Exchange)
nmap cxc <Plug>(ExchangeClear)
nmap cxx <Plug>(ExchangeLine)
" Improve %
Plug 'https://github.com/vim-scripts/matchit.zip'
Plug 'https://github.com/vim-scripts/python_match.vim'
Plug 'https://github.com/itchyny/lightline.vim'

let g:lightline = {
      \ 'colorscheme': 'one',
      \ 'active': {
      \   'left': [ [ 'mode', 'paste' ],
      \             [ 'gitbranch', 'readonly', 'filename', 'modified' ] ]
      \ },
      \ 'component_function': {
      \   'gitbranch': 'fugitive#head'
      \ },
      \ }

Plug 'https://github.com/editorconfig/editorconfig-vim'
let g:EditorConfig_exclude_patterns = ['fugitive://.*', 'scp://.*']

Plug '/usr/bin/fzf'
Plug 'https://github.com/junegunn/fzf.vim'
" Customize fzf colors to match your color scheme
let g:fzf_colors =
\ { 'fg':      ['fg', 'Normal'],
  \ 'bg':      ['bg', 'Normal'],
  \ 'hl':      ['fg', 'Comment'],
  \ 'fg+':     ['fg', 'CursorLine', 'CursorColumn', 'Normal'],
  \ 'bg+':     ['bg', 'CursorLine', 'CursorColumn'],
  \ 'hl+':     ['fg', 'Statement'],
  \ 'info':    ['fg', 'PreProc'],
  \ 'border':  ['fg', 'Ignore'],
  \ 'prompt':  ['fg', 'Conditional'],
  \ 'pointer': ['fg', 'Exception'],
  \ 'marker':  ['fg', 'Keyword'],
  \ 'spinner': ['fg', 'Label'],
  \ 'header':  ['fg', 'Comment'] }
let g:fzf_buffers_jump = 1

nnoremap <leader>fb :<C-u>Buffers<cr>
nnoremap <leader>ff :<C-u>FZF <c-r>=expand("%:p:h")<cr>/..<cr>
nnoremap <leader>fh :<C-u>History<cr>
nnoremap <leader>fg :<C-u>Rg <c-r>=expand("<cword>")<cr><cr>
nnoremap <leader>fG :<C-u>Rg<cr>
nnoremap <leader>fm :<C-u>Marks<cr>
nnoremap <leader>fc :<C-u>BCommits<cr>
nnoremap <leader>fp :<C-u>Maps<cr>

" Snippets
Plug 'https://github.com/SirVer/ultisnips' | Plug 'https://github.com/honza/vim-snippets'
" If you want :UltiSnipsEdit to split your window.
let g:UltiSnipsExpandTrigger = "<tab>"
let g:UltiSnipsJumpForwardTrigger = "<tab>"
let g:UltiSnipsJumpBackwardTrigger = "<s-tab>"

let g:UltiSnipsEditSplit="vertical"
let g:UltiSnipsListSnippets = "<c-u>"
let g:UltiSnipsSnippetDirectories=['UltiSnips', $HOME . '/.snippets/']

" Colorschemes
Plug 'https://github.com/jnurmine/Zenburn'
let g:zenburn_high_Contrast=1
let g:zenburn_alternate_Visual = 1
let g:zenburn_alternate_Include = 1
let g:zenburn_alternate_Error = 1
let g:zenburn_disable_Label_underline = 1
let g:zenburn_force_dark_Background = 1
let g:zenburn_unified_CursorColumn = 1

"
" Latex plugin
Plug 'https://github.com/lervag/vimtex'
let g:vimtex_complete_enabled = 1
" let g:vimtex_complete_recursive_bib = 1
let g:vimtex_view_method='zathura'
let g:tex_flavor="latex"
let g:vimtex_compiler_method = 'latexmk'
let g:vimtex_compiler_latexmk = {
      \ 'backend': 'nvim',
      \ 'continuous': 1,
      \ 'build_dir' : 'build',
      \}


" Split/Join lines
Plug 'https://github.com/AndrewRadev/splitjoin.vim'
let g:splitjoin_split_mapping = 'gS'
let g:splitjoin_join_mapping  = 'gJ'

" Diff two lines
Plug 'https://github.com/AndrewRadev/linediff.vim'

" Improved tab
Plug 'https://github.com/ervandew/supertab'
let g:SuperTabDefaultCompletionType    = '<C-n>'
let g:SuperTabCrMapping                = 0
let g:UltiSnipsExpandTrigger           = '<tab>'
let g:UltiSnipsJumpForwardTrigger      = '<C-n>'
let g:UltiSnipsJumpBackwardTrigger     = '<C-p>'

" make YCM compatible with UltiSnips (using supertab)
let g:ycm_key_list_select_completion = ['<C-n>', '<Down>']
let g:ycm_key_list_previous_completion = ['<C-p>', '<Up>']
let g:SuperTabDefaultCompletionType = '<C-n>'


Plug 'https://github.com/dense-analysis/ale'
let g:ale_set_loclist = 1
let g:ale_set_quickfix = 1
let g:ale_fix_on_save = 1

let g:ale_linters = {
\   'python': ['flake8', 'vulture', 'bandit', 'mypy', 'pyflakes'],
\}

let g:ale_fixers = {
\   '*': ['remove_trailing_lines', 'trim_whitespace'],
\   'javascript': ['eslint'],
\   'python': ['isort', 'black'],
\}

" nnoremap <silent> <leader>af :<C-u>ALEFix<cr>

Plug 'https://github.com/neoclide/coc.nvim', {'branch': 'release'}
Plug 'https://github.com/antoinemadec/coc-fzf'

inoremap <silent><expr> <c-space> coc#refresh()
" if has('patch8.1.1068')
"   " Use `complete_info` if your (Neo)Vim version supports it.
"   inoremap <expr> <cr> complete_info()["selected"] != "-1" ? "\<C-y>" : "\<C-g>u\<CR>"
" else
"   imap <expr> <cr> pumvisible() ? "\<C-y>" : "\<C-g>u\<CR>"
" endif
" Use `[g` and `]g` to navigate diagnostics
nmap <silent> [g <Plug>(coc-diagnostic-prev)
nmap <silent> ]g <Plug>(coc-diagnostic-next)
" GoTo code navigation.
nmap <silent> gd <Plug>(coc-definition)
nmap <silent> gy <Plug>(coc-type-definition)
nmap <silent> gi <Plug>(coc-implementation)
nmap <silent> gf <Plug>(coc-references)

" Use K to show documentation in preview window.
nnoremap <silent> K :call <SID>show_documentation()<CR>
autocmd CursorHold * silent call CocActionAsync('highlight')

function! s:show_documentation()
  if (index(['vim','help'], &filetype) >= 0)
    execute 'h '.expand('<cword>')
  else
    call CocAction('doHover')
  endif
endfunction

" Symbol renaming.
nnoremap <leader>cr <Plug>(coc-rename)

augroup mygroup
  autocmd!
  " Setup formatexpr specified filetype(s).
  autocmd FileType typescript,json setl formatexpr=CocAction('formatSelected')
  " Update signature help on jump placeholder.
  autocmd User CocJumpPlaceholder call CocActionAsync('showSignatureHelp')
augroup end

" Applying codeAction to the selected region.
" Example: `<leader>aap` for current paragraph
xnoremap <leader>ca  <Plug>(coc-codeaction-selected)
nnoremap <leader>ca  <Plug>(coc-codeaction-selected)
" Remap keys for applying codeAction to the current line.
nnoremap <leader>caa  <Plug>(coc-codeaction)
" Apply AutoFix to problem on the current line.
noremap <leader>cff  <Plug>(coc-fix-current)
"
" Mappings using CoCList:
" Show all diagnostics.
nnoremap <silent> <space>cd  :<C-u>CocFzfList diagnostics<cr>
" Manage extensions.
nnoremap <silent> <space>ce  :<C-u>CocFzfList extensions<cr>
" Show commands.
nnoremap <silent> <space>cc  :<C-u>CocFzfList commands<cr>
" Find symbol of current document.
nnoremap <silent> <space>co  :<C-u>CocFzfList outline<cr>
" Search workspace symbols.
nnoremap <silent> <space>cs  :<C-u>CocFzList -I symbols<cr>

let g:lightline = {
      \ 'active': {
      \   'left': [ [ 'mode', 'paste' ],
      \             [ 'cocstatus', 'readonly', 'filename', 'modified' ] ]
      \ },
      \ 'component_function': {
      \   'cocstatus': 'coc#status'
      \ },
      \ }

" Use auocmd to force lightline update.
autocmd User CocStatusChange,CocDiagnosticChange call lightline#update()



" The Silver Searcher
if executable('rg')
  " Use ag over grep
  set grepprg=rg\ --vimgrep
endif

Plug 'https://github.com/luochen1990/rainbow'
let g:rainbow_active = 1 "0 if you want to enable it later via :RainbowToggle
let g:rainbow_conf = {
      \   'ctermfgs': [4, 3, 8, 11],
      \   'guifgs': ['lightblue', 'coral', 'mediumseagreen', 'lightgoldenrod'],
      \   'operators': '_,_',
      \   'parentheses': ['start=/(/ end=/)/ fold', 'start=/\[/ end=/\]/ fold', 'start=/{/ end=/}/ fold'],
      \   'separately': {
      \       '*': {},
      \       'tex': {
      \           'parentheses': ['start=/(/ end=/)/', 'start=/\[/ end=/\]/'],
      \       },
      \       'vim': {
      \           'parentheses': ['start=/(/ end=/)/', 'start=/\[/ end=/\]/', 'start=/{/ end=/}/ fold', 'start=/(/ end=/)/ containedin=vimFuncBody', 'start=/\[/ end=/\]/ containedin=vimFuncBody', 'start=/{/ end=/}/ fold containedin=vimFuncBody'],
      \       },
      \       'html': {
      \           'parentheses': ['start=/\v\<((area|base|br|col|embed|hr|img|input|keygen|link|menuitem|meta|param|source|track|wbr)[ >])@!\z([-_:a-zA-Z0-9]+)(\s+[-_:a-zA-Z0-9]+(\=("[^"]*"|'."'".'[^'."'".']*'."'".'|[^ '."'".'"><=`]*))?)*\>/ end=#</\z1># fold'],
      \       },
      \       'css': 0,
      \   }
      \}

" Writing tools
Plug 'https://github.com/reedes/vim-lexical'

let g:lexical#spell = 1
command! -nargs=0 LexFr call lexical#init({
      \ 'spell': 1,
      \ 'spelllang':  ['fr'],
      \ 'spellfile':  ['~/.vim/spell/fr.utf-8.add'],
      \ })
command! -nargs=0 LexEn call lexical#init({
      \ 'spell': 1,
      \ 'spelllang':  ['en'],
      \ 'thesaurus':  ['~/.vim/thesaurus/mobythes.aur'],
      \ })

Plug 'https://github.com/vim-pandoc/vim-pandoc' |
      \ Plug 'https://github.com/vim-pandoc/vim-pandoc-syntax' |
      \ Plug 'https://github.com/vim-pandoc/vim-criticmarkup' |
      \ Plug 'https://github.com/vim-pandoc/vim-rmarkdown' |
      \ Plug 'https://github.com/vim-pandoc/vim-pandoc-after'

let g:pandoc#keyboard#use_default_mappings = 0
let g:pandoc#after#modules#enabled = ["ultisnips", "supertab"]
let g:pandoc#formatting#mode = "s"
let g:pandoc#syntax#conceal#use = 0
let g:pandoc#biblio#use_bibtool = 1

Plug 'https://github.com/tbabej/taskwiki'
Plug 'https://github.com/blindFS/vim-taskwarrior'

call plug#end()

runtime! plugin/sensible.vim
runtime! plugin/opinion.vim
runtime! macros/sandwich/keymap/surround.vim
runtime! macros/matchit.vim
source /usr/share/vim/vimfiles/plugin/fzf.vim

colorscheme zenburn

inoremap <c-e> <ESC>A
inoremap <c-b> <Esc>I

filetype on
filetype plugin indent on

scriptencoding utf-8

set guifont=Source\ Code\ Pro.otf
set autowrite
set autochdir
set tags=./tags,tags
set t_Co=256
set foldopen+=search
set foldopen+=jump
set cursorline
set showtabline=0
set completeopt=longest,menuone
set wildignore+=tags,.*.un~,*.pyc
set complete+=kspell
set confirm
set virtualedit=block
set modeline
set modelines=5
set wrap
set formatoptions+=n
set formatoptions-=l
set linebreak
set showbreak=>>
set mouse=nvi
set mousemodel=popup
set listchars-=trail:-
set t_vb=
set novisualbell
set noeb vb t_vb=
set list
set nohlsearch
set nojoinspaces
set noshowmode
set laststatus=2
set hidden
set diffopt+=vertical
set signcolumn=yes
set shortmess +=c

if exists('&inccommand')
  set incsearch
  set inccommand=nosplit
endif

if v:version >= 703
  set wildignorecase
  set undofile
  set undodir=/tmp
  set relativenumber
endif

if exists("syntax_on") || exists("syntax_manual")
else
  syntax on
endif
if has('unnamedplus')
  set clipboard=unnamedplus
else
  set clipboard=unnamed
endif

" Autocmd
" Copied from tpope
if has("autocmd")

  augroup lexical
    autocmd!
    autocmd FileType markdown,md call lexical#init()
    autocmd FileType textile call lexical#init()
    autocmd FileType tex call lexical#init()
  augroup END

  augroup ftcheck
    autocmd!
    autocmd bufnewfile,bufread *.cls       set ft=tex
    autocmd bufnewfile,bufread *named.conf*       set ft=named
    autocmd bufnewfile,bufread *.txt if &ft == ""|set ft=text|endif
    autocmd bufnewfile,bufread readme,install,news,todo if &ft == ""|set ft=pandoc|endif
  augroup end

  augroup ftoptions
    autocmd!
    autocmd FileType html,css,jinja2 EmmetInstall
    autocmd filetype c,cpp,cs,java          setlocal commentstring=//\ %s
    autocmd syntax   javascript             setlocal isk+=$
    autocmd filetype xml,xsd,xslt,javascript setlocal ts=2
    autocmd filetype text,txt,mail          setlocal ai com=fb:*,fb:-,n:>
    autocmd filetype sh,zsh,csh,tcsh        inoremap <silent> <buffer> <c-x>! #!/bin/<c-r>=&ft<cr>
    autocmd filetype sh,zsh,csh,tcsh        let &l:path = substitute($path, ':', ',', 'g')
    autocmd filetype perl,python,ruby       inoremap <silent> <buffer> <c-x>! #!/usr/bin/env<space><c-r>=&ft<cr>
    autocmd filetype c,cpp,cs,java,perl,javscript,php,aspperl,tex,css let b:surround_101 = "\r\n}"
    autocmd filetype apache       setlocal commentstring=#\ %s
    autocmd filetype git,gitcommit setlocal foldmethod=syntax foldlevel=1
    autocmd filetype gitcommit setlocal spell
    autocmd filetype help setlocal ai fo+=2n | silent! setlocal nospell
    autocmd filetype help nnoremap <silent><buffer> q :q<cr>
    autocmd filetype lua  setlocal includeexpr=substitute(v:fname,'\\.','/','g').'.lua'
    autocmd filetype ruby setlocal tw=79 comments=:#\  isfname+=:
    autocmd filetype liquid,markdown,text,txt setlocal tw=78 linebreak nolist
    autocmd filetype * if exists("+omnifunc") && &omnifunc == "" | setlocal omnifunc=syntaxcomplete#complete | endif
    autocmd filetype tex,plaintex execute "setlocal indentkeys="
    autocmd filetype python let &colorcolumn=join(range(88,999),",")
  augroup end

  augroup cursorline
    autocmd!
    autocmd WinLeave * set nocursorline
    autocmd WinEnter * set cursorline
    autocmd InsertEnter * set nocursorline
    autocmd InsertLeave * set cursorline
  augroup END

  augroup trailing
    autocmd!
    autocmd InsertEnter * :set listchars-=trail:·
    autocmd InsertLeave * :set listchars+=trail:·
  augroup END

  augroup ft_quickfix
    autocmd!
    autocmd Filetype qf setlocal colorcolumn=0 nolist nocursorline nowrap textwidth=0
  augroup END

  augroup indentguide
    autocmd!
    autocmd VimEnter,Colorscheme * :hi IndentGuidesOdd  ctermbg=darkgrey guibg=darkgrey
    autocmd VimEnter,Colorscheme * :hi IndentGuidesEven ctermbg=grey guibg=grey
  augroup end

endif

highlight link SneakPluginTarget IncSearchMatch
highlight ColorColumn ctermbg=235 guibg=#2c2d27

"  Shortcuts
" nmap <cr> :
nnoremap <expr> <CR> &buftype ==# 'quickfix' ? "\<CR>" : "\:"

" Window shortcut

" Use | and _ to split windows (while preserving original behaviour of [count]bar and [count]_).
nnoremap <expr><silent> <Bar> !v:count ? "<C-W>v<C-W><Right>zt" : "<Bar>"
nnoremap <expr><silent> _     !v:count ? "<C-W>s<C-W><Down>zt"  : '_'

nnoremap <leader><Up> <C-w><Up>
nnoremap <leader><Down> <C-w><Down>
nnoremap <leader><Right> <C-w><Right>
nnoremap <leader><Left> <C-w><Left>
nnoremap <leader>et :tabe <c-r>=expand("%:p:h")<cr>/
nnoremap <leader>ee :e <c-r>=expand("%:p:h")<cr>/
nnoremap <leader>e_ <C-w><C-s><C-w>l:e <c-r>=expand("%:p:h")<cr>/
nnoremap <leader>e<bar> <C-w><C-v><C-w>l:e <c-r>=expand("%:p:h")<cr>/
nnoremap <leader>ww <C-w>c
nnoremap <leader>w= <C-w>=
nnoremap <leader>wr <C-w>r
nnoremap <leader>wT <C-w>T
nnoremap <leader>wo <C-w>o
nnoremap <leader>wh <C-w>t<C-w>K
nnoremap <leader>wv <C-w>t<C-w>H

nnoremap <leader>+ 10<C-w>+
nnoremap <leader>- 10<C-w>-
nnoremap <leader>« 10<C-w><
nnoremap <leader>» 10<C-w>>


nmap ( [
nmap ) ]
nmap ' `
nnoremap Q @@
vnoremap . :normal .<CR>
vnoremap Q :normal @@<CR>
nnoremap <leader>ws :%s/\s\+$//<cr>:let @/=''<CR>
nnoremap W :w<CR>
nnoremap gV `]V`]
vnoremap < <gv
vnoremap < <gv
cnoremap <Nul> <C-R><C-W>

" nnoremap <leader>cd :cd %:p:h<cr>:pwd<cr>

" Shortcuts using <leader>
" [os and ]os toggle spell
nnoremap <leader>sn ]s
nnoremap <leader>sp [s
nnoremap <leader>sa zg
nnoremap <leader>sA zG
nnoremap <leader>si 2zg
nnoremap <leader>s? z=

nnoremap <silent> <leader>ve :e $MYVIMRC<cr>
nnoremap <silent> <leader>vs :source $MYVIMRC<cr>
" cnoremap w!! w !sudo tee %
nnoremap <leader>i mqHmwgg=G`wzt`q

nmap <C-space> <C-x><C-o>
nnoremap <expr> <Down> v:count ? 'j' : 'gj'
nnoremap <expr> <Up> v:count ? 'k' : 'gk'
vnoremap <silent><Down> gj
vnoremap <silent><Up> gk
" Switch between last 2 files
nnoremap <leader><leader> <c-^>
" Open terminal in a split

nnoremap <silent> <leader>t<Bar> <C-W>v<C-W><Right>:terminal<cr>
nnoremap <silent> <leader>t_ <C-W>s<C-W><Down>:terminal<cr>
tnoremap <Esc> <C-\><C-n>
