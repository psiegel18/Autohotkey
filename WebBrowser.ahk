#Requires AutoHotkey v2.0
#Include lib\WebView2.ahk


browser := Gui()
browser.Show("w1200 h975")
wv := WebView2.create(browser.Hwnd)
wv.CoreWebView2.Navigate("https://psiegel18.github.io")
return

;shft+F2 will open the popup window (see LaunchWB.ahk)
;ctl+shft+F2 will close the popup window
^+F2:: ExitApp
