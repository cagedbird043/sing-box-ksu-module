#!/system/bin/sh
# Mice System Tools - Intelligent Installer

WORKSPACE="/data/adb/sing-box-workspace"

ui_print "--------------------------------------"
ui_print "    Mice Sing-box System Integration  "
ui_print "--------------------------------------"

# 1. 物理地基翻新
mkdir -p $WORKSPACE/bin $WORKSPACE/etc $WORKSPACE/var/lib $WORKSPACE/var/run $WORKSPACE/var/log

# 2. 执行热停机
if [ -x "$WORKSPACE/bin/sbc" ]; then
    ui_print "- 正在执行服务停机..."
    "$WORKSPACE/bin/sbc" stop >/dev/null 2>&1
fi

ui_print "- 正在物理同步核心组件到 Workspace..."

# 3. 部署文件
cp -f $MODPATH/bin/sing-box $WORKSPACE/bin/
cp -f $MODPATH/bin/envsubst $WORKSPACE/bin/
cp -f $MODPATH/bin/sbc $WORKSPACE/bin/
cp -f $MODPATH/config.template.json $WORKSPACE/

chmod -R 755 $WORKSPACE/bin/
chmod 644 $WORKSPACE/config.template.json

# 4. 凭证初始化
if [ ! -f "$WORKSPACE/.env" ]; then
    ui_print "- 初始化 .env 凭证模板..."
    cp -f $MODPATH/.env.example $WORKSPACE/.env
    chmod 600 $WORKSPACE/.env
    
    # 首次安装强提醒
    ui_print " "
    ui_print "📌 首次安装必读:"
    ui_print "   1. 请使用 MT 管理器编辑: $WORKSPACE/.env"
    ui_print "   2. 填入 SUB_URL_1 等变量"
    ui_print "   3. 保存后执行: su -c sbc restart"
    ui_print " "
fi

# 5. 热启动
ui_print "- 正在重新拉起守护进程 (无需重启)..."
sh $MODPATH/service.sh >/dev/null 2>&1 &

ui_print "--------------------------------------"
ui_print " ✅ 模块更新完毕，服务已重载。"
ui_print "--------------------------------------"