local M = {}

local keymap = require("keymaps")
local map = keymap.map
local nmap = keymap.nmap
local vmap = keymap.vmap
local xmap = keymap.xmap
local cmap = keymap.cmap
local imap = keymap.imap
local nmap2 = keymap.nmap2
local vmap2 = keymap.vmap2
local vmap2x = keymap.vmap2x

-----------------------------------
---- VIM MARK 高亮数量限制解除 ----
-----------------------------------
--
vim.g.mw_no_mappings = 1
vim.g.mwDefaultHighlightingPalette = "maximum"

------------------------------------------------------------------------------------------
-- 异步shell插件 窗口设置
------------------------------------------------------------------------------------------
--
vim.g.asyncrun_open = 12
------------------------------------------------------------------------------------------

------------------------------------------------------------------------------------------
-- 书签保存设置
------------------------------------------------------------------------------------------
--
vim.g.bookmark_save_per_working_dir = 1 -- 书签保存到工作目录
vim.g.bookmark_auto_save = 1 -- 自动保存书签

function M.lualine_init()
	require("lualine").setup {
		options = {
			icons_enabled = true,
			theme = "auto",
			component_separators = {left = "", right = ""},
			section_separators = {left = "", right = ""},
			disabled_filetypes = {
				statusline = {},
				winbar = {}
			},
			ignore_focus = {},
			always_divide_middle = true,
			globalstatus = false,
			refresh = {
				statusline = 1000,
				tabline = 1000,
				winbar = 1000
			}
		},
		sections = {
			lualine_a = {"mode"},
			lualine_b = {"branch", "diff", "diagnostics"},
			lualine_c = {
				{"aerial"},
				{"filename", path = 1}, -- 显示文件名
				{"gitsigns", blame = true} -- 显示 Git Blame 信息
			},
			lualine_x = {"encoding", "fileformat", "filetype"},
			lualine_y = {"progress"},
			lualine_z = {"location"}
		},
		inactive_sections = {
			lualine_a = {},
			lualine_b = {},
			lualine_c = {"filename"},
			lualine_x = {"location"},
			lualine_y = {},
			lualine_z = {}
		},
		tabline = {},
		winbar = {},
		inactive_winbar = {},
		extensions = {}
	}
end

------------------------------------------
----     bufferline 语法高亮配置      ----
------------------------------------------
function M.bufferline_init()
	require("bufferline").setup {
		options = {
			mode = "buffers",
			numbers = "none",
			separator_style = "slant",
			show_close_icon = false,
			show_buffer_close_icons = false,
			show_buffer_icons = false,
			indicator = {icon = " ●"},
			buffer_close_icon = "",
			modified_icon = "[+]",
			close_icon = "",
			left_trunc_marker = "",
			right_trunc_marker = "",
			diagnostics = "nvim_lsp", -- 使用 nvim-lsp 提供的诊断信息
			diagnostics_indicator = function(count, level, diagnostics_dict, context)
				local icon = level:match("error") and " " or " " -- 设置错误和警告的图标
				return icon .. count -- 显示图标和数量
			end,
			custom_filter = function(bufnr)
				-- 排除 quickfix 缓冲区
				if vim.api.nvim_buf_get_option(bufnr, "buftype") == "quickfix" then
					return false
				end
                return true
			end,
            highlights = {
                buffer_selected = { 
                    gui = "underline",
                    guifg = "#ffffff",
                    guibg = "#000000",
                    -- 如果你还想自定义前景色/背景色，可以添加如下配置 guifg = "任意颜色", -- 比如 #ffffff guibg = "任意颜色", -- 比如 #000000 
                }, 
            },
			show_tab_indicators = true
		}
	}
end

------------------------------------------
---- for nvim-treesitter 语法高亮配置 ----
------------------------------------------
--
function M.nvim_treesitter_configs_init()
	vim.api.nvim_create_autocmd(
		{"BufEnter", "BufAdd", "BufNew", "BufNewFile", "BufWinEnter"},
		{
			group = vim.api.nvim_create_augroup("TS_FOLD_WORKAROUND", {}),
			callback = function()
				-- vim.opt.foldmethod     = 'expr'
				vim.opt.foldexpr = "nvim_treesitter#foldexpr()"
			end
		}
	)
	require "nvim-treesitter.configs".setup {
		-- A list of parser names, or "all"
		ensure_installed = {"c", "lua", "python", "cpp", "markdown", "vim", "sql", "json", "xml"},
		--ensure_installed = { "c", "lua", "python", "cpp" , "markdown", "vim", "sql", "yaml",
		--"bash", "cmake", "json", "javascript", "java", "kotlin", "llvm", "make", "qmljs"},

		-- Install parsers synchronously (only applied to `ensure_installed`)
		sync_install = true,
		-- Automatically install missing parsers when entering buffer
		auto_install = true,
		-- List of parsers to ignore installing (for "all")
		ignore_install = {"vimdoc"},
		highlight = {
			-- `false` will disable the whole extension
			enable = true,
			-- NOTE: these are the names of the parsers and not the filetype. (for example if you want to
			-- disable highlighting for the `tex` filetype, you need to include `latex` in this list as this is
			-- the name of the parser)
			-- list of language that will be disabled
			disable = {"vimdoc"},
			-- Setting this to true will run `:h syntax` and tree-sitter at the same time.
			-- Set this to `true` if you depend on 'syntax' being enabled (like for indentation).
			-- Using this option may slow down your editor, and you may see some duplicate highlights.
			-- Instead of true it can also be a list of languages
			additional_vim_regex_highlighting = false
		}
	}
end

