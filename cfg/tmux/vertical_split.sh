# tmux新开pane时，保留原来的conda环境, 以及pwd



# wf_conda=$CONDA_DEFAULT_ENV
#
# # Before being executed, shell-command is expanded
# tmux run-shell 'echo wf_conda:  $wf_conda'  # 一直是空白
# tmux run-shell 'echo CONDA_DEFAULT_ENV:  $CONDA_DEFAULT_ENV'  # 一直是空白

# tmux run-shell 'echo $CONDA_DEFAULT_ENV > ~/.t/conda_env_name_wf' Enter
tmux split-window -h -p 50  -c '#{pane_current_path}'
#                    # -p percent,
tmux send-keys  ' conda activate `cat ~/.t/conda_name` ' Enter
#                                             # Enter加不加引号都行
# tmux send-keys  "clear && figlet Welcome" 'Enter'


# 在tmux看来, $CONDA_DEFAULT_ENV"是 进入tmux时所在的环境
# 在zsh里敲, $CONDA_DEFAULT_ENV 则是当前所在conda环境
# 失败:
    # 1.
    # tmux send-keys  "conda activate ${CONDA_DEFAULT_ENV}" Enter
    # 2.
    # tmux run-shell 'export my_conda=${CONDA_DEFAULT_ENV}'
    # tmux send-keys  "conda activate ${my_conda}" Enter
