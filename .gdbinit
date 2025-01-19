
define hook-run
	b abort
	catch throw
	catch catch

	# SIGINT	中断信号（通常由 Ctrl+C 触发）。在调试时，你可能希望忽略它以避免意外中断。
	# SIGTERM	终止信号（通常由 kill 命令触发）。在调试时，通常不需要捕获它。
	# SIGCHLD	子进程状态改变信号。通常由子进程退出触发，调试时通常可以忽略。
	# SIGWINCH	窗口大小改变信号。通常由终端调整大小触发，调试时通常可以忽略。
	# SIGALRM	定时器信号。通常由定时器触发，调试时通常可以忽略。

	handle all stop print
	handle SIGABRT stop print

	handle SIGINT nostop noprint pass
	handle SIGTERM nostop noprint pass
	handle SIGCHLD nostop noprint pass
	handle SIGWINCH nostop noprint pass
	handle SIGALRM nostop noprint pass
	echo "Catchpoints set for throw exceptions.\n"
end

define hook-stop
# 检查是否是因为信号中断
	if $_siginfo.si_signo != 0
		printf "Signal received: %s\n", $_siginfo.si_signo
		printf "Fault address: 0x%lx\n", $_siginfo._sifields._sigfault.si_addr
	end

# 检查是否是因为捕获异常
	if $_exception != 0
		printf "Exception caught: %s\n", $_exception.what
	end
end


echo "Gdbinit loaded."
