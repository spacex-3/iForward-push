# iForward-push 编译指南

本文档说明如何编译 iForward-push 并生成 deb 安装包。

## ⚠️ iOS 14.3 兼容性说明

### 数据库兼容性
**✅ 完全兼容 iOS 14.3**

- iOS 14.3 属于 iOS 8.0+ 系统，使用相同的数据库结构
- 短信数据库：`/private/var/mobile/Library/SMS/sms.db`
- 通话数据库：`/var/mobile/Library/CallHistoryDB/CallHistory.storedata`
- 语音邮件数据库：`/private/var/mobile/Library/Voicemail/voicemail.db`

代码在 `main.m:2003-2013` 已经针对 iOS 8.0+ 进行适配，iOS 14.3 会自动使用正确的 SQL 语句。

### 双卡功能支持
**✅ 已添加双卡识别功能**

修改了短信查询 SQL，增加了 `account` 和 `service` 字段：
```sql
select m.text,h.id,m.date,m.is_from_me,m.ROWID,m.cache_roomnames,
       m.cache_has_attachments,m.account,m.service
from message m LEFT JOIN handle h on h.ROWID = m.handle_id
```

推送消息格式示例：
```
New SMS at Jan 15, 2025  03:45:23 PM
from 张三 (13812345678):
Account: E1234567-89AB-CDEF-0123-456789ABCDEF Service: SMS
短信内容在这里
```

- **Account**: 显示接收短信的账户 ID（通常是 GUID 格式）
- **Service**: 显示服务类型（SMS 或 iMessage）

**注意**: iOS 的 `account` 字段存储的是账户 GUID，不是直接的手机号码。如需显示具体号码，需要额外从系统设置中读取账户-号码映射关系。

## 🛠️ 编译方法

### 方法 1: 使用 Theos (推荐)

iForward-push 是越狱插件，推荐使用 Theos 工具链编译。

#### 1. 安装 Theos
```bash
# macOS
brew install ldid xz
git clone --recursive https://github.com/theos/theos.git ~/theos
export THEOS=~/theos
```

#### 2. 创建 Theos 项目结构

在项目根目录创建 `Makefile`:
```makefile
export THEOS_DEVICE_IP=localhost
export THEOS_DEVICE_PORT=2222

ARCHS = arm64 arm64e
TARGET = iphone:clang:14.5:14.0

include $(THEOS)/makefiles/common.mk

TOOL_NAME = iForward

iForward_FILES = Classes/main.m
iForward_FRAMEWORKS = UIKit Foundation AddressBook CoreGraphics
iForward_LIBRARIES = curl sqlite3
iForward_INSTALL_PATH = /usr/bin

include $(THEOS)/makefiles/tool.mk
```

创建 `control` 文件:
```
Package: com.yourname.iforward
Name: iForward-PushPlus
Version: 1.0.0
Architecture: iphoneos-arm
Description: Forward SMS/Calls to PushPlus notifications
Maintainer: Your Name
Author: Your Name
Section: Utilities
Depends: firmware (>= 14.0), curl
```

#### 3. 编译
```bash
cd /Users/ks/Documents/GitHub/iForward-push
make clean
make package
```

生成的 deb 包位于当前目录。

### 方法 2: 使用现有 Makefile

项目自带的 Makefile 针对 iOS 6.1 SDK，需要修改：

#### 1. 检查 SDK 路径
```bash
ls /Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/SDKs/
```

#### 2. 修改 Makefile
将 `iPhoneOS6.1.sdk` 改为实际的 SDK 版本（如 `iPhoneOS14.5.sdk`）

#### 3. 确保有 curl 库
```bash
# 项目需要 libcurl.dylib，应该放在：
/usr/local/iForward/lib/libcurl.dylib
```

#### 4. 编译
```bash
make clean
make dist
```

生成的 deb 包：`cydia/iForward.deb`

### 方法 3: GitHub Actions 自动编译

创建 `.github/workflows/build.yml`:
```yaml
name: Build iForward

on:
  push:
    branches: [ master ]
  pull_request:
    branches: [ master ]
  workflow_dispatch:

jobs:
  build:
    runs-on: macos-latest

    steps:
    - name: Checkout
      uses: actions/checkout@v3

    - name: Install Theos
      run: |
        brew install ldid xz
        git clone --recursive https://github.com/theos/theos.git $HOME/theos
        echo "THEOS=$HOME/theos" >> $GITHUB_ENV

    - name: Setup iOS SDK
      run: |
        curl -LO https://github.com/theos/sdks/archive/master.zip
        unzip master.zip
        mv sdks-master/*.sdk $THEOS/sdks/

    - name: Build Package
      run: |
        export THEOS=$HOME/theos
        make package

    - name: Upload DEB
      uses: actions/upload-artifact@v3
      with:
        name: iForward-deb
        path: packages/*.deb
```

提交后，GitHub Actions 会自动编译并提供下载链接。

## 📦 获取 deb 包的其他方法

### 1. 直接从 Release 下载
如果项目维护者提供了 Release，直接从 GitHub Releases 页面下载 deb 包。

### 2. 使用预编译版本
某些越狱源可能已经提供了编译好的版本，可以通过 Cydia/Sileo 等包管理器搜索安装。

### 3. 本地交叉编译
如果你有越狱设备和 SSH 访问权限：
```bash
# 在设备上直接编译
ssh root@your-device-ip
cd /path/to/iForward-push
make
```

## 🔧 安装到设备

### 通过 SSH
```bash
scp cydia/iForward.deb root@your-device-ip:/tmp/
ssh root@your-device-ip
dpkg -i /tmp/iForward.deb
```

### 通过 Filza
1. 将 deb 包传输到设备
2. 使用 Filza 文件管理器打开
3. 点击安装

### 通过 Cydia/Sileo
1. 将 deb 包放到本地源目录
2. 刷新源
3. 安装

## 📝 配置插件

安装后：
1. 进入 设置 → iForward
2. 填入 PushPlus Token (从 https://www.pushplus.plus 获取)
3. 启用需要的功能（接收短信、来电等）
4. 插件会自动在后台运行，每 160 秒检查一次新消息

## ⚙️ 测试双卡功能

发送一条测试短信到你的任一 SIM 卡号码，推送消息应该显示：
```
New SMS at Jan 15, 2025  03:45:23 PM
from 测试联系人 (13800138000):
Account: XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX Service: SMS
测试消息内容
```

Account ID 是 iOS 内部的账户标识符，可以用来区分不同的 SIM 卡。

## 🐛 调试

查看日志：
```bash
ssh root@your-device-ip
tail -f /var/log/syslog | grep iForward
```

或者编译时启用 debug 模式：
```bash
/usr/bin/iForward debug
```

## 📚 参考资料

- [Theos 文档](https://theos.dev/)
- [iOS 越狱开发](https://iphonedev.wiki/)
- [PushPlus API](https://www.pushplus.plus/doc/)
