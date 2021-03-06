" :h只要路径
" https://github.com/vim/vim/issues/6793
" Register % contains the name of the current file.
" 这3行结果貌似一样, expand和fnamemodify只有细微区别？
" let $no_vscode = expand('%:h') . "/no_vscode.vim"
" let $no_vscode = fnamemodify('%',':h') . "/no_vscode.vim"
let $no_vscode = fnamemodify($MYVIMRC,':h') . "/no_vscode.vim"

if exists('g:vscode')
    " 用vscode时，本文件里也有依赖于$MYVIMRC的变量。别扔掉$MYVIMRC
    let $MYVIMRC =  "~/dotF/cfg/nvim/init.vim"
    " 放进if？ gf无法跳到has_vscode.vim
    " let $has_vscode = fnamemodify($MYVIMRC,':h') . "/has_vscode.vim"
endif
let $has_vscode = fnamemodify($MYVIMRC,':h') . "/has_vscode.vim"

" 无法expand/扩展/识别 文件名
" let $has_vscode = fnamemodify($MYVIMRC,':h') . "/has_vscode.vim"
" let $has_vscode = expand('%:h') . "/has_vscode.vim"
" let $has_vscode = fnamemodify('%',':h') . "/has_vscode.vim"


" echom 'has_vscode找到了吗'
" echom $has_vscode



nnoremap <c-d> 15<c-d>
nnoremap <c-u> 15<c-u>

" 禁用netrw，不过应该用不着了。我删掉了对应文件
" let g:loaded_netrw       = 1
" let g:netrw_banner=0
" let g:loaded_netrwPlugin = 1
"

" 让配置变更立即生效
" >_>_>===================================================================begin
" 1.  `:augroup {name}`
" 	Define the autocmd group name for the  following ":autocmd"
augroup Reload

" 2. Delete any old autocommands  `:help autocmd-remove`
autocmd!

" 或者： 先在group内删除匹配{event}和{pat}的autocmd，再定义新的cmd
":autocmd! [group]   {event}     {pat}      {cmd}
" autocmd! Reload BufWritePost $MYVIMRC  echom '改了init.vim'

" When resourcing vimrc always use autocmd-nested  因为autocmd执行时 会又遇到autocmd
" ++nested 在老版本中是nested
                                                                                " 点号拼接字符串
autocmd Reload BufWritePost $MYVIMRC    ++nested   source $MYVIMRC | echom "更新了"."init.vim "| redraw
autocmd Reload BufWritePost $no_vscode  ++nested   source $MYVIMRC | echom '改了no_vscode.vim, reload了init.vim' | redraw
autocmd Reload BufWritePost $has_vscode  ++nested   source $MYVIMRC | echom '改了has_vscode.vim, 更新init.vim'  | redraw

" 4. Go back to the default group, named "end"
augroup end
" end=====================================================================<_<_<


nnoremap gf :tabedit <cfile><CR>

cnoremap <Up> <c-p>
cnoremap <Down> <c-n>

" =============================================================
" block模式
" 记忆：c for block
" c发音:ke
nnoremap <c-c> <c-v>
" 变成^  作用是 显示ASCII码 （以^H等方式显示一些控制字符）
cnoremap <c-c> <c-v>
" vscod里不生效：
inoremap <c-c> <c-v>

" 加了几行，还是粘贴
" inoremap <c-v> <c-v>
" cnoremap <c-v> <c-v>
" nnoremap <c-v> <c-v>
"
" 加了这两行，还是删除到行首
" cnoremap <c-q> <c-v>
" inoremap <c-q> <c-v>
"
" =============================================================


set iskeyword+=-

let mapleader =" "

