------------------
---- 通用函数 ----
------------------
--
-- Modes
--   normal_mode = "n",
--   insert_mode = "i",
--   visual_mode = "v",
--   visual_block_mode = "x",
--   term_mode = "t",
--   command_mode = "c",
--
local M = {}
function map(mode, shortcut, command)
	vim.api.nvim_set_keymap(mode, shortcut, command, {noremap = true, silent = true})
end
M.map = map

function nmap(shortcut, command)
	map("n", shortcut, command)
end
M.nmap = nmap

function vmap(shortcut, command)
	map("v", shortcut, command)
end
M.vmap = vmap

function xmap(shortcut, command)
	map("x", shortcut, command)
end
M.mmap = mmap

function cmap(shortcut, command)
	vim.api.nvim_set_keymap("c", shortcut, command, {noremap = true, silent = false})
end
M.cmap = cmap

function imap(shortcut, command)
	map("i", shortcut, command)
end
M.imap = imap

-- 定义 nmap 函数
local function nmap2(key, cmd, opts)
	opts = opts or {}
	opts.desc = opts.desc or ""
	vim.keymap.set("n", key, cmd, opts)
end
M.nmap2 = nmap2

-- 定义 vmap 函数
local function vmap2(key, cmd, opts)
	opts = opts or {}
	opts.desc = opts.desc or ""
	vim.keymap.set("v", key, cmd, opts)
end
M.vmap2 = vmap2

-- 定义 vmap2 函数
local function vmap2x(keys, command, opts)
	opts = opts or {}
	opts.noremap = opts.noremap == nil and true or opts.noremap
	opts.silent = opts.silent == nil and true or opts.silent
	vim.api.nvim_set_keymap("v", keys, command, opts)
end
M.vmap2x = vmap2x

------------------------------------------------------------------------------------------
-- 取消无用 按键映射
------------------------------------------------------------------------------------------
--nmap('<leader>r', '<nop>')
--nmap('<leader>f', '<nop>')
nmap("<Space>", "<nop>")
vmap("<Space>", "<nop>")
xmap("<Space>", "<nop>")
imap("<C-k>", "<Esc>")
xmap("<C-k>", "<Esc>")
vmap("<C-k>", "<Esc>")

------------------------------------------------------------------------------------------
-- Telescope 映射
------------------------------------------------------------------------------------------
-- cmap('te', 'Telescope')

------------------------------------------------------------------------------------------
-- CMake-tools 映射
------------------------------------------------------------------------------------------
cmap("Cst", "CMakeSelectBuildType")
cmap("Cb", "CMakeBuild")
cmap("Cg", "CMakeGenerate")
-- cmap('SS', 'Leaderf! rg -g *.{}')

-- 重置工作目录
cmap("Rw", "lua vim.g.reset_workspace_dir.get()")
------------------
---- VIM 相关 ----
------------------
--
-- 保存文件
nmap("<leader>fs", ":w<CR>")

-- 保存所有文件
nmap("<leader>fS", ":wa<CR>")

-- 关闭当前文件
nmap("<leader>fd", ": bp | bd! #<CR>")
--nmap('<leader>fo',':e ') -- 异常
vim.cmd "nmap <leader>fo :e "

-- 文件保存与退出
nmap("<leader>wq", ":wq<CR>")
nmap("<leader>wQ", ":wqa<CR>")

-- 文件不保存退出
nmap("<leader>q", ":q<CR>")
nmap("<leader>Q", ":q!<CR>")

-- 上/下一个 buffer
nmap("<leader>fn", ":bn<CR>")
nmap("<leader>fp", ":bp<CR>")

-- 上/下一个 buffer
nmap("<leader>tn", ":tabp<CR>")
nmap("<leader>tp", ":tabn<CR>")

-- 开启与关闭高亮
nmap("<leader>hl", ":set hlsearch<CR>")
nmap("<leader>hc", ":set nohlsearch<CR>")

-- 快速切换到行首行尾
nmap("H", "^")
xmap("H", "^")
vmap("H", "^")
nmap("L", "$")
xmap("L", "$")
vmap("L", "$")

-- 批量缩进
xmap("<<", "<gv")
xmap(">>", ">gv")

-- 关闭quickfix
nmap("<leader>wc", ":cclose<cr>")

-- 16进制打开文件
nmap("<leader>hx", ":%!xxd<cr>")

-- 16进制打开文件恢复到正常模式打开文件
nmap("<leader>hr", ":%!xxd -r<cr>")

-- 显示开始界面
--nmap('<leader>ho :Startify<CR>

-- 上一个文件分屏横向分屏
nmap("<leader>ls", ":vsplit #<CR> ")

-- 上一个文件垂直分屏
nmap("<leader>lv", ":split #<CR> ")
nmap("<leader>lo", ":e #<CR>")

-- 窗口切换
nmap("<leader>wk", "<C-w>k")
nmap("<leader>wl", "<C-w>l")
nmap("<leader>wh", "<C-w>h")
nmap("<leader>wj", "<C-w>j")
nmap("<leader>w=", "<C-w>=")

-- 窗口移动
nmap("<leader>wK", "<C-w>K")
nmap("<leader>wL", "<C-w>L")
nmap("<leader>wH", "<C-w>H")
nmap("<leader>wJ", "<C-w>J")

-- 窗口删除
nmap("<leader>wo", ":only<CR>")

-- 窗口尺寸调整
nmap2("<leader>ws", ":vertical resize ")
nmap2("<leader>wv", ":resize ")

-- 括号跳转
nmap("<C-h>", "%")
vmap("<C-h>", "%")

------------------------------------------------------------------------------------------
-- 选中文字加括号引号
------------------------------------------------------------------------------------------
--
local wrappers = {
	double_quote = {'"', '"'},
	bracket = {"(", ")"},
	curly_brace = {"{", "}"}
}

vim.api.nvim_set_keymap(
	"v",
	'<leader>"',
	"",
	{
		noremap = true,
		callback = function()
			vim.schedule(
				function()
					vim.g.wrap_selection(wrappers.double_quote)
				end
			)
		end
	}
)
vim.api.nvim_set_keymap(
	"v",
	"<leader>(",
	"",
	{
		noremap = true,
		callback = function()
			vim.schedule(
				function()
					vim.g.wrap_selection(wrappers.bracket)
				end
			)
		end
	}
)
vim.api.nvim_set_keymap(
	"v",
	"<leader>{",
	"",
	{
		noremap = true,
		callback = function()
			vim.schedule(
				function()
					vim.g.wrap_selection(wrappers.curly_brace)
				end
			)
		end
	}
)

------------------------------------------
-- 定义 Lua 文件格式化
------------------------------------------
vim.api.nvim_create_autocmd('FileType', {
  pattern = 'lua', -- 仅对 Lua 文件生效
  callback = function()
    vim.api.nvim_set_keymap('n', '<leader>ff', ':%!npx lua-fmt --use-tabs --stdin<CR>', {noremap = true, silent = true})
  end,
})

return M
