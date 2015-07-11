" VIM Environment Setup
let $VIM="$HOME/.vim"
set nu
set ts=4
set expandtab
set shiftwidth=4
set softtabstop=4
set ignorecase

" For vundle
set nobackup
set nocompatible
filetype off
set rtp+=~/.vim/bundle/vundle/
call vundle#rc()
Bundle 'gmarik/vundle'
" vim-scripts repos
Bundle 'bash-support.vim'
Bundle 'suan/vim-instant-markdown'
Bundle 'plasticboy/vim-markdown'
Bundle 'vimwiki/vimwiki'
Bundle 'scrooloose/nerdtree'
Bundle 'myhere/vim-nodejs-complete'
Bundle 'walm/jshint.vim'
Bundle 'pangloss/vim-javascript'
Bundle 'guileen/vim-node'
Bundle 'mattn/emmet-vim'
filetype plugin indent on 

" Using Pandoc to generate html
function! s:PreviewMarkdown()
    if !executable('pandoc')
        echohl ErrorMsg | echo 'Please install pandoc first.' | echohl None
        return
    endif
    if s:isWin
        let BROWSER_COMMAND = 'cmd.exe /c start ""'
    elseif s:isLinux
        let BROWSER_COMMAND = 'xdg-open'
    elseif s:isMac
        let BROWSER_COMMAND = 'open'
    endif
    let output_file = tempname() . '.html'
    let input_file = tempname() . '.md'
    let css_file = 'file://' . expand($HOME . '/.vimdb/pandoc/github.css', 1)
    " Convert buffer to UTF-8 before running pandoc
    let original_encoding = &fileencoding
    let original_bomb = &bomb
    silent! execute 'set fileencoding=utf-8 nobomb'
    " Generate html file for preview
    let content = getline(1, '$')
    let newContent = []
    for line in content
        let str = matchstr(line, '\(!\[.*\](\)\@<=.\+\.\%(png\|jpe\=g\|gif\)')
        if str != "" && match(str, '^https\=:\/\/') == -1
            let newLine = substitute(line, '\(!\[.*\]\)(' . str . ')',
                        \'\1(file://' . escape(expand("%:p:h", 1), '\') . 
                        \(s:isWin ? '\\\\' : '/') . 
                        \escape(expand(str, 1), '\') . ')', 'g')
        else
            let newLine = line
        endif
        call add(newContent, newLine)
    endfor
    call writefile(newContent, input_file)
    silent! execute '!pandoc -f markdown -t html5 -s -S -c "' . css_file . '" -o "' . output_file .'" "' . input_file . '"'
    call delete(input_file)
    " Change encoding back
    silent! execute 'set fileencoding=' . original_encoding . ' ' . original_bomb
    " Preview 
    silent! execute '!' . BROWSER_COMMAND . ' "' . output_file . '"'
    execute input('Press ENTER to continue...')
    echo
    call delete(output_file)
endfunction

nnoremap <silent> <LocalLeader>p :call <SID>PreviewMarkdown()<CR>

" Using english dictionary
set dictionary+=$VIM/dict/english.dict


" Complete
":inoremap [ []<Esc>i
":inoremap ( ()<Esc>i
:inoremap { {}<Esc>i
":inoremap < <><Esc>i
":inoremap ' ''<Esc>i
"":inoremap " ""<Esc>i

" NerdTree
:nmap <Leader>d :NERDTreeToggle<CR>

" Insert date
:nnoremap <Leader>t "=strftime("%F")<CR>gP

" Enable realtime preview for *.md file
autocmd BufNewFile,BufReadPost *.md set filetype=markdown

" disable vim-markdown folding
let g:vim_markdown_folding_disabled=1

" Using chrome to browse file
function ViewInBrowser(name)
	let file = expand("%:p")
	let l:browser = {
		\"cr":"google-chrome",
	\}
	let htdocs = '/home/bertrand/'
	let strpos = stridx(file, substitute(htdocs, '\\\\', '\' "g"))
	let file = '"' .file.'"'
	exec ":update " . file
	if strpos == -1
		exec ":silent ! " . l:browser[a:name] . " file://" .file
	else 
		let file = substitute(file, htdocs, "http://127.0.0.1:8090", "g")
		let file = substitute(file, '\\', '/', "g")
		exec ":silent ! " .l:browser[a:name] file
	endif
endfunction
nmap <Leader>cr :call ViewInBrowser("cr")<cr>
