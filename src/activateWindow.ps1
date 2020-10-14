Add-Type  @"
    using System;
    using System.Runtime.InteropServices;
    using System.Text;
    
    public class Win32
    {
        public delegate void ThreadDelegate(IntPtr hWnd, IntPtr lParam);
        
        [DllImport("user32.dll")]
        public static extern bool EnumThreadWindows(int dwThreadId, ThreadDelegate lpfn,
            IntPtr lParam);

        [DllImport("user32.dll")]
        public static extern IntPtr GetForegroundWindow();

        [DllImport("user32.dll")]
        public static extern bool SetForegroundWindow(IntPtr hWnd);
        
        [DllImport("user32.dll")]
        public static extern bool ShowWindowAsync(IntPtr hWnd, int nCmdShow);
        
        [DllImport("user32.dll", CharSet = CharSet.Auto, SetLastError = true)]
        public static extern int GetWindowText(IntPtr hwnd, StringBuilder lpString, int cch);
        
        [DllImport("user32.dll", SetLastError=true, CharSet=CharSet.Auto)]
        public static extern Int32 GetWindowTextLength(IntPtr hWnd);

        [DllImport("user32.dll")]
        public static extern bool IsIconic(IntPtr hWnd);

        [DllImport("user32.dll")]
        public static extern bool IsWindowVisible(IntPtr hWnd);

        public static string GetTitle(IntPtr hWnd) {
            var len = GetWindowTextLength(hWnd);
            StringBuilder message = new StringBuilder(len + 1);
            GetWindowText(hWnd, message, message.Capacity);
            return message.ToString();
        }
    }
"@

$Host.UI.RawUI.WindowTitle = "Activate Window"
# Set the encoding of the pipe and of the console output
$OutputEncoding = [Console]::OutputEncoding = [Text.UTF8Encoding]::UTF8
$ActiveHandle = [Win32]::GetForegroundWindow()

$windows = @{}

Get-Process | Where { $_.MainWindowTitle -and 
                      ($_.MainWindowHandle -ne $ActiveHandle) -and
                      ($_.ProcessName -ne "TextInputHost") -and
                      ($_.ProcessName -ne "ShellExperienceHost")
                    } | 
foreach {
    $_.Threads.ForEach({
        [void][Win32]::EnumThreadWindows($_.Id, {
            param($hwnd, $lparam)
            if ([Win32]::IsIconic($hwnd) -or [Win32]::IsWindowVisible($hwnd)) {
                $windows[[Win32]::GetTitle($hwnd)] = $hwnd 
            }}, 0)
        })
}

$window = echo $windows.keys | hs

if($window) {
    $iconic = [Win32]::IsIconic($windows[$window])
    if ($iconic) {
        [Win32]::ShowWindowAsync($windows[$window], 3) | Out-Null
    }
    [Win32]::SetForegroundWindow($windows[$window]) | Out-Null
}
