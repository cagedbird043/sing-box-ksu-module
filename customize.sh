#!/system/bin/sh
# Mice System Tools - Intelligent Installer

WORKSPACE="/data/adb/sing-box-workspace"

ui_print "--------------------------------------"
ui_print "    Mice Sing-box System Integration  "
ui_print "--------------------------------------"

# 1. 执行热停机 (内联逻辑，拒绝调用外部脚本以防自杀)
ui_print "- 正在执行服务停机..."
# 精准匹配二进制路径，防止误杀安装器
pkill -9 -f "$WORKSPACE/bin/sing-box" >/dev/null 2>&1 || true
# 精准匹配服务脚本路径
pkill -9 -f "modules/sing-box-ksu-module/service.sh" >/dev/null 2>&1 || true

# 2. 物理地基翻新
ui_print "- 正在部署 Unix-like 工作空间..."
mkdir -p $WORKSPACE/bin $WORKSPACE/etc $WORKSPACE/var/lib $WORKSPACE/var/run $WORKSPACE/var/log

# 对齐部署
cp -f $MODPATH/bin/sing-box $WORKSPACE/bin/
cp -f $MODPATH/bin/envsubst $WORKSPACE/bin/
cp -f $MODPATH/bin/sbc $WORKSPACE/bin/
cp -f $MODPATH/config.template.json $WORKSPACE/

chmod -R 755 $WORKSPACE/bin/
chmod 644 $WORKSPACE/config.template.json

# 3. 凭证初始化
if [ ! -f "$WORKSPACE/.env" ]; then
    ui_print "- 初始化 .env 凭证模板..."
    cp -f $MODPATH/.env.example $WORKSPACE/.env
    chmod 600 $WORKSPACE/.env
    
    ui_print " "
    ui_print "📌 首次安装必读:"
    ui_print "   1. 请使用 MT 管理器编辑: $WORKSPACE/.env"
    ui_print "   2. 填入 SUB_URL_1 等变量"
    ui_print "   3. 保存后执行: su -c sbc restart"
    ui_print " "
fi

# 4. 热启动
ui_print "- 正在重新拉起守护进程..."
# 使用 nohup 确保安装脚本退出后服务不被杀
nohup sh $MODPATH/service.sh >/dev/null 2>&1 &

ui_print "--------------------------------------"
ui_print " ✅ 热更新成功！请重启以应用全局软链。"
ui_print "--------------------------------------"