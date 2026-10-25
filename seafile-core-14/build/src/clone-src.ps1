$ErrorActionPreference = 'Stop'

# ===== 配置区 =====
$Mirror = 'https://gh-proxy.com/https://github.com'    # 直连 GitHub 时改成 ''

# [ordered] 保证按声明顺序执行,普通 @{...} 的键序是乱的
$Repos = [ordered]@{
    'libevhtp'       = @{ Url = "$Mirror/haiwen/libevhtp.git";       CloneArgs = @('--branch','1.1.6','--depth=1') }
    'libsearpc'      = @{ Url = "$Mirror/haiwen/libsearpc.git";      CloneArgs = @('--branch','v3.3-latest','--depth=1') }
    'seafile-server' = @{ Url = "$Mirror/haiwen/seafile-server.git"; CloneArgs = @('--branch','v14.0.9-server','--depth=100') }
    'seafobj'        = @{ Url = "$Mirror/haiwen/seafobj.git";        CloneArgs = @('--branch','v14.0.9-server','--depth=1') }
    'seafdav'        = @{ Url = "$Mirror/haiwen/seafdav.git";        CloneArgs = @('--branch','v14.0.9-server','--depth=1') }
    'seafevents'     = @{ Url = "$Mirror/haiwen/seafevents.git";     CloneArgs = @('--branch','v14.0.9-server','--depth=1') }
    'seahub'         = @{ Url = "$Mirror/haiwen/seahub.git";         CloneArgs = @('--branch','v14.0.9-server','--depth=100') }
}
# ==================

function Invoke-GitClone {
    param([string]$Dir, [string]$Url, [string[]]$CloneArgs)

    # git 把进度写到 stderr;PS 5.1 下 EAP=Stop 会把 stderr 当 terminating error 抛出,
    # 所以临时降级 EAP,并把 ErrorRecord 转成普通字符串输出
    $prevEap = $ErrorActionPreference
    $ErrorActionPreference = 'Continue'
    try {
        & git clone @CloneArgs $Url $Dir 2>&1 | ForEach-Object { Write-Host "  $_" }
    } finally {
        $ErrorActionPreference = $prevEap
    }
    return $LASTEXITCODE
}

if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
    Write-Error 'git not found in PATH'
    exit 1
}

try {
    foreach ($entry in $Repos.GetEnumerator()) {
        $dir  = $entry.Key
        $url  = $entry.Value.Url
        $cArgs = $entry.Value.CloneArgs

        # 与 bash 版一致:目录在 且 .git 在 才算已 clone
        if (Test-Path -LiteralPath (Join-Path $dir '.git')) {
            Write-Host "SKIP      $dir" -ForegroundColor DarkGray
        }
        elseif (Test-Path -LiteralPath $dir) {
            Write-Host "BROKEN    $dir (incomplete, re-cloning)" -ForegroundColor Yellow
            Remove-Item -LiteralPath $dir -Recurse -Force
            if ((Invoke-GitClone -Dir $dir -Url $url -CloneArgs $cArgs) -ne 0) {
                Write-Host "FAILED    $dir" -ForegroundColor Red
            }
        }
        else {
            Write-Host "CLONE     $dir"
            if ((Invoke-GitClone -Dir $dir -Url $url -CloneArgs $cArgs) -ne 0) {
                Write-Host "FAILED    $dir" -ForegroundColor Red
            }
        }
    }

    Write-Host ''
    Write-Host '=== 仓库状态汇总 ==='
    foreach ($entry in $Repos.GetEnumerator()) {
        $dir = $entry.Key
        if (Test-Path -LiteralPath (Join-Path $dir '.git')) {
            try {
                $head = (& git -C $dir rev-parse --short HEAD 2>$null) -join ''
            } catch { $head = 'unknown' }
            Write-Host ('OK      {0,-16} @ {1}' -f $dir, $head)
        } else {
            Write-Host ('MISSING ' + $dir) -ForegroundColor Red
        }
    }
}
finally {
    Pop-Location
}
