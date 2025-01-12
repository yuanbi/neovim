-----------------------------------------------------------------------------------------
-- LSP 配置
------------------------------------------------------------------------------------------
local lspconfig = require("lspconfig")

function switch_file_and_search()
	-- 获取当前文件名
	local current_file = vim.fn.expand("%:t:r") -- 获取文件名（不带路径和扩展名）
	local file_extension = vim.fn.expand("%:e") -- 获取文件扩展名
	local filename

	-- 根据扩展名修改文件名
	if file_extension == "c" or file_extension == "cpp" or file_extension == "cxx" then
		filename = current_file .. ".h" -- 修改为头文件
	elseif file_extension == "h" or file_extension == "hpp" then
		filename = current_file .. ".c" -- 修改为源文件
	else
		print("Not a C/C++ file")
		return
	end

	-- 拼接 LeaderfFilePattern 命令
	-- local command = ':LeaderfFilePattern ' .. filename
	local command =
		string.format(
		'lua require("telescope.builtin").find_files({ cwd = vim.g.workspace_dir.get(), default_text="%s" })',
		filename
	)
	vim.cmd(command)
end

-- C++ 配置 (clangd)
lspconfig.clangd.setup(
	{
		cmd = {"clangd", "--background-index=true", "--clang-tidy"},
		cmd = {"clangd", "--compile-commands-dir=build"}, -- 指定 compile_commands.json 所在目录
		filetypes = {"c", "cpp", "objc", "objcpp", "cuda", "proto", "hpp", "cxx"},
		diagnostics = {
			-- 设置诊断刷新延迟（单位：毫秒）
			update_in_insert = true, -- 在插入模式下不更新诊断
			debounce = 300 -- 设置诊断刷新延迟为 300 毫秒
		},
		on_attach = function(client, bufnr)
			local opts = {noremap = true, silent = true}
			local keymap = vim.api.nvim_buf_set_keymap
			-- keymap(bufnr, 'n', 'gd', '<Cmd>lua vim.lsp.buf.definition()<CR>', opts)
			vim.keymap.set("n", "gd", "<cmd>Telescope lsp_definitions<cr>", {desc = "Find definitions"})
			-- keymap(bufnr, 'n', 'gi', '<Cmd>lua vim.lsp.buf.implementation()<CR>', opts)
			vim.keymap.set("n", "gi", "<cmd>Telescope lsp_implementations<cr>", {desc = "Find implementations"})
			-- keymap(bufnr, 'n', 'gr', '<Cmd>lua vim.lsp.buf.references()<CR>', opts)
			vim.keymap.set("n", "gr", "<cmd>Telescope lsp_references<cr>", {desc = "Find references"})
			vim.keymap.set("n", "gl", "<cmd>Telescope lsp_document_symbols<cr>", {desc = "Find references"})
			vim.keymap.set("n", "ga", "<cmd>Telescope lsp_dynamic_workspace_symbols<cr>", {desc = "Find references"})
			vim.keymap.set("n", "<C-t>", "<cmd>Telescope lsp_workspace_symbols<cr>", {desc = "Find workspace symbols"})
			keymap(bufnr, "n", "K", "<Cmd>lua vim.lsp.buf.hover()<CR>", opts)
			keymap(bufnr, "n", "<leader>rn", "<Cmd>lua vim.lsp.buf.rename()<CR>", opts)
			keymap(bufnr, "n", "<leader>ff", "<Cmd>lua vim.lsp.buf.format()<CR>", opts)
			keymap(bufnr, "n", "<leader>fx", "<Cmd>lua vim.lsp.buf.code_action()<CR>", opts)
			keymap(
				bufnr,
				"n",
				"<leader>wf",
				"<cmd>lua for _, folder in ipairs(vim.lsp.buf.list_workspace_folders()) do print(folder) end<CR>",
				opts
			)
			keymap(bufnr, "n", "<leader>hs", "<cmd>lua switch_file_and_search()<CR>", opts)
			keymap(bufnr, "i", "<C-j>", "<cmd>lua vim.lsp.buf.signature_help()<CR>", opts) -- 弹出参数提示
			-- vim.api.nvim_create_autocmd('CursorHoldI', { -- 自动弹出参数提示
			--     buffer = bufnr,
			--     callback = function()
			--         vim.lsp.buf.signature_help()
			--     end
			-- })
		end
	}
)

