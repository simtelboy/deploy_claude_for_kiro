# Claude Code 自动部署脚本
# 作者: hotyi
# 日期: 2025-10-19
# 运行: .\deploy_claude_code.ps1 (管理员模式)

# 设置控制台编码为 UTF-8
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
[Console]::InputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8

# 刷新环境变量的函数
function Refresh-Environment {
    $env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path", "User")
    Write-Host "环境变量已刷新" -ForegroundColor Green
}


# 步骤 A: 显示 LOGO 和说明
$logo = @"
               .-''-''-.
              /   '-'  .: __
      .._    /  /|||\\  Y`  `\
     |:  `-.J  /__ __.., )   |
     |  .   ( ( ==|<== : )   |
     :   `.(  )\ _L__ /( )   |
      \    \(  )\\__//(  )   |
       \    \  ):`'':(  /    \
        -_   -.-   .'-'` ` . |
         `. :           .  ' :
          )            :    /
         /    : /   _   :  :
        @)    : |  (@)  | :
         \   /   \     / /
          `i`     `---' /
           |           (
           |           \
          /   )         \
         |               \
         |                |
         \                |
         |  `\__          \
         |    |#\ /        |
"@

Write-Host $logo -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host "         Claude Code 部署工具           " -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host "欢迎使用 Claude Code 自动部署脚本！" -ForegroundColor Yellow
Write-Host "功能："
Write-Host "- 安装 VS Code（可选）、Claude Code、Claude Code Router、AIClient-2-API"
Write-Host "- 直接安装 Kiro 并配置登录"
Write-Host "- 支持三种模式：AIClient、Router Kiro 链式、Router Qwen"
Write-Host "- 自动配置 JSON 文件和切换脚本"
Write-Host ""

# 主菜单
# 尝试自动检测已安装的路径
$possibleDrives = @("F", "C", "D", "E")
$hotyiDevPath = $null
foreach ($drive in $possibleDrives) {
    $testPath = "$drive" + ":\hotyi-dev"
    if (Test-Path "$testPath\Scripts\switch_to_aiclient.ps1") {
        $hotyiDevPath = $testPath
        break
    }
}

