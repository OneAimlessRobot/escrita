#include <sdktools>
#include <clientprefs>
#include <string>
#include <emitsoundany>
#pragma semicolon 1

public Plugin myinfo =
{
	name = "Join Music",
	author = "TheBO$$ (worked on by MilkChanThaGOAT))",
	description = "Join server music",
	version = "1.0",
	url = "TheBΦ$$♚#2967"
};

#define PATH_PREFIX "->_"
#define _MAX_NUM_OF_SONGS_ 1000
#define PATH_LENGTH 1024
#define song_config_file_path "configs/join_music_file_paths"
#define song_config_file_ini "/join_music.ini"
stock char songs[_MAX_NUM_OF_SONGS_][PATH_LENGTH];
stock const char comment_prefixes[3][128]={
	"//",
	"#",
	";"
};
enum Line_Type{
	invalid_line=0,
	comment_line=1,
	song_line=2
};
stock int total_songs=0;
Handle g_JM_Cookie = null;
Handle g_JM_Volume_Cookie = null;

/*

File OpenFile(const char[] file, const char[] mode, bool use_valve_fs=false, const char[] valve_path_id="GAME");
bool ReadFileLine(Handle hndl, char[] buffer, int maxlength);
 
*/
stock Line_Type get_line_type(char line[PATH_LENGTH],char song_dst[PATH_LENGTH]){
	Line_Type result=invalid_line;
	for(int i=0;i<sizeof comment_prefixes;i++){
		if(!strncmp(comment_prefixes[i],line,strlen(comment_prefixes[i]))){
					
				PrintToConsole(0,"comment: %s\n",line);
				result=comment_line;
				break;
		}
	}
	if(!strncmp(PATH_PREFIX,line,strlen(PATH_PREFIX))){
		//list[strlen(PATH_PREFIX)]
		strcopy(song_dst,PATH_LENGTH-1,line[strlen(PATH_PREFIX)+1]);
		song_dst[strlen(song_dst)-2]=0;
		PrintToConsole(0,"song!!!!: \"%s\"\n",song_dst);
		result=song_line;
	}
	return result;
	
}

