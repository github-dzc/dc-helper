# WeChat Helper - 微信增强 deb 插件

类似「黄白助手」的 iOS 微信增强插件，以 **deb** 包形式发布，支持越狱注入或配合注入器使用。

## 已实现功能

- **消息防撤回**：对方撤回后仍保留消息内容，可在设置中**单独开关**（类似黄白助手）。
- **设置页**：在系统「设置」中增加 **WeChat Helper** 入口，可开启/关闭「防撤回」等。

## 功能规划（可扩展）

- **双击复读**：双击某条消息自动复读发送
- **消息增强**：气泡、通知、多开等（需逆向分析微信后实现）

## 设置页（像黄白助手一样开关功能）

安装插件后，在 iOS **设置** App 中会出现 **WeChat Helper** 一项，点进去即可：

- **防撤回**：开启后，对方撤回的消息不会从聊天里消失；关闭则恢复微信默认撤回行为。

设置会即时生效，无需重启微信（下次收到撤回时即按当前开关状态处理）。

## 项目结构

```
wechat-deb-helper/
├── Makefile              # Theos 构建配置
├── control               # deb 包元信息（依赖 mobilesubstrate + preferenceloader）
├── Tweak.xm              # Hook 逻辑：防撤回 + 读取设置
├── WeChatHelper.plist    # 注入目标：仅对微信生效
├── WeChatHelperPrefs.plist # 设置页内容（防撤回开关等）
└── README.md
```

- **WeChatHelper.plist**：指定只注入到 `com.tencent.xin`（微信）。
- **WeChatHelperPrefs.plist**：安装到 `PreferenceLoader/Preferences/`，用于「设置 -> WeChat Helper」页面。
- **control**：依赖 `mobilesubstrate`、`preferenceloader`（设置页需要）。

## 环境要求

