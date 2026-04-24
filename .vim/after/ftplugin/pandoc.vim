command! -buffer CopyHTML silent !pandoc -f markdown -t html "%" | wl-copy --type text/html