stock bool parse_songs(){
	
	static char file_path[PATH_LENGTH];
	static char file_dir[PATH_LENGTH];
	static char raw_song_path[PATH_LENGTH];
	static char song_path[PATH_LENGTH];
	BuildPath(Path_SM,file_dir,PATH_LENGTH-1,"%s",song_config_file_path);
	LogMessage("The target dir for song_list is %s\n",file_dir);
	PrintToConsole(0,"The target dir for song_list is %s\n",file_dir);
	if (!DirExists(file_dir))
	{
		CreateDirectory(file_dir, 511);
		if (!DirExists(file_dir)){
			
			LogError("Failed to create directory at %s - Please manually create that path and reload this plugin.",file_dir);
			PrintToConsole(0,"Failed to create directory at %s - Please manually create that path and reload this plugin.",file_dir);
			return false;
		}
	}
	BuildPath(Path_SM,file_path,PATH_LENGTH-1,"%s%s",song_config_file_path,song_config_file_ini);
	LogMessage("The target path for song_list is %s\n",file_path);
	PrintToConsole(0,"The target path for song_list is %s\n",file_path);
	File paths=OpenFile(file_path,"r");
	if(paths!=INVALID_HANDLE){
		for(;ReadFileLine(paths,raw_song_path,PATH_LENGTH-1);){
			Line_Type type=get_line_type(raw_song_path,song_path);
			bool should_continue=false;
			switch(type){
				case invalid_line:{
					
					
					LogMessage("Invalid line found!\n%s\n\nIgnoring it!",raw_song_path);
					PrintToConsole(0,"Invalid line found!\n%s\n\nIgnoring it!",raw_song_path);
					should_continue=true;
					
				}
				case comment_line:{
					
					
					should_continue=true;
					
				}
				case song_line:{
					
					should_continue=false;
					
				}
				default:{						
					LogMessage("We should not be here what the hell\n");
					PrintToConsole(0,"We should not be here what the hell\n");
					CloseHandle(paths);
					return false;
				}
				
				
			}
			if(should_continue){
				
				continue;
			}
			char string_to_see[PATH_LENGTH];
			FormatEx(string_to_see,sizeof string_to_see,"sound/%s",song_path);
			File song=OpenFile(string_to_see,"r");
			if(song==INVALID_HANDLE){
				
				LogError("Cannot read the path %s for song from song_list!!!\nExcluding from memory path storage\nWe currently have % songs stored",string_to_see,total_songs);
				PrintToConsole(0,"Cannot read the path %s for song from song_list!!!\nExcluding from memory path storage\nWe currently have % songs stored",string_to_see,total_songs);
				
				continue;
			}
			StrCat(songs[total_songs++],PATH_LENGTH-1,song_path);
			LogMessage("Just read the path %s for song from song_list!!!\nWe currently have % songs stored",string_to_see,total_songs);
			PrintToConsole(0,"Just read the path %s for song from song_list!!!\nWe currently have % songs stored",string_to_see,total_songs);
			CloseHandle(song);
			
		}
		CloseHandle(paths);
	}
	else{
		
		LogError("Cannot read the path %s for list of songs!!\nTrying to create file, stand by...\n",file_path);
		PrintToConsole(0,"Cannot read the path %s for list of songs!!\nTrying to create file, stand by...\n",file_path);
		
		paths=OpenFile(file_path,"w");
		
		if(paths==INVALID_HANDLE){
			
			LogError("Could not even create file in path %s for list of songs!!\nGiving up executing the plugin\n",file_path);
			PrintToConsole(0,"Could not even create file in path %s for list of songs!!\nGiving up executing the plugin\n",file_path);
			
		}
		else{
			
			LogMessage("Sucessfully created file in path %s for list of songs!!\n...\nBut still giving up executing the plugin\nWriting header and Closing Handle\n",file_path);
			PrintToConsole(0,"Sucessfully created file in path %s for list of songs!!\n...\nBut still giving up executing the plugin\nWriting header and Closing Handle\n",file_path);
			WriteFileLine(paths, "#Your songs go here, man\n");
			WriteFileLine(paths, "#Feel free to play music while your parents argue\n");
			WriteFileLine(paths, "#Comments are hashes (#), double right slashes (//) or semicolons (;)\n");
			WriteFileLine(paths, ";Song titles are prefixed by \"->_\" and between double quotes\n");
			WriteFileLine(paths, ";(Oh.and they must be mp3, too. Format, extension and everything)\n");
			WriteFileLine(paths, "//Example follows:");
			WriteFileLine(paths, "//->_\"this/is/a/song/path/song_name.mp3\"\n");
			CloseHandle(paths);
			
		}
		return false;
	}
	
	
	return true;
	
	
	
	
	
}
stock void print_songs(){
	
	static char file_path[PATH_LENGTH];
	BuildPath(Path_SM,file_path,PATH_LENGTH-1,"%s%s",song_config_file_path,song_config_file_ini);
	LogMessage("We are about to print out all the songs in the song list!\n(at path %s)\n\n\nWe have sucessfully read %d of them\n\n\n",file_path,total_songs);
	PrintToConsole(0,"We are about to print out all the songs in the song list!\n(at path %s)\n\n\nWe have sucessfully read %d of them\n\n\n",file_path,total_songs);
	for(int i=0;i<total_songs;i++){
		LogMessage("Just read the path %s for song from song_list!!!\nIt was song number %d\n",songs[i],i);
		PrintToConsole(0,"Just read the path %s for song from song_list!!!\nIt was song number %d\n",songs[i],i);
		
	}
	
}
public void OnPluginStart()
{
	if(!parse_songs()){
		
		SetFailState("Could not parse songs from file!Check logs for info.");
		return;
		
	}
	print_songs();
	g_JM_Cookie = RegClientCookie("join_server_music", "Join Music On/Off", CookieAccess_Private);
	g_JM_Volume_Cookie = RegClientCookie("join_music_volume", "join Music volume", CookieAccess_Private);
	
	SetCookieMenuItem(SoundCookieHandler, 0, "Join Server Music");
	RegConsoleCmd("sm_joinmusic", Command_JoinMusic);
	
	LoadTranslations("joinmusic.phrases.txt");
	
	SetRandomSeed(GetTime({0,0}));
	
	for(int i = 1; i <= MaxClients; i++)
	{
		if(IsClientValid(i))
		{
			if(!AreClientCookiesCached(i))
			{
				continue;
			}
			OnClientCookiesCached(i);
		}	
	}	
}
stock int precache_songs(){
	
	int num_precached= 0;
	for(int i=0;i<total_songs;i++){
		char string_to_add[PATH_LENGTH];
		FormatEx(string_to_add,sizeof string_to_add,"sound/%s",songs[i]);
		if (!PrecacheSoundAny( songs[i],true))
		{
			LogError("Could not precache song number %d (index %d): %s\nWe have currently precached...\n%d songs\n",i+1,i,songs[i],num_precached);
			PrintToConsole(0,"Could not precache song number %d (index %d): %s\nWe have currently precached...\n%d songs\n",i+1,i,songs[i],num_precached);
		}
		else{
			num_precached++;
			AddFileToDownloadsTable(string_to_add);
		
		}
	}
	return num_precached;
	
}
public void OnMapStart()
{
	int num_precached =precache_songs();
	LogMessage("%s %d",(num_precached>0)?"We have sucessfully precached this number of songs:":"Failure! Number of songs precached:",num_precached);
	PrintToConsole(0,"%s %d",(num_precached>0)?"We have sucessfully precached this number of songs:":"Failure! Number of songs precached:",num_precached);
	
}

