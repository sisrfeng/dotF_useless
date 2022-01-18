" some map
" >_>_>===================================================================begin
"set wrap 后，同物理行上线直接跳。
"  they are not recursively mapped themselves (I don't know why this matters) but
"  you can still recursively map to them.
map j gj
map k gk

" 还是跳到物理行的 空白开头 ? 现在是跳到非空白开头了，是vscode的设置起效了？
map H g0
" nmap H g$<ESC>wk
map 0 g0
map L g$

omap <silent> j gj
omap <silent> k gk
" 不好：
    " nmap dd g^dg$i<BS><Esc>
    " nmap yy g^yg$
    " nmap cc g^cg$
" 不行：
    " nmap A g$a
    " nmap I g^i

" nmap gm g$
" nnoremap M

nnoremap ss <Cmd>call VSCodeNotify('workbench.action.closeActiveEditor')<CR>
vnoremap ss <Cmd>call VSCodeNotify('workbench.action.closeActiveEditor')<CR>
nnoremap qq <Cmd>call VSCodeNotify('workbench.action.revertAndCloseActiveEditor')<CR>
" noremap qq :q!<CR>  vscode里，这样搞只退出插件，文件还打开着
"end=====================================================================<_<_<
"
"


" 不行：
" nnoremap gk :<C-u>call VSCodeCall('cursorMove', { 'to': 'up', 'by': 'wrappedLine', 'value': v:count ? v:count : 1 })<CR>
" nnoremap gj :<C-u>call VSCodeCall('cursorMove', { 'to': 'down', 'by': 'wrappedLine', 'value': v:count ? v:count : 1 })<CR>
" todo
" insert mode下，neovim不管事，（但esc退回normal还是可以的），imap都用不了
" nnoremap gd vaw<F12>
" 不行
" nnoremap zz ZZ
" filetype on        " 检测文件类型  不会和vscode 打架吧




nnoremap ce A<space><space><Esc>o/<Esc><Esc>:::::call nerdcommenter#Comment("n", "Comment")<space><CR>kJA<BS>
" 有时会弄脏代码，可能是vscode-nvim弹出窗口太慢了？它不能接管inputmode？  " 提issue吧
    " vscode里，<C-_>注释，用的是vscode的"editor.action.comment"之类的,不是vim的命令,这样不行：
    " nnoremap ce A<space><space><Esc>o/<Esc><Esc><Esc><Esc><Esc><Esc><C-_>kJA<BS>


    " vscode-neovim的 VSCodeCommentary is just a simple function which calls editor.action.commentLine.
    " xmap <C-_>  <Plug>VSCodeCommentary
    " nmap <C-_>  <Plug>VSCodeCommentary
    " omap <C-_>  <Plug>VSCodeCommentary
    " nmap <C-_>  <Plug>VSCodeCommentaryLine

echom '到了in_vscode.vim的最后'
