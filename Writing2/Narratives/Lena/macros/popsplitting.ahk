#Requires Autohotkey v2.0
gstimeinterval:= 170
splittimeinterval:= 200
feedtimeinterval:= 100
splitkeydown:=   "{SPACE down}"
splitkeyup:=   "{SPACE up}"
feeddown:=   "{w down}"
feedup:=   "{w up}"
splitinputstring:= "space"
splitinput:= "{SPACE}"
potioninput:= "f"


autosplit(number){

Loop number
{
	SendInput(splitkeydown)
	Sleep(splittimeinterval)
	SendInput(splitkeyup)
}
}
autogluesplit(){

	SendInput(splitinput)
	Sleep(gstimeinterval)
	SendInput(potioninput)
}

autofeed(number){

Loop number
{
	SendInput(feeddown)
	Sleep(feedtimeinterval)
	SendInput(feedup)
}
}
gshelper_enable(){
KeyWait(splitinputstring, "D")
starttime := A_TickCount		

KeyWait(potioninput, "D")
endtime := A_tickcount
totaltime := endtime - starttime		
MsgBox(totaltime)	
}

q::{
	global
	autosplit(4)
	return
}

d::{
	
	global
	autosplit(2)
	return
}
k::{
	
	global
	autofeed(6)
	return
}
x::{
	
	global
	autogluesplit()
	return

}
z::
{
	gshelper_enable()
	return
}