" About search
" >_>_>===================================================================begin

    set incsearch         " incremental searching
    set wrapscan
    set ignorecase smartcase

    " .1 自动取消高亮=========================================begin
        set hlsearch " 高亮search
        " s: search set highlight
        nnoremap <Leader>ss :set hlsearch!<CR>


        let s:current_timer = -1

        func Highlight_Search_off(timerId)
            set hlsearch!
        endfunc

        func ResetTimer()
            if s:current_timer > -1
                call timer_stop(s:current_timer)
            endif
            " 第一个参数：按键多少秒后 自动取消
            let s:current_timer = timer_start(1000, 'Highlight_Search_off')
        endfunc


        nnoremap <silent> N N:call ResetTimer()<CR>
        nnoremap <silent> n n:call ResetTimer()<CR>
    " end========================================================<_<_<


    " .2 不搜注释里的内容=========================================begin
    " filetype        on        " 检测文件类型
    " filetype plugin on        " 针对不同的文件类型, load不同plugin
    " filetype indent on        " 针对不同的文件类型采用不同的缩进格式
    filetype plugin indent on " 实现了上面3行
                                " there is no need  to do ":filetype on" after ":syntax on".

    " if the file type is not detected automatically, or it finds the wrong type,
    " you can  add a modeline to your  file.
    " 但我用笔记本时，root用户或者vscode-neovim使得modeline是off的，不能靠modeline这时要靠这行：

    filetype detect
    " echom "文件类型是"
    " echom &filetype
    " echom "文件类型输出结束"


    " ms: mark as searh, 回头敲's跳回来
    " https://stackoverflow.com/a/3760486/14972148
    " 据说map了slash会影响其他插件. 不过先用着吧
        if &filetype == 'vim'
            nnoremap ? msgg/\v^[^"]*
        " 防止检测filetype不准
        elseif expand('%:t') == 'init.vim'
            nnoremap ? msgg/\v^[^"]*

        " vim的某个文件已经设置了:  au BufNewFile,BufRead *.ahk  setf autohotkey
        elseif &filetype == 'autohotkey'
            nnoremap ? msgg/\v^[^;]*
            " todo 装个插件
            " https://github.com/hnamikaw/vim-autohotkey
        elseif expand('%:t') == 'wf_key.ahk'
            nnoremap ? msgg/\v^[^;]*
        elseif expand('%:t') == 'tmux.conf'
            nnoremap ? msgg/\v^[^#]*
        elseif &filetype  == 'zsh'
            nnoremap ? msgg/\v^[^#]*
        elseif &filetype  == 'json'
            nnoremap ? msgg/\v^[^/]*
        else
            " vscode neovim无法识别filetype?
            " 暂时一锅乱炖
            nnoremap ? msgg/\v^[^#";]*
        endif

        " 记作global search
        nnoremap g/ msgg/
    " end=====================================================================<_<_<




" U is seldom useful in practice,U 本身的功能，不及C-R
nnoremap U <C-R>
nnoremap <M-u> <C-R>

set timeoutlen=500  " 主要影响map
inoremap jj <esc>

" set notimeout
" tty?
set ttimeout ttimeoutlen=10

let g:selecmode="mouse"

" set linebreak
" set list  " 没设listchar时，这行会导致tab排版混乱
" set listchars=tab:>_,trail:-,nbsp:+


" `:autocmd` adds to the list of autocommands regardless of whether they are
        " already present.  When your .vimrc file is sourced twice, the autocommands
        " will appear twice.  To avoid this, define your autocommands in a group, so
        " that you can easily clear them:



" When a function by this name already exists and [!] is
" not used an error message is given.  There is one
" exception: When sourcing a script again, a function
" that was previously defined in that script will be
" silently replaced.
" When [!] is used, an existing function is silently
" replaced.  Unless it is currently being executed, that
" is an error.
" NOTE: Use ! wisely.  If used without care it can cause
" an existing function to be replaced unexpectedly,
" which is hard to debug.

" 改了 beautify_wf并保存后， 保存init.vim会说function already exist
" 些别想着避免这个问题，毕竟很少改init.vim以外的文件.
" https://github.com/xolox/vim-reload


" " 竖着分屏打开help
" augroup my_filetype_settings
"     autocmd!
"     " winnr: 当前window的编号，top winodw是1
"     " $  表示 last window
"     autocmd FileType help if winnr('$') > 2 | wincmd K | else | wincmd L | endif
"     augroup end

" 1.4 LISTING MAPPINGS                  *map-listing*
" When listing mappings the characters in the first two columns are:

"       CHAR    MODE    ~
"      <Space>  Normal, Visual, Select and Operator-pending
"     n Normal
"     v Visual and Select
"     s Select
"     x Visual
"     o Operator-pending
"     ! Insert and Command-line
"     i Insert
"     l ":lmap" mappings for Insert, Command-line and Lang-Arg
"     c Command-line
"     t Terminal-Job
"
" Just before the {rhs} a special character can appear:
"     * indicates that it is not remappable
"     & indicates that only script-local mappings are remappable
"     @ indicates a buffer-local mapping


" todo
" shif left
" map <S-Left>
" map <S-Right>
" map <C-Left>
" map <C-Right>

"  系统粘贴板  "+
inoremap <C-V> "+p
set clipboard+=unnamedplus  " vim外也可以粘贴vim的registry了
" echo 'wls有bug， 别设unnamedplus'
" xsel换成xcliip, 貌似可以在wsl下用unnamedplus了
        " if hostname() == 'redmi14-leo' && !exists('g:vscode')
        "     " set clipboard=""  " 默认就是这样
        "
        "     " 备用方案:
        "     " wsl下:
        "     " https://github.com/equalsraf/win32yank/release
        "     " https://gist.github.com/MinSomai/c732fc66e36534feb5a8fb9e0a3c8fb2
        " endif

inoremap <C-P> <Esc>pa
" 现在的ctrl v能在normal模式下直接粘贴系统粘贴板的内容

noremap <Right> *
noremap <Left> #
" CTRL-O                Go to [count] Older cursor position in jump list
                        " (not a motion command).

" <Tab>
" CTRL-I                  Go to [count] newer cursor position in jump list
"                         (not a motion command).

" 在vusial mode下好像没功能
noremap <Up> <C-O>
vnoremap <Up> <Esc><C-O>
" CTRL-I <Tab>          Go to [count] newer cursor position in jump list
                        " (not a motion command)
" 在vusial mode下好像没功能
nnoremap <Down> <C-I>
vnoremap <Down> <Esc><C-I>


" :[range]s[ubstitute]/{pattern}/{string}/[flags] [count]
" mr 表示 mark for replace 方便跳回来
nnoremap <F2>   mr:  .,$subs  #\<\>##gc<Left><Left><Left><Left><Left><Left><C-R><C-W><Right><Right><Right><C-R><C-W>
nnoremap <M-F2> mr:  .,$subs  ###gc<Left><Left><Left><Left><C-R><C-W><Right>
    "       %       表示全文. Example: :%s/foo/bar/g.
    "       .       当前行
    "       $       表示结尾
    "       .,$     from the current line to the end of the file.
                                " 这些不能作为delimiter : 双引号， 竖线， backslash
                                " 其他single-byte character都可以




noremap <Up> <C-O>





" vscode里是切到terminal
" nnoremap <C-J>

noremap <BS> <left>
" normal模式：<C-X>  数字减1
" shift在ctrl上，加1 vs 减一，刚好
nnoremap X <C-A>

" 被coc占用了？
" <C-X> 调自带的omnicomplete,  有的功能好像被屏蔽了.
" omonicomplet和coc可以互补?
inoremap <C-F> <C-X><C-F>

    " 对于vscode-nvim：insert mode is being handled by vscode 所以<C-X>没反应
                            " *i_CTRL-X* *insert_expand*
    " CTRL-X enters a sub-mode where several commands can be used.  Most of these
    " commands do keyword completion; see |ins-completion|.

    " no help for <C-X>
    " no help for CTRL-X CRTL-O
    " 这样才行：
    " h i_CTRL-X


" 这样可以 不那么死板地 只能用~/AppData/Local/nvim/init.vim来进入windows的nvim, 从而管理插件(
    " windows的nvim和vscode的nvim共用):
"nvim -u '\\wsl$\Ubuntu\root\dotF\.config\nvim\init.vim'
" 插件位置:
" C:\Users\noway\AppData\Local\nvim-data
" 把wsl下的dotfile发送快捷方式到 ~/AppData/Local/nvim/init.vim , 不行.因为shortcut和软链接还不一样
" https://superuser.com/questions/253935/what-is-the-difference-between-symbolic-link-and-shortcut

" todo:  有些粘贴来的配置，应该要清理掉


" 【【-----------------------------------------------------------begin
" Return to last edit position when opening files
" 有bug: autocmd BufReadPost * normal! g`"zv
"  normal! 表示 Execute Normal mode commands,    [!] :  mappings will not be used.
"  g`"表示 跳到 the last known position in a file
"  zv 取消折叠光标所在行
" 如果: the file is truncated outside of vim, and vim's mark is on a line that no longer exists, vim throws an error. Fixed that with:
" autocmd BufReadPost * silent! normal! g`"zv
" 或者:
autocmd BufReadPost *
     \ if line("'\"") > 0 && line("'\"") <= line("$") |
     \   execute "normal! g`\"zv" |
     \ endif
" end-------------------------------------------------------------】】


" T:tab, tab to space
func T2S()
    " vscode 有个插件：takumii.tabspace  " 不过应该用不着了
    set expandtab tabstop=4
    " [range]retab 百分号% 表示全文
    %retab!
    echo "  Tab变成4空格"
endfunc
" 没有混淆时，任意缩写都可以？endfunc

" autocmd对neovim-vscode无效？
autocmd BufNewFile,BufRead *.py  execute ":call T2S()"

" https://github.com/neoclide/coc.nvim/wiki/Using-the-configuration-file
autocmd FileType json syntax match Comment +\/\/.\+$+

func T2F()
    echom "  2个空格 变成tab"
    set noexpandtab tabstop=2
    " [range]retab 百分号% 表示全文
    %retab!
    call T2S()
endfunc

" nnoremap <F10> :call Indent_wf()<CR>
" inoremap <F10> <ESC>:call Indent_wf()<CR>i


" python文件中输入新行时#号注释不切回行首
" autocmd BufNewFile,BufRead *.py inoremap # X<c-h>#


" 保存python等文件时删除多余空格
func <SID>TrailingWhiteSpace()
        let l = line(".")
        let c = col(".")
        %s/\s\+$//e
        call cursor(l, c)
endfunc
autocmd FileType c,cpp,javascript,python,vim,sh,zsh autocmd BufWritePre <buffer> :call <SID>TrailingWhiteSpace()


" 让光标看着没动
nnoremap yf ggyG<C-O>  " 让光标看着没动
nnoremap df ggdG
" p后面一般没有参数，所以pf不好。选中全文，一般只是为了替换。所以vf选中后，多了p这一步
nnoremap vf ggVGp:echo"已粘贴之前复制的内容"<CR>

" comment at the end of line


" vscode里不行，别试了:
" inoremap yf <Esc>ggyG<C-O>

" Lazy loading, my preferred way, as you can have both [避免被PlugClean删除没启动的插件]
" https://github.com/junegunn/vim-plug/wiki/tips
" leo改过
func VimPlugConds(arg1, ...)

    " a: 表示argument
    " You must prefix a parameter name with "a:" (argument).
        " a:0  等于 len(a:000)),
        " a:1 first unnamed parameters, and so on.  `a:1` is the same as "a:000[0]".
    " A function cannot change a parameter

            " To avoid an error for an invalid index use the get() function
            " get(list, idx, default)
    let leo_opts = get(a:000, 0, {})  "  a:000 (list of all parameters), 获得该list的第一个元素
    " Borrowed from the C language is the conditional expression:
    " a ? b : c
    " If "a" evaluates to true, "b" is used
    let out = (a:arg1 ? leo_opts : extend(leo_opts, { 'on': [], 'for': [] }))  " 括号不能换行
    " an empty `on` or `for` option : plugin is registered but not loaded by default depending on the condition.
    return  out
endfunc



" =============================================vim-plug===============================begin
" 插件 (plugin) 在~/.local/share/nvim/plugged
call plug#begin(stdpath('data') . '/plugged')
    Plug 'junegunn/vim-plug' " 为了能用:help plug-options

    Plug 'voldikss/vim-translator'
        " todo mobaxterm 2080ti上不行

        " <Leader>t 翻译光标下的文本，在命令行回显
        nnoremap  <Leader>a <Plug>Translate
        vnoremap <silent> <Leader>a <Plug>TranslateV
        " h被占了
        " <Leader>h 翻译光标下的文本，在窗口中显示   h：here
        nnoremap <silent> <Leader>a <Plug>TranslateW
        vnoremap <silent> <Leader>a <Plug>TranslateWV
        " Leader h被 set hlsearch！占用了


    Plug 'sheerun/vim-polyglot'
    Plug 'jonathanfilip/vim-lucius'   " colorscheme lucius

    Plug 'andymass/vim-matchup'
    Plug 'junegunn/vim-easy-align'

    Plug 'neoclide/coc.nvim', VimPlugConds(!exists('g:vscode'), {'branch': 'release'})

    " 装了没啥变化，neovim本身就可以实现：多个窗口编辑同一个文件时，只要一个窗口保存了，
    " 跳到另一个窗口，会看到变化
        " Plug 'gioele/vim-autoswap'
        " set title
        " " the default titlestring will work just fine
        " set titlestring=
        " let g:autoswap_detect_tmux = 1



    " 要编译python+，难搞 放弃
    " 允许多人同时编辑一个文件。避免多处打开同一个文件
    " Plug 'FredKSchott/CoVim', VimPlugConds(!exists('g:vscode'))

    " ga :  记作 get alignment,  本来是get ascii
    " Start interactive EasyAlign in visual mode (e.g. vipga)
    xmap ga <Plug>(EasyAlign)

    " Start interactive EasyAlign for a motion/text object (e.g. gaip)
    nmap ga <Plug>(EasyAlign)
        " Start interactive EasyAlign for a motion/text object (e.g. gaip)
    nmap ga <Plug>(EasyAlign)
    " wf_align
        " \|是竖线的escape   dict里面不能放注释？ shell的换行也是，不像python
        " 空行分开的前面几个,是我自定义的
        " 小心对齐后 字符串里多出来的空格
        let g:easy_align_delimiters = {
            \                          'r': { 'pattern': "whatever_wf_want" },
            \
            \                          '?': { 'pattern': '?' },
            \                          ':': { 'pattern': ":" },
            \                          '\': { 'pattern': '\' },
            \
            \                          '>': { 'pattern': '>>\|=>\|>' },
            \                          '/': {
            \                                 'pattern'         : '//\+\|/\*\|\*/',
            \                                 'delimiter_align' : 'l',
            \                                 'ignore_groups'   : ['!Comment']
            \                               },
            \                          ']': {
            \                                 'pattern'       : '[[\]]',
            \                                 'left_margin'   : 0,
            \                                 'right_margin'  : 0,
            \                                 'stick_to_left' : 0
            \                               },
            \                          ')': {
            \                                 'pattern'       : '[()]',
            \                                 'left_margin'   : 0,
            \                                 'right_margin'  : 0,
            \                                 'stick_to_left' : 0
            \                            },
            \                          'd': {
            \                                 'pattern'      : ' \(\S\+\s*[;=]\)\@=',
            \                                 'left_margin'  : 0,
            \                                 'right_margin' : 0
            \                               }
            \                          }


    " [[==============================easymotion 配置=====================begin

    " Plug 'asvetliakov/vim-easymotion'   " vscode定制的easymotion
    " Plug 'easymotion/vim-easymotion'    " 只用裸nvim下的easymotion  千万别这么干。会把正在编辑的文件全搞乱

    Plug 'easymotion/vim-easymotion', VimPlugConds(!exists('g:vscode'))
    Plug 'asvetliakov/vim-easymotion', VimPlugConds(exists('g:vscode'), { 'as': 'leo-jump' })  " as的名字随便起，

    " 这样可能更容易理解，没那么绕: 【an empty `on` or `for` option : plugin is registered but not loaded by default depending on the condition.】
    " Plug 'easymotion/vim-easymotion',  has('g:vscode') ? { as': 'ori-easymotion', 'on': [] } : {}
    " Plug 'asvetliakov/vim-easymotion', has('g:vscode') ? {} : { 'on': [] }

    " map <Leader> <Plug>(easymotion-prefix)
    " 默认:
    map <Leader><Leader> <Plug>(easymotion-prefix)

    let g:EasyMotion_do_mapping = 0 " Disable default mappings
    let g:EasyMotion_smartcase = 1 " 敲小写，能匹配大写。反之不然

    " Line motions
    map <Leader>j <Plug>(easymotion-j)
    map <Leader>k <Plug>(easymotion-k)

    " todo  debug buggy 出了问题来这里
    "s for search
    " 用了vim-sandwich的默认keymapping，sa代表sandwich add.  sd 代表sandwich delete
    " 干脆用大写的S算了，避免冲突
    nmap S <Plug>(easymotion-f)
    " 用nnoremap不行


    " Need one more keystroke
    nmap f <Plug>(easymotion-f2)

    " 会抽风颤抖
    " nmap f <Plug>(easymotion-f) "f{char}
    " map  <Leader>f <Plug>(easymotion-bd-f) " <Leader>f{char} to move to {char}
    "" umap后，变回默然的功能
    " unmap f

    " 会显示高亮字母后，光标到下一行
    " nmap S <Plug>(easymotion-f2) " {char}{char} 怎样可以上下文都搜索？现在只能搜下文
    " map  <Leader>w <Plug>(easymotion-w) " Move to word    " buftype option is set??
    " ================================easymotion 配置=====================]]

    Plug 'kurkale6ka/vim-pairs'   " 和sandwich“互补”

    Plug 'machakann/vim-sandwich'
    " 别再试同类(前浪)
    "  Plug 'tpope/vim-surround'
    "  Plug 'kana/vim-textobj-user'
    "  Plug 'sgur/vim-textobj-parameter'



    Plug 'scrooloose/nerdcommenter'



    Plug  'Yggdroot/LeaderF'
    " >>>---------------------------------------------------------------------LeaderF
    " don't show the help in normal mode
    let g:Lf_HideHelp = 1
    let g:Lf_UseCache = 0
    let g:Lf_UseVersionControlTool = 0
    let g:Lf_IgnoreCurrentBufferName = 1


    " popup mode
    let g:Lf_WindowPosition = 'popup'
    let g:Lf_PreviewInPopup = 1
    let g:Lf_StlSeparator = { 'left': "\ue0b0", 'right': "\ue0b2", 'font': "DejaVu Sans Mono for Powerline" }
    let g:Lf_PreviewResult = {'Function': 0, 'BufTag': 0 }

    " let g:Lf_ShortcutF = "<leader>o"
    " 和zsh下按ctrl f 作用一致
    " let g:Lf_ShortcutF = "<c-f>"  " 要想快点弹出窗口，按下f后，马上输出字符
    nnoremap <c-f>          :<C-U><C-R>=printf("LeaderfFile  %s", "")<CR><CR>
    " mru: most recently used file
    " C-u: 删掉cmdline的字符。主要对visual mode有用？很多插件都这么设
        nnoremap <leader>fm :<C-U><C-R>=printf("Leaderf mru %s", "")<CR><CR>
    " search a line in current buffer.  " 有点vscode下的感觉
        nnoremap <leader>/ :<C-U><C-R>=printf("Leaderf line %s", "")<CR><CR>
    " <cword> is replaced with the word under the cursor (like |star|)
        " nnoremap <C-B> :<C-U><C-R>=printf("Leaderf! rg --current-buffer -e %s ", expand("<cword>"))<CR><CR>
        " 删掉了叹号
        "  LeaderfFunction! 叹号版本直接打开 normal 模式，并且定位到对应位置
        nnoremap <C-B> :<C-U><C-R>=printf("Leaderf rg --current-buffer -e %s ", expand("<cword>"))<CR><CR>
        " 不确定是否靠谱  " 代替在zsh中用rg
        nnoremap <leader>f :<C-U><C-R>=printf("Leaderf rg -g '!*.zsh_history' -g '!*.lesshst' -g '!/data1/weifeng_liu/.large_trash' ")<CR><CR>
        " 这个不起作用，不能ctrl+shift？
        " nnoremap <C-S-F> :<C-U><C-R>=printf("Leaderf! rg -e %s ", expand("<cword>"))<CR><CR>
        " nnoremap <C-S-F> :<C-U><C-R>=printf("Leaderf! rg -e ")<CR><CR>

    " search visually selected text literally
    " xnoremap gf :<C-U><C-R>=printf("Leaderf! rg -F -e %s ", leaderf#Rg#visual())<CR>
    " noremap go :<C-U>Leaderf! rg --recall<CR>

    " should use `Leaderf gtags --update` first
    let g:Lf_GtagsAutoGenerate = 0
    let g:Lf_Gtagslabel = 'native-pygments'
    " noremap <leader>fr :<C-U><C-R>=printf("Leaderf! gtags -r %s --auto-jump", expand("<cword>"))<CR><CR>
    " noremap <leader>fd :<C-U><C-R>=printf("Leaderf! gtags -d %s --auto-jump", expand("<cword>"))<CR><CR>
    " noremap <leader>fo :<C-U><C-R>=printf("Leaderf! gtags --recall %s", "")<CR><CR>
    " noremap <leader>fn :<C-U><C-R>=printf("Leaderf gtags --next %s", "")<CR><CR>
    " noremap <leader>fp :<C-U><C-R>=printf("Leaderf gtags --previous %s", "")<CR><CR>
    " ---------------------------------------------------------------------<<<LeaderF





    Plug 'sisrfeng/toggle-bool'

    " leaderf里有这个keybind，我这里覆盖掉
    noremap <leader>b :ToggleBool<CR>

    Plug 'mbbill/undotree'
call plug#end()


if has('persistent_undo')
    let target_path = expand('~/.undodir')
    " let target_path = expand('~/.undo_dir_nvim_wf')
    if !isdirectory(target_path)
        call mkdir(target_path, "p", 0700) " create the directory and any parent directories
    endif

    let &undodir=target_path
    set undofile
endif
nnoremap <F4> :UndotreeToggle<CR>
let g:undotree_SetFocusWhenToggle = 1



" 同类:
"  Plug 'tpope/vim-repeat'
"  Plug 'chaoren/vim-wordmotion'
"  Plug 'kkoomen/vim-doge'
"  Plug 'mattn/emmet-vim'
" Plug 'junegunn/vim-easy-align'

" Any valid git URL is allowed
" Plug 'https://github.com/junegunn/vim-github-dashboard.git'

" Plug 'SirVer/ultisnips'
" Plug 'honza/vim-snippets'

" On-demand loading
" Plug 'tpope/vim-fireplace', { 'for': 'clojure' }

" todo
" https://github.com/pechorin/any-jump.vim



if has('win32')
    " echo 'leo: 正在用win32，win32表示 32 or 64 bit的windows'
    let g:python3_host_prog = "F:\\python39\\python.exe"  " ToggleBool会用到
    " let g:python_host_prog = ""  " ToggleBool会用到   我fork了这个插件 并改了?
    " let g:loaded_python_provider = 0
endif




" [[----------------------------nerdcommenter-config-------------------------------begin
" g代表Global Variable
let g:NERDCreateDefaultMappings = 0    " 别用默认的键位

let g:NERDSpaceDelims = 1 " Add spaces after comment delimiters
let g:NERDCompactSexyComs = 1 " Use compact syntax for  multi-line comments
" Align line-wise comment delimiters flush left instead of following code indentation
let g:NERDDefaultAlign = 'left'

" Add your own custom formats or override the defaults
let g:NERDCustomDelimiters = { 'c': { 'left': '/*','right': '*/' } }
let g:NERDCommentEmptyLines = 1  " Allow commenting and inverting empty lines (useful when commenting a region)
let g:NERDTrimTrailingWhitespace = 1 " Enable trimming of trailing whitespace when uncommenting
let g:NERDToggleCheckAllLines = 1 " check all selected lines is commented or not

" 对vscode无效,不知道为啥
" <C-/> 在vim中由C-_表示 zsh下敲cat后，ctrl / 显示  ^_
nnoremap <C-_> :call nerdcommenter#Comment('n', 'toggle')<CR>j
inoremap <C-_> <ESC>:call nerdcommenter#Comment('n', 'toggle')<CR>j
vnoremap <C-_> :call nerdcommenter#Comment('n', 'toggle')<CR>


" 不行
" func! InlineCommentWf()
"     execute "normal A"
"     execute "normal o/"
"     call nerdcommenter#Comment("n", "Comment")
"     execute "normal kJA"
" endfunc





nnoremap <M-/> yy:call nerdcommenter#Comment('n', 'toggle')<CR>p

" 好慢：
" nnoremap = :<plug>nerdcommentertoggle<cr>j
" nnoremap - :k<plug>nerdcommentertoggle<cr>
" 这行不行:
" nnoremap = :call <Plug>NERDCommenterInvert<CR>


"let g:NERDDefaultNesting = 1
" ---------------------------nerdcommenter-config----------------------------------end]]


" todo: vscode中会复制到 前后空格  " a变成i估计就行了
nnoremap vp viwp
" 类似于Y D C等，到行末
nnoremap P v$<left>p


" todo: `omap`代替下面的有点重复的各种operator的map
" omap ' i'
" omap " vi"
" omap ( i(
" omap ) i)
" omap [ i[
" omap ] i]
" omap { i{
" omap } i}
" omap } i}
" omap ' i'



nnoremap v" vi"
nnoremap v( vi(
nnoremap v) vi)
nnoremap v[ vi[
nnoremap v] vi]
nnoremap v{ vi{
nnoremap v} vi}
nnoremap v} vi}


nnoremap yp yyp
nnoremap yw yiw
nnoremap y' yi'
nnoremap y" yi"
nnoremap y( yi(
nnoremap y) yi)
nnoremap y[ yi[
nnoremap y] yi]
nnoremap y{ yi{
nnoremap y} yi}


nnoremap cw ciw



func! DoubleAsSingle()
    " When [!] is added, error messages will also be skipped,
    " and commands and mappings will not be aborted
    " when an error is detected.  |v:errmsg| is still set.
    let v:errmsg = ""
    silent! :s#\"\([^"]*\)\"#'\1'#g
    if (v:errmsg == "")
        echo "双变单"
    endif
endfunc

nnoremap c' :call DoubleAsSingle()<CR>ci'
nnoremap v' :call DoubleAsSingle()<CR>vi'
nnoremap y' :call DoubleAsSingle()<CR>yi'
nnoremap d' :call DoubleAsSingle()<CR>da'
" nnoremap c' :s#\"\([^"]*\)\"#'\1'#g<CR>ci'
" nnoremap d' :s#\"\([^"]*\)\"#'\1'#g<CR>da'
" nnoremap v' :s#\"\([^"]*\)\"#'\1'#g<CR>vi'
" nnoremap y' :s#\"\([^"]*\)\"#'\1'#g<CR>ya'



