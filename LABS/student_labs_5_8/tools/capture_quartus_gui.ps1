param(
    [ValidateSet("rtl", "wave", "all")]
    [string]$Mode = "all"
)

$ErrorActionPreference = "Stop"

$Root = Resolve-Path (Join-Path $PSScriptRoot "..")
$QuartusExe = "D:\quartus\bin\quartus.exe"
$OutDir = Join-Path $Root "assets\quartus_captures"
New-Item -ItemType Directory -Force -Path $OutDir | Out-Null

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

Add-Type @"
using System;
using System.Text;
using System.Runtime.InteropServices;

public static class QGui {
    public delegate bool EnumWindowsProc(IntPtr hWnd, IntPtr lParam);

    [DllImport("user32.dll")]
    public static extern bool EnumWindows(EnumWindowsProc cb, IntPtr lParam);

    [DllImport("user32.dll")]
    public static extern bool IsWindowVisible(IntPtr hWnd);

    [DllImport("user32.dll")]
    public static extern int GetWindowText(IntPtr hWnd, StringBuilder text, int count);

    [DllImport("user32.dll")]
    public static extern uint GetWindowThreadProcessId(IntPtr hWnd, out uint processId);

    [DllImport("user32.dll")]
    public static extern bool SetForegroundWindow(IntPtr hWnd);

    [DllImport("user32.dll")]
    public static extern bool ShowWindow(IntPtr hWnd, int nCmdShow);

    [DllImport("user32.dll")]
    public static extern bool PostMessage(IntPtr hWnd, uint msg, IntPtr wParam, IntPtr lParam);

    [DllImport("user32.dll")]
    public static extern bool SetCursorPos(int x, int y);

    [DllImport("user32.dll")]
    public static extern void mouse_event(uint dwFlags, uint dx, uint dy, uint dwData, UIntPtr dwExtraInfo);

    [DllImport("user32.dll")]
    public static extern bool GetWindowRect(IntPtr hWnd, out RECT rect);

    public struct RECT {
        public int Left;
        public int Top;
        public int Right;
        public int Bottom;
    }
}
"@

function Get-VisibleWindows {
    $windows = New-Object System.Collections.Generic.List[object]
    [QGui]::EnumWindows({
        param([IntPtr]$hWnd, [IntPtr]$lParam)
        if ([QGui]::IsWindowVisible($hWnd)) {
            $sb = New-Object System.Text.StringBuilder 1024
            [void][QGui]::GetWindowText($hWnd, $sb, $sb.Capacity)
            $title = $sb.ToString()
            if ($title.Length -gt 0) {
                [uint32]$windowProcessId = 0
                [void][QGui]::GetWindowThreadProcessId($hWnd, [ref]$windowProcessId)
                $windows.Add([pscustomobject]@{
                    Handle = $hWnd
                    ProcessId = [int]$windowProcessId
                    Title = $title
                })
            }
        }
        return $true
    }, [IntPtr]::Zero) | Out-Null
    return $windows
}

function Close-QuartusUpdateDialogs {
    $closed = $false
    foreach ($win in Get-VisibleWindows) {
        if ($win.Title -eq "Quartus II") {
            [void][QGui]::PostMessage($win.Handle, 0x0010, [IntPtr]::Zero, [IntPtr]::Zero)
            $closed = $true
        }
    }
    return $closed
}

function Wait-NoQuartusModal {
    param([int]$TimeoutSeconds = 10)
    $deadline = (Get-Date).AddSeconds($TimeoutSeconds)
    while ((Get-Date) -lt $deadline) {
        if (-not (Close-QuartusUpdateDialogs)) {
            return
        }
        Start-Sleep -Milliseconds 400
    }
}

function Find-QuartusWindow {
    param(
        [int]$ProcessId,
        [string]$TitleFragment
    )
    foreach ($win in Get-VisibleWindows) {
        if ($win.ProcessId -eq $ProcessId -and $win.Title -like "*$TitleFragment*") {
            return $win
        }
    }
    return $null
}

function Wait-QuartusWindow {
    param(
        [int]$ProcessId,
        [string]$TitleFragment,
        [int]$TimeoutSeconds = 60
    )
    $deadline = (Get-Date).AddSeconds($TimeoutSeconds)
    while ((Get-Date) -lt $deadline) {
        Close-QuartusUpdateDialogs
        $win = Find-QuartusWindow -ProcessId $ProcessId -TitleFragment $TitleFragment
        if ($null -ne $win) {
            return $win
        }
        Start-Sleep -Milliseconds 500
    }
    throw "Timed out waiting for Quartus window '$TitleFragment' in process $ProcessId."
}