public void OnClientCookiesCached(int client)
{
	if(IsFakeClient(client))
	{
		return;
	}
	
	if (GetIntCookie(client, g_JM_Cookie) == 0)
	{
		GetClientVolume(client);
	}
		
}

public void OnClientPostAdminCheck(int client)
{
	if (IsFakeClient(client))
	{
		return;
	}
	int is_off=GetIntCookie(client, g_JM_Cookie);
	float selectedVolume = GetClientVolume(client);
	if (!is_off)
	{
		char song_string[PATH_LENGTH];
		FormatEx(song_string,PATH_LENGTH-1,"%s",songs[GetRandomInt(0, total_songs-1)]);
		EmitSoundToClientAny(client, song_string, _, _, _, _, selectedVolume);
		LogMessage("Success!\nWe will now try to play startup sound of path %s\n\nValue of JM_Cookie: %d\nValue of volume_JM_Cookie: %0.2f\n",song_string,is_off,selectedVolume );
		PrintToConsole(0,"Success!\nWe will now try to play startup sound of path %s\n\nValue of JM_Cookie: %d\nValue of volume_JM_Cookie: %0.2f\n",song_string,is_off,selectedVolume);
	
	}
	else{
		
		LogMessage("Will not play sound at startup for this client!\nValue of JM_Cookie: %d\nValue of volume_JM_Cookie: %0.2f\n",is_off,selectedVolume);
		PrintToConsole(0,"Will not play sound at startup for this client!\nValue of JM_Cookie: %d\nValue of volume_JM_Cookie: %0.2f\n",is_off,selectedVolume);
	
		
	}
}

public Action Command_JoinMusic(int client, int args)
{
	if (!IsClientValid(client))
	{
		return Plugin_Handled;
	}
	
	JoinMusicMenu(client, 0);
	return Plugin_Handled;
}

public void SoundCookieHandler(int client, CookieMenuAction action, any info, char[] buffer, int maxlen)
{
	JoinMusicMenu(client, 0);
}

