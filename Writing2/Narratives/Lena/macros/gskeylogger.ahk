z::
{
KeyWait("space", "D")			
starttime := A_TickCount		

KeyWait("f", "D")
endtime := A_tickcount
totaltime := endtime - starttime		
MsgBox(totaltime)			
return
}