nnoremap c" ci"
nnoremap c( ci(
nnoremap c) ci)
nnoremap c[ ci[
nnoremap c] ci]
nnoremap c{ ci{
nnoremap c} ci}

nnoremap dw diw
nnoremap d" da"
nnoremap d( da(
nnoremap d) da)
nnoremap d[ da[
nnoremap d] da]
nnoremap d{ da{
nnoremap d} da}



" 百分号 能自动跳到配对的符号
" onoremap b %ib  这样map后 yb有时会进入insert mode
nnoremap cb %cib
nnoremap vb %vib
nnoremap yb %yib
nnoremap db %dab


" nnoremap cb O'''<Esc>Go'''<Esc>
" inoremap cb '''<Esc>Go'''<Esc><C-o>i

"====https://github.com/ahonn/dotfiles/tree/master/vim/vscode================start
nnoremap < <<
nnoremap > >>
vnoremap < <gv


noremap K r<CR><UP>
nnoremap J Ji <Esc>

set pastetoggle=<F9>

"有空再搞

"nnoremap <silent> <C-j> :<C-u>call VSCodeNotify('workbench.action.focusBelowGroup')<CR>
"nnoremap <silent> <C-k> :<C-u>call VSCodeNotify('workbench.action.focusAboveGroup')<CR>
"nnoremap <silent> <C-h> :<C-u>call VSCodeNotify('workbench.action.focusLeftGroup')<CR>
"nnoremap <silent> <C-l> :<C-u>call VSCodeNotify('workbench.action.focusRightGroup')<CR>

