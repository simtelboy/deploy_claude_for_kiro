# Claude Code 自动部署工具

## 简介

这是一个用于自动部署和配置 Claude Code 开发环境的 PowerShell 脚本，支持多种运行模式，包括 AIClient、Router Kiro 链式模式和 Router Qwen 模式。

## 功能特性

- 🚀 **一键安装**：自动检测并安装所有必需的软件和依赖
- 🔧 **多模式支持**：支持三种不同的运行模式
- 🎯 **智能配置**：自动生成配置文件和切换脚本
- 🔄 **模式切换**：快速在不同模式间切换
- 🧹 **清理功能**：支持完整的环境清理和重置

## 支持的模式

### 1. AIClient 模式
- 使用 Kiro + AIClient MCP
- 直接通过 AIClient-2-API 连接 Kiro

### 2. Router Kiro 链式模式（默认推荐）
- 使用 Kiro via AIClient + AIClient MCP
- 通过 Claude Code Router 链式调用

### 3. Router Qwen 模式
- 使用 Qwen 直接 + Router MCP
- 支持多种 Qwen 模型（qwen3-max、qwen-plus、deepseek-v3.2-exp）

## 安装的软件组件

- **VS Code**（可选）
- **Claude Code**：Anthropic 官方 CLI 工具
- **Claude Code Router**：全局安装的路由器
- **AIClient-2-API**：Kiro API 客户端
- **Claude-MCP-Router**：MCP 路由服务
- **Kiro IDE**：AI 开发环境

## 使用方法

### 快速开始

1. **下载脚本**：
   ```powershell
   # 克隆仓库
   git clone https://github.com/你的用户名/deploy_claude_for_kiro.git
   cd deploy_claude_for_kiro
   ```

2. **以管理员身份运行 PowerShell**

3. **执行脚本**：
   ```powershell
   .\deploy_claude_code.ps1
   ```

### 菜单选项

运行脚本后，您将看到以下菜单：

```
请选择操作模式：
1. 安装模式 - 检测并安装所有必需软件和配置
2. AIClient 模式
3. Router Kiro 链式模式 (默认)
4. Router Qwen 模式
5. Kiro 续杯
6. 清理项目配置
7. 退出
```

### 首次使用建议

1. **选择选项 1**：进行完整安装和配置
2. **输入必要信息**：
   - 安装盘符（如：F）
   - Claude API 密钥
   - 各服务端口号
   - Qwen API 密钥
3. **选择运行模式**：推荐选择模式 2（Router Kiro 链式模式）

## 配置说明

### 端口配置
- **AIClient Server Port**：默认 4000
- **Router Port**：默认 8000
- **MCP Router Port**：默认 8001

### API 密钥
- **Claude API Key**：用于 Claude Code 认证
- **Qwen API Key**：用于 Qwen 模型调用

## 目录结构

安装完成后，将在指定盘符下创建以下目录结构：

```
{盘符}:\hotyi-dev\
├── AIClient-2-API\          # Kiro API 客户端
├── Claude-MCP-Router\       # MCP 路由服务
└── Scripts\                 # 模式切换脚本
    ├── switch_to_aiclient.ps1
    ├── switch_to_router_kiro.ps1
    └── switch_to_router_qwen.ps1
```

## 配置文件位置

- **Claude 配置**：`%USERPROFILE%\.claude\settings.json`
- **Router 配置**：`%USERPROFILE%\.claude-code-router\config.json`
- **AIClient 配置**：`{安装目录}\AIClient-2-API\config.json`
- **Kiro Token**：`%USERPROFILE%\.aws\sso\cache\kiro-auth-token.json`

## 故障排除

### 常见问题

1. **ccr 命令找不到**
   - 确保 Claude Code Router 已全局安装
   - 重启 PowerShell 刷新环境变量

2. **端口被占用**
   - 脚本会自动检测端口占用
   - 选择其他可用端口

3. **Kiro 登录问题**
   - 确保 Kiro IDE 已正确安装
   - 在 Kiro IDE 中完成登录操作

4. **网络连接错误**
   - 检查 API 密钥是否正确
   - 确认网络连接正常

### 清理和重置

如果遇到问题，可以使用菜单选项 6 进行完整清理：
- 删除所有项目文件
- 清理配置文件
- 卸载 Claude Code Router
- 保留 Claude Code、VS Code 和 Kiro IDE

## 系统要求

- **操作系统**：Windows 10/11
- **PowerShell**：5.1 或更高版本
- **Node.js**：v22.11.0（脚本会自动安装）
- **Git**：用于克隆项目（脚本会自动安装）
- **网络连接**：用于下载依赖和 API 调用

## 更新日志

### v1.0.0
- 初始版本发布
- 支持三种运行模式
- 自动安装和配置功能
- 模式切换脚本生成

## 贡献

欢迎提交 Issue 和 Pull Request 来改进这个项目。

## 许可证

MIT License

## 联系方式

如有问题或建议，请通过 GitHub Issues 联系。

---

**注意**：使用前请确保您有相应的 API 密钥和访问权限。