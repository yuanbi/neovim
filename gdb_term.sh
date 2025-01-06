#!/bin/bash

# 创建 Tmux 分屏并获取终端设备路径
PTS_PATH=$(tmux split-window -v -P -F '#{pane_tty}')

if [ -z "$PTS_PATH" ]; then
  echo "Failed to create tmux pane or get its TTY path."
  exit 1
fi

# 输出获取的终端路径供调试验证
echo "Redirecting program I/O to: $PTS_PATH"

# 启动 GDB，并将被调试程序的 I/O 重定向到新终端
gdb --eval-command="set inferior-tty $PTS_PATH" "$@"

