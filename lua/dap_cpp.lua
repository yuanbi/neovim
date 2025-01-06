
local dap = require('dap')
local dapui = require('dapui')

require('telescope').load_extension('dap')
require('nvim-dap-virtual-text').setup()

dapui.setup()
vim.cmd("highlight DapBreakpointText guifg=red ctermfg=red")
vim.cmd("highlight DapRunToCusor guifg=blue ctermfg=red")
vim.fn.sign_define('DapBreakpoint', { text = 'BP', texthl = 'DapBreakpointText', linehl = '', numhl = '' })
vim.fn.sign_define('DapStopped', { text = '->', texthl = 'DapRunToCusor', linehl = '', numhl = '' })
vim.g.debuger_short = false

-----------------------------------------------
-- 全局参数
-----------------------------------------------
---
local tmux_split_pty = nil  -- 保存终端的设备ID
local original_K_mapping = nil -- 保存 K 快捷键功能
local debug_args = nil

-----------------------------------------------------------------
-- 配置 GDB 以将输出重定向到新建TMUX终端窗口
-----------------------------------------------------------------


function terminate_tmux_split_and_get_pty()
  if tmux_split_pty == nil then
    return
  end
  local cmd = string.format('tmux list-windows -F "#{window_id}" | while read win_id;'..
      ' do tmux list-panes -t $win_id -F "#{pane_tty} #{pane_id}" | grep "^/dev/pts/";'..
        'done | grep %s | cut -d" " -f2 | xargs -I {} tmux kill-pane -t {};', tmux_split_pty)
  vim.fn.system(cmd)
  tmux_split_pty = nil
end

----------------------------------------------------------------------
-- 水平分屏后切换到右侧 Pane：
-- tmux split-window -h -P -F '#{pane_tty}' \; select-pane -R
--
-- 垂直分屏后切换到下方 Pane：
-- tmux split-window -v -P -F '#{pane_tty}' \; select-pane -D
--
-- 水平分屏后切换到左侧 Pane：
-- tmux split-window -h -P -F '#{pane_tty}' \; select-pane -L
----------------------------------------------------------------------
--
local function create_tmux_split_and_get_pty()
  
  vim.cmd("cclose")
  vim.cmd("TagbarClose")
  vim.cmd("NvimTreeClose")
  terminate_tmux_split_and_get_pty()

  -- 创建一个新的 tmux 分屏，大小为当前窗口的三分之一
  local split_cmd = "tmux split-window -h -p 33 -c '#{pane_current_path}' 'sh'"  -- 水平分屏，使用 -v 垂直分屏
  vim.fn.system(split_cmd)

  -- print('Waitting sh load ...')
  -- vim.fn.system('sleep 3') -- 等待终端启动结束
  -- vim.fn.system('usleep 60000') -- 等待终端启动结束

  -- 获取新分屏的 pty 路径
  local pty_cmd = "tmux display-message -p '#{pane_tty}'; tmux select-pane -R"
  local pty = vim.fn.system(pty_cmd):gsub('\n', '')  -- 去除换行符
  tmux_split_pty = pty
  return pty
end


local function get_debug_option(case)
  if vim.g.build_bin_path == nil or vim.fn.filereadable(vim.g.build_bin_path) == 0 then
      if vim.fn.isdirectory(vim.g.build_dir) == 1 then
        vim.g.build_bin_path = vim.fn.input('Path to executable: ', vim.g.build_dir .. '/', 'file')
      else
        vim.g.build_bin_path = vim.fn.input('Path to executable: ', vim.fn.getcwd() .. '/', 'file')
      end
  elseif debug_args == nil then
    debug_args = vim.fn.input('Debug args: ', '-', 'file')
    -- if #debug_args > 1 then
      -- debug_args = string.sub(debug_args, 2) -- 从第 2 个字符开始截取
    -- end
  end

  if case == nil then
    print('Can not get debug option, case is nil')
  elseif case == 'path' then
    return vim.g.build_bin_path
  elseif case == 'args' then
    -- print(debug_args)
    return {debug_args}
  end
  return nil
