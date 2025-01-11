-- 这部分帮助你在自动下载所需的packers.nvim文件
-- local fn = vim.fn
-- local install_path = fn.stdpath('data')..'/site/pack/packer/start/packer.nvim'
-- if fn.empty(fn.glob(install_path)) > 0 then
--   packer_bootstrap = fn.system({'git', 'clone', '--depth', '1', 'https://github.com/wbthomason/packer.nvim', install_path})
-- end

local programming_filetypes = {
  "c", "cpp", "java", "python", "javascript", "typescript", "lua", "rust", "go", "ruby", "php", 
  "html", "css", "scss", "json", "yaml", "toml", "bash", "sh", "zsh", "fish", "vim", "markdown", 
  "tex", "sql", "dockerfile", "make", "cmake", "perl", "r", "swift", "kotlin", "scala", "haskell", 
  "ocaml", "elixir", "erlang", "clojure", "fsharp", "dart", "groovy", "puppet", "terraform", 
  "proto", "thrift", "graphql", "vue", "svelte"
}


return{

  {
    "andymass/vim-matchup", -- 高亮匹配
  },

  {
    "yamatsum/nvim-cursorline", -- 高亮光标下内容和行
    config = function()
      require("nvim-cursorline").setup({
        cursorline = {
          enable = false,
          timeout = 240,
          number = false,
        },
        cursorword = {
          enable = true,
          min_length = 3,
          hl = { underline = true },
        },
      })
    end,
  },

  {
    "jiangmiao/auto-pairs", -- 自动括号
  },

  {
    -- "ellisonleao/gruvbox.nvim", -- Gruvbox 主题
    -- dependencies = { "rktjmp/lush.nvim" },

    -- config = function()
    --     vim.schedule(function()vim.cmd("colorscheme gruvbox")end)
    -- end,
  },

  {
    "nvim-lualine/lualine.nvim", -- 状态栏
    dependencies = { "kyazdani42/nvim-web-devicons", opt = true },
    -- lazy = true,
  },

  {
    "kyazdani42/nvim-web-devicons", -- 图标支持
  },

  {
    "tpope/vim-sensible", -- 提供一些合理的默认设置
  },

  {
    "nvimdev/dashboard-nvim", -- 启动面板
    event = "VimEnter",
    config = function()
      require("dashboard").setup({})
    end,
    dependencies = { "nvim-tree/nvim-web-devicons" },
  },
    {
        'stevearc/aerial.nvim', -- 类窗口
    },

  {
    "inkarkat/vim-mark", -- 高亮
  },

  {
    "inkarkat/vim-ingo-library", -- 通用函数库
  },

  {
    "numToStr/Comment.nvim", -- 注释插件
  },

  {
    "MattesGroeger/vim-bookmarks", -- 书签
  },

  {
    "skywind3000/asyncrun.vim", -- 异步执行命令插件
  },

  {
    "morhetz/gruvbox", -- 主题
    config = function()
        vim.schedule(function()vim.cmd("colorscheme gruvbox")end)
    end,
  },

  -- {
  --   "tmhedberg/SimpylFold", -- 代码折叠
  --   ft = { "python" },
  -- },

  {
    "akinsho/bufferline.nvim", -- 缓冲区标签栏
    config = function()
      require("bufferline").setup({
        options = {
          separator_style = "slant",  -- 使用 slant 样式
        },
      })
    end,
  },

  {
    "nvim-treesitter/nvim-treesitter", -- 语法高亮
    run = function()
      require("nvim-treesitter.install").update({ with_sync = true })
    end,
  },

  {
    "numToStr/FTerm.nvim", -- 弹出式终端
  },

  {
    "sindrets/diffview.nvim", -- GIT DIFF MERGE WINDOW
  },

  {
    "tpope/vim-fugitive", -- Git 插件 :G status<CR> :G ..<CR>
  },

  {
    "lewis6991/gitsigns.nvim", -- 侧边栏显示 Git 状态
    config = function()
      require("gitsigns").setup()
    end,
  },

  {
    "lukas-reineke/indent-blankline.nvim", -- 缩进线
    event = "BufRead",
    config = function()
      require("ibl").setup()
    end,
  },

  {
    "nvim-tree/nvim-tree.lua", -- 文件浏览器
  },

  -- LSP 和补全
  {
    "neovim/nvim-lspconfig", -- LSP 配置
  },

  {
    "hrsh7th/nvim-cmp", -- 补全引擎
  },

  {
    "hrsh7th/cmp-nvim-lsp", -- LSP 补全源
  },

  {
    "hrsh7th/cmp-buffer", -- 缓冲区补全源
  },

  {
    "hrsh7th/cmp-path", -- 文件路径补全
  },

  {
    "L3MON4D3/LuaSnip", -- 代码片段引擎
  },

  {
    "jose-elias-alvarez/null-ls.nvim", -- 代码格式化插件
  },

  -- 安装 Telescope 插件
  {
    "nvim-telescope/telescope.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
      {
        "nvim-telescope/telescope-fzf-native.nvim", -- 提供更快的模糊查找
        build = "make", -- 需要编译
      },
      {
        "nvim-telescope/telescope-file-browser.nvim", -- 文件浏览器
      },
      {
        "nvim-telescope/telescope-live-grep-args.nvim", -- 增强 live_grep
      },
      {
        "nvim-telescope/telescope-ui-select.nvim", -- 增强 UI 选择
      },
    },
  },

  -- 调试插件
  {
    "mfussenegger/nvim-dap",
    event = { "BufRead", "BufNewFile" },
    ft = programming_filetypes,
    dependencies = {
      "nvim-neotest/nvim-nio",
      "rcarriga/nvim-dap-ui",
      "theHamsta/nvim-dap-virtual-text",
      "mfussenegger/nvim-dap-python",
      "nvim-telescope/telescope-dap.nvim",
    },
  },

  -- CMAKE 插件
  {
    "Civitasv/cmake-tools.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim", -- 依赖插件
      "mfussenegger/nvim-dap", -- 调试支持
    },
  },

  -- 会话保存与恢复
  {
    "Shatur/neovim-session-manager",
    dependencies = { "nvim-lua/plenary.nvim" },
  },

  ------------------------------------------
  ----     avante AI                    ----
  ------------------------------------------
  {
    "yetone/avante.nvim",
    event = { "BufRead", "BufNewFile" },
    ft = programming_filetypes,
    config = function()
      require("avante_cfg")
    end,
    build = "make", -- if you want to build from source then do `make BUILD_FROM_SOURCE=true`
    -- run = "powershell -ExecutionPolicy Bypass -File Build.ps1 -BuildFromSource false" -- for windows
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
      "stevearc/dressing.nvim",
      "nvim-lua/plenary.nvim",
      "MunifTanjim/nui.nvim",
      --- The below dependencies are optional,
      "nvim-tree/nvim-web-devicons", -- or echasnovski/mini.icons
      -- "zbirenbaum/copilot.lua", -- for providers='copilot'
      -- {
      --   -- support for image pasting
      --   "HakonHarnes/img-clip.nvim",
      --   event = "BufRead",
      --   config = function()
      --     require("img-clip").setup({
      --       -- recommended settings
      --       default = {
      --         embed_image_as_base64 = false,
      --         prompt_for_file_name = false,
      --         drag_and_drop = {
      --           insert_mode = true,
      --         },
      --         -- required for Windows users
      --         use_absolute_path = true,
      --       },
      --     })
      --   end,
      -- },
      -- {
      --   -- Make sure to set this up properly if you have lazy=true
      {
        "MeanderingProgrammer/render-markdown.nvim",
        config = function()
          require("render-markdown").setup({
            file_types = { "markdown", "Avante" },
          })
        end,
        ft = { "markdown", "Avante" },
      },
    },
  },

  ------------------------------------------
  ----     avante AI END                ----
  ------------------------------------------
  -- install = { colorscheme = { "gruvbox" } },
}

