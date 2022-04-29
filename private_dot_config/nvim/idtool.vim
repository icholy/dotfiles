" idtool

function FetchID(stage) abort
  let id = expand("<cword>")
  new
  let x = system("idtool -e " . a:stage . " " . id)
  put=x
  setf json
endfunction

function ShowID() abort
  let id = expand("<cword>")
  new
  let x = system("idtool -i " . id)
  put=x
  setf text
endfunction

map <Leader>id :call FetchID("dev")<CR>
map <Leader>is :call FetchID("staging")<CR>
map <Leader>ip :call FetchID("v1")<CR>
map <Leader>ii :call ShowID()<CR>

