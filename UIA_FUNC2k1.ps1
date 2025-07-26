<#
有効な関数

UIA_MOUSE_SAVE #マウス位置の保存
UIA_MOUSE_RTN  #マウス位置の復帰

UIA_ctrl_init "電卓,1000,0"
UIA_L_CLK_S "$x,$y,68,273" #CEボタン
UIA_tx_send "123453="
UIA_Press_key "^c"
UIA_CURSR_MV "$x,$y,68,273"


#>

<#
#作業前のマウス位置保存
UIA_MOUSE_SAVE

# 座標
#$x += 136
#$y += 63

Start-Process calc -Wait

UIA_ctrl_init "電卓,1000,0"


UIA_L_CLK_S "$x,$y,68,273" 	#CEボタン
UIA_L_CLK_S "$x,$y,464,127"  	#実行結果ウィンドウ

UIA_tx_send "123456"
UIA_L_CLK_S "$x,$y,429,417"  	#+button
UIA_tx_send "123="

UIA_L_CLK_S "$x,$y,464,127"  	#実行結果ウィンドウ

UIA_Press_key "^a"
UIA_Press_key "^c"

UIA_Press_key "%{F4}"

Write-Host clipbordの中身
$Gettext = Get-Clipboard 
Write-Host $Gettext


UIA_MOUSE_RTN

pause



#>




Add-Type @"
using System;
using System.Runtime.InteropServices;

public struct RECT{
        public int Left;
        public int Top;
        public int Right;
        public int Bottom;
}


public class User32 {
    [DllImport("user32.dll")]
    public static extern bool EnumWindows(EnumWindowsProc lpEnumFunc, IntPtr lParam);
    public delegate bool EnumWindowsProc(IntPtr hWnd, IntPtr lParam);
    
    [DllImport("user32.dll")]
    public static extern int GetWindowText(IntPtr hWnd, System.Text.StringBuilder lpString, int nMaxCount);
    
    [DllImport("user32.dll")]
    public static extern bool SetWindowPos(IntPtr hWnd, IntPtr hWndInsertAfter, int X, int Y, int cx, int cy, uint uFlags);
    
    [DllImport("user32.dll")]
    public static extern bool ShowWindow(IntPtr hWnd, int nCmdShow);
    
    [DllImport("user32.dll")]
    public static extern bool SetForegroundWindow(IntPtr hWnd);

    public const int SW_SHOWNORMAL = 1;
}

public class WinAPI
{
        // ウインドウの現在の座標データを取得する関数
        [DllImport("user32.dll")]
        public static extern bool GetWindowRect(IntPtr hWnd, out RECT lpRect);

        // ウインドウの座標を変更する関数
        [DllImport("user32.dll")]
        public static extern bool MoveWindow(IntPtr hWnd, int X, int Y, int nWidth, int nHeight, bool bRepaint);
}


"@