end

-----------------------------------------------------------------
-- 调试器配置
-----------------------------------------------------------------
--
-- 配置 CPP 调试
dap.configurations.cpp = {
  {
    name = "Launch",
    type = "gdb",
    request = "launch",
    program = function()
      return get_debug_option('path')
    end,
    args = function()
      return get_debug_option('args')
    end,
    -- args = {'--test-case=dummy'},
    cwd = '${workspaceFolder}',
    stopOnEntry = true,
    externalConsole = true,
    setupCommands = {
      {
        text = '-enable-pretty-printing',
        description = 'enable pretty printing',
        ignoreFailures = false
      },
    },
  }
}

-- 配置 Python 调试
require('dap-python').setup('python3')
dap.configurations.python = {
  {
    type = 'python',
    request = 'launch',
    name = 'Launch file',
    program = '${file}',
    pythonPath = function()
      return 'python3'
    end,
  },
}

-- 配置 pyright
require('lspconfig').pyright.setup({
  on_attach = on_attach,
  settings = {
    python = {
      analysis = {
        autoSearchPaths = true,
        useLibraryCodeForTypes = true,
        typeCheckingMode = "off", -- 关闭类型检查（可选）
      },
    },
  },
})


-----------------------------------------------
-- 函数定义
-----------------------------------------------
---
local function setup_debug_keymaps()
  if vim.g.debuger_short == true then
    return
  else
    vim.g.debuger_short = true
  end
  -- 设置调试快捷键
  original_K_mapping = vim.fn.maparg('K', 'n')
  vim.api.nvim_set_keymap('n', '<F5>', '<cmd>lua require("dap").continue()<CR>', { noremap = true, silent = true })
  vim.api.nvim_set_keymap('n', '<F10>', '<cmd>lua require("dap").step_over()<CR>', { noremap = true, silent = true })
  vim.api.nvim_set_keymap('n', '<F11>', '<cmd>lua require"dap".step_into()<CR>', { noremap = true, silent = true })
  vim.api.nvim_set_keymap('n', 'I', '<cmd>lua require"dapui".eval()<CR>', { noremap = true, silent = true })
end

local function clear_debug_keymaps()
  if vim.g.debuger_short == false then
    return
  else
    vim.g.debuger_short = false
  end
  -- 恢复 K 的原始映射
  -- 删除调试快捷键
  vim.api.nvim_del_keymap('n', '<F5>')
  vim.api.nvim_del_keymap('n', '<F10>')
  vim.api.nvim_del_keymap('n', '<F11>')
  vim.api.nvim_del_keymap('n', 'I')
end

function start_debug_session()

  local pty = create_tmux_split_and_get_pty()

  -- cpp 单独设置配置项
  local filetype = vim.bo.filetype
  if filetype == "c" or filetype == "cpp" then
    require("dapui").setup({
      layouts = {
        {
          elements = {
            { id = "scopes", size = 0.25 },      -- 作用域窗口，占 25% 宽度
            { id = "breakpoints", size = 0.25 }, -- 断点窗口，占 25% 宽度
            { id = "stacks", size = 0.25 },      -- 调用栈窗口，占 25% 宽度
            { id = "watches", size = 0.25 },     -- 监视窗口，占 25% 宽度
          },
          size = 40,                             -- 左侧总宽度为 40 列
          position = "left",                     -- 左侧显示
        },
        {
          elements = {
            { id = "repl", size = 1 },         -- REPL 窗口，占 50% 高度
            -- { id = "console", size = 0.5 },      -- 控制台窗口，占 50% 高度
          },
          size = 10,                             -- 底部总高度为 10 行
          position = "bottom",                   -- 底部显示
        },
      },
    })    -- 在这里添加你的逻辑
    dap.adapters.gdb = {
      id='gdb',
      type = 'executable',
      command = 'gdb',  -- GDB 的可执行文件
      args = { "--interpreter=dap", "--eval-command", "set print pretty on",
        "-tty",  pty },
      -- args = { "--interpreter=dap", "--eval-command", "set print pretty on",
      --   "--eval-command", "set inferior-tty " .. pty },
    }

  end

  require("dap").continue()
