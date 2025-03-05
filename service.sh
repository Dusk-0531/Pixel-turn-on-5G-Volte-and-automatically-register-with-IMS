#!/system/bin/sh
# 等待系统完全启动
until [ "$(getprop sys.boot_completed)" = "1" ]; do
    sleep 1
done

# 日志文件路径
LOG_FILE="data/media/0/Androidlog.txt"
mkdir -p "/data/media/0/Android" 2>/dev/null

# 记录脚本开始
echo "$(date): Script started" >> "$LOG_FILE"

# 获取并清理运营商代码（只取第一个五位数）
RAW_OPERATOR=$(getprop gsm.operator.numeric)
OPERATOR=$(echo "$RAW_OPERATOR" | cut -d',' -f1 | tr -d '() ')
echo "$(date): Raw operator value: $RAW_OPERATOR" >> "$LOG_FILE"
echo "$(date): Cleaned operator value: $OPERATOR" >> "$LOG_FILE"

# 延迟 10 秒，确保系统稳定
sleep 10
echo "$(date): Waited 10 seconds for system stability" >> "$LOG_FILE"

# 统一设置 VoLTE、VoNR、WFC 等属性
echo "$(date): Applying VoLTE, VoNR, and WFC settings" >> "$LOG_FILE"
setprop persist.dbg.ims_volte_enable 1
setprop persist.dbg.vt_avail_ovr 1
setprop persist.radio.nr.volte 1
setprop persist.radio.volte_enabled 1
setprop persist.radio.imsregistered 1
setprop persist.dbg.allow_ims_off 0
setprop persist.vendor.radio.vonr_enabled 1
setprop persist.vendor.radio.vonr_enabled_0 1
setprop persist.vendor.radio.vonr_enabled_1 1
setprop persist.radio.data_ltd_sys_ind 1
setprop persist.sys.cust.lte_config true
setprop persist.radio.user.edit.apn 1
setprop persist.dbg.allow_apn_edit 1
setprop persist.dbg.wfc_avail_ovr 1
setprop persist.data.iwlan.enable true
setprop persist.data.iwlan 1
echo "$(date): VoLTE, VoNR, and WFC properties set" >> "$LOG_FILE"

# 重启 IMS 服务和 RIL 守护进程
setprop ctl.restart vendor.imsd
echo "$(date): Restarted IMS service (vendor.imsd)" >> "$LOG_FILE"

setprop ctl.restart ril-daemon
echo "$(date): Restarted ril-daemon" >> "$LOG_FILE"

# 延迟 10 秒，确保 IMS 注册完成
sleep 10
echo "$(date): Waited 10 seconds for IMS registration" >> "$LOG_FILE"

# 检查 IMS 状态
IMS_STATUS=$(dumpsys telephony.registry | grep -i "ims" | grep -E "true|1")
if [ -n "$IMS_STATUS" ]; then
    echo "$(date): IMS is registered" >> "$LOG_FILE"
else
    echo "$(date): IMS is NOT registered" >> "$LOG_FILE"
fi

# 记录脚本结束
echo "$(date): Script finished" >> "$LOG_FILE"