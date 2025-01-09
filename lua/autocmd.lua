--vim.lsp.get_active_clients() local myAutoGroup = vim.api.nvim_create_augroup("myAutoGroup", {
  -- clear = true,
-- })

local autocmd = vim.api.nvim_create_autocmd
local vim = vim


-- 加载 Fterm
local fterm = require('FTerm')

function build_project(compile_command)

    local cmd = ''
    -- 获取当前缓冲区的 LSP 客户端
    local clients = vim.lsp.get_active_clients()
    if #clients == 0 then
        print("No LSP client attached.")
        return
    end

    local wsdir = vim.g.workspace_dir2()
    local cmake_lists_path = wsdir .. "/CMakeLists.txt"
    local makefile_path = wsdir .. "/Makefile"
    local current_file = vim.fn.expand("%:p") -- 获取当前文件的完整路径
    local file_extension = vim.fn.expand("%:e") -- 获取当前文件的扩展名
    local build_makefile_path = wsdir .. '/build/Makefile'

    local build_dir = wsdir .. "/build"

    if vim.fn.isdirectory(build_dir) == 1 and vim.fn.filereadable(build_makefile_path) == 1 and compile_command == true then
        cmd = "cd " .. build_dir .. "&& make"
        vim.cmd("AsyncRun " .. cmd)
    elseif vim.fn.filereadable(cmake_lists_path) == 1 then
        -- 如果 CMakeLists.txt 存在
        print("CMakeLists.txt found.")

        -- 检查 build 目录是否存在，如果不存在则创建
        local build_dir = wsdir .. "/build"
        if vim.fn.isdirectory(build_dir) == 0 then
            vim.fn.mkdir(build_dir, "p")
            print("Created build directory: " .. build_dir)
        end

        local cmake_pam = '-DCMAKE_C_COMPILER=clang -DCMAKE_CXX_COMPILER=clang++ -DCMAKE_BUILD_TYPE=Debug -DCMAKE_C_FLAGS="${CMAKE_C_FLAGS} -g -gdwarf-4" -DCMAKE_CXX_FLAGS="${CMAKE_CXX_FLAGS} -g -gdwarf-4"'
        -- 在 Fterm 中执行 cmake 命令
        cmd = "cd " .. build_dir .. " && cmake -DCMAKE_EXPORT_COMPILE_COMMANDS=ON .."
        if compile_command == true then
          cmd = "cd " .. build_dir .. " && cmake " .. cmake_pam .. " -DCMAKE_EXPORT_COMPILE_COMMANDS=ON .. && make"
          -- fterm.run(cmd)
          vim.cmd("AsyncRun " .. cmd)
        else
          cmd = "cd " .. build_dir .. " && cmake " .. cmake_pam .. " -DCMAKE_EXPORT_COMPILE_COMMANDS=ON .."
          vim.cmd("AsyncRun " .. cmd)
        end

        -- 将生成的可执行文件目录保存到全局变量中
        vim.g.build_dir = build_dir
        print("CMake build directory saved to global variable: " .. vim.g.build_dir)

    elseif vim.fn.filereadable(makefile_path) == 1 then
        -- 如果 Makefile 存在
        print("Makefile found.")

        -- 在 Fterm 中执行 make 命令
        if compile_command == true then
          cmd = "cd " .. wsdir .. " && bear --append -o compile_commands.json make"
          vim.cmd("AsyncRun " .. cmd)
        else
          cmd = "cd " .. wsdir .. " && make"
          -- fterm.run(cmd)
          vim.cmd("AsyncRun " .. cmd)
        end

        -- 将生成的可执行文件目录保存到全局变量中
        vim.g.build_dir = wsdir
        print("Make build directory saved to global variable: " .. vim.g.build_dir)

    else
        -- 如果既没有 CMakeLists.txt 也没有 Makefile
        print("No CMakeLists.txt or Makefile found. Compiling directly.")

        -- 根据文件类型选择编译器
        local compiler = ""
        local output_file = wsdir .. "/main"
        if file_extension == "cpp" then
            compiler = "g++"
        elseif file_extension == "c" then
            compiler = "gcc"
        else
            print("Unsupported file type. Only .c and .cpp files are supported.")
            return
        end

        -- 在 Fterm 中执行编译命令
        local cmd = compiler .. " " .. current_file .. " -o " .. output_file
        fterm.run(cmd)

        -- 将生成的可执行文件目录保存到全局变量中
        vim.g.build_dir = wsdir
        print("Build directory saved to global variable: " .. vim.g.build_dir)
    end
end

function build_project_bin()
  build_project(true)
end

function build_project_sym()
  build_project(false)
end

vim.api.nvim_create_autocmd('BufEnter', { -- 自动添加工作区
  pattern = '*.cpp,*.h,*.py,CMakeLists.txt', 
  callback = function()
    -- vim.lsp.buf.add_workspace_folder(vim.fn.getcwd())  -- 添加工作区目录
  end,
})

-- CPP 文件启用:
--  调试
--  构建
vim.api.nvim_create_autocmd("BufEnter", {
    pattern = { "*.h", "*.hpp", "*.cxx", "*.c", "*.cpp" }, -- 匹配的文件类型
    callback = function()
        vim.keymap.set("n", "<leader>wbd", build_project_bin, { noremap = true, silent = true, buffer = true })
        vim.keymap.set("n", "<leader>wbg", build_project_sym, { noremap = true, silent = true, buffer = true })
        require('dap_cpp')
    end,
})

-- PY 文件启用调试功能，AI功能
vim.api.nvim_create_autocmd("BufEnter", {
    pattern = { "*.py" }, -- 匹配的文件类型
    callback = function()
        require('dap_cpp')
    end,
})


-- 在 Vim 启动时执行 generate_ctags 函数
vim.cmd([[
augroup GenerateCtags
    autocmd!
    autocmd VimEnter * lua vim.g.generate_ctags.get()
augroup END
]])

-- 当只剩下 NvimTree 窗口时，自动退出
vim.cmd([[
  augroup NvimTreeWindowSize
    autocmd!
    autocmd WinEnter * if winnr('$') == 1 && &filetype == 'NvimTree' | quit | endif
  augroup END
]])
