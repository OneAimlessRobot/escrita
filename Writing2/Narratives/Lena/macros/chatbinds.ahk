#Requires Autohotkey v2.0
ap_chatmsg:= "Panzergranate, geladen."
he_chatmsg:= "Sprengrannate, geladen."
mg_chatmsg:= "Maschinen gewehr, geladen."
tg_destroyed_msg:= "Ziel zerstört!"
tg_damaged_msg:= "Ziel beshadigt!"

exit_msg:= "Exiting..."

PasteText(stuffToPaste) {
	tempClipboard := GetAndClearClipboard()
	
	A_Clipboard := stuffToPaste
	Sleep(20)
	Send("^v")
	Sleep(100)
	A_Clipboard := tempClipboard
	
	return
}

;Functions
GetAndClearClipboard() {
	tempClipboard := A_Clipboard
	A_Clipboard := ""
	While A_Clipboard {
		Sleep(10)
	}
	return tempClipboard
}
Send_chat_bind(msg){

	SendInput("t")
	Sleep(200)
	PasteText(msg)
	Sleep(1000)
	SendInput("{ENTER}")

}
h & 1::
{
	
	Send_chat_bind(tg_destroyed_msg)
	return
	
}
h & 2::
{
	
	Send_chat_bind(tg_damaged_msg)
	return
	



}
h & 3::
{
	
	Send_chat_bind(ap_chatmsg)
	return
	



}
h & 4::
{
	
	Send_chat_bind(he_chatmsg)
	return
	



}
h & 5::
{
	
	Send_chat_bind(mg_chatmsg)
	return
	



}
f7::
{
MsgBox(exit_msg)
ExitApp()
}