-----------------------------------
---- 弹出式终端，GIT对比窗口   ----
-----------------------------------
--
function M.FTerm_init()
	require "FTerm".setup(
		{
			border = "double",
			dimensions = {
				height = 0.9,
				width = 0.9
			},
			---Filetype of the terminal buffer
			---@type string
			ft = "FTerm",
			---Command to run inside the terminal
			---NOTE: if given string[], it will skip the shell and directly executes the command
			---@type fun():(string|string[])|string|string[]
			cmd = os.getenv("SHELL"),
			---Neovim's native window border. See `:h nvim_open_win` for more configuration options.
			border = "single",
			---Close the terminal as soon as shell/command exits.
			---Disabling this will mimic the native terminal behaviour.
			---@type boolean
			auto_close = true,
			---Highlight group for the terminal. See `:h winhl`
			---@type string
			hl = "Normal",
			---Transparency of the floating window. See `:h winblend`
			---@type integer
			blend = 0,
			---Object containing the terminal window dimensions.
			---The value for each field should be between `0` and `1`
			---@type table<string,number>
			dimensions = {
				height = 0.8, -- Height of the terminal window
				width = 0.8, -- Width of the terminal window
				x = 0.5, -- X axis of the terminal window
				y = 0.5 -- Y axis of the terminal window
			},
			---Replace instead of extend the current environment with `env`.
			---See `:h jobstart-options`
			---@type boolean
			clear_env = false,
			---Map of environment variables extending the current environment.
			---See `:h jobstart-options`
			---@type table<string,string>|nil
			env = nil,
			---Callback invoked when the terminal exits.
			---See `:h jobstart-options`
			---@type fun()|nil
			on_exit = nil,
			---Callback invoked when the terminal emits stdout data.
			---See `:h jobstart-options`
			---@type fun()|nil
			on_stdout = nil,
			---Callback invoked when the terminal emits stderr data.
			---See `:h jobstart-options`
			---@type fun()|nil
			on_stderr = nil
		}
	)
	nmap("<leader>t", '<CMD>lua require("FTerm").toggle()<CR>')
end

