#NoEnv
#SingleInstance, Force
SetWorkingDir, %A_ScriptDir%
Menu, Tray, Icon, % A_ScriptDir "\" RegExReplace(A_ScriptName, "\.ahk|exe$") ".ico"

global units:={"FT/HR":[{mult:0.016667}], "M/HR":[{div:60}], "MIN/M":[{pow:-1}]}, Version:="1.0.1"

Gui New, +AlwaysOnTop +hwndGuiHwnd
Gui,Font, s11, Segoe UI

;Labels
Gui Add, Text, x8 y8 w80 h23 +BackgroundTrans, RSS EROP:
Gui Add, Text, x136 y8 w80 h23 +BackgroundTrans, BendTime `%:
Gui Add, Text, x255 y8 w80 h23 +BackgroundTrans, Actual ROP:
;EROP
Gui, Font, norm
Gui Add, Edit, x8 y32 w80 h28 +Number -Multi +Center veRop gCalculate
Gui Add, Text, x+3 yp+7 +BackgroundTrans +0x200, ft/hr
;BendTime
Gui Add, Edit, x136 y32 w80 h28 +Number -Multi +Center vbTime gCalculate
Gui Add, Text, x+3 yp+7 +BackgroundTrans +0x200, `%
;Actual ROP
Gui Add, Edit, x255 y32 w90 h28 -Multi +Center vactRop hwndactRopHwnd gCalculate

unitList := ""
for c, v in units
	unitList .= (unitList ? (A_Index=2 ? "||" : "|") : "") c
Gui, Font, s8 bold
Gui Add, DDL, x+1 yp+7 w65 gCalculate vropUnit hwndropUnitHwnd, %unitList%
Gui, Font, s11 norm

;Refresh Button
Gui Add, Button, gCalculate x164 y+15 w100 h35 +Default -TabStop, &Refresh

;RESULTS
Gui, Font, bold
Gui Add, GroupBox, x7 y115 w398 h91, RESULTS
Gui, Font, norm s10
;Window Time
Gui Add, Text, x16 y149 w90 h23 +BackgroundTrans, Window Time:
Gui Add, Edit, vwinTime hwndwinTimeHwnd x16 y168 w90 h28 +ReadOnly -TabStop +Center
Gui Add, Text, x+3 yp+7 0x200 +BackgroundTrans, min.
;Slide Time
Gui Add, Text, x151 y149 w90 h23 +BackgroundTrans, Slide Time:
Gui Add, Edit, vslideTime hwndslideTimeHwnd x151 y168 w90 h28 +ReadOnly -TabStop +Center
Gui Add, Text, x+3 yp+7 0x200 +BackgroundTrans, min.
;Slide Distance
Gui Add, Text, x284 y149 w90 h23 +BackgroundTrans, Slide Distance:
Gui Add, Edit, vslideDist hwndslideDistHwnd x284 y168 w90 h28 +ReadOnly -TabStop +Center
Gui Add, Edit, x+2 yp+3 0x200 +Disabled hwndsdistUnitHwnd, FT

Gui Show,, EROP Calculator
return


Calculate() {
	global
	static looper:=false
	
	Gui, Submit, NoHide
	if (!looper) {
		looper := true
		SetTimer, Calculate, -250
		return
	}
	looper := false
	if (!erop) 
		return
	if (RegExMatch(actRop, "[^\d\.]$")) {
		ControlSetText,, % RegExReplace(actRop, "[^\d\.]$"), ahk_id %actRopHwnd%
		ControlSend, ahk_id %actRopHwnd%, {End}
		return
	}
	wTime := (15/erop)*60
	sTime := bTime ? wTime*(bTime/100) : ""
	if (actRop && sTime) {
		aRop := actRop
		for c, v in units[ropUnit]
			for cmd, val in v
				aRop := DoMath(cmd, aRop, val)
		sDist := sTime*aRop
	}
	else
		sDist := ""
	ControlSetText,, % Round(wTime, 3), ahk_id %winTimeHwnd%
	ControlSetText,, % sTime ? Round(sTime, 3) : "", ahk_id %slideTimeHwnd%
	ControlSetText,, % sDist ? Round(sDist, 3) : "", ahk_id %slideDistHwnd%
	ControlSetText,, % ropUnit~="M/|/M" ? "M" : "FT", ahk_id %sDistUnitHwnd%
}


DoMath(cmd, value, factor) {
	if (cmd="mult") 
		return (value * factor)
	else if (cmd="div")
		return (value / factor)
	else if (cmd~="i)(?:pow(?:er)?|exp)")
		return (value ** factor)
}


GuiClose() {
	GuiEscape:
	ExitApp
}