"nnoremap <silent> <C-b> :<C-u>call VSCodeNotify('workbench.action.toggleSidebarVisibility')

"nnoremap <silent> <C-w>H :<C-u>call VSCodeNotify('workbench.action.moveEditorToLeftGroup');<CR>
"nnoremap <silent> <C-w>L :<C-u>call VSCodeNotify('workbench.action.moveEditorToRightGroup');<CR>

"nnoremap <silent> <Leader>f :<C-u>call VSCodeNotify('editor.action.formatDocument')<CR>
"


"nnoremap <silent> <Leader>pi :PlugInstall<Cr>
"nnoremap <silent> <Leader>pc :PlugClean<Cr>
"nnoremap <silent> <Leader>pu :PlugUpdate<Cr>




"" vim-textobj-parameter
"let g:vim_textobj_parameter_mapping = 'a'

"" vim-doge
"let g:doge_mapping = '<Leader>dc'


"====https://github.com/ahonn/dotfiles/tree/master/vim/vscode================end



" nnoremap  J j
" c b means: comment block


" pressing  Ctrl[   will usually get you the equivalent of pressing Esc.
" *i_CTRL-V*
" CTRL-V    Insert next non-digit `literally`.  For special keys, the
"         terminal code is inserted.
"         The characters typed right after CTRL-V are not considered for
"         mapping.
"
" *i_CTRL-Q*
" CTRL-Q        Same as CTRL-V.