------------------------------------------------------------------------------------------
-- diffview 配置
------------------------------------------------------------------------------------------
-- Lua
function M.diffview_init()
	local actions = require("diffview.actions")
	require("diffview").setup(
		{
			diff_binaries = false, -- Show diffs for binaries
			enhanced_diff_hl = false, -- See ':h diffview-config-enhanced_diff_hl'
			git_cmd = {"git"}, -- The git executable followed by default args.
			hg_cmd = {"hg"}, -- The hg executable followed by default args.
			use_icons = true, -- Requires nvim-web-devicons
			show_help_hints = true, -- Show hints for how to open the help panel
			watch_index = true, -- Update views and index buffers when the git index changes.
			icons = {
				-- Only applies when use_icons is true.
				folder_closed = "",
				folder_open = ""
			},
			signs = {
				fold_closed = "",
				fold_open = "",
				done = "✓"
			},
			view = {
				-- Configure the layout and behavior of different types of views.
				-- Available layouts:
				--  'diff1_plain'
				--    |'diff2_horizontal'
				--    |'diff2_vertical'
				--    |'diff3_horizontal'
				--    |'diff3_vertical'
				--    |'diff3_mixed'
				--    |'diff4_mixed'
				-- For more info, see ':h diffview-config-view.x.layout'.
				default = {
					-- Config for changed files, and staged files in diff views.
					layout = "diff2_horizontal",
					winbar_info = false -- See ':h diffview-config-view.x.winbar_info'
				},
				merge_tool = {
					-- Config for conflicted files in diff views during a merge or rebase.
					layout = "diff3_horizontal",
					disable_diagnostics = true, -- Temporarily disable diagnostics for conflict buffers while in the view.
					winbar_info = true -- See ':h diffview-config-view.x.winbar_info'
				},
				file_history = {
					-- Config for changed files in file history views.
					layout = "diff2_horizontal",
					winbar_info = false -- See ':h diffview-config-view.x.winbar_info'
				}
			},
			file_panel = {
				listing_style = "tree", -- One of 'list' or 'tree'
				tree_options = {
					-- Only applies when listing_style is 'tree'
					flatten_dirs = true, -- Flatten dirs that only contain one single dir
					folder_statuses = "only_folded" -- One of 'never', 'only_folded' or 'always'.
				},
				win_config = {
					-- See ':h diffview-config-win_config'
					position = "left",
					width = 35,
					win_opts = {}
				}
			},
			file_history_panel = {
				log_options = {
					-- See ':h diffview-config-log_options'
					git = {
						single_file = {
							diff_merges = "combined"
						},
						multi_file = {
							diff_merges = "first-parent"
						}
					},
					hg = {
						single_file = {},
						multi_file = {}
					}
				},
				win_config = {
					-- See ':h diffview-config-win_config'
					position = "bottom",
					height = 16,
					win_opts = {}
				}
			},
			commit_log_panel = {
				win_config = {
					-- See ':h diffview-config-win_config'
					win_opts = {}
				}
			},
			default_args = {
				-- Default args prepended to the arg-list for the listed commands
				DiffviewOpen = {},
				DiffviewFileHistory = {}
			},
			hooks = {}, -- See ':h diffview-config-hooks'
			keymaps = {
				disable_defaults = false, -- Disable the default keymaps
				view = {
					-- The `view` bindings are active in the diff buffers, only when the current
					-- tabpage is a Diffview.
					{"n", "<tab>", actions.select_next_entry, {desc = "Open the diff for the next file"}},
					{"n", "<s-tab>", actions.select_prev_entry, {desc = "Open the diff for the previous file"}},
					{"n", "gf", actions.goto_file_edit, {desc = "Open the file in the previous tabpage"}},
					{"n", "<C-w><C-f>", actions.goto_file_split, {desc = "Open the file in a new split"}},
					{"n", "<C-w>gf", actions.goto_file_tab, {desc = "Open the file in a new tabpage"}},
					{"n", "<leader>e", actions.focus_files, {desc = "Bring focus to the file panel"}},
					{"n", "<leader>b", actions.toggle_files, {desc = "Toggle the file panel."}},
					{"n", "g<C-x>", actions.cycle_layout, {desc = "Cycle through available layouts."}},
					{"n", "[x", actions.prev_conflict, {desc = "In the merge-tool: jump to the previous conflict"}},
					{"n", "]x", actions.next_conflict, {desc = "In the merge-tool: jump to the next conflict"}},
					{"n", "<leader>co", actions.conflict_choose("ours"), {desc = "Choose the OURS version of a conflict"}},
					{"n", "<leader>ct", actions.conflict_choose("theirs"), {desc = "Choose the THEIRS version of a conflict"}},
					{"n", "<leader>cb", actions.conflict_choose("base"), {desc = "Choose the BASE version of a conflict"}},
					{"n", "<leader>ca", actions.conflict_choose("all"), {desc = "Choose all the versions of a conflict"}},
					{"n", "dx", actions.conflict_choose("none"), {desc = "Delete the conflict region"}},
					{
						"n",
						"<leader>cO",
						actions.conflict_choose_all("ours"),
						{desc = "Choose the OURS version of a conflict for the whole file"}
					},
					{
						"n",
						"<leader>cT",
						actions.conflict_choose_all("theirs"),
						{desc = "Choose the THEIRS version of a conflict for the whole file"}
					},
					{
						"n",
						"<leader>cB",
						actions.conflict_choose_all("base"),
						{desc = "Choose the BASE version of a conflict for the whole file"}
					},
					{
						"n",
						"<leader>cA",
						actions.conflict_choose_all("all"),
						{desc = "Choose all the versions of a conflict for the whole file"}
					},
					{"n", "dX", actions.conflict_choose_all("none"), {desc = "Delete the conflict region for the whole file"}}
				},
				diff1 = {
					-- Mappings in single window diff layouts
					{"n", "g?", actions.help({"view", "diff1"}), {desc = "Open the help panel"}}
				},
				diff2 = {
					-- Mappings in 2-way diff layouts
					{"n", "g?", actions.help({"view", "diff2"}), {desc = "Open the help panel"}}
				},
				diff3 = {
					-- Mappings in 3-way diff layouts
					{{"n", "x"}, "2do", actions.diffget("ours"), {desc = "Obtain the diff hunk from the OURS version of the file"}},
					{{"n", "x"}, "3do", actions.diffget("theirs"), {desc = "Obtain the diff hunk from the THEIRS version of the file"}},
					{"n", "g?", actions.help({"view", "diff3"}), {desc = "Open the help panel"}}
				},
				diff4 = {
					-- Mappings in 4-way diff layouts
					{{"n", "x"}, "1do", actions.diffget("base"), {desc = "Obtain the diff hunk from the BASE version of the file"}},
					{{"n", "x"}, "2do", actions.diffget("ours"), {desc = "Obtain the diff hunk from the OURS version of the file"}},
					{{"n", "x"}, "3do", actions.diffget("theirs"), {desc = "Obtain the diff hunk from the THEIRS version of the file"}},
					{"n", "g?", actions.help({"view", "diff4"}), {desc = "Open the help panel"}}
				},
				file_panel = {
					{"n", "j", actions.next_entry, {desc = "Bring the cursor to the next file entry"}},
					{"n", "<down>", actions.next_entry, {desc = "Bring the cursor to the next file entry"}},
					{"n", "k", actions.prev_entry, {desc = "Bring the cursor to the previous file entry"}},
					{"n", "<up>", actions.prev_entry, {desc = "Bring the cursor to the previous file entry"}},
					{"n", "<cr>", actions.select_entry, {desc = "Open the diff for the selected entry"}},
					{"n", "o", actions.select_entry, {desc = "Open the diff for the selected entry"}},
					{"n", "l", actions.select_entry, {desc = "Open the diff for the selected entry"}},
					{"n", "<2-LeftMouse>", actions.select_entry, {desc = "Open the diff for the selected entry"}},
					{"n", "-", actions.toggle_stage_entry, {desc = "Stage / unstage the selected entry"}},
					{"n", "s", actions.toggle_stage_entry, {desc = "Stage / unstage the selected entry"}},
					{"n", "S", actions.stage_all, {desc = "Stage all entries"}},
					{"n", "U", actions.unstage_all, {desc = "Unstage all entries"}},
					{"n", "X", actions.restore_entry, {desc = "Restore entry to the state on the left side"}},
					{"n", "L", actions.open_commit_log, {desc = "Open the commit log panel"}},
					{"n", "zo", actions.open_fold, {desc = "Expand fold"}},
					{"n", "h", actions.close_fold, {desc = "Collapse fold"}},
					{"n", "zc", actions.close_fold, {desc = "Collapse fold"}},
					{"n", "za", actions.toggle_fold, {desc = "Toggle fold"}},
					{"n", "zR", actions.open_all_folds, {desc = "Expand all folds"}},
					{"n", "zM", actions.close_all_folds, {desc = "Collapse all folds"}},
					{"n", "<c-b>", actions.scroll_view(-0.25), {desc = "Scroll the view up"}},
					{"n", "<c-f>", actions.scroll_view(0.25), {desc = "Scroll the view down"}},
					{"n", "<tab>", actions.select_next_entry, {desc = "Open the diff for the next file"}},
					{"n", "<s-tab>", actions.select_prev_entry, {desc = "Open the diff for the previous file"}},
					{"n", "gf", actions.goto_file_edit, {desc = "Open the file in the previous tabpage"}},
					{"n", "<C-w><C-f>", actions.goto_file_split, {desc = "Open the file in a new split"}},
					{"n", "<C-w>gf", actions.goto_file_tab, {desc = "Open the file in a new tabpage"}},
					{"n", "i", actions.listing_style, {desc = "Toggle between 'list' and 'tree' views"}},
					{"n", "f", actions.toggle_flatten_dirs, {desc = "Flatten empty subdirectories in tree listing style"}},
					{"n", "R", actions.refresh_files, {desc = "Update stats and entries in the file list"}},
					{"n", "<leader>e", actions.focus_files, {desc = "Bring focus to the file panel"}},
					{"n", "<leader>b", actions.toggle_files, {desc = "Toggle the file panel"}},
					{"n", "g<C-x>", actions.cycle_layout, {desc = "Cycle available layouts"}},
					{"n", "[x", actions.prev_conflict, {desc = "Go to the previous conflict"}},
					{"n", "]x", actions.next_conflict, {desc = "Go to the next conflict"}},
					{"n", "g?", actions.help("file_panel"), {desc = "Open the help panel"}},
					{
						"n",
						"<leader>cO",
						actions.conflict_choose_all("ours"),
						{desc = "Choose the OURS version of a conflict for the whole file"}
					},
					{
						"n",
						"<leader>cT",
						actions.conflict_choose_all("theirs"),
						{desc = "Choose the THEIRS version of a conflict for the whole file"}
					},
					{
						"n",
						"<leader>cB",
						actions.conflict_choose_all("base"),
						{desc = "Choose the BASE version of a conflict for the whole file"}
					},
					{
						"n",
						"<leader>cA",
						actions.conflict_choose_all("all"),
						{desc = "Choose all the versions of a conflict for the whole file"}
					},
					{"n", "dX", actions.conflict_choose_all("none"), {desc = "Delete the conflict region for the whole file"}}
				},
				file_history_panel = {
					{"n", "g!", actions.options, {desc = "Open the option panel"}},
					{"n", "<C-A-d>", actions.open_in_diffview, {desc = "Open the entry under the cursor in a diffview"}},
					{"n", "y", actions.copy_hash, {desc = "Copy the commit hash of the entry under the cursor"}},
					{"n", "L", actions.open_commit_log, {desc = "Show commit details"}},
					{"n", "zR", actions.open_all_folds, {desc = "Expand all folds"}},
					{"n", "zM", actions.close_all_folds, {desc = "Collapse all folds"}},
					{"n", "j", actions.next_entry, {desc = "Bring the cursor to the next file entry"}},
					{"n", "<down>", actions.next_entry, {desc = "Bring the cursor to the next file entry"}},
					{"n", "k", actions.prev_entry, {desc = "Bring the cursor to the previous file entry."}},
					{"n", "<up>", actions.prev_entry, {desc = "Bring the cursor to the previous file entry."}},
					{"n", "<cr>", actions.select_entry, {desc = "Open the diff for the selected entry."}},
					{"n", "o", actions.select_entry, {desc = "Open the diff for the selected entry."}},
					{"n", "<2-LeftMouse>", actions.select_entry, {desc = "Open the diff for the selected entry."}},
					{"n", "<c-b>", actions.scroll_view(-0.25), {desc = "Scroll the view up"}},
					{"n", "<c-f>", actions.scroll_view(0.25), {desc = "Scroll the view down"}},
					{"n", "<tab>", actions.select_next_entry, {desc = "Open the diff for the next file"}},
					{"n", "<s-tab>", actions.select_prev_entry, {desc = "Open the diff for the previous file"}},
					{"n", "gf", actions.goto_file_edit, {desc = "Open the file in the previous tabpage"}},
					{"n", "<C-w><C-f>", actions.goto_file_split, {desc = "Open the file in a new split"}},
					{"n", "<C-w>gf", actions.goto_file_tab, {desc = "Open the file in a new tabpage"}},
					{"n", "<leader>e", actions.focus_files, {desc = "Bring focus to the file panel"}},
					{"n", "<leader>b", actions.toggle_files, {desc = "Toggle the file panel"}},
					{"n", "g<C-x>", actions.cycle_layout, {desc = "Cycle available layouts"}},
					{"n", "g?", actions.help("file_history_panel"), {desc = "Open the help panel"}}
				},
				option_panel = {
					{"n", "<tab>", actions.select_entry, {desc = "Change the current option"}},
					{"n", "q", actions.close, {desc = "Close the panel"}},
					{"n", "g?", actions.help("option_panel"), {desc = "Open the help panel"}}
				},
				help_panel = {
					{"n", "q", actions.close, {desc = "Close help menu"}},
					{"n", "<esc>", actions.close, {desc = "Close help menu"}}
				}
			}
		}
	)
