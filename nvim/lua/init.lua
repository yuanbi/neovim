
--------------------
---- 顺序不可变 ----
--------------------
require 'plugins'
require 'basic'
require 'keymaps'

vim.cmd('source ~/.config/nvim/coc_init.vim')
vim.cmd('source ~/.config/nvim/plugins_init.vim')
vim.cmd('source ~/.config/nvim/autocmd.vim')


local fn = vim.fn

--vim.cmd([[
--autocmd FileType json syntax match Comment +\/\/.\+$+
--]])

--[[function SetupCommandAbbrs(from, to)]]
  --[[fn.system('cnoreabbrev <expr> ' + a + ]]
         --[[' ((getcmdtype() ==# ":" && getcmdline() ==# "'from'")' +]]
         --[['? ("'to'") : ("'from'"))')]]
--[[end]]

--[[SetupCommandAbbrs('CC', 'CocCommand<CR>')]]