while ($true) {
    Write-Host "请选择操作模式：" -ForegroundColor Cyan
    Write-Host "1. 安装模式 - 检测并安装所有必需软件和配置"
    Write-Host "2. AIClient 模式"
    Write-Host "3. Router Kiro 链式模式 (默认)"
    Write-Host "4. Router Qwen 模式"
    Write-Host "5. Kiro 续杯"
    Write-Host "6. 清理项目配置"
    Write-Host "7. 管理简短指令"
    Write-Host "8. 退出"
    $mainChoice = Read-Host "请输入选项 (1-8, 默认 3)"

    if (-not $mainChoice) { $mainChoice = "3" }

    switch ($mainChoice) {
        "1" {
            # 安装模式 - 包含原有的所有安装逻辑
            Write-Host "进入安装模式..." -ForegroundColor Green
            break
        }
        "2" {
            # AIClient 模式
            if ($hotyiDevPath -and (Test-Path "$hotyiDevPath\Scripts\switch_to_aiclient.ps1")) {
                Write-Host "切换到 AIClient 模式..."
                & "$hotyiDevPath\Scripts\switch_to_aiclient.ps1"
                Exit
            } else {
                Write-Host "切换脚本不存在，请先运行安装模式。" -ForegroundColor Red
                continue
            }
        }
        "3" {
            # Router Kiro 链式模式
            if ($hotyiDevPath -and (Test-Path "$hotyiDevPath\Scripts\switch_to_router_kiro.ps1")) {
                Write-Host "切换到 Router Kiro 链式模式..."
                & "$hotyiDevPath\Scripts\switch_to_router_kiro.ps1"
                Exit
            } else {
                Write-Host "切换脚本不存在，请先运行安装模式。" -ForegroundColor Red
                continue
            }
        }
        "4" {
            # Router Qwen 模式
            if ($hotyiDevPath -and (Test-Path "$hotyiDevPath\Scripts\switch_to_router_qwen.ps1")) {
                Write-Host "切换到 Router Qwen 模式..."
                & "$hotyiDevPath\Scripts\switch_to_router_qwen.ps1"
                Exit
            } else {
                Write-Host "切换脚本不存在，请先运行安装模式。" -ForegroundColor Red
                continue
            }
        }
        "5" {
            # Kiro 续杯
            Write-Host "Kiro 续杯..." -ForegroundColor Cyan
            Write-Host ""
            Write-Host "请按照以下步骤进行 Kiro 续杯：" -ForegroundColor Yellow
            Write-Host "1. 启动 Kiro IDE 程序" -ForegroundColor White
            Write-Host "2. 在 Kiro 界面中退出当前账号" -ForegroundColor White
            Write-Host "3. 使用新的试用账号重新登录" -ForegroundColor White
            Write-Host "4. 登录成功后 token 文件会自动更新" -ForegroundColor White
            Write-Host ""
            Write-Host "注意：Kiro 续杯需要在 Kiro IDE 图形界面中操作" -ForegroundColor Cyan

            # 询问是否启动 Kiro IDE
            $startKiro = Read-Host "是否现在启动 Kiro IDE? (y/n)"
            if ($startKiro -eq "y") {
                $kiroStarted = $false
                $possiblePaths = @(
                    "$env:LOCALAPPDATA\Programs\Kiro\Kiro.exe",
                    "$env:PROGRAMFILES\Kiro\Kiro.exe",
                    "$env:PROGRAMFILES(X86)\Kiro\Kiro.exe"
                )

                foreach ($path in $possiblePaths) {
                    if (Test-Path $path) {
                        try {
                            Start-Process -FilePath $path
                            Write-Host "已启动 Kiro IDE" -ForegroundColor Green
                            $kiroStarted = $true
                            break
                        } catch {
                            Write-Host "启动失败: $($_.Exception.Message)" -ForegroundColor Red
                        }
                    }
                }
                if (-not $kiroStarted) {
                    Write-Host "无法自动启动 Kiro IDE，请手动启动" -ForegroundColor Yellow
                }
            }

            Write-Host ""
            $kiroRenew = Read-Host "是否已完成 Kiro 续杯登录? (y/n)"
            if ($kiroRenew -eq "y") {
                Write-Host "Kiro 续杯完成！" -ForegroundColor Green
            } else {
                Write-Host "请完成 Kiro 续杯后重新选择此选项" -ForegroundColor Yellow
            }
            continue
        }
        "6" {
            # 清理项目配置和文件
            Write-Host "步骤: 清理项目配置和文件..." -ForegroundColor Red
            $confirm = Read-Host "警告: 这将清理 hotyi-dev 文件夹和相关配置，但保留 Claude Code、VS Code 和 Kiro IDE，是否继续? (y/n)"
            if ($confirm -eq "y") {
                # 询问是否也要卸载 Claude Code
                Write-Host ""
                Write-Host "额外清理选项:" -ForegroundColor Cyan
                $claudeCodeConfirm = Read-Host "是否也要卸载 Claude Code? 这将完全移除 Claude Code CLI 工具 (y/n)"

                Write-Host "停止运行中的进程..."
                taskkill /F /IM node.exe /FI "WINDOWTITLE eq Router*" /T 2>$null
                taskkill /F /IM node.exe /FI "WINDOWTITLE eq MCP*" /T 2>$null
                taskkill /F /IM node.exe /FI "WINDOWTITLE eq AIClient*" /T 2>$null

                Write-Host "清理项目文件和配置..."
                try {
                    # 卸载全局安装的 Claude Code Router
                    if (Get-Command ccr -ErrorAction SilentlyContinue) {
                        Write-Host "卸载全局安装的 Claude Code Router..." -ForegroundColor Yellow
                        npm uninstall -g @musistudio/claude-code-router 2>$null
                    }

                    # 卸载 Claude Code（如果用户确认）
                    if ($claudeCodeConfirm -eq "y") {
                        if (Get-Command claude -ErrorAction SilentlyContinue) {
                            Write-Host "卸载 Claude Code..." -ForegroundColor Yellow
                            npm uninstall -g @anthropic-ai/claude-code 2>$null
                        }
                    }

                    # 清理 PowerShell Profile 中的简短指令引用
                    Write-Host "清理 PowerShell Profile 中的简短指令..." -ForegroundColor Yellow
                    $profilePath = $PROFILE
                    if (Test-Path $profilePath) {
                        $profileContent = Get-Content $profilePath -Raw -ErrorAction SilentlyContinue
                        if ($profileContent) {
                            # 移除所有可能的 aliases.ps1 引用（支持不同盘符）
                            $profileContent = $profileContent -replace '# Claude Code 部署工具简短指令\s*\n', ''
                            $profileContent = $profileContent -replace '\.\s*"[A-Z]:\\hotyi-dev\\Scripts\\aliases\.ps1"\s*\n?', ''
                            $profileContent = $profileContent -replace '\.\s*"[^"]*\\aliases\.ps1"\s*\n?', ''
                            # 清理多余的空行
                            $profileContent = $profileContent -replace '\n{3,}', "`n`n"
                            $profileContent = $profileContent.Trim()
                            if ($profileContent) {
                                $profileContent | Set-Content $profilePath -Encoding UTF8
                            } else {
                                Remove-Item $profilePath -Force -ErrorAction SilentlyContinue
                            }
                            Write-Host "- 已从 PowerShell Profile 移除简短指令引用" -ForegroundColor Green
                        }
                    }

                    # 删除 hotyi-dev 文件夹（包含 AIClient-2-API、Claude-MCP-Router 等）
                    if ($hotyiDevPath -and (Test-Path $hotyiDevPath)) {
                        Write-Host "删除 hotyi-dev 文件夹: $hotyiDevPath" -ForegroundColor Yellow
                        Remove-Item -Path "$hotyiDevPath" -Recurse -Force -ErrorAction SilentlyContinue
                    }

                    # 完整清理配置文件夹
                    $userFolder = $env:USERPROFILE

                    # Claude 相关配置
                    if (Test-Path "$userFolder\.claude") {
                        Write-Host "删除 Claude 配置文件夹" -ForegroundColor Yellow
                        Remove-Item -Path "$userFolder\.claude" -Recurse -Force -ErrorAction SilentlyContinue
                    }

                    # Claude Code Router 配置
                    if (Test-Path "$userFolder\.claude-code-router") {
                        Write-Host "删除 Claude Code Router 配置文件夹" -ForegroundColor Yellow
                        Remove-Item -Path "$userFolder\.claude-code-router" -Recurse -Force -ErrorAction SilentlyContinue
                    }

                    # 额外清理（如果用户选择了完全清理）
                    if ($claudeCodeConfirm -eq "y") {
                        # 清理 npm 缓存中的相关包
                        Write-Host "清理 npm 缓存..." -ForegroundColor Yellow
                        npm cache clean --force 2>$null
                    }

                    # 注意：保留 Kiro 认证配置 (~/.aws/sso/cache/kiro-auth-token.json)
                    # 这样用户无需重新登录 Kiro IDE

                    # AIClient 日志文件清理
                    $possibleLogPaths = @(
                        "$hotyiDevPath\AIClient-2-API\claude_logs*",
                        "$env:TEMP\claude_logs*",
                        "$userFolder\claude_logs*"
                    )
                    foreach ($logPath in $possibleLogPaths) {
                        if (Test-Path $logPath) {
                            Write-Host "删除日志文件: $logPath" -ForegroundColor Yellow
                            Remove-Item -Path $logPath -Recurse -Force -ErrorAction SilentlyContinue
                        }
                    }

                    # 移除环境变量
                    Write-Host "清理环境变量..." -ForegroundColor Yellow
                    [System.Environment]::SetEnvironmentVariable("ANTHROPIC_BASE_URL", $null, "User")
                    [System.Environment]::SetEnvironmentVariable("ANTHROPIC_API_KEY", $null, "User")

                    # 刷新环境变量
                    Refresh-Environment

                    Write-Host "清理完成！" -ForegroundColor Green
                    if ($claudeCodeConfirm -eq "y") {
                        Write-Host "注意：已完全清理 Claude Code 和相关配置。" -ForegroundColor Cyan
                        Write-Host "保留项：VS Code、Kiro IDE 和 Kiro 登录凭证，可继续使用。" -ForegroundColor Cyan
                    } else {
                        Write-Host "注意：Claude Code、VS Code、Kiro IDE 和 Kiro 登录凭证已保留，可继续使用。" -ForegroundColor Cyan
                    }
                    Write-Host "如需重新安装，请重新运行此脚本的安装模式。" -ForegroundColor Yellow
                } catch {
                    Write-Host "清理过程中出现错误: $($_.Exception.Message)" -ForegroundColor Red
                }
                Exit
            } else {
                Write-Host "清理取消，返回菜单。"
                continue
            }
        }
        "7" {
            # 管理简短指令
            Write-Host ""
            Write-Host "===== 简短指令管理 =====" -ForegroundColor Cyan
            Write-Host "简短指令可以让你在 PowerShell 中快速执行常用命令"
            Write-Host ""
            
            # 检查当前已配置的简短指令
            $aliasScriptPath = "$hotyiDevPath\Scripts\aliases.ps1"
            $profilePath = $PROFILE
            
            # 显示当前已有的简短指令
            if (Test-Path $aliasScriptPath) {
                Write-Host "当前已配置的简短指令：" -ForegroundColor Green
                Get-Content $aliasScriptPath | Where-Object { $_ -match "^function\s+(\w+)" } | ForEach-Object {
                    if ($_ -match "function\s+(\w+)\s*\{.*`"(.+)`"") {
                        Write-Host "  $($Matches[1]) -> $($Matches[2])" -ForegroundColor White
                    } elseif ($_ -match "function\s+(\w+)") {
                        Write-Host "  $($Matches[1])" -ForegroundColor White
                    }
                }
            } else {
                Write-Host "尚未配置任何简短指令" -ForegroundColor Yellow
            }
            
            Write-Host ""
            Write-Host "请选择操作：" -ForegroundColor Cyan
            Write-Host "1. 添加简短指令"
            Write-Host "2. 删除简短指令"
            Write-Host "3. 查看所有简短指令"
            Write-Host "4. 重置为默认简短指令"
            Write-Host "5. 返回主菜单"
            $aliasChoice = Read-Host "请输入选项 (1-5)"
            
            switch ($aliasChoice) {
                "1" {
                    # 添加简短指令
                    Write-Host ""
                    Write-Host "添加新的简短指令" -ForegroundColor Cyan
                    $aliasName = Read-Host "请输入简短指令名称 (如: goa)"
                    if (-not $aliasName) {
                        Write-Host "指令名称不能为空" -ForegroundColor Red
                        continue
                    }
                    
                    Write-Host "请选择指令类型：" -ForegroundColor Cyan
                    Write-Host "1. 执行脚本文件"
                    Write-Host "2. 执行自定义命令"
                    $cmdType = Read-Host "请输入选项 (1-2)"
                    
                    if ($cmdType -eq "1") {
                        Write-Host "可用的脚本文件：" -ForegroundColor Yellow
                        Get-ChildItem "$hotyiDevPath\Scripts\*.ps1" -ErrorAction SilentlyContinue | ForEach-Object {
                            Write-Host "  - $($_.Name)" -ForegroundColor White
                        }
                        $scriptName = Read-Host "请输入脚本文件名 (如: switch_to_aiclient.ps1)"
                        $aliasCommand = "& `"$hotyiDevPath\Scripts\$scriptName`""
                    } else {
                        $aliasCommand = Read-Host "请输入要执行的命令"
                    }
                    
                    # 确保 Scripts 目录存在
                    if (-not (Test-Path "$hotyiDevPath\Scripts")) {
                        New-Item -Path "$hotyiDevPath\Scripts" -ItemType Directory -Force | Out-Null
                    }
                    
                    # 创建或更新 aliases.ps1
                    $newFunction = "function $aliasName { $aliasCommand }"
                    
                    if (Test-Path $aliasScriptPath) {
                        # 检查是否已存在同名指令
                        $existingContent = Get-Content $aliasScriptPath -Raw
                        if ($existingContent -match "function\s+$aliasName\s*\{") {
                            Write-Host "指令 '$aliasName' 已存在，是否覆盖? (y/n)" -ForegroundColor Yellow
                            $overwrite = Read-Host
                            if ($overwrite -eq "y") {
                                $existingContent = $existingContent -replace "function\s+$aliasName\s*\{[^}]+\}\s*", ""
                                $existingContent + "`n$newFunction" | Set-Content $aliasScriptPath -Encoding UTF8
                                Write-Host "指令 '$aliasName' 已更新" -ForegroundColor Green
                            }
                        } else {
                            Add-Content $aliasScriptPath "`n$newFunction" -Encoding UTF8
                            Write-Host "指令 '$aliasName' 已添加" -ForegroundColor Green
                        }
                    } else {
                        # 创建新的 aliases.ps1
                        $aliasHeader = "# Claude Code 部署工具 - 简短指令配置`n# 自动生成，请勿手动编辑`n"
                        "$aliasHeader$newFunction" | Set-Content $aliasScriptPath -Encoding UTF8
                        Write-Host "指令 '$aliasName' 已添加" -ForegroundColor Green
                    }
                    
                    # 确保 PowerShell Profile 引用了 aliases.ps1
                    if (Test-Path $profilePath) {
                        $profileContent = Get-Content $profilePath -Raw -ErrorAction SilentlyContinue
                        if ($profileContent -notmatch [regex]::Escape($aliasScriptPath)) {
                            Add-Content $profilePath "`n. `"$aliasScriptPath`"" -Encoding UTF8
                            Write-Host "已将简短指令配置添加到 PowerShell Profile" -ForegroundColor Green
                        }
                    } else {
                        # 创建 Profile
                        New-Item -Path (Split-Path $profilePath -Parent) -ItemType Directory -Force -ErrorAction SilentlyContinue | Out-Null
                        ". `"$aliasScriptPath`"" | Set-Content $profilePath -Encoding UTF8
                        Write-Host "已创建 PowerShell Profile 并添加简短指令配置" -ForegroundColor Green
                    }
                    
                    Write-Host "提示：重新打开 PowerShell 后生效，或执行: . `"$aliasScriptPath`"" -ForegroundColor Cyan
                }
                "2" {
                    # 删除简短指令
                    if (-not (Test-Path $aliasScriptPath)) {
                        Write-Host "没有配置任何简短指令" -ForegroundColor Yellow
                        continue
                    }
                    
                    Write-Host ""
                    Write-Host "当前已配置的简短指令：" -ForegroundColor Cyan
                    $aliases = @()
                    Get-Content $aliasScriptPath | Where-Object { $_ -match "^function\s+(\w+)" } | ForEach-Object {
                        if ($_ -match "function\s+(\w+)") {
                            $aliases += $Matches[1]
                            Write-Host "  - $($Matches[1])" -ForegroundColor White
                        }
                    }
                    
                    $delAlias = Read-Host "请输入要删除的指令名称"
                    if ($aliases -contains $delAlias) {
                        $content = Get-Content $aliasScriptPath -Raw
                        $content = $content -replace "function\s+$delAlias\s*\{[^}]+\}\s*`n?", ""
                        $content | Set-Content $aliasScriptPath -Encoding UTF8
                        Write-Host "指令 '$delAlias' 已删除" -ForegroundColor Green
                        Write-Host "提示：重新打开 PowerShell 后生效" -ForegroundColor Cyan
                    } else {
                        Write-Host "指令 '$delAlias' 不存在" -ForegroundColor Red
                    }
                }
                "3" {
                    # 查看所有简短指令
                    if (Test-Path $aliasScriptPath) {
                        Write-Host ""
                        Write-Host "===== aliases.ps1 内容 =====" -ForegroundColor Cyan
                        Get-Content $aliasScriptPath
                        Write-Host "=============================" -ForegroundColor Cyan
                    } else {
                        Write-Host "没有配置任何简短指令" -ForegroundColor Yellow
                    }
                }
                "4" {
                    # 重置为默认简短指令
                    Write-Host "将重置为以下默认简短指令：" -ForegroundColor Yellow
                    Write-Host "  goa  -> 切换到 AIClient 模式"
                    Write-Host "  gok  -> 切换到 Router Kiro 链式模式"
                    Write-Host "  goq  -> 切换到 Router Qwen 模式"
                    Write-Host "  aic  -> 启动 AIClient-2-API 服务"
                    $resetConfirm = Read-Host "确认重置? (y/n)"
                    
                    if ($resetConfirm -eq "y") {
                        # 确保 Scripts 目录存在
                        if (-not (Test-Path "$hotyiDevPath\Scripts")) {
                            New-Item -Path "$hotyiDevPath\Scripts" -ItemType Directory -Force | Out-Null
                        }
                        
                        $defaultAliases = @"
# Claude Code 部署工具 - 简短指令配置
# 自动生成

function goa { & "$hotyiDevPath\Scripts\switch_to_aiclient.ps1" }
function gok { & "$hotyiDevPath\Scripts\switch_to_router_kiro.ps1" }
function goq { & "$hotyiDevPath\Scripts\switch_to_router_qwen.ps1" }
function aic { Push-Location "$hotyiDevPath\AIClient-2-API"; node src/services/api-server.js; Pop-Location }
"@
                        $defaultAliases | Set-Content $aliasScriptPath -Encoding UTF8
                        Write-Host "简短指令已重置为默认值" -ForegroundColor Green
                        
                        # 确保 PowerShell Profile 引用了 aliases.ps1
                        if (Test-Path $profilePath) {
                            $profileContent = Get-Content $profilePath -Raw -ErrorAction SilentlyContinue
                            if ($profileContent -notmatch [regex]::Escape($aliasScriptPath)) {
                                Add-Content $profilePath "`n. `"$aliasScriptPath`"" -Encoding UTF8
                                Write-Host "已将简短指令配置添加到 PowerShell Profile" -ForegroundColor Green
                            }
                        } else {
                            New-Item -Path (Split-Path $profilePath -Parent) -ItemType Directory -Force -ErrorAction SilentlyContinue | Out-Null
                            ". `"$aliasScriptPath`"" | Set-Content $profilePath -Encoding UTF8
                            Write-Host "已创建 PowerShell Profile 并添加简短指令配置" -ForegroundColor Green
                        }
                        
                        Write-Host "提示：重新打开 PowerShell 后生效" -ForegroundColor Cyan
                    }
                }
                "5" {
                    # 返回主菜单
                    continue
                }
                default {
                    Write-Host "无效选项" -ForegroundColor Red
                }
            }
            continue
        }
        "8" {
            Write-Host "退出脚本..." -ForegroundColor Green
            Exit
        }
        default {
            Write-Host "无效选项，请重新选择。" -ForegroundColor Red
            continue
        }
    }

    # 如果选择了安装模式，跳出循环继续执行安装逻辑
    if ($mainChoice -eq "1") {
        break
    }
}

# 检测系统依赖
Write-Host "检测系统依赖..." -ForegroundColor Cyan

# 检查依赖
$missingDependencies = @()
if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
    $missingDependencies += "Winget"
}
# 检查 Node.js 版本
$nodeMinVersion = 18
$nodeInstalled = $false
if (Get-Command node -ErrorAction SilentlyContinue) {
    try {
        $nodeVersion = node --version 2>$null
        # 提取版本号（去掉 'v' 前缀）
        $versionNumber = $nodeVersion -replace '^v', ''
        $majorVersion = [int]($versionNumber -split '\.')[0]

        if ($majorVersion -ge $nodeMinVersion) {
            $nodeInstalled = $true
            Write-Host "✓ Node.js $nodeVersion 已安装 (要求: v$nodeMinVersion+)" -ForegroundColor Green
        } else {
            Write-Host "⚠ Node.js 版本过低: 当前 $nodeVersion, 需要 v$nodeMinVersion 或更新版本" -ForegroundColor Yellow
        }
    } catch {
        Write-Host "⚠ Node.js 版本检查失败" -ForegroundColor Yellow
    }
}
if (-not $nodeInstalled) {
    $missingDependencies += "Node.js"
}
if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
    $missingDependencies += "Git"
}