function Invoke-Click {
    param([int]$X, [int]$Y)
    [void][QGui]::SetCursorPos($X, $Y)
    Start-Sleep -Milliseconds 120
    [QGui]::mouse_event(0x0002, 0, 0, 0, [UIntPtr]::Zero)
    [QGui]::mouse_event(0x0004, 0, 0, 0, [UIntPtr]::Zero)
    Start-Sleep -Milliseconds 250
}

function Invoke-Hover {
    param([int]$X, [int]$Y)
    [void][QGui]::SetCursorPos($X, $Y)
    Start-Sleep -Milliseconds 450
}

function Set-QuartusForeground {
    param([object]$Window)
    [void][QGui]::ShowWindow($Window.Handle, 3)
    Start-Sleep -Milliseconds 250
    [void][QGui]::SetForegroundWindow($Window.Handle)
    Start-Sleep -Milliseconds 300
}

function Save-ClipboardImage {
    param([string]$Path)
    if (-not [System.Windows.Forms.Clipboard]::ContainsImage()) {
        throw "Clipboard does not contain an image."
    }
    $img = [System.Windows.Forms.Clipboard]::GetImage()
    try {
        $img.Save($Path, [System.Drawing.Imaging.ImageFormat]::Png)
    }
    finally {
        $img.Dispose()
    }
}

function Capture-RtlViewer {
    param(
        [string]$Name,
        [string]$QpfPath,
        [string]$ProjectTitle
    )

    Write-Host "Opening $Name RTL..."
    $proc = Start-Process -FilePath $QuartusExe -ArgumentList "`"$QpfPath`"" -PassThru
    try {
        $main = Wait-QuartusWindow -ProcessId $proc.Id -TitleFragment $ProjectTitle -TimeoutSeconds 90
        Wait-NoQuartusModal -TimeoutSeconds 10
        Set-QuartusForeground -Window $main

        # Tools -> Netlist Viewers -> RTL Viewer. Coordinates are physical pixels for Quartus 9.1 on this VM.
        Invoke-Click 330 33
        Invoke-Hover 416 254
        Invoke-Click 610 255

        $rtl = Wait-QuartusWindow -ProcessId $proc.Id -TitleFragment "[RTL Viewer]" -TimeoutSeconds 90
        Wait-NoQuartusModal -TimeoutSeconds 5
        Set-QuartusForeground -Window $rtl

        # View -> Copy Image -> Full Image.
        [System.Windows.Forms.Clipboard]::Clear()
        for ($attempt = 1; $attempt -le 2; $attempt++) {
            Invoke-Click 86 33
            Invoke-Hover 95 107
            Invoke-Click 226 110
            Start-Sleep -Seconds 3
            if ([System.Windows.Forms.Clipboard]::ContainsImage()) {
                break
            }
        }

        $out = Join-Path $OutDir "$Name`_rtl_viewer_full.png"
        Save-ClipboardImage -Path $out
        Write-Host "Saved $out"
    }
    finally {
        if (-not $proc.HasExited) {
            Stop-Process -Id $proc.Id -Force -ErrorAction SilentlyContinue
        }
        Start-Sleep -Seconds 1
    }
}

$Labs = @(
    @{
        Name = "lab5"
        ProjectTitle = "lab5_alu"
        Qpf = Join-Path $Root "lab5_alu\quartus\lab5_alu.qpf"
    },
    @{
        Name = "lab6"
        ProjectTitle = "lab6_stack"
        Qpf = Join-Path $Root "lab6_stack\quartus\lab6_stack.qpf"
    },
    @{
        Name = "lab7"
        ProjectTitle = "lab7_bus_arbiter"
        Qpf = Join-Path $Root "lab7_bus_arbiter\quartus\lab7_bus_arbiter.qpf"
    },
    @{
        Name = "lab8"
        ProjectTitle = "lab8_cache"
        Qpf = Join-Path $Root "lab8_cache\quartus\lab8_cache.qpf"
    }
)

if ($Mode -in @("rtl", "all")) {
    Get-Process quartus -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue
    foreach ($lab in $Labs) {
        Capture-RtlViewer -Name $lab.Name -QpfPath $lab.Qpf -ProjectTitle $lab.ProjectTitle
    }
}
