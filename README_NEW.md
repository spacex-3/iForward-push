# iForward-PushPlus

[![Build Status](https://github.com/yourusername/iForward-push/actions/workflows/build.yml/badge.svg)](https://github.com/yourusername/iForward-push/actions)
[![License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)
[![iOS](https://img.shields.io/badge/iOS-14.0%2B-green.svg)](https://www.apple.com/ios/)

> 🔔 Forward SMS, iMessages, calls, and voicemails from your jailbroken iPhone to [PushPlus](https://www.pushplus.plus) notification service.

一个 iOS 越狱插件，用于将短信、iMessage、来电和语音邮件转发到 PushPlus 推送服务。支持双卡识别，适配 iOS 14.3。

[English](#english) | [中文](#chinese)

---

<a name="chinese"></a>

## ✨ 功能特性

- 📱 **短信/iMessage 转发** - 自动转发接收和发送的短信
- 📞 **来电通知** - 实时推送来电和去电记录（含通话时长）
- 🎤 **语音邮件提醒** - 新语音邮件即时通知
- 📡 **双卡支持** - 显示 Account ID 和 Service 类型，区分不同 SIM 卡
- 👤 **联系人识别** - 自动从通讯录匹配联系人姓名
- ⚙️ **灵活配置** - 可单独启用/禁用各类通知
- 🔄 **后台运行** - 通过 LaunchDaemon 持续监控，无需手动启动
- 🚀 **轻量高效** - 每 160 秒检查一次，低功耗运行

## 📋 系统要求

- iOS 14.0 或更高版本（已在 iOS 14.3 测试）
- 越狱设备（支持 unc0ver、checkra1n、Taurine 等）
- PushPlus 账号和 Token（免费，从 [pushplus.plus](https://www.pushplus.plus) 获取）

## 📦 安装方法

### 方法 1: 从 Release 下载（推荐）

1. 前往 [Releases](https://github.com/yourusername/iForward-push/releases) 页面
2. 下载最新的 `.deb` 文件
3. 通过 SSH 或 Filza 安装：

```bash
# SSH 安装
scp iForward*.deb root@your-device-ip:/tmp/
ssh root@your-device-ip
dpkg -i /tmp/iForward*.deb
```

### 方法 2: 自动编译安装

项目使用 GitHub Actions 自动编译，每次 push 都会生成 deb 包：

1. Fork 本仓库
2. 推送代码后，前往 Actions 标签页
3. 等待编译完成（约 5-10 分钟）
4. 下载 Artifacts 中的 deb 包
5. 按照方法 1 安装

## ⚙️ 配置使用

### 1. 获取 PushPlus Token

1. 访问 [pushplus.plus](https://www.pushplus.plus)
2. 使用微信登录
3. 复制你的 Token

### 2. 配置插件

安装后，在设备上：

1. 打开 **设置** → **iForward**
2. 填入以下信息：
   - **PushPlus Token**: 你的 PushPlus Token（必填）
   - **PushPlus URL**: 默认 `https://www.pushplus.plus/send`（通常不需要修改）
3. 启用需要的功能：
   - ✅ Enable Incoming SMS - 接收短信
   - ✅ Enable Outgoing SMS - 发送短信
   - ✅ Enable Incoming Call - 来电
   - ✅ Enable Outgoing Call - 去电
   - ✅ Enable Voicemail - 语音邮件
4. 可自定义通知标题（可选）

### 3. 测试

发送一条测试短信到你的手机，几分钟内应该收到 PushPlus 推送。

## 📱 双卡支持

对于双卡设备，推送消息会显示：

```
New SMS at Jan 15, 2025  03:45:23 PM
from 张三 (13812345678):
Account: E1234567-89AB-CDEF-0123-456789ABCDEF Service: SMS
你好，今晚一起吃饭吗？
```

- **Account**: iOS 内部的账户 GUID，每个 SIM 卡唯一
- **Service**: 服务类型（SMS 或 iMessage）

**如何识别哪张卡？**
1. 向两个号码分别发送测试短信
2. 记录下对应的 Account GUID
3. 以后就可以通过 GUID 区分了

## 🔍 消息格式示例

### 短信
```
New SMS at Jan 15, 2025  03:45:23 PM
from 张三 (13812345678):
Account: E123... Service: SMS
短信内容
```

### 来电
```
New Call at Jan 15, 2025  03:45:23 PM
from 李四 (13912345678)  duration 5 min 32 sec
```

### 语音邮件
```
New Voicemail at Jan 15, 2025  03:45:23 PM
from 王五 (13712345678)
```

## 🛠️ 编译开发

详见 [COMPILE_GUIDE.md](COMPILE_GUIDE.md)

快速编译：
```bash
# 安装 Theos
brew install ldid xz
git clone --recursive https://github.com/theos/theos.git ~/theos
export THEOS=~/theos

# 克隆项目
git clone https://github.com/yourusername/iForward-push.git
cd iForward-push

# 编译
make package
```

## 🐛 故障排除

### 插件未运行
```bash
# 检查 LaunchDaemon 状态
ssh root@your-device-ip
launchctl list | grep iforward

# 重新加载
launchctl unload /Library/LaunchDaemons/com.iforward.plist
launchctl load /Library/LaunchDaemons/com.iforward.plist
```

### 查看日志
```bash
# 实时查看日志
tail -f /var/log/syslog | grep iForward

# 或者启用调试模式
/usr/bin/iForward debug
```

### 没有收到推送
1. 确认 Token 正确
2. 检查网络连接
3. 确认启用了对应功能（设置中）
4. 测试 PushPlus API：
```bash
curl -X POST https://www.pushplus.plus/send \
  -H "Content-Type: application/json" \
  -d '{"token":"your_token","title":"Test","content":"Hello"}'
```

## 📝 更新日志

### v2.0.0 (2025-01-15)
- ✨ 将邮件转发改为 PushPlus 推送
- ✨ 添加双卡支持（显示 Account 和 Service）
- ✨ 适配 iOS 14.3
- ✨ 添加 GitHub Actions 自动编译
- 🔧 优化代码结构
- 📚 完善文档

### v1.0.0 (原版)
- 支持通过 SMTP 转发到邮箱

## 🤝 贡献

欢迎提交 Issue 和 Pull Request！

## 📄 许可证

本项目基于原 iForward 项目修改，遵循相同的开源协议。

## ⚠️ 免责声明

本工具仅供学习和个人使用。请遵守当地法律法规，不要用于非法用途。

---

<a name="english"></a>

## English

### Features

- 📱 SMS/iMessage forwarding
- 📞 Call notifications with duration
- 🎤 Voicemail alerts
- 📡 Dual SIM support (shows Account ID)
- 👤 Contact name resolution
- ⚙️ Configurable notification types
- 🔄 Background monitoring via LaunchDaemon

### Installation

1. Download `.deb` from [Releases](https://github.com/yourusername/iForward-push/releases)
2. Install: `dpkg -i iForward*.deb`
3. Configure in Settings → iForward
4. Enter your PushPlus token from [pushplus.plus](https://www.pushplus.plus)

### Configuration

1. Get token from [pushplus.plus](https://www.pushplus.plus)
2. Settings → iForward → Enter PushPlus Token
3. Enable desired notification types
4. Test by sending an SMS

### Troubleshooting

```bash
# Check daemon
launchctl list | grep iforward

# View logs
tail -f /var/log/syslog | grep iForward

# Debug mode
/usr/bin/iForward debug
```

## 🌟 Star History

如果这个项目对你有帮助，请给个 Star ⭐️

---

**Made with ❤️ for the jailbreak community**