if ($missingDependencies.Count -gt 0) {
    Write-Host "缺少依赖: $($missingDependencies -join ', ')" -ForegroundColor Red
    $installDeps = Read-Host "是否安装缺少的依赖? (y/n)"
    if ($installDeps -eq "y") {
        if ($missingDependencies -contains "Winget") {
            Write-Host "请手动安装 Winget (Microsoft Store -> App Installer)"
            Exit
        }
        if ($missingDependencies -contains "Node.js") {
            Write-Host "安装 Node.js (最新 LTS 版本)..."
            # 安装最新 LTS 版本的 Node.js
            winget install OpenJS.NodeJS --accept-package-agreements --accept-source-agreements --scope user
            if ($LASTEXITCODE -ne 0) {
                Write-Host "Winget 安装失败，尝试从官网下载..." -ForegroundColor Yellow
                # 使用最新 LTS 版本
                $nodeUrl = "https://nodejs.org/dist/v22.11.0/node-v22.11.0-x64.msi"
                $nodeInstaller = "$env:TEMP\node-v22.11.0-x64.msi"
                Write-Host "下载 Node.js v22.11.0..."
                Invoke-WebRequest -Uri $nodeUrl -OutFile $nodeInstaller
                Write-Host "安装 Node.js v22.11.0..."
                Start-Process -FilePath "msiexec.exe" -ArgumentList "/i `"$nodeInstaller`" /quiet" -Wait
                Remove-Item $nodeInstaller -Force
            }
            Refresh-Environment
        }
        if ($missingDependencies -contains "Git") {
            Write-Host "安装 Git..."
            winget install Git.Git --accept-package-agreements --accept-source-agreements --scope user
            Refresh-Environment
        }

        # 等待环境变量生效
        Write-Host "等待环境变量生效..." -ForegroundColor Yellow
        Start-Sleep -Seconds 3
    } else {
        Write-Host "缺少依赖，脚本退出。" -ForegroundColor Red
        Exit
    }
}

# 检查 Kiro IDE
$kiroInstalled = $false
$possiblePaths = @(
    "$env:LOCALAPPDATA\Programs\Kiro\Kiro.exe",
    "$env:PROGRAMFILES\Kiro\Kiro.exe",
    "$env:PROGRAMFILES(X86)\Kiro\Kiro.exe"
)

foreach ($path in $possiblePaths) {
    if (Test-Path $path) {
        Write-Host "检测到 Kiro IDE: $path" -ForegroundColor Green
        $kiroInstalled = $true
        break
    }
}

if (-not $kiroInstalled) {
    Write-Host "未检测到 Kiro IDE" -ForegroundColor Yellow
    $installKiro = Read-Host "是否下载并安装 Kiro IDE? (y/n)"

    if ($installKiro -eq "y") {
        $kiroUrl = "https://prod.download.desktop.kiro.dev/releases/202510142329-Kiro-win32-x64.exe"
        $kiroInstaller = "$env:TEMP\Kiro-installer.exe"

        try {
            Write-Host "下载 Kiro IDE..." -ForegroundColor Cyan
            Write-Host "下载地址: $kiroUrl" -ForegroundColor White

            # 使用 Invoke-WebRequest 下载
            Invoke-WebRequest -Uri $kiroUrl -OutFile $kiroInstaller -UseBasicParsing
            Write-Host "下载完成" -ForegroundColor Green

            # 启动安装程序（不等待）
            Write-Host "启动 Kiro 安装程序..." -ForegroundColor Cyan
            Start-Process -FilePath $kiroInstaller

            Write-Host "安装程序已启动，请按照安装向导完成 Kiro IDE 安装" -ForegroundColor Yellow
            Write-Host "安装完成后，请启动 Kiro IDE 并登录你的账号" -ForegroundColor Yellow
            Write-Host ""
            Read-Host "安装并登录完成后，按 Enter 继续"

            # 清理安装文件
            Remove-Item $kiroInstaller -ErrorAction SilentlyContinue
        } catch {
            Write-Host "Kiro 下载失败: $($_.Exception.Message)" -ForegroundColor Red
            Write-Host "请手动下载并安装 Kiro:" -ForegroundColor Yellow
            Write-Host "下载地址: $kiroUrl" -ForegroundColor White
            Read-Host "手动安装并登录完成后，按 Enter 继续"
        }
    } else {
        Write-Host "跳过 Kiro IDE 安装" -ForegroundColor Yellow
    }
} else {
    # 检查是否已登录 Kiro (通过检查 kiro-auth-token.json 文件)
    $kiroTokenPath = "$env:USERPROFILE\.aws\sso\cache\kiro-auth-token.json"

    if (-not (Test-Path $kiroTokenPath)) {
        Write-Host "检测到 Kiro IDE 已安装，但尚未登录" -ForegroundColor Yellow
        Write-Host ""
        Write-Host "请按照以下步骤登录 Kiro 账号：" -ForegroundColor Cyan
        Write-Host "1. 启动 Kiro IDE 程序" -ForegroundColor White
        Write-Host "2. 在 Kiro 界面中登录你的账号" -ForegroundColor White
        Write-Host "3. 登录成功后会生成认证 token 文件" -ForegroundColor White
        Write-Host ""

        # 询问用户是否要启动 Kiro IDE
        $startKiro = Read-Host "是否现在启动 Kiro IDE? (y/n)"
        if ($startKiro -eq "y") {
            # 尝试启动 Kiro IDE
            $kiroStarted = $false
            foreach ($path in $possiblePaths) {
                if (Test-Path $path) {
                    try {
                        Start-Process -FilePath $path
                        Write-Host "已启动 Kiro IDE，请在程序中完成登录" -ForegroundColor Green
                        $kiroStarted = $true
                        break
                    } catch {
                        Write-Host "启动 Kiro IDE 失败: $($_.Exception.Message)" -ForegroundColor Red
                    }
                }
            }
            if (-not $kiroStarted) {
                Write-Host "无法自动启动 Kiro IDE，请手动启动" -ForegroundColor Yellow
            }
        }

        Write-Host ""
        Write-Host "正在等待登录完成..." -ForegroundColor Cyan
        Write-Host "提示：按 Ctrl+C 可以中断等待" -ForegroundColor Gray

        $waitTime = 0
        # 循环检查直到登录完成
        while (-not (Test-Path $kiroTokenPath)) {
            Start-Sleep -Seconds 2
            $waitTime += 2
            Write-Host "." -NoNewline -ForegroundColor Yellow

            # 每30秒提示一次
            if ($waitTime % 30 -eq 0) {
                Write-Host ""
                Write-Host "仍在等待登录... (已等待 $waitTime 秒)" -ForegroundColor Gray
                Write-Host "请确保已在 Kiro IDE 中完成登录操作" -ForegroundColor Cyan
            }
        }

        Write-Host ""
        Write-Host "检测到登录成功！" -ForegroundColor Green
    } else {
        Write-Host "检测到 Kiro IDE 已安装并已登录" -ForegroundColor Green
    }
}

# 检查软件状态
Write-Host "检查软件安装状态..." -ForegroundColor Cyan
$missingSoftware = @()
if (-not (Get-Command claude -ErrorAction SilentlyContinue)) {
    $missingSoftware += "Claude Code"
    Write-Host "- Claude Code: 未安装" -ForegroundColor Red
} else {
    Write-Host "- Claude Code: 已安装" -ForegroundColor Green
}

# 检查 Claude Code Router 是否已全局安装
$routerInstalled = $false
if (Get-Command ccr -ErrorAction SilentlyContinue) {
    $routerInstalled = $true
}

if (-not $routerInstalled) {
    $missingSoftware += "Claude Code Router"
    Write-Host "- Claude Code Router: 未安装" -ForegroundColor Red
} else {
    Write-Host "- Claude Code Router: 已安装" -ForegroundColor Green
}

if (-not (winget list | Select-String "Visual Studio Code")) {
    $missingSoftware += "VS Code"
    Write-Host "- VS Code: 未安装" -ForegroundColor Red
} else {
    Write-Host "- VS Code: 已安装" -ForegroundColor Green
}

# 询问安装盘符（无论是否缺少软件都询问）
Write-Host ""
$driveLetter = Read-Host "请输入安装盘符 (e.g., F)"
$hotyiDevPath = "$driveLetter" + ":\hotyi-dev"
New-Item -Path $hotyiDevPath -ItemType Directory -Force

# 检查 AIClient-2-API 是否需要安装
if (-not (Test-Path "$hotyiDevPath\AIClient-2-API\package.json")) {
    $missingSoftware += "AIClient-2-API"
    Write-Host "- AIClient-2-API: 未安装" -ForegroundColor Red
} else {
    Write-Host "- AIClient-2-API: 已安装" -ForegroundColor Green
}

Write-Host ""
if ($missingSoftware.Count -gt 0) {
    Write-Host "检测到缺少软件: $($missingSoftware -join ', ')" -ForegroundColor Yellow
    $installChoice = Read-Host "是否安装缺少的软件? (y/n)"
} else {
    Write-Host "所有软件都已安装，是否重新配置? (y/n)" -ForegroundColor Green
    $installChoice = Read-Host
}

if ($installChoice -eq "y") {
    # 安装缺少的软件
    if ($missingSoftware.Count -gt 0) {
        Write-Host "开始安装缺少的软件..." -ForegroundColor Cyan

        # 安装 VS Code（可选）
        if ($missingSoftware -contains "VS Code") {
            $installVSCode = Read-Host "是否安装 VS Code? (y/n)"
            if ($installVSCode -eq "y") {
                Write-Host "安装 VS Code..."
                winget install Microsoft.VisualStudioCode --accept-package-agreements --accept-source-agreements --scope user
            }
        }

        # 安装 Claude Code
        if ($missingSoftware -contains "Claude Code") {
            Write-Host "安装 Claude Code..."
            if (Get-Command npm -ErrorAction SilentlyContinue) {
                try {
                    npm install -g @anthropic-ai/claude-code
                    Write-Host "Claude Code 安装成功" -ForegroundColor Green
                } catch {
                    Write-Host "Claude Code 安装失败: $($_.Exception.Message)" -ForegroundColor Red
                }
            } else {
                Write-Host "npm 不可用，请重启 PowerShell 后手动安装" -ForegroundColor Red
            }
        }

        # 安装 Claude Code Router
        if ($missingSoftware -contains "Claude Code Router") {
            Write-Host "安装 Claude Code Router..."
            if (Get-Command npm -ErrorAction SilentlyContinue) {
                try {
                    # 全局安装 Claude Code Router
                    Write-Host "全局安装 Claude Code Router..." -ForegroundColor Yellow
                    npm install -g @musistudio/claude-code-router

                    # 刷新环境变量以确保 ccr 命令可用
                    Refresh-Environment

                    # 验证安装是否成功
                    if (Get-Command ccr -ErrorAction SilentlyContinue) {
                        Write-Host "Claude Code Router 全局安装成功，ccr 命令已可用" -ForegroundColor Green
                    } else {
                        Write-Host "Claude Code Router 安装完成，但 ccr 命令可能需要重启 PowerShell 后才能使用" -ForegroundColor Yellow
                    }
                } catch {
                    Write-Host "Claude Code Router 安装失败: $($_.Exception.Message)" -ForegroundColor Red
                }
            } else {
                Write-Host "npm 不可用，请重启 PowerShell 后手动安装" -ForegroundColor Red
            }
        }

        # 安装 AIClient-2-API
        if ($missingSoftware -contains "AIClient-2-API") {
            Write-Host "安装 AIClient-2-API..."
            if (Get-Command git -ErrorAction SilentlyContinue) {
                try {
                    $aiclientPath = "$hotyiDevPath\AIClient-2-API"
                    # 如果目录已存在，先删除以确保全新安装
                    if (Test-Path $aiclientPath) {
                        Write-Host "删除现有 AIClient-2-API 目录..." -ForegroundColor Yellow
                        Remove-Item -Path $aiclientPath -Recurse -Force -ErrorAction SilentlyContinue
                    }

                    git clone https://github.com/justlovemaki/AIClient-2-API.git $aiclientPath
                    if (Test-Path $aiclientPath) {
                        Push-Location $aiclientPath
                        if (Get-Command npm -ErrorAction SilentlyContinue) {
                            npm install
                            Write-Host "AIClient-2-API 安装成功" -ForegroundColor Green
                        } else {
                            Write-Host "npm 不可用，请稍后手动运行 npm install" -ForegroundColor Yellow
                        }
                        Pop-Location
                    }
                } catch {
                    Write-Host "AIClient-2-API 安装失败: $($_.Exception.Message)" -ForegroundColor Red
                }
            } else {
                Write-Host "git 不可用，请重启 PowerShell 后手动安装" -ForegroundColor Red
            }
        }
    }

    # 配置参数（无论是否安装软件都执行）
    Write-Host ""
    Write-Host "配置系统参数..." -ForegroundColor Cyan

    # 询问密钥和端口
    $apiKey = Read-Host "请输入 Claude API 密钥 (e.g., 1234)"

    # AIClient 端口输入和检查循环
    do {
        $aiclientPortInput = Read-Host "请输入 AIClient Server Port (默认 4000)"
        if ([string]::IsNullOrWhiteSpace($aiclientPortInput)) {
            $aiclientPort = 4000
        } else {
            $aiclientPort = [int]$aiclientPortInput
        }
        $portCheck = netstat -ano | Select-String ":$aiclientPort\s"
        if ($portCheck) {
            Write-Host "端口 $aiclientPort 已被占用，请选择其他端口。" -ForegroundColor Red
        }
    } while ($portCheck)

    # Router 端口输入和检查循环
    do {
        $routerPortInput = Read-Host "请输入 Router Port (默认 8000)"
        if ([string]::IsNullOrWhiteSpace($routerPortInput)) {
            $routerPort = 8000
        } else {
            $routerPort = [int]$routerPortInput
        }
        $portCheck = netstat -ano | Select-String ":$routerPort\s"
        if ($portCheck) {
            Write-Host "端口 $routerPort 已被占用，请选择其他端口。" -ForegroundColor Red
        }
    } while ($portCheck)

    # MCP Router 端口输入和检查循环
    do {
        $mcpRouterPortInput = Read-Host "请输入 MCP Router Port (默认 8001)"
        if ([string]::IsNullOrWhiteSpace($mcpRouterPortInput)) {
            $mcpRouterPort = 8001
        } else {
            $mcpRouterPort = [int]$mcpRouterPortInput
        }
        $portCheck = netstat -ano | Select-String ":$mcpRouterPort\s"
        if ($portCheck) {
            Write-Host "端口 $mcpRouterPort 已被占用，请选择其他端口。" -ForegroundColor Red
        }
    } while ($portCheck)

    $qwenApiKey = Read-Host "请输入 Qwen API 密钥 (e.g., sk-f566b65f141646609ab0cf23dcf3fa5b)"

    # 获取用户文件夹（兼容 Windows 10/11）
    $userFolder = $env:USERPROFILE

    Write-Host ""
    Write-Host "生成配置文件..." -ForegroundColor Cyan

    # 写入配置
    # Claude settings.json
    $claudeSettingsPath = "$userFolder\.claude\settings.json"
    New-Item -Path (Split-Path $claudeSettingsPath -Parent) -ItemType Directory -Force
    $claudeSettings = @{
        api = @{
            baseUrl = "http://127.0.0.1:$aiclientPort"
            apiKey = $apiKey
        }
        mcp = @{
            enabled = $true
            defaultServer = "ai-client-mcp"
        }
        mcpServers = @{
            "ai-client-mcp" = @{
                transport = "http"
                url = "http://127.0.0.1:$aiclientPort/claude-kiro-oauth"
                env = @{
                    ANTHROPIC_API_KEY = $apiKey
                    ANTHROPIC_MODEL = "claude-sonnet-4-5-20251001"
                }
            }
            "router-mcp" = @{
                transport = "http"
                url = "http://127.0.0.1:$mcpRouterPort"
                env = @{
                    ANTHROPIC_API_KEY = $apiKey
                    ANTHROPIC_MODEL = "qwen3-coder-72b"
                }
            }
        }
    }
    $claudeSettings | ConvertTo-Json -Depth 10 | Set-Content $claudeSettingsPath -Encoding UTF8
    Write-Host "- Claude settings.json 已生成" -ForegroundColor Green

    # Router config.json
    $routerConfigPath = "$userFolder\.claude-code-router\config.json"
    New-Item -Path (Split-Path $routerConfigPath -Parent) -ItemType Directory -Force
    $routerConfig = @{
        APIKEY = $apiKey
        PROXY_URL = $null
        LOG = $true
        LOG_LEVEL = "debug"
        API_TIMEOUT_MS = 600000
        NON_INTERACTIVE_MODE = $false
        API_PORT = [int]$routerPort
        UI_PORT = 3456
        Providers = @(
            @{
                name = "kiro-via-aiclient"
                api_base_url = "http://127.0.0.1:$aiclientPort/v1/chat/completions"
                api_key = $apiKey
                models = @("claude-sonnet-4-5-20251001")
                transformer = @{ use = @("openai") }
            },
            @{
                name = "qwen3-max"
                api_base_url = "https://dashscope.aliyuncs.com/compatible-mode/v1"
                api_key = $qwenApiKey
                models = @("qwen3-max")
                transformer = @{ use = @("openai") }
            },
            @{
                name = "qwen-plus-2025-07-28"
                api_base_url = "https://dashscope.aliyuncs.com/compatible-mode/v1"
                api_key = $qwenApiKey
                models = @("qwen-plus-2025-07-28")
                transformer = @{ use = @("openai") }
            },
            @{
                name = "deepseek-v3.2-exp"
                api_base_url = "https://dashscope.aliyuncs.com/compatible-mode/v1"
                api_key = $qwenApiKey
                models = @("deepseek-v3.2-exp")
                transformer = @{ use = @("openai") }
            }
        )
        Router = @{
            default = "qwen3-max,qwen3-max"
            background = "qwen3-max,qwen3-max"
            think = "qwen3-max,qwen3-max"
            longContext = "deepseek-v3.2-exp,deepseek-v3.2-exp"
            longContextThreshold = 60000
            coding = "qwen-plus-2025-07-28,qwen-plus-2025-07-28"
        }
    }
    $routerConfig | ConvertTo-Json -Depth 10 | Set-Content $routerConfigPath -Encoding UTF8
    Write-Host "- Router config.json 已生成" -ForegroundColor Green

    # AIClient config.json (新版本配置文件路径: configs/config.json)
    $aiclientConfigPath = "$hotyiDevPath\AIClient-2-API\configs\config.json"
    New-Item -Path (Split-Path $aiclientConfigPath -Parent) -ItemType Directory -Force

    # 使用 PowerShell 对象构建配置，避免转义问题
    # 新版本配置格式，包含所有必需字段
    $aiclientConfig = @{
        "REQUIRED_API_KEY" = $apiKey
        "SERVER_PORT" = $aiclientPort
        "HOST" = "127.0.0.1"
        "MODEL_PROVIDER" = "claude-kiro-oauth"
        "SYSTEM_PROMPT_FILE_PATH" = "configs/input_system_prompt.txt"
        "SYSTEM_PROMPT_MODE" = "append"
        "PROMPT_LOG_BASE_NAME" = "$hotyiDevPath\AIClient-2-API\claude_logs"
        "PROMPT_LOG_MODE" = "file"
        "REQUEST_MAX_RETRIES" = 5
        "REQUEST_BASE_DELAY" = 1000
        "CRON_NEAR_MINUTES" = 1
        "CRON_REFRESH_TOKEN" = $false
        "PROVIDER_POOLS_FILE_PATH" = "configs/provider_pools.json"
        "MAX_ERROR_COUNT" = 99
        "KIRO_OAUTH_CREDS_FILE_PATH" = "$userFolder\.aws\sso\cache\kiro-auth-token.json"
        "PROJECT_ID" = "kiro-test-project"
        "providerFallbackChain" = @{}
        "modelFallbackMapping" = @{}
        "PROXY_URL" = $null
        "PROXY_ENABLED_PROVIDERS" = @()
    }

    # 转换为 JSON 并修正路径转义问题
    $aiclientConfigJson = $aiclientConfig | ConvertTo-Json -Depth 10
    # 修正 ConvertTo-Json 产生的双重转义问题
    $aiclientConfigJson = $aiclientConfigJson -replace '\\\\\\\\', '\\'
    [System.IO.File]::WriteAllText($aiclientConfigPath, $aiclientConfigJson, [System.Text.UTF8Encoding]::new($false))
    Write-Host "- AIClient configs/config.json 已生成" -ForegroundColor Green

    # 生成 provider_pools.json（新版本必需）
    $providerPoolsPath = "$hotyiDevPath\AIClient-2-API\configs\provider_pools.json"
    $providerPools = @{
        "claude-kiro-oauth" = @(
            @{
                "customName" = "Kiro OAuth 主节点"
                "KIRO_OAUTH_CREDS_FILE_PATH" = "$userFolder\.aws\sso\cache\kiro-auth-token.json"
                "uuid" = "kiro-main-node"
                "checkModelName" = $null
                "checkHealth" = $false
                "isHealthy" = $true
                "isDisabled" = $false
                "lastUsed" = $null
                "usageCount" = 0
                "errorCount" = 0
                "lastErrorTime" = $null
            }
        )
    }
    $providerPoolsJson = $providerPools | ConvertTo-Json -Depth 10
    $providerPoolsJson = $providerPoolsJson -replace '\\\\\\\\', '\\'
    [System.IO.File]::WriteAllText($providerPoolsPath, $providerPoolsJson, [System.Text.UTF8Encoding]::new($false))
    Write-Host "- AIClient configs/provider_pools.json 已生成" -ForegroundColor Green
    
    # 删除旧版本根目录的 config.json（如果存在）
    $oldConfigPath = "$hotyiDevPath\AIClient-2-API\config.json"
    if (Test-Path $oldConfigPath) {
        Remove-Item -Path $oldConfigPath -Force -ErrorAction SilentlyContinue
        Write-Host "- 已删除旧版本 config.json" -ForegroundColor Yellow
    }

    # 安装和配置 Claude-MCP-Router
    Write-Host "安装 Claude-MCP-Router..." -ForegroundColor Cyan
    $mcpPath = "$hotyiDevPath\Claude-MCP-Router"

    # 如果目录已存在，先删除以确保全新安装
    if (Test-Path $mcpPath) {
        Write-Host "删除现有 Claude-MCP-Router 目录..." -ForegroundColor Yellow
        Remove-Item -Path $mcpPath -Recurse -Force -ErrorAction SilentlyContinue
    }

    New-Item -Path $mcpPath -ItemType Directory -Force

    # 进入 Claude-MCP-Router 目录并初始化项目
    Push-Location $mcpPath
    try {
        # 初始化 npm 项目
        Write-Host "初始化 npm 项目..." -ForegroundColor Yellow
        npm init -y

        # 安装 MCP SDK
        Write-Host "安装 @modelcontextprotocol/sdk..." -ForegroundColor Yellow
        npm install @modelcontextprotocol/sdk

        Write-Host "Claude-MCP-Router 依赖安装完成" -ForegroundColor Green
    } catch {
        Write-Host "Claude-MCP-Router 安装失败: $($_.Exception.Message)" -ForegroundColor Red
    } finally {
        Pop-Location
    }

    # 生成 task_history.json
    $taskHistory = @(
        @{ id = "1"; name = "Task1: Hello" },
        @{ id = "2"; name = "Task2: Code Gen" }
    )
    $taskHistory | ConvertTo-Json -Depth 10 | Set-Content "$mcpPath\task_history.json" -Encoding UTF8

    # 生成 server.js
    $serverJs = @'
const http = require('http');
const url = require('url');
const fs = require('fs').promises;
const path = require('path');

const HISTORY_FILE = path.join(__dirname, 'task_history.json');

// 加载历史
async function loadHistory() {
  try {
    const data = await fs.readFile(HISTORY_FILE, 'utf8');
    return JSON.parse(data);
  } catch (e) {
    return [];
  }
}

// 保存历史
async function saveHistory(tasks) {
  await fs.writeFile(HISTORY_FILE, JSON.stringify(tasks, null, 2));
}

const server = http.createServer(async (req, res) => {
  const parsedUrl = url.parse(req.url, true);
  const path = parsedUrl.pathname;

  if (req.method === 'POST') {
    let body = '';
    req.on('data', chunk => body += chunk);
    req.on('end', async () => {
      try {
        const data = JSON.parse(body);
        if (path === '/listHistory') {  // -r: 返回任务列表
          const tasks = await loadHistory();
          res.writeHead(200, { 'Content-Type': 'application/json' });
          res.end(JSON.stringify({ tasks }));
        } else if (path === '/resumeTask') {  // -c: 恢复任务
          const tasks = await loadHistory();
          const taskId = data.taskId || 'last';
          const task = taskId === 'last' ? tasks[tasks.length - 1] : tasks.find(t => t.id === taskId);
          res.writeHead(200, { 'Content-Type': 'application/json' });
          res.end(JSON.stringify({ success: true, task: task || 'No task found' }));
        } else {
          res.writeHead(404);
          res.end('Not found');
        }
      } catch (e) {
        res.writeHead(500);
        res.end(JSON.stringify({ error: e.message }));
      }
    });
  } else {
    res.writeHead(405);
    res.end('Method not allowed');
  }
});

server.listen(PORT_PLACEHOLDER, () => console.log('MCP server running on http://127.0.0.1:PORT_PLACEHOLDER'));
'@

    # 替换端口占位符
    $serverJs = $serverJs -replace 'PORT_PLACEHOLDER', $mcpRouterPort
    $serverJs | Set-Content -Path "$mcpPath\server.js" -Encoding UTF8
    Write-Host "- Claude-MCP-Router 项目已创建并配置完成" -ForegroundColor Green

    # 三个切换脚本
    Write-Host ""
    Write-Host "生成切换脚本..." -ForegroundColor Cyan
    $switchScriptsPath = "$hotyiDevPath\Scripts"
    New-Item -Path $switchScriptsPath -ItemType Directory -Force

    $switchToAiclient = @"
# 切换到 AIClient-2-API 模式（Kiro + AIClient MCP）
`$configPath = "$userFolder\.claude\settings.json"
`$config = Get-Content `$configPath -Raw | ConvertFrom-Json
`$config.api.baseUrl = "http://127.0.0.1:$aiclientPort"
`$config.mcp.defaultServer = "ai-client-mcp"
`$config | ConvertTo-Json -Depth 10 | Set-Content `$configPath
Write-Host "Switched to AIClient (Kiro)"
taskkill /F /IM node.exe /FI "WINDOWTITLE eq Router*" /T 2>`$null
taskkill /F /IM node.exe /FI "WINDOWTITLE eq MCP*" /T 2>`$null
Start-Process -FilePath "node" -ArgumentList "src/services/api-server.js" -WorkingDirectory "$hotyiDevPath\AIClient-2-API"
"@
    $switchToAiclient | Set-Content -Path "$switchScriptsPath\switch_to_aiclient.ps1" -Encoding UTF8
    Write-Host "- switch_to_aiclient.ps1 已生成" -ForegroundColor Green

    $switchToRouterKiro = @"
# 切换到 Router 链式模式（Kiro via AIClient + AIClient MCP）
`$configPath = "$userFolder\.claude\settings.json"
# 读取 settings.json
`$config = Get-Content `$configPath -Raw | ConvertFrom-Json
# 修改 baseUrl 和 defaultServer
`$config.api.baseUrl = "http://127.0.0.1:$routerPort"
`$config.mcp.defaultServer = "ai-client-mcp"
# 保存回 settings.json
`$config | ConvertTo-Json -Depth 10 | Set-Content `$configPath
Write-Host "Switched to Router (Kiro chain)"
# 启动 Router
Start-Process -FilePath "ccr" -ArgumentList "start --port $routerPort"
# 启动 AIClient
Start-Process -FilePath "node" -ArgumentList "src/services/api-server.js" -WorkingDirectory "$hotyiDevPath\AIClient-2-API"
# 停止 MCP
taskkill /F /IM node.exe /FI "WINDOWTITLE eq MCP*" /T 2>`$null
"@
    $switchToRouterKiro | Set-Content -Path "$switchScriptsPath\switch_to_router_kiro.ps1" -Encoding UTF8
    Write-Host "- switch_to_router_kiro.ps1 已生成" -ForegroundColor Green

    $switchToRouterQwen = @"
# 切换到 Router Qwen 模式（Qwen 直接 + Router MCP）
`$configPath = "$userFolder\.claude\settings.json"
# 读取 settings.json
`$config = Get-Content `$configPath -Raw | ConvertFrom-Json
# 修改 baseUrl 和 defaultServer
`$config.api.baseUrl = "http://127.0.0.1:$routerPort"
`$config.mcp.defaultServer = "router-mcp"
# 保存回 settings.json
`$config | ConvertTo-Json -Depth 10 | Set-Content `$configPath
Write-Host "Switched to Router (Qwen)"
# 停止 AIClient
taskkill /F /IM node.exe /FI "WINDOWTITLE eq AIClient*" /T 2>`$null
# 启动 Router
Start-Process -FilePath "ccr" -ArgumentList "start --port $routerPort"
# 启动 Router MCP
Start-Process -FilePath "node" -ArgumentList "server.js" -WorkingDirectory "$hotyiDevPath\Claude-MCP-Router"
"@
    $switchToRouterQwen | Set-Content -Path "$switchScriptsPath\switch_to_router_qwen.ps1" -Encoding UTF8
    Write-Host "- switch_to_router_qwen.ps1 已生成" -ForegroundColor Green

    # 询问是否添加简短指令
    Write-Host ""
    Write-Host "简短指令可以让你在 PowerShell 中快速执行常用命令：" -ForegroundColor Cyan
    Write-Host "  goa  -> 切换到 AIClient 模式"
    Write-Host "  gok  -> 切换到 Router Kiro 链式模式"
    Write-Host "  goq  -> 切换到 Router Qwen 模式"
    Write-Host "  aic  -> 启动 AIClient-2-API 服务"
    $addAliases = Read-Host "是否添加简短指令到 PowerShell? (y/n, 默认 y)"
    if (-not $addAliases) { $addAliases = "y" }
    
    if ($addAliases -eq "y") {
        # 生成简短指令配置
        Write-Host "生成简短指令配置..." -ForegroundColor Cyan
        $aliasScriptPath = "$switchScriptsPath\aliases.ps1"
        $defaultAliases = @"
# Claude Code 部署工具 - 简短指令配置
# 自动生成

function goa { & "$switchScriptsPath\switch_to_aiclient.ps1" }
function gok { & "$switchScriptsPath\switch_to_router_kiro.ps1" }
function goq { & "$switchScriptsPath\switch_to_router_qwen.ps1" }
function aic { Push-Location "$hotyiDevPath\AIClient-2-API"; node src/services/api-server.js; Pop-Location }
"@
        $defaultAliases | Set-Content $aliasScriptPath -Encoding UTF8
        Write-Host "- aliases.ps1 已生成" -ForegroundColor Green

        # 配置 PowerShell Profile 引用简短指令
        $profilePath = $PROFILE
        $profileDir = Split-Path $profilePath -Parent
        if (-not (Test-Path $profileDir)) {
            New-Item -Path $profileDir -ItemType Directory -Force | Out-Null
        }
        
        if (Test-Path $profilePath) {
            $profileContent = Get-Content $profilePath -Raw -ErrorAction SilentlyContinue
            if ($profileContent -notmatch [regex]::Escape($aliasScriptPath)) {
                Add-Content $profilePath "`n# Claude Code 部署工具简短指令`n. `"$aliasScriptPath`"" -Encoding UTF8
                Write-Host "- 已将简短指令添加到 PowerShell Profile" -ForegroundColor Green
            } else {
                Write-Host "- PowerShell Profile 已包含简短指令引用" -ForegroundColor Yellow
            }
        } else {
            "# PowerShell Profile`n# Claude Code 部署工具简短指令`n. `"$aliasScriptPath`"" | Set-Content $profilePath -Encoding UTF8
            Write-Host "- 已创建 PowerShell Profile 并添加简短指令" -ForegroundColor Green
        }
        Write-Host "  提示：重新打开 PowerShell 后生效" -ForegroundColor Cyan
    } else {
        Write-Host "跳过简短指令配置，可稍后通过菜单选项 7 添加" -ForegroundColor Yellow
    }

    # 配置 Kiro token
    Write-Host ""
    Write-Host "配置 Kiro token..." -ForegroundColor Cyan
    $kiroTokenPath = "$userFolder\.aws\sso\cache\kiro-auth-token.json"
    if (Test-Path $kiroTokenPath) {
        $kiroToken = Get-Content $kiroTokenPath -Raw | ConvertFrom-Json
        $kiroToken | Add-Member -MemberType NoteProperty -Name "region" -Value "us-east-1" -Force
        $kiroTokenJson = $kiroToken | ConvertTo-Json -Depth 10
        [System.IO.File]::WriteAllText($kiroTokenPath, $kiroTokenJson, [System.Text.UTF8Encoding]::new($false))
        Write-Host "- Kiro token 已配置" -ForegroundColor Green
    } else {
        Write-Host "- Kiro token 文件不存在，跳过配置" -ForegroundColor Yellow
    }

    # 设置环境变量
    Write-Host ""
    Write-Host "设置环境变量..." -ForegroundColor Cyan
    [System.Environment]::SetEnvironmentVariable("ANTHROPIC_BASE_URL", "http://127.0.0.1:$aiclientPort", "User")
    [System.Environment]::SetEnvironmentVariable("ANTHROPIC_API_KEY", $apiKey, "User")
    Write-Host "- 环境变量已设置" -ForegroundColor Green

    Write-Host ""
    Write-Host "安装和配置完成！运行 'ccr ui' 测试配置。" -ForegroundColor Green
} else {
    Write-Host "未选择安装/配置，脚本退出。" -ForegroundColor Red
    Exit
}

# 安装完成后的模式切换菜单
Write-Host "安装完成！进入模式切换菜单..." -ForegroundColor Green

# 确保变量已定义
if (-not $hotyiDevPath -and $driveLetter) {
    $hotyiDevPath = "$driveLetter" + ":\hotyi-dev"
}
if (-not $userFolder) {
    $userFolder = $env:USERPROFILE
}

while ($true) {
    Write-Host ""
    Write-Host "请选择运行模式：" -ForegroundColor Cyan
    Write-Host "1. AIClient 模式"
    Write-Host "2. Router Kiro 链式模式 (默认)"
    Write-Host "3. Router Qwen 模式"
    Write-Host "4. 退出"
    $choice = Read-Host "请输入选项 (1-4, 默认 2)"

    if (-not $choice) { $choice = "2" }

    switch ($choice) {
        "1" {
            if ($hotyiDevPath -and (Test-Path "$hotyiDevPath\Scripts\switch_to_aiclient.ps1")) {
                Write-Host "切换到 AIClient 模式..."
                & "$hotyiDevPath\Scripts\switch_to_aiclient.ps1"
                Exit
            } else {
                Write-Host "切换脚本不存在，安装可能未完成。" -ForegroundColor Red
            }
        }
        "2" {
            if ($hotyiDevPath -and (Test-Path "$hotyiDevPath\Scripts\switch_to_router_kiro.ps1")) {
                Write-Host "切换到 Router Kiro 链式模式..."
                & "$hotyiDevPath\Scripts\switch_to_router_kiro.ps1"
                Exit
            } else {
                Write-Host "切换脚本不存在，安装可能未完成。" -ForegroundColor Red
            }
        }
        "3" {
            if ($hotyiDevPath -and (Test-Path "$hotyiDevPath\Scripts\switch_to_router_qwen.ps1")) {
                Write-Host "切换到 Router Qwen 模式..."
                & "$hotyiDevPath\Scripts\switch_to_router_qwen.ps1"
                Exit
            } else {
                Write-Host "切换脚本不存在，安装可能未完成。" -ForegroundColor Red
            }
        }
        "4" {
            Write-Host "退出脚本..." -ForegroundColor Green
            Exit
        }
        default {
            Write-Host "无效选项，请重新选择。" -ForegroundColor Red
        }
    }
}
