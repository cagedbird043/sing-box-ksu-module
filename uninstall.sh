#!/system/bin/sh

# 定义工作区
WORKSPACE="/data/adb/sing-box-workspace"

# 1. 优雅停止可能还在运行的残留进程
pkill -15 -f "$WORKSPACE/bin/sing-box" >/dev/null 2>&1

# 2. 暴力清场：删除整个工作空间（含 bin, etc, var, .env）
if [ -d "$WORKSPACE" ]; then
    rm -rf "$WORKSPACE"
fi

# 3. 同样的，/system/bin/ 下的软链会随模块卸载自动消失

exit 0
