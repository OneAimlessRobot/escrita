
#include "../my_includes/sm_basic_stocks.inc"

#define PLUGIN_AUTHOR "MilkChanThaGoat"
#define PLUGIN_VERSION "1.0.0"
#define CHEAT_NAME cheat_name_goes_here
public Plugin myinfo = 
{
	name = "Milk's filthy cheat_name_goes_here plugin", 
	author = PLUGIN_AUTHOR, 
	description = "Let girls cheat in CS:GO Lmao xd", 
	version = PLUGIN_VERSION, 
	url = "http://localhost:11001/"
};

enum CHEAT_NAME_MODES {
	//cheat modes go here
	
	
};

stock bool:g_cheat_name_goes_here_enabled, 
bool:g_iInform, 
bool:g_bInformed[MAXPLAYERS + 1], 
bool:g_player_can_cheat_name_goes_here[MAXPLAYERS + 1];
bool:g_player_is_cheat_name_goes_here[MAXPLAYERS + 1];

stock int g_cheat_name_goes_here_mode;
stock int g_cheat_name_goes_here_logging_mode;

stock Handle:cvarInform, 
Handle:g_cheat_name_goes_here_enabled_handle, 
Handle:g_cheat_name_goes_here_radius_handle, 
Handle:g_cheat_name_goes_here_mode_handle, 
Handle:g_cheat_name_goes_here_logging_mode_handle;






public void OnPluginStart()
{
	CreateConVar("sm_cheat_name_goes_here_version", PLUGIN_VERSION, "the version of this disgusting crap of cheat_name_goes_here evil bad bad bad bad bad!!!1!!!", FCVAR_REPLICATED | FCVAR_SPONLY | FCVAR_DONTRECORD | FCVAR_NOTIFY);
	g_cheat_name_goes_here_enabled_handle = CreateConVar("sm_cheat_name_goes_here_enabled", "1", "0 = Disabled , 1 = Enables the Plugin.", _, true, 0.0, true, 1.0);
	//g_cheat_name_goes_here_mode_handle = CreateConVar("sm_cheat_name_goes_here_mode", "2", "there are several modes, including \"Cone\" and \"Rage\". Feel free to try them all out!", _, true, 0.0, true, float(view_as<int>(cheat_name_goes_here_Cone)));
	g_cheat_name_goes_here_logging_mode_handle = CreateConVar("sm_cheat_name_goes_here_logging_mode", "2", "there are several logging modes, including \"NONE\" and \"Console\". Feel free to try them all out!", _, true, 0.0, true, float(view_as<int>(Log_Chat)));
	HookConVarChange(g_cheat_name_goes_here_enabled_handle, CVarChange);
	//HookConVarChange(g_cheat_name_goes_here_mode_handle, CVarChange);
	HookConVarChange(g_cheat_name_goes_here_logging_mode_handle, CVarChange);
	
	
	cvarInform = CreateConVar("sm_cheat_name_goes_here_inform", "1", "Enable information notification\n0 = Disabled\n1 = Enabled", _, true, 0.0, true, 1.0);
	g_iInform = GetConVarBool(cvarInform);
	HookConVarChange(cvarInform, CVarChange);
	
	RegAdminCmd("sm_cheat_name_goes_here_active", CheatNameGoesHereCmd, 0, "Enable/Disable CheatNameGoesHere");
	LoadTranslations("cheat_name_goes_here.phrases");
	
	
	RegConsoleCmd("reset_cheat_name_goes_here", Command_ResetCheatNameGoesHere, "reset cheat_name_goes_here");
	RegConsoleCmd("toggle_cheat_name_goes_here", Command_CheatNameGoesHere, "toggle cheat_name_goes_here");
	
	AutoExecConfig(true, "sm_cheat_name_goes_here");
	Load_Cfg();
	init_several_stocks();
	
}

public OnConfigsExecuted(){
	
	
	
	Load_Cfg();
	
	
}

public void Load_Cfg(){
	
	g_cheat_name_goes_here_enabled = GetConVarBool(g_cheat_name_goes_here_enabled_handle);
	g_iInform = GetConVarBool(cvarInform);
	g_cheat_name_goes_here_logging_mode = GetConVarInt(g_cheat_name_goes_here_logging_mode_handle);
	
}
public CVarChange(Handle:hConvar, const String:strOldValue[], const String:strNewValue[])
{
	if (hConvar == g_cheat_name_goes_here_enabled_handle) {
		g_cheat_name_goes_here_enabled = GetConVarBool(g_cheat_name_goes_here_enabled_handle);
	}
	if (hConvar == cvarInform) {
		g_iInform = GetConVarBool(cvarInform);
	}
	if (hConvar == g_cheat_name_goes_here_logging_mode_handle) {
		g_cheat_name_goes_here_logging_mode = GetConVarInt(g_cheat_name_goes_here_logging_mode_handle);
	}
}

