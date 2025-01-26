if exists('g:loaded_maker')
  finish
endif
let g:loaded_maker = 1

command! MyGitStatus call commit#init()

command! -nargs=1 MyGitCommit call commit#commit(<q-args>)
