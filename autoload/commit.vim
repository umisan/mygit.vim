" commitに含むファイルを簡単に選択できるプラグイン
"
" バッファー名
let s:status_buffer = 'STATUS'

" commitに含めるかどうかの選択状況
let s:select_status = {}

let s:highlight = 'CommitSelected'
highlight MakerSelected ctermbg=green ctermfg=black

function! s:echo_err(msg) abort
  echohl ErrorMsg
  echomsg 'commit-maker.vim:' a:msg
  echohl None
endfunction

function! s:get_status() abort
	return system('git status --short')
endfunction

function! s:init_select_status(modified_list) abort
  let s:select_status = {}
  for object in a:modified_list
    let s:select_status[s:extract_entry(object)] = {'selected': 0}
  endfor
endfunction

function! s:extract_entry(line) abort
  return split(a:line)[1]
endfunction

function! s:toggle_current_line() abort
  let l:current_line = getline('.')
  let l:entry = s:extract_entry(l:current_line)
  if s:select_status[l:entry]['selected'] == 0
    let s:select_status[l:entry]['selected'] = 1
    let s:select_status[l:entry]['id'] =  matchadd(s:highlight, '\%' . line('.') . 'l')
  else
    let s:select_status[l:entry]['selected'] = 0
    call matchdelete(s:select_status[l:entry]['id'])
  endif
endfunction

function! commit#init() abort
  if exists('g:maker#highlight')
    let s:highlight = g:maker#highlight
  endif
  execute 'new' s:status_buffer
  setlocal buftype=nofile
  setlocal bufhidden=wipe 
  let l:modified_list = split(s:get_status(), '\n')
  call s:init_select_status(modified_list)
  call setline(1, l:modified_list)
  " mappingの設定
  nnoremap <silent> <buffer>
    \ <Plug>(toggle_current_line)
    \ :call <SID>toggle_current_line()<CR>
  nmap <buffer> <CR> <Plug>(toggle_current_line)
endfunction

function! commit#commit(msg) abort
  for entry in keys(s:select_status)  
    if s:select_status[entry]['selected']
      call system('git add ' . entry)
    endif
  endfor
  let l:result = system('git commit -m ' . '"' . a:msg . '"')
  if v:shell_error != 0
    call s:echo_err('commit failed ' . l:result)
    return 0
  endif
  echo 'commit succeeded!'
  execute 'bd'
endfunction
