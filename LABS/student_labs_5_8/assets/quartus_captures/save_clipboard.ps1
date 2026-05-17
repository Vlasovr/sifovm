Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing
$out = "D:\git\sifovm\LABS\student_labs_5_8\assets\quartus_captures\lab5_rtl_full_clipboard.png"
if ([System.Windows.Forms.Clipboard]::ContainsImage()) {
  $img = [System.Windows.Forms.Clipboard]::GetImage()
  $img.Save($out, [System.Drawing.Imaging.ImageFormat]::Png)
  $img.Dispose()
  Write-Output $out
} else {
  Write-Error "Clipboard does not contain image"
}