function  UIA_ctrl_init($str){
	$buff= $str.split(",")

        $global:windowNames=    [string]"電卓"
	$global:x		=[int]0
	$global:y		=[int]0
	$width		=[int]500
	$hight		=[int]500
       if($buff.length -gt 0){	$global:windowNames = [string]$buff[0]	}
       if($buff.length -gt 1){	$global:x	    = [int]$buff[1]	}
       if($buff.length -gt 2){	$global:y	    = [int]$buff[2]	}
       if($buff.length -gt 3){	$width		    = [int]$buff[3]	}
       if($buff.length -gt 4){	$hight		    = [int]$buff[4]	}
       Write-Host $buff

#ADDTYPE

$windowNameArray = $windowNames -split '\s+'

$enumCallback = {
    param ($hWnd, $lParam)

    $sb = New-Object System.Text.StringBuilder 256
    $wndText = [User32]::GetWindowText($hWnd, $sb, $sb.Capacity)

    if ($wndText -gt 0) {
        $windowTitle = $sb.ToString()

        foreach ($windowName in $windowNameArray) {


#            if ($windowTitle -like "*$windowName*") {
#		完全一致に変更
             if ($windowTitle -eq "$windowName") {
		$rc = New-Object RECT
		[WinAPI]::GetWindowRect($hWnd, [ref]$rc)

                Write-Host "Window name: $windowTitle"
		$global:x= $rc.Left
		$global:y= $rc.Top
		Write-Host $rc.Top
		Write-Host "NOW_POS:          ($rc.Left, $rc.Top)"
                Write-Host "Dst Position:    ($x, $y)"
                Write-Host "Dst Size:        ($width, $hight)"

                [User32]::ShowWindow($hWnd, [User32]::SW_SHOWNORMAL) | Out-Null
                [User32]::SetForegroundWindow($hWnd) | Out-Null
                #[User32]::SetWindowPos($hWnd, [IntPtr]::Zero, $x, $y, $width, $hight, 0) | Out-Null
                break
            }
        }
    }
    return $true
}






[User32]::EnumWindows($enumCallback, [IntPtr]::Zero) | Out-Null


# .NET Frameworkの宣言
[void] [System.Reflection.Assembly]::LoadWithPartialName("System.Drawing") 
[void] [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms") 

# Windows APIの宣言
$signature=@'
[DllImport("user32.dll",CharSet=CharSet.Auto,CallingConvention=CallingConvention.StdCall)]
public static extern void mouse_event(long dwFlags, long dx, long dy, long cButtons, long dwExtraInfo);
'@
$global:SendMouseClick = Add-Type -memberDefinition $signature -name "Win32MouseEventNew" -namespace Win32Functions -passThru

Start-Sleep -s 1






}



#文字入力用
Add-Type -AssemblyName Microsoft.VisualBasic
Add-Type -AssemblyName System.Windows.Forms

function UIA_Press_key($STR){
    	[System.Windows.Forms.SendKeys]::SendWait(   $STR   )
	Start-Sleep -Milliseconds 100
	Write-Host UIA_Press_key:$STR
}

function UIA_tx_send($STR){


    $str_array = $STR.ToCharArray()

    #配列を取り出す
    foreach ($msg in $str_array) {
    	[System.Windows.Forms.SendKeys]::SendWait(   $msg   )
	Start-Sleep -Milliseconds 100

    }
    Write-Host UIA_tx_send:$STR

}



function UIA_CURSR_MV ($str){
	$buff= $str.split(",")

       if($buff.length -gt 2){	$kizyun_x =[int]$buff[0]	}
       if($buff.length -gt 3){	$kizyun_y =[int]$buff[1]	}
       if($buff.length -gt 0){	$soutai_x =[int]$buff[2]	}
       if($buff.length -gt 1){	$soutai_y =[int]$buff[3]	}

	$soutai_x += $kizyun_x
	$soutai_y += $kizyun_y

	[System.Windows.Forms.Cursor]::Position = New-Object System.Drawing.Point([int]$soutai_x, [int]$soutaiy)
	Write-Host UIA_CURSR_MV X:$soutai_x Y:$soutai_y
}







#        UIA_L_CLK_S "$x,$y,68,273" #CEボタン
function UIA_L_CLK_S($str){
	$buff= $str.split(",")

       if($buff.length -gt 2){	$kizyun_x =[int]$buff[0]	}
       if($buff.length -gt 3){	$kizyun_y =[int]$buff[1]	}
       if($buff.length -gt 0){	$soutai_x =[int]$buff[2]	}
       if($buff.length -gt 1){	$soutai_y =[int]$buff[3]	}

	$soutai_x += $kizyun_x
	$soutai_y += $kizyun_y

	[System.Windows.Forms.Cursor]::Position = New-Object System.Drawing.Point([int]$soutai_x, [int]$soutai_y)
	$SendMouseClick::mouse_event(0x0002, 0, 0, 0, 0); #左クリック押し
	Start-Sleep -Milliseconds 100
	$SendMouseClick::mouse_event(0x0004, 0, 0, 0, 0); #左クリック離し

	Write-Host UIA_L_CLK X:$soutai_x Y:$soutai_y

}

function UIA_MOUSE_SAVE{
	$global:Mouse_def_pos_X = [System.Windows.Forms.Cursor]::Position.X
	$global:Mouse_def_pos_Y = [System.Windows.Forms.Cursor]::Position.Y
} #マウス位置の保存
function UIA_MOUSE_RTN{
	[System.Windows.Forms.Cursor]::Position = New-Object System.Drawing.Point($Mouse_def_pos_X, $Mouse_def_pos_Y)
} #マウス位置の復帰

