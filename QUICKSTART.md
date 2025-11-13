# 🚀 快速开始指南

## 第一步：推送代码到 GitHub

```bash
cd /Users/ks/Documents/GitHub/iForward-push

# 检查当前状态
git status

# 添加所有新文件
git add .github/workflows/build.yml
git add Makefile
git add control
git add .gitignore
git add COMPILE_GUIDE.md
git add README_NEW.md
git add QUICKSTART.md
git add Classes/main.m
git add cydia/iForward/Library/PreferenceLoader/Preferences/iForward.plist

# 提交更改
git commit -m "feat: Add PushPlus support with dual SIM detection

- Replace email forwarding with PushPlus HTTP API
- Add dual SIM support (display Account ID and Service type)
- Update for iOS 14.3 compatibility
- Add GitHub Actions for automatic compilation
- Create Theos build system
- Update configuration UI for PushPlus Token"

# 推送到 GitHub（如果是新仓库，需要先创建远程仓库）
git push origin master
# 或者
git push origin main
```

## 第二步：在 GitHub 上查看编译结果

1. 打开你的 GitHub 仓库页面
2. 点击顶部的 **Actions** 标签
3. 你会看到 "Build iForward-PushPlus" 工作流正在运行
4. 等待 5-10 分钟，直到显示绿色的 ✅

## 第三步：下载编译好的 deb 包

### 方法 A: 从 Actions Artifacts 下载

1. 在 Actions 页面，点击最新的成功构建
2. 滚动到页面底部 **Artifacts** 部分
3. 点击下载 `iForward-PushPlus-2.0.0` (或类似名称)
4. 解压 ZIP 文件，得到 `.deb` 文件

### 方法 B: 创建 Release（推荐）

```bash
# 在本地创建 tag
git tag -a v2.0.0 -m "Release v2.0.0: PushPlus support with dual SIM"
git push origin v2.0.0
```

然后：
1. 前往 GitHub 仓库的 **Releases** 页面
2. 会自动创建新的 Release，包含 deb 包
3. 直接从 Release 页面下载

## 第四步：安装到越狱设备

### 通过 SSH 安装

```bash
# 1. 将 deb 包传输到设备
scp com.iforward.pushplus_2.0.0_iphoneos-arm.deb root@192.168.1.xxx:/tmp/

# 2. SSH 连接到设备
ssh root@192.168.1.xxx
# 默认密码通常是: alpine

# 3. 安装
dpkg -i /tmp/com.iforward.pushplus_2.0.0_iphoneos-arm.deb

# 4. 重新加载守护进程
launchctl load /Library/LaunchDaemons/com.iforward.plist
```

### 通过 Filza 安装

1. 使用 AirDrop、iCloud 或其他方式将 deb 包传到设备
2. 打开 Filza 文件管理器
3. 找到 deb 文件并点击
4. 点击右上角 "安装"
5. 安装完成后重启 SpringBoard（或重启设备）

## 第五步：配置插件

1. 打开 **设置** → **iForward**
2. 填入配置：

```
✓ Enable Incoming SMS: ON
✓ Enable Outgoing SMS: ON
✓ Enable Incoming Call: ON
✓ Enable Outgoing Call: ON
✓ Enable Voicemail: ON

PushPlus Token: [在这里粘贴你的 token]
PushPlus URL: https://www.pushplus.plus/send
```

3. 保存设置（自动保存）

## 第六步：获取 PushPlus Token

1. 访问 https://www.pushplus.plus
2. 使用微信扫码登录
3. 在首页找到你的 **Token**（一串字符）
4. 复制并粘贴到插件设置中

## 第七步：测试

### 测试短信转发

1. 用另一部手机给你的 iPhone 发送测试短信
2. 等待 1-3 分钟（插件每 160 秒检查一次）
3. 在微信上应该收到 PushPlus 推送

### 测试双卡识别

如果你有双卡：

1. 分别向两个号码发送测试短信
2. 查看推送消息中的 **Account ID**
3. 记录下来：
   ```
   卡 1 (主号 138****1234): Account ID = E1234567-...
   卡 2 (副号 139****5678): Account ID = F9876543-...
   ```

### 查看日志（可选）

```bash
ssh root@your-device-ip

# 实时查看日志
tail -f /var/log/syslog | grep iForward

# 或手动运行一次（调试模式）
/usr/bin/iForward debug
```

## 🎉 完成！

现在你的 iPhone 会自动将短信、来电和语音邮件转发到 PushPlus 了！

## 📊 预期的推送消息格式

### 接收短信
```
标题: New Incoming SMS

内容:
New SMS at Jan 15, 2025  03:45:23 PM
from 张三 (13812345678):
Account: E1234567-89AB-CDEF-0123-456789ABCDEF Service: SMS
你好，今晚一起吃饭吗？
```

### 来电
```
标题: New Incoming Call

内容:
New Call at Jan 15, 2025  03:45:23 PM
from 李四 (13912345678)  duration 5 min 32 sec
```

### 未接来电
```
标题: New Incoming Call

内容:
New Call at Jan 15, 2025  03:45:23 PM
from 王五 (13712345678)  duration 0 sec
```

## ⚠️ 常见问题

### Q: 没有收到推送？
A:
1. 检查插件是否正在运行：`launchctl list | grep iforward`
2. 确认 Token 正确
3. 查看日志：`tail -f /var/log/syslog | grep iForward`
4. 手动测试 API：
   ```bash
   curl -X POST https://www.pushplus.plus/send \
     -H "Content-Type: application/json" \
     -d '{"token":"your_token","title":"Test","content":"Hello"}'
   ```

### Q: 推送延迟很久？
A: 插件每 160 秒（约 2.7 分钟）检查一次新消息，这是正常的。如需更频繁，可以修改 `/Library/LaunchDaemons/com.iforward.plist` 中的 `StartInterval` 值（单位：秒）。

### Q: 如何卸载？
A:
```bash
ssh root@your-device-ip
dpkg -r com.iforward.pushplus
```

### Q: 如何更新到新版本？
A:
1. 从 GitHub 下载新版本 deb
2. 直接安装即可：`dpkg -i new_version.deb`
3. 配置会保留

## 🔄 更新代码后重新编译

如果你修改了代码：

```bash
# 提交更改
git add .
git commit -m "描述你的修改"
git push

# GitHub Actions 会自动重新编译
# 几分钟后从 Actions → Artifacts 下载新的 deb 包
```

## 📱 建议的配置

**如果你只关心重要通知：**
```
✓ Enable Incoming SMS: ON
✗ Enable Outgoing SMS: OFF
✓ Enable Incoming Call: ON
✗ Enable Outgoing Call: OFF
✓ Enable Voicemail: ON
```

**如果你想要完整记录：**
```
✓ Enable Incoming SMS: ON
✓ Enable Outgoing SMS: ON
✓ Enable Incoming Call: ON
✓ Enable Outgoing Call: ON
✓ Enable Voicemail: ON
```

---

**需要帮助？** 请在 GitHub Issues 中提问！
