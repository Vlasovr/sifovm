$ErrorActionPreference = "Stop"

$root = Resolve-Path (Join-Path $PSScriptRoot "..")
$ghdlRoot = Join-Path $PSScriptRoot "ghdl_work"
$vcdRoot = Join-Path $PSScriptRoot "vcd"
New-Item -ItemType Directory -Force -Path $ghdlRoot, $vcdRoot | Out-Null

function Invoke-GhdlLab {
  param(
    [string]$Name,
    [string[]]$Files,
    [string]$Tb,
    [string]$StopTime
  )

  $work = Join-Path $ghdlRoot $Name
  if (Test-Path $work) {
    Remove-Item -Recurse -Force $work
  }
  New-Item -ItemType Directory -Force -Path $work | Out-Null

  foreach ($file in $Files) {
    & ghdl -a --std=08 --workdir=$work (Join-Path $root $file)
    if ($LASTEXITCODE -ne 0) { throw "GHDL analysis failed for $file" }
  }
  & ghdl -e --std=08 --workdir=$work $Tb
  if ($LASTEXITCODE -ne 0) { throw "GHDL elaboration failed for $Tb" }
  & ghdl -r --std=08 --workdir=$work $Tb "--vcd=$(Join-Path $vcdRoot ($Name + '.vcd'))" "--stop-time=$StopTime"
  if ($LASTEXITCODE -ne 0) { throw "GHDL simulation failed for $Tb" }
}

$common = @("common/lab_variant_pkg.vhd")

Invoke-GhdlLab "lab5_alu" ($common + @(
  "lab5_alu/src/alu_cmp.vhd",
  "lab5_alu/src/alu_nor.vhd",
  "lab5_alu/src/alu_sra.vhd",
  "lab5_alu/src/alu_flags.vhd",
  "lab5_alu/src/alu_control.vhd",
  "lab5_alu/src/lab5_alu_top.vhd",
  "lab5_alu/tb/tb_lab5_alu.vhd"
)) "tb_lab5_alu" "100ns"

Invoke-GhdlLab "lab6_stack" ($common + @(
  "lab6_stack/src/stack7x16.vhd",
  "lab6_stack/src/stack_control.vhd",
  "lab6_stack/src/lab6_stack_top.vhd",
  "lab6_stack/tb/tb_lab6_stack.vhd"
)) "tb_lab6_stack" "250ns"

Invoke-GhdlLab "lab7_bus_arbiter" ($common + @(
  "lab7_bus_arbiter/src/master_device.vhd",
  "lab7_bus_arbiter/src/bus_arbiter_parallel_quantum.vhd",
  "lab7_bus_arbiter/src/bus_mux_4.vhd",
  "lab7_bus_arbiter/src/slave_sync.vhd",
  "lab7_bus_arbiter/src/lab7_bus_top.vhd",
  "lab7_bus_arbiter/tb/tb_lab7_bus.vhd"
)) "tb_lab7_bus" "400ns"

Invoke-GhdlLab "lab8_cache" ($common + @(
  "lab8_cache/src/cache_direct_mapped.vhd",
  "lab8_cache/src/main_memory_sync.vhd",
  "lab8_cache/src/lab8_cache_top.vhd",
  "lab8_cache/tb/tb_lab8_cache.vhd"
)) "tb_lab8_cache" "800ns"

Write-Host "All GHDL simulations completed. VCD files are in $vcdRoot"
