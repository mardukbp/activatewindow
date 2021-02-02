Add-Type  @"
    using System;
    using System.Runtime.InteropServices;
    using System.Text;
    
    public class Win32
    {
        public delegate void ThreadDelegate(IntPtr hWnd, int lParam);
        
        [DllImport("user32.dll")]
        public static extern bool EnumThreadWindows(int dwThreadId, ThreadDelegate lpfn,
            int lParam);

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
            // Window title plus null terminator
            StringBuilder title = new StringBuilder(len + 1);
            GetWindowText(hWnd, title, title.Capacity);
            return title.ToString();
        }
    }
"@

$Host.UI.RawUI.WindowTitle = "Activate Window"
# Set the encoding of the pipe and of the console output
$OutputEncoding = [Console]::OutputEncoding = [Text.UTF8Encoding]::UTF8
$ActiveHandle = [Win32]::GetForegroundWindow()

$windows = @{}

Get-Process | where { ($_.ProcessName -eq "explorer") -or $_.MainWindowTitle -and 
                      ($_.MainWindowHandle -ne $ActiveHandle) -and
                      ($_.ProcessName -ne "WindowsInternal.ComposableShell.Experiences.TextInput.InputApp") -and
                      ($_.ProcessName -ne "TextInputHost") -and
                      ($_.Threads.WaitReason -ne "Suspended") -and
                      ($_.ProcessName -ne "ApplicationFrameHost")
                    } | 
foreach {
    $_.Threads.foreach({
        [void][Win32]::EnumThreadWindows($_.Id, {
            param($hwnd, $lparam)
            if ([Win32]::IsIconic($hwnd) -or [Win32]::IsWindowVisible($hwnd)) {
                $title=[Win32]::GetTitle($hwnd)
                if ($title -and ($title -ne "Program Manager")) {
                    if ($windows.ContainsKey($title)) {
                      $id=$windows[$title].id + 1
                      $windows[$title + " (${id})"] = @{hwnd=$hwnd; id=$id}
                    }
                    else {
                        $windows[$title] = @{hwnd=$hwnd; id=0}
                    }
                }
            }}, 0)
        })
}

$window = echo $windows.keys | hs

if($window) {
    $iconic = [Win32]::IsIconic($windows[$window].hwnd)
    if ($iconic) {
        # https://docs.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-showwindow
        # 9: SW_RESTORE
        [Win32]::ShowWindowAsync($windows[$window].hwnd, 9) | Out-Null
    }
    [Win32]::SetForegroundWindow($windows[$window].hwnd) | Out-Null
}
