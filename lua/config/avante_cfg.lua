vim.api.nvim_set_hl(0, "AvanteDiffText", {fg = "#000000", bg = "#384752"}) -- 白色文字，红色背景
vim.api.nvim_set_hl(0, "AvanteDiffAdd", {fg = "#000000", bg = "#3d4745"}) -- 黑色文字，绿色背景

return require("avante").setup(
	{
		provider = "geminix",
		auto_suggestions_provider = "copilot", -- Since auto-suggestions are a high-frequency operation and therefore expensive, it is recommended to specify an inexpensive provider or even a free provider: copilot
		web_search_engine = {
			provider = "tavily",
			api_key_name = "TAVILY",
			provider_opts = {
				time_range = "m",
				include_answer = "basic"
			}
		},
		copilot = {
			-- endpoint = "https://api.githubcopilot.com",
			-- model = "gpt-4o-2024-08-06",
			proxy = 'http://127.0.0.1:10808', -- [protocol://]host[:port] Use this proxy
			allow_insecure = false, -- Allow insecure server connections
			timeout = 3000, -- Timeout in milliseconds
			temperature = 0,
			max_tokens = 4096,
		},
		-- openai = {
		-- 	endpoint = "",
		-- 	model = "",
		-- 	timeout = 3000, -- Timeout in milliseconds
		-- 	temperature = 0,
		-- 	max_tokens = 4096
		-- },
		vendors = {
			["geminix"] = {
				__inherited_from = "gemini",
				model = "gemini-2.0-flash",
				api_key_name = "GEMINI_API_KEY",
				proxy = 'http://127.0.0.1:10808',
			},
			["nvidia"] = {
				__inherited_from = "openai",
				endpoint = "https://integrate.api.nvidia.com/v1",
				model = "deepseek-ai/deepseek-r1",
				api_key_name = "GTX",
				-- disable_tools = true,
				-- proxy = 'http://127.0.0.1:10808',
				timeout = 3000, -- Timeout in milliseconds
				temperature = 0,
				max_tokens = 4096
			},
			["qwen"] = {
				__inherited_from = "openai",
				model = "qwen",
				endpoint = "http://192.168.0.101:8000/v1",
				api_key_name = "ORG",
				timeout = 3000, -- Timeout in milliseconds
				temperature = 0,
				max_tokens = 4096
			},
			["sil_deepseek"] = {
				__inherited_from = "openai",
				endpoint = "https://api.siliconflow.cn/v1",
				model = "deepseek-ai/DeepSeek-V3",
				api_key_name = "SILICONFLOW_DSK",
				timeout = 3000, -- Timeout in milliseconds
				temperature = 0,
				max_tokens = 4096
			},
			["hw_deepseek"] = {
				__inherited_from = "openai",
				endpoint = "https://infer-modelarts-cn-southwest-2.modelarts-infer.com/v1/infers/f354eacc-a2c5-43b4-a785-e5aadca988b3/v1",
				model = "DeepSeek-V3",
				api_key_name = "HUAWEI_CLOUD_API",
				timeout = 3000, -- Timeout in milliseconds
				temperature = 0,
				max_tokens = 4096
			},
			["gemini"] = {
				__inherited_from = "openai",
				endpoint = "https://api.deepseek.com/v1",
				model = "deepseek-chat",
				api_key_name = "DSK",
				timeout = 3000, -- Timeout in milliseconds
				temperature = 0,
				max_tokens = 4096
			},
			["deepseek"] = {
				__inherited_from = "openai",
				endpoint = "https://api.deepseek.com/v1",
				model = "deepseek-chat",
				api_key_name = "DSK",
				timeout = 3000, -- Timeout in milliseconds
				temperature = 0,
				max_tokens = 4096
			}
		},
		behaviour = {
			auto_suggestions = false, -- Experimental stage
			auto_set_highlight_group = true,
			auto_set_keymaps = true,
			auto_apply_diff_after_generation = false,
			support_paste_from_clipboard = false,
			minimize_diff = true -- Whether to remove unchanged lines when applying a code block
		},
		mappings = {
			--- @class AvanteConflictMappings
			diff = {
				ours = "co",
				theirs = "ct",
				all_theirs = "ca",
				both = "cb",
				cursor = "cc",
				next = "]x",
				prev = "[x"
			},
			suggestion = {
				accept = "<M-l>",
				next = "<M-]>",
				prev = "<M-[>",
				dismiss = "<C-]>"
			},
			jump = {
				next = "]]",
				prev = "[["
			},
			submit = {
				normal = "<CR>",
				insert = "<C-s>"
			},
			sidebar = {
				apply_all = "A",
				apply_cursor = "a",
				switch_windows = "<Tab>",
				reverse_switch_windows = "<S-Tab>"
			},
			ask = "<leader>aa",
			edit = "<leader>ae",
			refresh = "<leader>ar",
			focus = "<leader>af",
			toggle = {
				default = "<leader>aa",
				debug = "<nop>",
				hint = "<leader>ah",
				suggestion = "<leader>as",
				repomap = "<nop>"
			},
			files = {
				add_current = "<leader>ac", -- Add current buffer to selected files
			},
		},
		hints = {enabled = true},
		windows = {
			---@type "right" | "left" | "top" | "bottom"
			position = "right", -- the position of the sidebar
			wrap = true, -- similar to vim.o.wrap
			width = 30, -- default % based on available width
			sidebar_header = {
				enabled = true, -- true, false to enable/disable the header
				align = "center", -- left, center, right for title
				rounded = true
			},
			input = {
				prefix = "> ",
				height = 8 -- Height of the input window in vertical layout
			},
			edit = {
				border = "rounded",
				start_insert = true -- Start insert mode when opening the edit window
			},
			ask = {
				floating = false, -- Open the 'AvanteAsk' prompt in a floating window
				start_insert = true, -- Start insert mode when opening the ask window
				border = "rounded",
				---@type "ours" | "theirs"
				focus_on_apply = "ours" -- which diff to focus after applying
			}
		},
		highlights = {
			---@type AvanteConflictHighlights
			diff = {
				current = "AvanteDiffText",
				incoming = "AvanteDiffAdd"
			}
		},
		--- @class AvanteConflictUserConfig
		diff = {
			autojump = true,
			---@type string | fun(): any
			list_opener = "copen",
			--- Override the 'timeoutlen' setting while hovering over a diff (see :help timeoutlen).
			--- Helps to avoid entering operator-pending mode with diff mappings starting with `c`.
			--- Disable by setting to -1.
			override_timeoutlen = 500
		}
	}
)