- **编译环境**：**macOS**（推荐）或 **Windows + WSL（Ubuntu）**，需安装 [Theos](https://theos.dev)
- **目标设备**：已越狱或使用可注入 dylib 的注入器/重签名方式

---

### 方式一：macOS 下安装 Theos

```bash
# 使用官方推荐方式
sudo git clone --recursive https://github.com/theos/theos.git /opt/theos

# 或使用镜像
sudo git clone --recursive https://github.com/theos/theos.git $THEOS  # 需先 export THEOS=/path
```

**必装依赖（macOS）**：

- **ldid**：编译时给 dylib 签名，未安装会报 `ldid: command not found`。
- **xz**：打 deb 包时用于压缩，未安装会报 `lzma: No such file or directory`（dm.pl 会调用 `lzma`）。

```bash
brew install ldid xz
```

若安装 xz 后仍提示找不到 `lzma`，可创建软链（将 `$(which xz)` 所在目录换成你的实际路径）：

```bash
sudo ln -sf $(which xz) /usr/local/bin/lzma
```

若未安装 Homebrew，可先执行 [Homebrew 安装脚本](https://brew.sh)，再执行上述命令。

---

### 方式二：Windows 下用 WSL 编译（可用）

Theos 不直接支持 Windows，但可以通过 **WSL（适用于 Linux 的 Windows 子系统）** 在 Windows 里用 Linux 环境编译。

1. **启用 WSL 并安装 Ubuntu**
   - 以管理员身份打开 PowerShell，执行：`wsl --install`（或到「启用或关闭 Windows 功能」中勾选「适用于 Linux 的 Windows 子系统」后，在 Microsoft Store 安装 Ubuntu）。
   - 安装完成后打开 **Ubuntu**，按提示创建用户名和密码。

2. **在 WSL Ubuntu 里安装依赖与 Theos**

   ```bash
   sudo apt-get update
   sudo apt-get install -y build-essential git unzip libio-compress-perl libxml2 libstdc++6
   ```

3. **安装 Theos**

   ```bash
   sudo git clone --recursive https://github.com/theos/theos.git /opt/theos
   echo 'export THEOS=/opt/theos' >> ~/.bashrc
   echo 'umask 0022' >> ~/.bashrc
   source ~/.bashrc
   ```

4. **安装 iOS 工具链和 SDK（Linux 交叉编译用）**

   - 工具链（示例，可按 [Theos 文档](https://theos.dev/docs/installation) 或你使用的教程替换链接）：
     ```bash
     # 以 theos 官方或社区提供的 Linux 工具链为准，例如：
     # 将 iOS 工具链解压到 $THEOS/toolchain/linux/iphone
     ```
   - iOS SDK：将对应版本的 iOS SDK 放到 `$THEOS/sdks/`（可从 Xcode 抽取或使用社区提供的预编译 SDK）。

   具体下载链接和目录结构因版本而异，可参考：[Windows WSL 上安装 theos](https://www.chengzz.com/429.html)、[Theos 官方文档](https://theos.dev/docs/installation)。

5. **在 WSL 里进入项目并编译**

   ```bash
   # 项目在 Windows 盘上时，路径一般为 /mnt/d/Project/gitee-dzc/ccnetlink-test/wechat-deb-helper
   cd /mnt/d/Project/gitee-dzc/ccnetlink-test/wechat-deb-helper
   make clean && make && make package
   ```

生成的 `.deb` 在 WSL 的 `packages/` 下，可在 Windows 资源管理器中通过 `\\wsl$\Ubuntu\home\你的用户名\...` 或 `cd` 到对应目录后用 `explorer.exe .` 打开文件夹拷贝出来。

## 编译与打包

在项目目录下执行：

```bash
cd wechat-deb-helper
make clean
make
make package
```

生成产物：

- **dylib**：`.theos/obj/debug/WeChatHelper.dylib`（注意是隐藏目录 `.theos`）
- **deb 包**：`packages/com.ccnetlink.wechathelper_1.0.0_iphoneos-arm64.deb`（路径以实际 THEOS 输出为准）

## 安装方式

### 方式一：越狱设备

1. 将生成的 `.deb` 传到设备（如通过 Filza、SSH、拷贝到 Cydia 源等）。
2. 使用 Cydia/Sileo/Installer 等安装该 deb，或命令行：
   ```bash
   dpkg -i com.ccnetlink.wechathelper_1.0.0_iphoneos-arm64.deb
   ```
3. 重启微信或执行 `killall -9 WeChat` 使插件生效。

**若安装时报错「Read-only file system」或「error creating directory 'Library/MobileSubstrate'」**：说明设备是 **根less 越狱**（Dopamine、palera1n rootless 等）。本仓库 Makefile 已默认使用 `PREFIX=/var/jb`，打出的 deb 会安装到 `/var/jb/Library/...`，请用当前仓库重新执行 `make clean && make package` 再安装新生成的 deb。若你是**传统（rootful）越狱**，需打包时指定：`make package PREFIX=/`。

### 方式二：免越狱（注入器）

1. 使用 `make` 得到 `WeChatHelper.dylib`。
2. 若为**非越狱**，需将 dylib 依赖的 CydiaSubstrate 改为可用的 lib（如 `@loader_path/libsubstrate.dylib`），再用 **insert_dylib** 注入到微信二进制，最后用 **zsign** 等工具重签名并安装。
3. 具体步骤依赖你所用的注入工具（如 Sideloadly、AltStore、自研注入器等），此处不展开。

## 防撤回实现说明

- Hook 的是微信的 **CMessageMgr** 的 **onRevokeMsg:** 方法；开启「防撤回」时不调用原方法，消息不会被撤回。
- 设置保存在 `com.ccnetlink.wechathelper` 的 Preferences 中，键为 `RevokeEnabled`，与设置页开关一致。
- 若你的微信版本中该类/方法名不同（如 `onRevokeMsg:withRevokeInfo:`），需用 class-dump 等对当前微信逆向后，在 `Tweak.xm` 中调整类名或方法签名并重新编译。

## 如何添加更多功能

要增加「双击复读」等：

1. **逆向微信**：用 class-dump、Hopper、IDA 等获取相关类名、方法名。
2. **在 WeChatHelperPrefs.plist** 中增加对应开关（如 `RepeatOnDoubleTapEnabled`），并在 `Tweak.xm` 中读取该 key。
3. **在 Tweak.xm 中写 Hook**：用 `%hook ClassName`、`%orig` 等实现逻辑。
4. 重新 `make` / `make package`。

可参考：[HBWeChatHelper（黄白助手）](https://github.com/Huangbai233/HBWeChatHelper)、[MonkeyDev](https://github.com/AloneMonkey/MonkeyDev) 等。

## 注意事项

- 插件仅用于学习与合规的增强，请勿用于违反微信用户协议或法律的行为。
- 不同微信版本内部类名可能变化，需按版本逆向后适配。
- 免越狱注入需自行处理签名与安装限制（如 7 天重签等）。

## 许可证

与主仓库保持一致；若单独使用，可自选 MIT/AGPL 等并注明出处。