" 这两个都不行， airblade/vim-rooter也不行了
" set autochdir
" autocmd BufEnter * silent! lcd %:p:h

" Note: When this option is on some plugins may not work.
" 在vscode里会报错, 放到no_vscode.vim
    " autocmd VimEnter * set autochdir
" vscode里, 可以手动敲 :lcd


noremap <Leader>y "*y
noremap <Leader>Y "+y
" noremap <Leader>p "*p
" noremap <Leader>P "+p

" 有个自动补全插件 导致(变成  选中候选，只能这样map
inoremap ( (

set completeopt=noinsert,menuone


func Wfprint_n()
    if &filetype == 'python'
        " todo 加叹号
        " normal! 表示不允许mapping
        " execute "normal yiwoprint(f'{= }')"
        execute "normal yiwoprint(f'{= }')"
        execute "normal hhhhhp"
    elseif &filetype == 'cpp'
        " execute 'normal yiwocout<<""<<' | execute 'normal hhhpf<lpa<<endl;'
        execute 'normal yiwocout<<""<<'
        execute 'normal hhhpf<lpa<<endl;'
    elseif &filetype == 'zsh'
        execute 'normal yiwoecho ${}'
        execute "normal hp"
    elseif &filetype == 'vim'
        execute 'normal yiwoecho &'
        execute "normal p"
    endif
endfunc

func Wfprint_v()
    if &filetype == 'python'
        " todo
        " visual 是退出ex mode，进入normal mode, 不是在visual mode 执行
        " execute "visual y"
        " y
        execute "normal oprint(f'{= }')"
        execute "normal 4h"
    endif
endfunc

nnoremap _p :call Wfprint_n()<CR>
vnoremap _p :call Wfprint_v()<CR>




" <bar> : 表示 '|' ,  to separate commands, cannot use it directly in a mapping, since it would be seen as marking the end of the mapping.
" 百分号代表当前文件
" bash 的  &&  是前面的命令成功了，继续执行后面的
" autocmd filetype cpp nnoremap <C-c> :w <bar> !clear && g++ -std=gnu++14 -O2 % -o %:p:h/%:t:r.exe && ./%:r.exe<CR>

set autowrite

" mswin.vim会导致visual mode 光标所在字符不被选中
" ~/dotF/mswin.vim里有用的内容都在这里
" [[---------------------------------------msvim-------------------------------


" saving,
noremap <C-S>       :update<CR>
inoremap <C-S>      <C-O>:update<CR>
" *v_CTRL-C*  v表示 Visual mode; Stop Visual mode
vnoremap <C-S>      <C-C>:update<CR>

" For CTRL-V to work autoselect must be off.
" On Unix we have two selections, autoselect can be used.
" if !has("unix")
"   set guioptions-=a
" endif


" nnoremap <C-Z> u|  " CTRL-Z is Undo
" 竖线前的空格，视为map后的一部分。上行等价于：
nnoremap <C-Z> u
" CTRL-Z is Undo

inoremap <C-Z> <C-O>u

" inoremap <C-R> <C-O>u
"<C-R>:    Insert the contents of a register

" CTRL-Y is Redo (although not repeat)
nnoremap <C-Y> <C-R>
" inoremap <C-Y> <C-O><C-R>
inoremap <C-Y> <Esc><C-R>a



" ---------------------------------------msvim-------------------------------]]

" 要删完行末，敲D, dL用于删剩最后一个，比如引号 括号
nnoremap dL v$hhd

noremap <F5> <ESC>oimport pudb<ESC>opu.db
inoremap <F5> <ESC>oimport pudb<ESC>opu.db

" 定义函数AutoHead，自动插入文件头
func AutoHead()
    if &filetype == 'sh'
        call setline(1, "\#!/bin/zsh")
    elseif &filetype == 'python'
        " google Python风格规范: 不要在行尾加分号, 也不要用分号将两条命令放在同一行。
        " 但不会报错

        " call append(2, 'from dotF.wf_snippet import *')
        " call append(2, 'sys.path.append(wf_home)')
        " call append(2, 'wf_home = os.path.expanduser("~/")')
        call setline(1, 'import cv2 as cv,cv2')

        call append(1, '#-----------------------自动import结束------------------------#')
        call append(1, 'import sys os json')
        call append(1, 'import numpy as np')

        " call append(2, '    ')
        " call append(2, '    print(round(wf_str,2))')
        " call append(2, '    if type(wf_variable) ==r ')
        " call append(2, 'def xprint(wf_variable):')
        " 括号内部不能换行
    endif

    normal G
    normal o
    normal o
endfunc

autocmd BufNewFile *.sh,*.py execute ":call AutoHead()"







" if 1
    " echo ' wf初始化的文件: ~/dotF/vimrc'
" endif
" nvim中不了<HOME> <END>    $行末 ^行首 结合autohotkey


" <Plug>NERDCommenterToggle<CR>和 :call NERDComment('n', 'toggle')<CR> 应该一样
" nnoremap = :call nerdcommenter#Comment('n', 'toggle')<CR>j
" vim的等号：用来indent
" ==     4= 等
nnoremap - :call nerdcommenter#Comment('n', 'toggle')<CR>k

" 这行 不行:
" nnoremap = :call <Plug>NERDCommenterInvert<CR>



nnoremap <Leader>r :call WfRun()<CR>

func! WfRun()
    execute "w"
    echo "wf_已保存"
    if &filetype == 'python'
        "跑votenet的某个文件时,若这样执行,pc_util.write_ply没被调用; 若正常敲python执行,则正常
        "% 代表当前文件
        execute "! python %"
    elseif &filetype == 'sh'
        execute "! zsh %"
    elseif &filetype == 'cpp'
        execute " ! rm -f /d/script.wf_cpp; g++ -std=c++11 % -Wall -g -o /d/script.wf_cpp `pkg-config --cflags --libs opencv` ; /d/script.wf_cpp "
    endif
endfunc




" CapsLock 识别不了
" map <CapsLock>[ #
" map <CapsLock>] *

let g:ackprg = 'ag --vimgrep'



if exists('$TMUX')
    autocmd BufReadPost,FileReadPost,BufNewFile * call system("tmux rename-window " . expand("%"))
    autocmd VimLeave * call system("tmux rename-window zsh")
    " autocmd BufEnter,FocusGained * call system("tmux rename-window " . expand("%:t"))
    " autocmd BufEnter * let &titlestring = ' ' . expand("%:t")
    set title
endif


set title
set mouse=a
" syntax on  " 别用，会覆盖DIY的配置

set nocompatible  " 别兼容老的vi
set backspace=indent,eol,start
" indent  allow backspacing over autoindent
" eol     allow backspacing over line breaks (join lines)
" start   allow backspacing over the start of insert; CTRL-W and CTRL-U stop once at the start of insert.

" >>>`1.` 基础设置---------------------------------------------------------------------
" history存储容量
set history=2000

" 文件修改之后自动载入
set autoread

" shortmess: short messages, 简略提示
set shortmess=I  " I:启动的时候不显示多余提示
set shortmess+=t  " t: trunc if too long
set shortmess+=F  " F don't give the file info when editing a file, like :silent

set shortmess=filnxtToOF

" To reduce the number of hit-enter prompts:
" - Set 'cmdheight' to 2 or higher.
set cmdheight=2

let s:noSwapSuck_file = fnamemodify($MYVIMRC, ":p:h")  . "/noswapsuck.vim"    " 字符串concat，用点号
            " fnamemodify比expand的功能更强
            " :echo @%                |" directory/name of file
            " :echo expand('%:p')     |" full path
            " :echo expand('%:p:h')   |" directory containing file ('head')
            " :echo expand('%:t')     |" name of file ('tail')
exe 'source ' . s:noSwapSuck_file
         " 这样不行： source  . s:noSwapSuck_file
" 取代了这些：
    " set nobackup  取消备份。 视情况自己改
    " set noswapfile  关闭交换文件




" 突出显示当前行
set cursorline


" 启用鼠标
set mouse=a
set mousehide  " Hide the mouse cursor while typing

set title  " change the terminal's title

" Remember info about open buffers on close
set viminfo^=%


"==========================================
" Display Settings 展示/排版等界面格式设置
"==========================================

set ruler  " 显示当前的行号列号
set showmatch  " 括号配对情况, 跳转并高亮一下匹配的括号
set matchtime=5  " How many tenths of a second to blink when matching brackets


" set cmdheight=2

" 代码折叠
" set foldmethod=indent  " 初步尝试, 缩进最好
" set foldmethod
" 初步尝试, 缩进最好
" set foldlevel=99


" 自动判断编码时，依次尝试以下编码：
set fileencodings=utf-8,gb2312,gb18030,gbk,ucs-bom,cp936,latin1,big5,eu
set fencs=utf8,gbk,gb2312,gb18030

nnoremap <C-a> ^
inoremap <C-a> <ESC>I

nnoremap <C-e> $
inoremap <C-e> <ESC>A



" http://stackoverflow.com/questions/2005214/switching-to-a-particular-tab-in-vim


" normal模式下切换到确切的tab
noremap <leader>1 1gt
noremap <leader>2 2gt
noremap <leader>3 3gt
noremap <leader>4 4gt

" Toggles between the active and last active tab "
" The first tab is always 1 "
let g:last_active_tab = 1
nnoremap <silent> <leader>tt :execute 'tabnext ' . g:last_active_tab<cr>
autocmd TabLeave * let g:last_active_tab = tabpagenr()  " tabpagenr(): 换取当前tab的序号
" autocmd [group] {event} {pat} {cmd}



"缩进后自动选中，方便再次操作
vnoremap < <gv
vnoremap > >gv

map Y y$

" 复制选中区到系统剪切板中
vnoremap <leader>y "+y


" 选中并高亮最后一次插入的内容
nnoremap gv `[v`]




" Jump to start and end of line using the home row keys
" 增强tab操作, 导致这个会有问题, 考虑换键
"nmap t o<ESC>k
"nmap T O<ESC>j



" 交换 ' `, 使得可以快速使用'跳到marked位置
nnoremap ' `
nnoremap ` '

" remap U to <C-r> for easier redo
nnoremap U <C-r>




" 放前面会被某些内容覆盖掉
nnoremap <C-E> $








let g:sandwich#recipes = deepcopy(g:sandwich#default_recipes)
" 在vscode里 只有sa生效，其他不行，不知道为啥

" easy-motion的nmap用的是S
" let g:operator_sandwich_no_default_key_mappings = 1


" NOTE: To prevent unintended operation
" nmap s <Nop>
" xmap s <Nop>
" xmap creates a mapping for just Visual mode
" vmap creates one for both Visual mode and Select mode. select mode很少用
" <NOP>     no-opperation? do nothing (useful in mappings)

" DEBUG: easymotion发疯来这里
nnoremap s :echo '待用'

" 之前不知道为什么不生效： 现在 没加这几行,也能用,应该是默认的
xnoremap sa <Plug>(operator-sandwich-add)
" xnoremap sd <Plug>(operator-sandwich-delete)
" xnoremap sr <Plug>(operator-sandwich-replace)
"
" sc:  sandwich surround Code
" nnoremap <Leader>pb <Plug>(operator-sandwich-add-query1st)
" nnoremap sa <Plug>(operator-sandwich-add-query1st)
"
" 加了没反应
nnoremap sc <Plug>(operator-sandwich-add)

" longer updatetime (default is 4000 ms = ) leads to  delays and poor user experience.
set updatetime=300




" 用法:  put =Vim_out('你的命令')
funct Vim_out(my_cmd)
" https://unix.stackexchange.com/a/8296/457327
    redir =>my_output
    " a 表示argument
    silent execute a:my_cmd
    redir END
    return my_output
endfunc
" 用法:  put =Vim_out('你的命令')

" <C-:> 不行，cat后`ctrl :`   显示的是<C-[>，和真的<C-[> 已经esc同体？
" unmap <C-[>
nnoremap  <c-'>     :tabedit ~/.t/wf_out.vim<CR>:put = Vim_out('')<left><left>
nnoremap  <Leader>: :tabedit ~/.t/wf_out.vim<CR>:put = Vim_out('')<left><left>

nnoremap ko O

" 垃圾别用
" >_>_>===================================================================begin
" 没啥用，文字容易跑走
" 在上下移动光标时，光标的上方或下方至少会保留显示的行数
" set scrolloff=7
" end=====================================================================<_<_<
"
"
func _put_your_comment_here()


    echo fnamemodify(expand('<sfile>:p'), ':h').'/main.vim'
    得到 ~/.Spacevim/main.vim
    https://stackoverflow.com/questions/4976776/how-to-get-path-to-the-current-vimscript-being-executed/18734557

    " 没啥用吧
    " >_>_>===================================================================begin

    auto jump to end of select
    这是在vscode里 会到下一行？
    vnoremap <silent> y y`]
    vnoremap <silent> p p`]
    nnoremap <silent> p p`]

    select block
    nnoremap <leader>v V`}

    " end=====================================================================<_<_<


endfunc


"

" 滚动scrolling of the viewport
" c-d本来是翻页，光标会动
nnoremap <C-d> 8<C-e>
nnoremap <C-u> 8<C-y>

" autocmd BufRead *  execute ":call Conceal_strang_chr()"
" 需要时手动执行吧
func Conceal_strang_chr()
    " syn match name_you_like  /[^[:print:]]/ conceal cchar=  " 空格会被自动删掉
    syn match name_you_like  /[^[:print:]]/ conceal cchar=%
    set conceallevel=2
    set concealcursor=vc
endfunc


" set isprint+=9  " 9代表tab，设了回导致排版错乱
set isprint=@,161-255  " 默认值
" set isprint=1-255  " 设了屏幕会很乱  " Stack Overflow有个傻逼回答，别信

" autocmd BufRead *.txt  execute ":call Conceal_strang_chr_3()"
func Conceal_strang_chr_3()
    " set isprint=1-255  " 设了屏幕会很乱
    set isprint+=9  " 设了屏幕会很乱
    " syn match name_you_like  /[^[:print:]]/ conceal cchar=%
    " set conceallevel=3
    " set concealcursor=vcni
endfunc


if !has('win32')
    " 这行要调用lucius， 要在它后面：call plug#end()
    source ~/dotF/cfg/nvim/beautify_wf.vim
    " 这么写比较啰嗦：
    " let s:beauty_path = fnamemodify($MYVIMRC, ":p:h") . "/beautify_wf.vim"    " 字符串concat，用点号
    " exe 'source ' . s:beauty_path      " 这样不行： source  . s:beauty_path
endif



" todo
" Each status line item is of the form: ( All fields except the {item} are optional.)
"       %-0{minwid}.{maxwid}{item}
" 在上面的基础上：  (几表示某个highlight设置)
" %Highlight配色号码

"    %=   右对齐
"    %r  readonly, 显示 [RO]
set statusline=
set statusline=%7*=%r
set statusline=%=%t                            " tittle
set statusline+=%=\ buffer号:%n\            "buffer number
set statusline+=%=%m                         "modified flag
" set statusline+=%=文件格式:%{&ff}            "是否unix
" flag[Preview] ??
set statusline+=%=\ %h
set statusline+=%=\ %w
set statusline+=%=\ %k
set statusline+=%=\ %q
set statusline+=%999X
" set statusline+=
set statusline+=%=第%l行/
set statusline+=%L行               "total lines
set statusline+=(%p%%)
set statusline+=%=第%v列         "virtual column number (screen column)
" set statusline+=\ %c           " Column number (byte index).



set statusline=
set statusline+=%0*\ %<%F\                                "File+path
set statusline+=%0*\ \ %m%r%w\                       "Modified? Readonly? Top/bot.
" buffer号码
set statusline+=%2*\[buffer:%n]                                  "buffernr
" set statusline+=%2*\ %y\                                  "FileType
" set statusline+=%3*\ %{''.(&fenc!=''?&fenc:&enc).''}      "Encoding
" set statusline+=%3*\ %{(&bomb?\",BOM\":\"\")}\            "Encoding2
" set statusline+=%4*\ %{&ff}\                              "FileFormat (dos/unix..)
" set statusline+=%5*\ %{&spelllang}\                         "Spellanguage
set statusline+=%8*\ %=\ 行:%l/%L\ (%3p%%)\             "Rownumber/total (%)
set statusline+=%9*\ 列:%3c\                            "Colnr
" set statusline+=%0*\ \ %m%r%w\ %P\ \                      "Modified? Readonly? Top/bot.

" set laststatus=1  " only if there are at least two windows
" 没有statusline时，命令那行和代码容易混在一起
set laststatus=2  "  always show statusline

" put the  block above in your vimrc file and
" the following lines in your current colorscheme file.
" hi User1 guifg=#ffdad8  guibg=#880c0e
"

map <leader>h :tabprev<cr>
map <leader>l :tabnext<cr>
" 或者叫tabline? tab statusline tab栏 tab status
" 改了不生效：
set guitablabel=\[%N\]\ %t\ %M
" set guitablabel=%t


" function GuiTabLabel()
"     let label = ''
"     let bufnrlist = tabpagebuflist(v:lnum)
"
"     " Add '+' if one of the buffers in the tab page is modified
"     for bufnr in bufnrlist
"     if getbufvar(bufnr, "&modified")
"         let label = '+'
"         break
"     endif
"     endfor
"
"     " Append the number of windows in the tab page if more than one
"     let wincount = tabpagewinnr(v:lnum, '$')
"     if wincount > 1
"     let label .= wincount
"     endif
"     if label != ''
"     let label .= ' '
"     endif
"
"     " Append the buffer name
"     return label . bufname(bufnrlist[tabpagewinnr(v:lnum) - 1])
" endfunction
"
" set guitablabel=%{GuiTabLabel()}
"


if exists('g:vscode')
    " cnoremap s/ s/\v
    " vscode里，用了camp时，必须在光标后有字符才能正常map
    " echom '准备进入has_vscode.vim: 路径'
    echom $has_vscode
    source $has_vscode
    echom 'wsl下pwd有问题, 等邮件通知更新'
    " https://github.com/asvetliakov/vscode-neovim/issues/520
else
    source $no_vscode
endif