end
function start_debug_session_new()
  vim.g.build_bin_path = nil
  debug_args = nil
  start_debug_session()
end

function close_debug_session()
    -- terminate_tmux_split_and_get_pty()
    clear_debug_keymaps()
    -- 获取 dap 和 dapui 模块
    local dap = require('dap')
    local dapui = require('dapui')

    -- 关闭当前 DAP 会话
    if dap.session() then
        dap.terminate()  -- 终止调试会话
        dap.close()      -- 关闭调试器
    end

    -- 关闭 dap-ui 的界面
    dapui.close()
end


-----------------------------------------------
-- 快捷键映射
-----------------------------------------------
--
-- 断点快捷键
vim.api.nvim_set_keymap('n', '<F9>', '<cmd>lua require"dap".toggle_breakpoint()<CR>', { noremap = true, silent = true })
-- 只跳转到下一个错误
vim.api.nvim_set_keymap('n', '<leader>de', '<cmd>lua vim.diagnostic.goto_next({ severity = vim.diagnostic.severity.ERROR })<CR>', { noremap = true, silent = true })
-- 只跳转到上一个错误
vim.api.nvim_set_keymap('n', '<leader>dE', '<cmd>lua vim.diagnostic.goto_prev({ severity = vim.diagnostic.severity.ERROR })<CR>', { noremap = true, silent = true })
-- 只跳转到下一个错误
vim.api.nvim_set_keymap('n', '<leader>dd', '<cmd>lua vim.diagnostic.goto_next({ severity = vim.diagnostic.severity.WARN })<CR>', { noremap = true, silent = true })
-- 只跳转到上一个错误
vim.api.nvim_set_keymap('n', '<leader>dD', '<cmd>lua vim.diagnostic.goto_prev({ severity = vim.diagnostic.severity.WARN })<CR>', { noremap = true, silent = true })

vim.api.nvim_set_keymap('n', '<leader>dr', '<cmd>lua start_debug_session()<CR>', { noremap = true, silent = true })  -- 启动调试器
vim.api.nvim_set_keymap('n', '<leader>dR', '<cmd>lua start_debug_session_new()<CR>', { noremap = true, silent = true }) -- 启动调试器，重新输入被调试程序的路径
vim.api.nvim_set_keymap('n', '<leader>dk', '<cmd>lua close_debug_session()<CR>', { noremap = true, silent = true }) -- 杀死调试器
vim.api.nvim_set_keymap('n', '<leader>db', ':Telescope dap list_breakpoints<CR>', { noremap = true, silent = true }) -- 断点列表
vim.api.nvim_set_keymap('n', '<leader>dc', ':Telescope dap commands<CR>', { noremap = true, silent = true }) -- DAP 命令列表
vim.api.nvim_set_keymap('n', '<leader>dq', '<cmd>lua terminate_tmux_split_and_get_pty()<CR>', { noremap = true, silent = true }) -- DAP 命令列表

-----------------------------------------------
-- 调试器事件监听
-----------------------------------------------
---
-- 监听调试器启动事件
dap.listeners.after.event_initialized['dapui_config'] = function()
  setup_debug_keymaps()  -- 设置快捷键
  dapui.open()           -- 打开 dapui
end

-- 监听调试器终止事件
dap.listeners.before.event_terminated['dapui_config'] = function()
  close_debug_session()
end

-- 监听调试器退出事件
dap.listeners.before.event_exited['dapui_config'] = function()
  close_debug_session()
end
