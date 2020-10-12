Add-Type -memberDefinition:@"
    [DllImport("user32.dll")]
    public static extern IntPtr GetForegroundWindow();
    [DllImport("user32.dll")]
    public static extern bool SetForegroundWindow(IntPtr hWnd);
    [DllImport("user32.dll")]
    public static extern bool IsIconic(IntPtr hWnd);
    [DllImport("user32.dll")]
    public static extern bool ShowWindowAsync(IntPtr hWnd, int nCmdShow);
"@ -name:Native -namespace:Win32

$Host.UI.RawUI.WindowTitle = "Activate Window"

# Set the encoding of the pipe and of the console output
$OutputEncoding = [Console]::OutputEncoding = [Text.UTF8Encoding]::UTF8
$ActiveHandle = [Win32.Native]::GetForegroundWindow()
$procs=@{}

Get-Process | Where { 
    ($_.MainWindowTitle -ne "") -and 
    ($_.MainWindowHandle -ne $ActiveHandle) -and
    ($_.ProcessName -ne "TextInputHost")
} | foreach { $procs[$_.MainWindowTitle] = $_.MainWindowHandle }

$window = echo $procs.keys | hs

if($window) {
    $iconic = [Win32.Native]::IsIconic($procs[$window])
    if ($iconic) {
        [Win32.Native]::ShowWindowAsync($procs[$window], 3) | Out-Null
    }
    [Win32.Native]::SetForegroundWindow($procs[$window]) | Out-Null
}