end

------------------------------------------------------------------------------------------
-- 注释插件 Comment 配置
------------------------------------------------------------------------------------------
function M.Comment_init()
	require("Comment").setup(
		{
			---Add a space b/w comment and the line
			padding = true,
			---Whether the cursor should stay at its position
			sticky = true,
			---Lines to be ignored while (un)comment
			ignore = "^$",
			---LHS of toggle mappings in NORMAL mode
			toggler = {
				---Line-comment toggle keymap
				line = "<leader>cc",
				---Block-comment toggle keymap
				block = "<leader>cb"
			},
			---LHS of operator-pending mappings in NORMAL and VISUAL mode
			opleader = {
				---Line-comment keymap
				line = "<leader>cc",
				---Block-comment keymap
				block = "<leadercb>"
			},
			---LHS of extra mappings
			extra = {
				---Add comment on the line above
				above = "<leader>cO",
				---Add comment on the line below
				below = "<leader>gco",
				---Add comment at the end of line
				eol = "<Nop>"
			},
			---Enable keybindings
			---NOTE: If given `false` then the plugin won't create any mappings
			mappings = {
				---Operator-pending mapping; `gcc` `gbc` `gc[count]{motion}` `gb[count]{motion}`
				basic = true,
				---Extra mapping; `gco`, `gcO`, `gcA`
				extra = true
			},
			---Function to call before (un)comment
			pre_hook = nil,
			---Function to call after (un)comment
			post_hook = nil
		}
	)
end

------------------------------------------------------------------------------------------
-- nvim-tree 配置
------------------------------------------------------------------------------------------
function M.nvim_tree_init()
	require("nvim-tree").setup(
		{
			update_focused_file = {
				enable = false -- 打开文件时不要聚焦到 nvim-tree
			},
			-- 禁用 netrw（Neovim 的默认文件浏览器）
			disable_netrw = true,
			hijack_netrw = true,
			sort = {
				sorter = "case_sensitive"
			},
			filters = {
				dotfiles = true
			},
			-- 文件图标
			renderer = {
				icons = {
					glyphs = {
						default = "", -- 默认文件图标
						symlink = "", -- 符号链接图标
						git = {
							unstaged = "", -- 未暂存的更改
							staged = "✓", -- 已暂存的更改
							unmerged = "", -- 未合并的更改
							renamed = "➜", -- 重命名的文件
							untracked = "", -- 未跟踪的文件
							deleted = "", -- 已删除的文件
							ignored = "◌" -- 忽略的文件
						}
					}
				}
			},
			-- 文件操作
			actions = {
				open_file = {
					quit_on_open = false -- 打开文件后不退出文件树
				}
			},
			-- Git 状态
			git = {
				enable = true, -- 启用 Git 状态显示
				ignore = false, -- 不忽略 Git 未跟踪的文件
				timeout = 400 -- Git 状态更新的延迟时间（毫秒）
			},
			-- 视图设置
			view = {
				width = 40,
				side = "left"
				--   mappings = {
				--     custom_only = false,  -- 是否只使用自定义映射
				--     list = {
				--       -- 自定义键位映射
				--       { key = '<CR>', action = 'edit' },
				--       { key = 'o', action = 'edit' },
				--       { key = 'a', action = 'create' },
				--       { key = 'd', action = 'remove' },
				--       { key = 'r', action = 'rename' },
				--       { key = 'x', action = 'cut' },
				--       { key = 'c', action = 'copy' },
				--       { key = 'p', action = 'paste' },
				--       { key = 'y', action = 'copy_name' },
				--       { key = 'gy', action = 'copy_path' },
				--       { key = 'I', action = 'toggle_ignored' },
				--       { key = 'H', action = 'toggle_dotfiles' },
				--       { key = 'R', action = 'refresh' },
				--       { key = 'q', action = 'close' },
				--     },
				--   },
			}
		}
	)
	nmap("<F3>", ":lua vim.g.toggle_nvimtree()<CR>")