public Action JoinMusicMenu(int client, int args)
{	
	int cookievalue = GetIntCookie(client, g_JM_Cookie);
	Handle g_CookieMenu = CreateMenu(JoinMusicMenuHandler);
	SetMenuTitle(g_CookieMenu, "Join Server Music");
	char Item[128];
	if(cookievalue == 0)
	{
		Format(Item, sizeof(Item), "%t %t", "JOINMUSIC_ON", "SELECTED"); 
		AddMenuItem(g_CookieMenu, "ON", Item);
		Format(Item, sizeof(Item), "%t", "JOINMUSIC_OFF"); 
		AddMenuItem(g_CookieMenu, "OFF", Item);
	}
	else
	{
		Format(Item, sizeof(Item), "%t", "JOINMUSIC_ON");
		AddMenuItem(g_CookieMenu, "ON", Item);
		Format(Item, sizeof(Item), "%t %t", "JOINMUSIC_OFF", "SELECTED"); 
		AddMenuItem(g_CookieMenu, "OFF", Item);
	}
	
	Format(Item, sizeof(Item), "%t", "VOLUME");
	AddMenuItem(g_CookieMenu, "volume", Item);
	
	
	SetMenuExitBackButton(g_CookieMenu, true);
	SetMenuExitButton(g_CookieMenu, true);
	DisplayMenu(g_CookieMenu, client, 30);
	return Plugin_Continue;
}

public int JoinMusicMenuHandler(Handle menu, MenuAction action, int client, int param2)
{
	Handle g_CookieMenu = CreateMenu(JoinMusicMenuHandler);
	if (action == MenuAction_DrawItem)
	{
		return ITEMDRAW_DEFAULT;
	}
	else if(param2 == MenuCancel_ExitBack)
	{
		ShowCookieMenu(client);
	}
	else if (action == MenuAction_Select)
	{
		switch (param2)
		{
			case 0:
			{
				SetClientCookie(client, g_JM_Cookie, "0");
				JoinMusicMenu(client, 0);
			}
			case 1:
			{
				SetClientCookie(client, g_JM_Cookie, "1");
				JoinMusicMenu(client, 0);
			}
			case 2: 
			{
				VolumeMenu(client);
			}			
		}
		CloseHandle(g_CookieMenu);
	}
	else if(action == MenuAction_End)
	{
		delete menu;
	}
	return 0;
}

void VolumeMenu(int client){
	
	
	float volumeArray[] = { 1.0, 0.75, 0.50, 0.25, 0.10 };
	float selectedVolume = GetClientVolume(client);
	
	Menu volumeMenu = new Menu(VolumeMenuHandler);
	volumeMenu.SetTitle("%t", "JMVOLUME");
	volumeMenu.ExitBackButton = true;
	
	for(int i = 0; i < sizeof(volumeArray); i++)
	{
		char strInfo[10];
		Format(strInfo, sizeof(strInfo), "%0.2f", volumeArray[i]);
		
		char display[20], selected[5];
		if(volumeArray[i] == selectedVolume)
		Format(selected, sizeof(selected), "%t", "SELECTED");
		
		Format(display, sizeof(display), "%s %s", strInfo, selected);
		
		volumeMenu.AddItem(strInfo, display);
	}
	
	volumeMenu.Display(client, MENU_TIME_FOREVER);
}

public int VolumeMenuHandler(Menu menu, MenuAction action, int client, int param2)
{
	if(action == MenuAction_Select){
		char sInfo[10];
		GetMenuItem(menu, param2, sInfo, sizeof(sInfo));
		SetClientCookie(client, g_JM_Volume_Cookie, sInfo);
		VolumeMenu(client);
	}
	else if(param2 == MenuCancel_ExitBack)
	{
		JoinMusicMenu(client, 0);
	}
	else if(action == MenuAction_End)
	{
		delete menu;
	}
	return 1;
}

int GetIntCookie(int client, Handle handle)
{
	char sCookieValue[11];
	GetClientCookie(client, handle, sCookieValue, sizeof(sCookieValue));
	return StringToInt(sCookieValue);
}

float GetClientVolume(int client){
	float defaultVolume = 0.75;
	
	char sCookieValue[11];
	GetClientCookie(client, g_JM_Volume_Cookie, sCookieValue, sizeof(sCookieValue));
	
	if(StrEqual(sCookieValue, "") || StrEqual(sCookieValue, "0"))
	Format(sCookieValue , sizeof(sCookieValue), "%0.2f", defaultVolume);
	
	return StringToFloat(sCookieValue);
}


bool IsClientValid(int client)
{
	if (client >= 1 && client <= MaxClients && IsClientConnected(client) && IsClientInGame(client) && !IsFakeClient(client))
	return true;
	return false;
}