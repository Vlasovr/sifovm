# clean-quartus-temp.ps1
param(
    [string]$ProjectRoot = "."
)

Set-Location $ProjectRoot

# 1. Временные каталоги Quartus / ModelSim
$dirs = @(
    "db",
    "incremental_db",
    "simulation",
    "greybox_tmp",
    "tmp",
    "work",
    "modelsim",
    "modelsim_work",
    "cdb",
    "qdb"
)

foreach ($d in $dirs) {
    if (Test-Path $d) {
        Write-Host "Removing directory $d"
        Remove-Item -Recurse -Force $d
    }
}

# 2. Временные / генерируемые файлы по маскам
$patterns = @(
    "*.rpt",
    "*.summary",
    "*.qws",
    "*.smsg",
    "*.jou",
    "*.log",
    "*.chg",
    "*.qmsg",
    "*.eqn",
    "*.eqn.out",
    "*.sdo",
    "*.vo",
    "*.vho",
    "*.sopcinfo",
    "*.html",
    "*.bak",
    "*_generation.rpt"
)

foreach ($p in $patterns) {
    Get-ChildItem -Path . -Recurse -Include $p -ErrorAction SilentlyContinue |
        ForEach-Object {
            Write-Host "Removing file $($_.FullName)"
            Remove-Item -Force $_.FullName
        }
}

Write-Host "Quartus temporary files cleanup finished."