------------------------------------------------------------------------------------------
-- Python 配置 (pyright)
------------------------------------------------------------------------------------------
lspconfig.pyright.setup(
	{
		on_attach = function(client, bufnr)
			local opts = {noremap = true, silent = true}
			local keymap = vim.api.nvim_buf_set_keymap
			keymap(bufnr, "n", "gd", "<Cmd>lua vim.lsp.buf.definition()<CR>", opts)
			keymap(bufnr, "n", "K", "<Cmd>lua vim.lsp.buf.hover()<CR>", opts)
			keymap(bufnr, "n", "<leader>rn", "<Cmd>lua vim.lsp.buf.rename()<CR>", opts)
			keymap(bufnr, "n", "<leader>ff", "<Cmd>lua vim.lsp.buf.format()<CR>", opts)
			keymap(bufnr, "n", "<leader>fx", "<Cmd>lua vim.lsp.buf.code_action()<CR>", opts)
		end,
		settings = {
			python = {
				analysis = {
					typeCheckingMode = "default",
					autoSearchPaths = true,
					useLibraryCodeForTypes = true
				}
			}
		}
	}
)

-- 自定义诊断符号
vim.diagnostic.config(
	{
		signs = true,
		virtual_text = {
			prefix = "■",
			source = "always",
			format = function(diagnostic)
				local icons = {
					-- [vim.diagnostic.severity.ERROR] = "❌",
					-- [vim.diagnostic.severity.WARN]  = "⚠️",
					-- [vim.diagnostic.severity.INFO]  = "ℹ️",
					-- [vim.diagnostic.severity.HINT]  = "💡",

					[vim.diagnostic.severity.ERROR] = "⨯",
					[vim.diagnostic.severity.WARN] = "▲",
					[vim.diagnostic.severity.INFO] = "»",
					[vim.diagnostic.severity.HINT] = "➤"
				}
				return icons[diagnostic.severity] .. " " .. diagnostic.message
			end
		},
		update_in_insert = false,
		severity_sort = true,
		float = {
			source = "always"
		},
		signs = {
			text = {
				[vim.diagnostic.severity.ERROR] = "⨯",
				[vim.diagnostic.severity.WARN] = "▲",
				[vim.diagnostic.severity.INFO] = "»",
				[vim.diagnostic.severity.HINT] = "➤"
				-- [vim.diagnostic.severity.ERROR] = "❌",
				-- [vim.diagnostic.severity.WARN]  = "⚠️",
				-- [vim.diagnostic.severity.INFO]  = "ℹ️",
				-- [vim.diagnostic.severity.HINT]  = "💡",
			}
		}
	}
)
------------------------------------------------------------------------------------------
-- 补全配置
------------------------------------------------------------------------------------------
local cmp = require "cmp"
cmp.setup(
	{
		-- snippet = {
		--   -- expand = function(args)
		--     -- require('luasnip').lsp_expand(args.body) -- 使用 LuaSnip 作为代码片段引擎
		--   -- end,
		-- },
		mapping = {
			["<C-n>"] = cmp.mapping.select_next_item({behavior = cmp.SelectBehavior.Insert}), -- 向下选择
			["<C-p>"] = cmp.mapping.select_prev_item({behavior = cmp.SelectBehavior.Insert}), -- 向上选择
			["<Tab>"] = cmp.mapping.select_next_item({behavior = cmp.SelectBehavior.Insert}), -- 向上选择
			["<C-e>"] = cmp.mapping.confirm({select = true}) -- 使用 Tab 键确认补全
		},
		sources = cmp.config.sources(
			{
				{name = "nvim_lsp"}, -- 从 LSP 获取补全项
				-- { name = 'luasnip' },  -- 支持代码片段
				{name = "buffer"}, -- 从当前缓冲区获取补全项
				{name = "path"}
			}
		),
		-- 模仿 VS2022，自动弹出补全列表
		completion = {},
		experimental = {}
	}
)