end

------------------------------------------------------------------------------------------
-- gitsigns 配置
------------------------------------------------------------------------------------------
function M.gitsigns_init()
	require("gitsigns").setup(
		{
			signs = {
				add = {text = "G+"}, -- 新增
				change = {text = "G~"}, -- 修改
				delete = {text = "G-"}, -- 删除
				topdelete = {text = "G▔"}, -- 顶部删除
				changedelete = {text = "G!"}, -- 修改并删除
				untracked = {text = "G?"} -- 未跟踪

				-- add          = { text = 'g+' }, -- 新增
				-- change       = { text = 'g~' }, -- 修改
				-- delete       = { text = 'g✗' }, -- 删除
				-- topdelete    = { text = 'g^' }, -- 顶部删除
				-- changedelete = { text = 'g!' }, -- 修改并删除
				-- untracked    = { text = 'g?' }, -- 未跟踪

				-- add          = { text = '🆕' }, -- 新增
				-- change       = { text = '📝' }, -- 修改
				-- delete       = { text = '🗑️' }, -- 删除
				-- topdelete    = { text = '🔥' }, -- 顶部删除
				-- changedelete = { text = '💥' }, -- 修改并删除
				-- untracked    = { text = '❓' }, -- 未跟踪
			},
			signcolumn = true, -- 始终显示 Git 状态列
			numhl = false, -- 不启用行号高亮
			linehl = false, -- 不启用行高亮
			word_diff = false, -- 不启用单词差异高亮
			watch_gitdir = {
				interval = 1000, -- 检查 Git 状态的时间间隔（毫秒）
				follow_files = true
			},
			attach_to_untracked = true, -- 显示未跟踪文件的状态
			current_line_blame = false, -- 不启用当前行的 Git  blame
			current_line_blame_opts = {
				virt_text = true,
				virt_text_pos = "eol", -- blame 信息显示在行尾
				delay = 1000, -- blame 信息显示的延迟时间（毫秒）
				ignore_whitespace = false
			},
			-- sign_priority = 6, -- Git 状态符号的优先级
			update_debounce = 1000, -- 更新防抖时间（毫秒）
			status_formatter = nil, -- 使用默认的状态格式化函数
			max_file_length = 4000, -- 最大文件长度（行数）
			preview_config = {
				border = "single", -- 预览窗口的边框样式
				style = "minimal", -- 预览窗口的样式
				relative = "cursor", -- 预览窗口相对于光标的位置
				row = 0, -- 预览窗口的行偏移
				col = 1 -- 预览窗口的列偏移
			}
		}
	)

	-- GIT 命令
	nmap("<leader>gr", ":Gitsigns refresh<CR>")
	nmap("<leader>gb", ":Gitsigns blame_line<CR>")
	nmap("<leader>gi", ":Gitsigns preview_hunk<CR>")
	nmap("<leader>gd", ":Gvdiffsplit<CR>")
	-- navigate conflicts of current buffer
	nmap("gkn", ":Gitsigns next_hunk<CR>")
	nmap("gkp", ":Gitsigns prev_hunk<CR>")
	nmap("gku", ":Gitsigns reset_hunk<CR>")
	nmap("gks", ":Gitsigns stage_hunk<CR>")
end
------------------------------------------------------------------------------------------
-- null-ls 配置
------------------------------------------------------------------------------------------

function M.null_ls_init()
	local null_ls = require("null-ls")
    vim.g.home_path = vim.fn.expand('~')
	null_ls.setup(
		{
			sources = {
				-- 添加你需要的格式化工具
				-- null_ls.builtins.formatting.prettier, -- JavaScript/TypeScript/CSS/HTML 格式化
				-- null_ls.builtins.formatting.stylua,   -- Lua 格式化
				-- null_ls.builtins.formatting.gofmt,    -- Go 格式化
				null_ls.builtins.formatting.yapf.with(
					{
						command = "python3",
						args = {"-m", "yapf"}
					}
				), -- 使用 yapf
				null_ls.builtins.formatting.clang_format.with(
					{
						extra_args = {"-style", "file:" .. vim.g.home_path .. "/.config/nvim/.clang-format"}, -- 使用项目根目录下的 .clang-format 文件
						filetypes = {"cpp", "c", "cxx", "hpp", "h"}
					}
				)
			}
		}
	)
end

------------------------------------------------------------------------------------------
-- cmake-tools.nvim 配置
------------------------------------------------------------------------------------------
function M.cmake_tools_init()
	require("cmake-tools").setup(
		{
			cmake_command = "cmake", -- CMake 可执行文件路径
			ctest_command = "ctest", -- CTest 可执行文件路径
			cmake_build_directory = "build", -- 构建目录
			cmake_build_options = {}, -- 额外的构建选项
			cmake_soft_link_compile_commands = false, -- 软链接 compile_commands.json
			cmake_kits_global = {} -- 全局编译器工具链配置
		}
	)
end