public Action:CheatNameGoesHereCmd(client, iArgs)
{
	if (!g_cheat_name_goes_here_enabled) {
		
		
		ReplyToCommand(client, "[SM] CheatNameGoesHere not enabled!!!");
		return Plugin_Handled;
		
	}
	char arg[65];
	char Arguments[256];
	if (iArgs >= 1)
	{
		GetCmdArgString(Arguments, sizeof(Arguments));
		
		int len = BreakString(Arguments, arg, sizeof(arg));
		
		if (len == -1)
		{
			/* Safely null terminate */
			len = 0;
			Arguments[0] = '\0';
		}
		
		char target_name[MAX_TARGET_LENGTH];
		int target_list[MAXPLAYERS], target_count;
		bool tn_is_ml;
		if ((target_count = ProcessTargetString(
					arg, 
					client, 
					target_list, 
					MAXPLAYERS, 
					COMMAND_FILTER_CONNECTED, 
					target_name, 
					sizeof(target_name), 
					tn_is_ml)) > 0)
		{
			int cheat_name_goes_here_self = 0;
			
			for (int i = 0; i < target_count; i++)
			{
				/* Kick everyone else first */
				if (target_list[i] == client)
				{
					cheat_name_goes_here_self = client;
				}
				else
				{
					enable_cheat_name_goes_here_on_client(client, target_list[i]);
				}
			}
			
			if (cheat_name_goes_here_self)
			{
				enable_cheat_name_goes_here_on_client(client, client);
			}
		}
		else
		{
			ReplyToTargetError(client, target_count);
		}
	}
	else {
		
		enable_cheat_name_goes_here_on_client(client, client);
		
		
	}
	
	
	
	return Plugin_Handled;
}

public Action Command_CheatNameGoesHere(int client, int args)
{
	if (client_hittable(client)) {
		if (g_player_can_cheat_name_goes_here[client]) {
			ToggleCheatNameGoesHerePlayer(client);
		}
	}
	return Plugin_Handled;
}

public OnClientPutInServer(client)
{
	g_player_can_cheat_name_goes_here[client] = false;
	g_player_is_cheat_name_goes_here[client] = false;
	g_bInformed[client] = false;
}

public Action:OnPlayerSpawn(Handle:hEvent, String:strName[], bool:bDontBroadcast)
{
	new client = GetClientOfUserId(GetEventInt(hEvent, "userid"));
	if (!client_hittable(client)) {
		return Plugin_Continue;
	}
	
	if (g_iInform && !g_bInformed[client] && CheckCommandAccess(client, "sm_cheat_name_goes_here_active", 0))
	{
		SetGlobalTransTarget(client);
		PrintToChat(client, "%t", "InformCheatNameGoesHere");
		g_bInformed[client] = true;
	}
	reset_CheatNameGoesHere(client);
	return Plugin_Continue;
}
void ToggleCheatNameGoesHerePlayer(int player_id, bool ignore = true, bool value = false) {
	static char log_string[256];
	if (g_player_can_cheat_name_goes_here[player_id]) {
		FormatEx(log_string, LOGGING_BUFF_SIZE, "You are %s!!!!", !g_player_is_cheat_name_goes_here[player_id] ? "CheatNameGoesHere-ing!":"NOT CheatNameGoesHere-ing...");
		g_player_is_cheat_name_goes_here[player_id] = (ignore ? (!g_player_is_cheat_name_goes_here[player_id]):value);
	}
	else {
		FormatEx(log_string, LOGGING_BUFF_SIZE, "My MAN you can NOT cheat_name_goes_here.\nBut here is your cheat_name_goes_here status anyways...:\n%s\n", g_player_is_cheat_name_goes_here[player_id] ? "CheatNameGoesHere-ing!":"NOT CheatNameGoesHere-ing...");
		
	}
	log_message(view_as<LOGGING_MODES>(g_cheat_name_goes_here_mode), player_id, log_string);
}
public Action Command_ResetCheatNameGoesHere(int client, int args)
{
	if (g_player_can_cheat_name_goes_here[client]) {
		reset_CheatNameGoesHere(client);
	}
	return Plugin_Handled;
}
void reset_CheatNameGoesHere(int client)
{
	
	if (client_hittable(client)) {
		if (g_player_is_cheat_name_goes_here[client]) {
			CPrintToChat(client, "Your cheat_name_goes_here has been reset!");
			g_player_is_cheat_name_goes_here[client] = false;
			
		}
		
	}
}
void enable_cheat_name_goes_here_on_client(int inflictor, int client) {
	
	if (g_player_can_cheat_name_goes_here[client])
	{
		reset_CheatNameGoesHere(client);
		g_player_can_cheat_name_goes_here[client] = false;
		SetGlobalTransTarget(client);
		char target_name[128];
		char inflictor_name[128];
		GetClientName(client, target_name, 127);
		GetClientName(inflictor, inflictor_name, 127);
		ShowActivity(inflictor, "You just disabled cheat_name_goes_here on %s!!!\n", target_name);
		ShowActivity(client, "%s Just disabled cheat_name_goes_here on you!!!\n", inflictor_name);
		ReplyToCommand(client, "[SM] %t", "EnableCheatNameGoesHere");
	}
	else
	{
		g_player_can_cheat_name_goes_here[client] = true;
		SetGlobalTransTarget(client);
		char target_name[128];
		char inflictor_name[128];
		GetClientName(client, target_name, 127);
		GetClientName(inflictor, inflictor_name, 127);
		ShowActivity(inflictor, "You just enabled cheat_name_goes_here on %s!!!\n", target_name);
		ShowActivity(client, "%s Just enabled cheat_name_goes_here on you!!!\n", inflictor_name);
		ReplyToCommand(client, "[SM] %t", "DisableCheatNameGoesHere");
	}
	
	
}
