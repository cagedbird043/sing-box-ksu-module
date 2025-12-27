#!/system/bin/sh
# Mice System Tools - Workspace Builder

WORKSPACE="/data/adb/sing-box-workspace"

ui_print "--------------------------------------"
ui_print "    Mice Sing-box Workspace Builder   "
ui_print "--------------------------------------"

# 1. 创建符合 FHS 规范的目录架构
ui_print "- 正在初始化工作空间目录..."
mkdir -p $WORKSPACE/bin
mkdir -p $WORKSPACE/etc
mkdir -p $WORKSPACE/var/lib
mkdir -p $WORKSPACE/var/run
mkdir -p $WORKSPACE/var/log

ui_print "- 正在自动部署组件..."

# 2. 部署核心组件
cp -f $MODPATH/bin/sing-box $WORKSPACE/bin/
chmod 755 $WORKSPACE/bin/sing-box

ui_print "- 部署 envsubst 渲染引擎..."
cp -f $MODPATH/system/bin/envsubst $WORKSPACE/bin/
chmod 755 $WORKSPACE/bin/envsubst

ui_print "- 部署 sbc 控制脚本..."
cp -f $MODPATH/system/bin/sbc $WORKSPACE/bin/
chmod 755 $WORKSPACE/bin/sbc

cp -f $MODPATH/etc/config.template.json $WORKSPACE/etc/
chmod 644 $WORKSPACE/etc/config.template.json

# 3. 核心改革：智能凭证初始化
if [ ! -f "$WORKSPACE/.env" ]; then
    ui_print "- 正在初始化凭证文件 .env ..."
    # 直接把示例文件考成正式文件，省去用户手动操作
    cp -f $MODPATH/.env.example $WORKSPACE/.env
    chmod 600 $WORKSPACE/.env
    ui_print "   [OK] 已为您自动创建 $WORKSPACE/.env"
else
    ui_print "- 发现已存在的 .env 凭证，保留用户原始配置。"
fi

# 另外保留一份 example 备查
cp -f $MODPATH/.env.example $WORKSPACE/.env.example

# 4. 安全审计与指引
ui_print " "
ui_print "📌 后续操作指引:"
ui_print "   请使用 MT 管理器编辑: $WORKSPACE/.env"
ui_print "   填入 SUB_URL_1 等变量后，执行 su -c sbc restart"
ui_print "--------------------------------------"