------------------------------------------------------------------------------------------
-- telescope 配置
------------------------------------------------------------------------------------------
function M.telescope_init()
	require("telescope").setup(
		{
			defaults = {
				-- find_command = { "rg", "--files", "--hidden", "--glob", "!**/.git/*" },
				-- vimgrep_arguments = {
				--   "rg",  -- 使用 ripgrep
				--   "--color=never",
				--   "--no-heading",
				--   "--with-filename",
				--   "--line-number",
				--   "--column",
				--   "--smart-case",
				-- },
				layout_strategy = "horizontal", -- 使用垂直布局
				sorting_strategy = "ascending",
				file_ignore_patterns = {
					"build/",
					"dist/",
					"out/",
					"tags",
					"node_modules/",
					"%.git/",
					"%.vs/",
					"%.cache/",
					"%.vscode/",
					"%.github/"
				},
				layout_config = {
					horizontal = {
						prompt_position = "top", -- 搜索框在顶部
						height = 0.9, -- 窗口高度
						width = 0.9, -- 窗口宽度
						preview_width = 0.6, -- 预览窗口占整个窗口宽度的60%
						preview_cutoff = 120, -- 预览窗口的截断宽度
						preview_height = 0.6 -- 预览窗口占整个窗口高度的60%
					}
				},
				border = true, -- 启用边框
				borderchars = {"─", "│", "─", "│", "╭", "╮", "╯", "╰"} -- 自定义边框字符
			},
			extensions = {
				fzf = {
					fuzzy = true,
					override_generic_sorter = true,
					override_file_sorter = true,
					case_mode = "smart_case"
				},
				file_browser = {
					theme = "ivy",
					hijack_netrw = true
				},
				live_grep_args = {
					auto_quoting = true,
					mappings = {
						-- extend mappings
						i = {
							["<CR>"] = require("telescope.actions").select_default,
							-- ["<C-k>"] = require("telescope-live-grep-args.actions").quote_prompt(),
							-- ["<C-i>"] = require("telescope-live-grep-args.actions").quote_prompt({postfix = " -F -g *"}),
							-- ["<C-space>"] = require("telescope-live-grep-args.actions").to_fuzzy_refine,
							["<Tab>"] = require("telescope.actions").move_selection_next,
							["<S-Tab>"] = require("telescope.actions").move_selection_previous
						}
					}
				}
			}
		}
	)

	-- 加载插件
	require("telescope").load_extension("fzf")
	require("telescope").load_extension("file_browser")
	require("telescope").load_extension("live_grep_args")

	------------------------------------------------------------------------------------------
	-- Telescope 配置
	------------------------------------------------------------------------------------------
	nmap("<leader>sb", ':lua require("telescope.builtin").buffers()<CR>')
	-- nmap('<leader>sm', ':lua require("telescope.builtin").oldfiles()<CR>')
	nmap("<leader>st", ':lua require("telescope.builtin").tags({ env = { TAGS = vim.o.tags}})<CR>')
	nmap("<leader>sl", ':lua require("telescope.builtin").current_buffer_fuzzy_find()<CR>')
	nmap(
		"<leader>sw",
		':lua require("telescope").extensions.live_grep_args.live_grep_args({ cwd = vim.g.workspace_dir.get() , auto_quoting=true})<CR>'
	)
	nmap(
		"<leader>sc",
		':lua require("telescope").extensions.live_grep_args.live_grep_args({ cwd = vim.g.workspace_dir.get(), search_dirs = { vim.fn.expand("%:p:h") } })<CR>'
	)
	nmap("<leader>sf", ':lua require("telescope.builtin").find_files({ cwd = vim.g.workspace_dir.get() })<CR>')
	nmap(
		"<leader>sd",
		':lua require("telescope-live-grep-args.shortcuts").grep_word_under_cursor({cwd = vim.g.workspace_dir.get()})<CR>'
	)
	nmap(
		"<leader>ss",
		':lua require("telescope.builtin").tags({ env = { TAGS = vim.o.tags}, default_text= vim.fn.expand("<cword>") } )<CR>'
	)
	nmap("<leader>sg", ":lua vim.g.generate_ctags.get()<CR>")

	-- 配置可视模式下的快捷键
	vmap(
		"<leader>sw",
		':lua require("telescope").extensions.live_grep_args.live_grep_args({ cwd = vim.g.workspace_dir.get() , default_text= vim.g.get_visual_selection.get()})<CR>'
	)

    nmap2(";", ":Telescope ")
	------------------------------------------------------------------------------------------
	-- 格式化代码 null-ls
	------------------------------------------------------------------------------------------
	vim.api.nvim_create_autocmd(
		"FileType",
		{
			pattern = "lua", -- 仅对 Lua 文件生效
			callback = function()
				nmap("<leader>ff", ":lua vim.lsp.buf.format()<CR>")
			end
		}
	)
end

------------------------------------------------------------------------------------------
-- session_manager 配置
------------------------------------------------------------------------------------------
function M.session_manager_init()
	require("session_manager").setup {
		sessions_dir = require("plenary.path"):new(vim.fn.stdpath("data"), "sessions"), -- 会话保存目录
		path_replacer = "__", -- 替换路径中的目录分隔符
		colon_replacer = "++", -- 替换路径中的冒号
		autoload_mode = require("session_manager.config").AutoloadMode.Disabled, -- 自动加载模式
		-- autoload_mode = false, -- 自动加载模式
		autosave_last_session = true, -- 自动保存最后会话
		autosave_ignore_not_normal = true, -- 忽略非正常缓冲区的自动保存
		autosave_only_in_session = false -- 仅在会话中自动保存
	}

	nmap("<leader>sm", ":SessionManager available_commands<CR>") -- 会话管理
end

