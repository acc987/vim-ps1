" Vim filetype plugin file
" Language:           Windows PowerShell
" Maintainer:         Peter Provost <peter@provost.org>
" Version:            2.10
" Project Repository: https://github.com/PProvost/vim-ps1
" Vim Script Page:    http://www.vim.org/scripts/script.php?script_id=1327

" Only do this when not done yet for this buffer
if exists("b:did_ftplugin") | finish | endif

" Don't load another plug-in for this buffer
let b:did_ftplugin = 1

setlocal tw=0
setlocal commentstring=#%s
setlocal formatoptions+=tcqroj
" Enable autocompletion of hyphenated PowerShell commands,
" e.g. Get-Content or Get-ADUser
setlocal iskeyword+=-

" Change the browse dialog on Win32 to show mainly PowerShell-related files
if has("gui_win32")
	let b:browsefilter =
				\ "All PowerShell Files (*.ps1, *.psd1, *.psm1, *.ps1xml)\t*.ps1;*.psd1;*.psm1;*.ps1xml\n" .
				\ "PowerShell Script Files (*.ps1)\t*.ps1\n" .
				\ "PowerShell Module Files (*.psd1, *.psm1)\t*.psd1;*.psm1\n" .
				\ "PowerShell XML Files (*.ps1xml)\t*.ps1xml\n" .
				\ "All Files (*.*)\t*.*\n"
endif

" Look up keywords by Get-Help:
" check for PowerShell Core in Windows, Linux or MacOS
if executable('pwsh') | let s:pwsh_cmd = 'pwsh'
  " on Windows Subsystem for Linux, check for PowerShell Core in Windows
elseif exists('$WSLENV') && executable('pwsh.exe') | let s:pwsh_cmd = 'pwsh.exe'
  " check for PowerShell <= 5.1 in Windows
elseif executable('powershell.exe') | let s:pwsh_cmd = 'powershell.exe'
endif

if exists('s:pwsh_cmd')
  if !has('gui_running') && executable('less') &&
        \ !(exists('$ConEmuBuild') && &term =~? '^xterm')
    " For exclusion of ConEmu, see https://github.com/Maximus5/ConEmu/issues/2048
    command! -buffer -nargs=1 Ps1KeywordPrg silent exe '!' . s:pwsh_cmd . ' -NoLogo -NoProfile -NonInteractive -ExecutionPolicy RemoteSigned -Command Get-Help -Full "<args>" | ' . (has('unix') ? 'LESS= less' : 'less') | redraw!
  elseif has('terminal')
    command! -buffer -nargs=1 Ps1KeywordPrg silent exe 'term ' . s:pwsh_cmd . ' -NoLogo -NoProfile -NonInteractive -ExecutionPolicy RemoteSigned -Command Get-Help -Full "<args>"' . (executable('less') ? ' | less' : '')
  else
    command! -buffer -nargs=1 Ps1KeywordPrg echo system(s:pwsh_cmd . ' -NoLogo -NoProfile -NonInteractive -ExecutionPolicy RemoteSigned -Command Get-Help -Full <args>')
  endif
  setlocal keywordprg=:Ps1KeywordPrg
endif

" Undo the stuff we changed
let b:undo_ftplugin = "setlocal tw< cms< fo< iskeyword< keywordprg<" .
                        \ " | sil! delc -buffer Ps1KeywordPrg" .
			\ " | unlet! b:browsefilter"