-- Call the setup function to change the default behavior
function M.aerial_init()
	require("aerial").setup(
		{
			-- Priority list of preferred backends for aerial.
			-- This can be a filetype map (see :help aerial-filetype-map)
			backends = {"treesitter", "lsp", "markdown", "asciidoc", "man"},
			layout = {
				-- These control the width of the aerial window.
				-- They can be integers or a float between 0 and 1 (e.g. 0.4 for 40%)
				-- min_width and max_width can be a list of mixed types.
				-- max_width = {40, 0.2} means "the lesser of 40 columns or 20% of total"
				max_width = {40, 0.2},
				width = 40,
				min_width = 10,
				-- key-value pairs of window-local options for aerial window (e.g. winhl)
				win_opts = {},
				-- Determines the default direction to open the aerial window. The 'prefer'
				-- options will open the window in the other direction *if* there is a
				-- different buffer in the way of the preferred direction
				-- Enum: prefer_right, prefer_left, right, left, float
				default_direction = "prefer_left",
				-- Determines where the aerial window will be opened
				--   edge   - open aerial at the far right/left of the editor
				--   window - open aerial to the right/left of the current window
				placement = "window",
				-- When the symbols change, resize the aerial window (within min/max constraints) to fit
				resize_to_content = true,
				-- Preserve window size equality with (:help CTRL-W_=)
				preserve_equality = false
			},
			-- Determines how the aerial window decides which buffer to display symbols for
			--   window - aerial window will display symbols for the buffer in the window from which it was opened
			--   global - aerial window will display symbols for the current window
			attach_mode = "window",
			-- List of enum values that configure when to auto-close the aerial window
			--   unfocus       - close aerial when you leave the original source window
			--   switch_buffer - close aerial when you change buffers in the source window
			--   unsupported   - close aerial when attaching to a buffer that has no symbol source
			close_automatic_events = {},
			-- Keymaps in aerial window. Can be any value that `vim.keymap.set` accepts OR a table of keymap
			-- options with a `callback` (e.g. { callback = function() ... end, desc = "", nowait = true })
			-- Additionally, if it is a string that matches "actions.<name>",
			-- it will use the mapping at require("aerial.actions").<name>
			-- Set to `false` to remove a keymap
			keymaps = {
				["?"] = "actions.show_help",
				["g?"] = "actions.show_help",
				["<CR>"] = "actions.jump",
				["<2-LeftMouse>"] = "actions.jump",
				["<C-v>"] = "actions.jump_vsplit",
				["<C-s>"] = "actions.jump_split",
				["p"] = "actions.scroll",
				["<C-j>"] = "actions.down_and_scroll",
				["<C-k>"] = "actions.up_and_scroll",
				["{"] = "actions.prev",
				["}"] = "actions.next",
				["[["] = "actions.prev_up",
				["]]"] = "actions.next_up",
				["q"] = "actions.close",
				["o"] = "actions.tree_toggle",
				["za"] = "actions.tree_toggle",
				["O"] = "actions.tree_toggle_recursive",
				["zA"] = "actions.tree_toggle_recursive",
				["l"] = "actions.tree_open",
				["zo"] = "actions.tree_open",
				["L"] = "actions.tree_open_recursive",
				["zO"] = "actions.tree_open_recursive",
				["h"] = "actions.tree_close",
				["zc"] = "actions.tree_close",
				["H"] = "actions.tree_close_recursive",
				["zC"] = "actions.tree_close_recursive",
				["zr"] = "actions.tree_increase_fold_level",
				["zR"] = "actions.tree_open_all",
				["zm"] = "actions.tree_decrease_fold_level",
				["zM"] = "actions.tree_close_all",
				["zx"] = "actions.tree_sync_folds",
				["zX"] = "actions.tree_sync_folds"
			},
			-- When true, don't load aerial until a command or function is called
			-- Defaults to true, unless `on_attach` is provided, then it defaults to false
			lazy_load = true,
			-- Disable aerial on files with this many lines
			disable_max_lines = 10000,
			-- Disable aerial on files this size or larger (in bytes)
			disable_max_size = 2000000, -- Default 2MB
			-- A list of all symbols to display. Set to false to display all symbols.
			-- This can be a filetype map (see :help aerial-filetype-map)
			-- To see all available values, see :help SymbolKind
			filter_kind = {
				"Class",
				"Constructor",
				"Enum",
				"Function",
				"Interface",
				"Module",
				"Method",
				"Struct"
			},
			-- Determines line highlighting mode when multiple splits are visible.
			-- split_width   Each open window will have its cursor location marked in the
			--               aerial buffer. Each line will only be partially highlighted
			--               to indicate which window is at that location.
			-- full_width    Each open window will have its cursor location marked as a
			--               full-width highlight in the aerial buffer.
			-- last          Only the most-recently focused window will have its location
			--               marked in the aerial buffer.
			-- none          Do not show the cursor locations in the aerial window.
			highlight_mode = "split_width",
			-- Highlight the closest symbol if the cursor is not exactly on one.
			highlight_closest = true,
			-- Highlight the symbol in the source buffer when cursor is in the aerial win
			highlight_on_hover = false,
			-- When jumping to a symbol, highlight the line for this many ms.
			-- Set to false to disable
			highlight_on_jump = 300,
			-- Jump to symbol in source window when the cursor moves
			autojump = false,
			-- Define symbol icons. You can also specify "<Symbol>Collapsed" to change the
			-- icon when the tree is collapsed at that symbol, or "Collapsed" to specify a
			-- default collapsed icon. The default icon set is determined by the
			-- "nerd_font" option below.
			-- If you have lspkind-nvim installed, it will be the default icon set.
			-- This can be a filetype map (see :help aerial-filetype-map)
			icons = {},
			-- Control which windows and buffers aerial should ignore.
			-- Aerial will not open when these are focused, and existing aerial windows will not be updated
			ignore = {
				-- Ignore unlisted buffers. See :help buflisted
				unlisted_buffers = false,
				-- Ignore diff windows (setting to false will allow aerial in diff windows)
				diff_windows = true,
				-- List of filetypes to ignore.
				filetypes = {},
				-- Ignored buftypes.
				-- Can be one of the following:
				-- false or nil - No buftypes are ignored.
				-- "special"    - All buffers other than normal, help and man page buffers are ignored.
				-- table        - A list of buftypes to ignore. See :help buftype for the
				--                possible values.
				-- function     - A function that returns true if the buffer should be
				--                ignored or false if it should not be ignored.
				--                Takes two arguments, `bufnr` and `buftype`.
				buftypes = "special",
				-- Ignored wintypes.
				-- Can be one of the following:
				-- false or nil - No wintypes are ignored.
				-- "special"    - All windows other than normal windows are ignored.
				-- table        - A list of wintypes to ignore. See :help win_gettype() for the
				--                possible values.
				-- function     - A function that returns true if the window should be
				--                ignored or false if it should not be ignored.
				--                Takes two arguments, `winid` and `wintype`.
				wintypes = "special"
			},
			-- Use symbol tree for folding. Set to true or false to enable/disable
			-- Set to "auto" to manage folds if your previous foldmethod was 'manual'
			-- This can be a filetype map (see :help aerial-filetype-map)
			manage_folds = false,
			-- When you fold code with za, zo, or zc, update the aerial tree as well.
			-- Only works when manage_folds = true
			link_folds_to_tree = false,
			-- Fold code when you open/collapse symbols in the tree.
			-- Only works when manage_folds = true
			link_tree_to_folds = true,
			-- Set default symbol icons to use patched font icons (see https://www.nerdfonts.com/)
			-- "auto" will set it to true if nvim-web-devicons or lspkind-nvim is installed.
			nerd_font = "auto",
			-- Call this function when aerial attaches to a buffer.
			-- on_attach = function(bufnr) end,

			-- Call this function when aerial first sets symbols on a buffer.
			-- on_first_symbols = function(bufnr) end,

			-- Automatically open aerial when entering supported buffers.
			-- This can be a function (see :help aerial-open-automatic)
			open_automatic = false,
			-- Run this command after jumping to a symbol (false will disable)
			post_jump_cmd = "normal! zz",
			-- Invoked after each symbol is parsed, can be used to modify the parsed item,
			-- or to filter it by returning false.
			--
			-- bufnr: a neovim buffer number
			-- item: of type aerial.Symbol
			-- ctx: a record containing the following fields:
			--   * backend_name: treesitter, lsp, man...
			--   * lang: info about the language
			--   * symbols?: specific to the lsp backend
			--   * symbol?: specific to the lsp backend
			--   * syntax_tree?: specific to the treesitter backend
			--   * match?: specific to the treesitter backend, TS query match
			-- post_parse_symbol = function(bufnr, item, ctx)
			--   return true
			-- end,

			-- Invoked after all symbols have been parsed and post-processed,
			-- allows to modify the symbol structure before final display
			--
			-- bufnr: a neovim buffer number
			-- items: a collection of aerial.Symbol items, organized in a tree,
			--        with 'parent' and 'children' fields
			-- ctx: a record containing the following fields:
			--   * backend_name: treesitter, lsp, man...
			--   * lang: info about the language
			--   * symbols?: specific to the lsp backend
			--   * syntax_tree?: specific to the treesitter backend
			-- post_add_all_symbols = function(bufnr, items, ctx)
			--   return items
			-- end,

			-- When true, aerial will automatically close after jumping to a symbol
			close_on_select = false,
			-- The autocmds that trigger symbols update (not used for LSP backend)
			update_events = "TextChanged,InsertLeave",
			-- Show box drawing characters for the tree hierarchy
			show_guides = false,
			-- Customize the characters used when show_guides = true
			guides = {
				-- When the child item has a sibling below it
				mid_item = "├─",
				-- When the child item is the last in the list
				last_item = "└─",
				-- When there are nested child guides to the right
				nested_top = "│ ",
				-- Raw indentation
				whitespace = "  "
			},
			-- Set this function to override the highlight groups for certain symbols
			-- get_highlight = function(symbol, is_icon, is_collapsed)
			--   -- return "MyHighlight" .. symbol.kind
			-- end,

			-- Options for opening aerial in a floating win
			float = {
				-- Controls border appearance. Passed to nvim_open_win
				border = "rounded",
				-- Determines location of floating window
				--   cursor - Opens float on top of the cursor
				--   editor - Opens float centered in the editor
				--   win    - Opens float centered in the window
				relative = "cursor",
				-- These control the height of the floating window.
				-- They can be integers or a float between 0 and 1 (e.g. 0.4 for 40%)
				-- min_height and max_height can be a list of mixed types.
				-- min_height = {8, 0.1} means "the greater of 8 rows or 10% of total"
				max_height = 0.9,
				height = nil,
				min_height = {8, 0.1}

				-- override = function(conf, source_winid)
				--   -- This is the config that will be passed to nvim_open_win.
				--   -- Change values here to customize the layout
				--   return conf
				-- end,
			},
			-- Options for the floating nav windows
			nav = {
				border = "rounded",
				max_height = 0.9,
				min_height = {10, 0.1},
				max_width = 0.5,
				min_width = {0.2, 20},
				win_opts = {
					cursorline = true,
					winblend = 10
				},
				-- Jump to symbol in source window when the cursor moves
				autojump = false,
				-- Show a preview of the code in the right column, when there are no child symbols
				preview = false,
				-- Keymaps in the nav window
				keymaps = {
					["<CR>"] = "actions.jump",
					["<2-LeftMouse>"] = "actions.jump",
					["<C-v>"] = "actions.jump_vsplit",
					["<C-s>"] = "actions.jump_split",
					["h"] = "actions.left",
					["l"] = "actions.right",
					["<C-c>"] = "actions.close"
				}
			},
			lsp = {
				-- If true, fetch document symbols when LSP diagnostics update.
				diagnostics_trigger_update = false,
				-- Set to false to not update the symbols when there are LSP errors
				update_when_errors = true,
				-- How long to wait (in ms) after a buffer change before updating
				-- Only used when diagnostics_trigger_update = false
				update_delay = 300,
				-- Map of LSP client name to priority. Default value is 10.
				-- Clients with higher (larger) priority will be used before those with lower priority.
				-- Set to -1 to never use the client.
				priority = {}
			},
			treesitter = {
				-- How long to wait (in ms) after a buffer change before updating
				update_delay = 300
			},
			markdown = {
				-- How long to wait (in ms) after a buffer change before updating
				update_delay = 300
			},
			asciidoc = {
				-- How long to wait (in ms) after a buffer change before updating
				update_delay = 300
			},
			man = {
				-- How long to wait (in ms) after a buffer change before updating
				update_delay = 300
			}
		}
	)
	nmap("<F2>", ":lua vim.g.toggle_tagbar()<CR>")
end

return M
