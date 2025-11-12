/*

plugin description here

basically...
a timer will be launched.
the timer will,
for every player which has the cheat enabled,
disable one random hitzone per every time they are found "hittable" during the loop.
if during the time of the loop,
the random hitzone selected is "head",
and some player x is selected,
and they also have the cheat enabled,
for the next second,
they will be immune to headshots!
But the hitzone can also be any of the others:
left/right foot/legs/arms,
torso, chest...
etc.

*/
#include "../my_includes/sm_basic_stocks.inc"
#include "../my_includes/sm_misc_stocks.inc"

#define HITZONE_SWITCH_PERIOD 1.0

#define PLUGIN_AUTHOR "MilkChanThaGoat"
#define PLUGIN_VERSION "1.0.0"
#define CHEAT_NAME randomized_hitzones
public Plugin myinfo = 
{
	name = "Milk's filthy randomized_hitzones plugin", 
	author = PLUGIN_AUTHOR, 
	description = "Let girls randomize their hitzones in CS:GO Lmao xd", 
	version = PLUGIN_VERSION, 
	url = "http://localhost:11001/"
};

enum CHEAT_NAME_MODES {
	//cheat modes go here
	
	
}
/*
player_hurt
Name:	player_hurt
Structure:	
short	userid	user ID of who was hurt
short	attacker	user ID of who attacked
byte	health	remaining health points
byte	armor	remaining armor points
string	weapon	weapon name attacker used, if not the world
short	dmg_health	damage done to health
byte	dmg_armor	damage done to armor
byte	hitgroup	hitgroup that was damaged

*/

stock bool:g_randomized_hitzones_enabled, 
bool:g_iInform, 
bool:g_bInformed[MAXPLAYERS + 1], 
bool:g_player_can_randomized_hitzones[MAXPLAYERS + 1] = { false, false, ... }, 
bool:g_player_which_randomized_hitzones[MAXPLAYERS + 1][int_cast(HITGROUP_GEAR) + 1], 
bool:g_player_is_randomized_hitzones[MAXPLAYERS + 1] = { false, false, ... };

stock int g_randomized_hitzones_mode;
stock int g_randomized_hitzones_logging_mode;

stock Handle:cvarInform, 
Handle:g_randomized_hitzones_enabled_handle, 
Handle:g_randomized_hitzones_radius_handle, 
Handle:g_randomized_hitzones_mode_handle, 
Handle:g_randomized_hitzones_logging_mode_handle;

stock Handle:hitzone_timer;






public void OnPluginStart()
{
	CreateConVar("sm_randomized_hitzones_version", PLUGIN_VERSION, "the version of this disgusting crap of randomized_hitzones evil bad bad bad bad bad!!!1!!!", FCVAR_REPLICATED | FCVAR_SPONLY | FCVAR_DONTRECORD | FCVAR_NOTIFY);
	g_randomized_hitzones_enabled_handle = CreateConVar("sm_randomized_hitzones_enabled", "1", "0 = Disabled , 1 = Enables the Plugin.", _, true, 0.0, true, 1.0);
	//g_randomized_hitzones_mode_handle = CreateConVar("sm_randomized_hitzones_mode", "2", "there are several modes, including \"Cone\" and \"Rage\". Feel free to try them all out!", _, true, 0.0, true, float(view_as<int>(randomized_hitzones_Cone)));
	g_randomized_hitzones_logging_mode_handle = CreateConVar("sm_randomized_hitzones_logging_mode", "2", "there are several logging modes, including \"NONE\" and \"Console\". Feel free to try them all out!", _, true, 0.0, true, float(view_as<int>(Log_Chat)));
	HookConVarChange(g_randomized_hitzones_enabled_handle, CVarChange);
	//HookConVarChange(g_randomized_hitzones_mode_handle, CVarChange);
	HookConVarChange(g_randomized_hitzones_logging_mode_handle, CVarChange);
	
	
	cvarInform = CreateConVar("sm_randomized_hitzones_inform", "1", "Enable information notification\n0 = Disabled\n1 = Enabled", _, true, 0.0, true, 1.0);
	g_iInform = GetConVarBool(cvarInform);
	HookConVarChange(cvarInform, CVarChange);
	
	RegAdminCmd("sm_randomized_hitzones_active", RandomizedHitzonesCmd, 0, "Enable/Disable RandomizedHitzones");
	LoadTranslations("randomized_hitzones.phrases");
	
	
	RegConsoleCmd("reset_randomized_hitzones", Command_ResetRandomizedHitzones, "reset randomized_hitzones");
	RegConsoleCmd("toggle_randomized_hitzones", Command_RandomizedHitzones, "toggle randomized_hitzones");
	RegConsoleCmd("list_randomized_hitzones", Command_ListRandomizedHitzones, "list randomized_hitzones");
	AutoExecConfig(true, "sm_randomized_hitzones");
	CreateTimer(HITZONE_SWITCH_PERIOD, hitzone_timer_func, _, TIMER_REPEAT );
	Load_Cfg();
	init_several_stocks();
	
}
public OnConfigsExecuted(){
	
	
	
	Load_Cfg();
	
	
}
public Action hitzone_timer_func(Handle timer, any data) {
	for (int player_id = 1; player_id <= MAXPLAYERS; player_id++) {
		if (client_hittable(player_id) && g_player_is_randomized_hitzones[player_id]&& g_player_can_randomized_hitzones[player_id]) {
			int hitzone = choose_random_hitzone();
			if(!g_player_which_randomized_hitzones[player_id][hitzone]){
				char hitzone_name[128];
				print_hitzone_name(hitzone, hitzone_name);
				log_message(view_as<LOGGING_MODES>(g_randomized_hitzones_logging_mode), player_id, hitzone_name);
				g_player_which_randomized_hitzones[player_id][hitzone] = true;
			}
			Handle data_timer = CreateArray(4, 2);
			SetArrayCell(data_timer, 0, player_id, 0);
			SetArrayCell(data_timer, 1, hitzone, 0);
			CreateTimer(HITZONE_SWITCH_PERIOD, hitzone_re_enable_timer, data_timer);
			
		}
	}
	return Plugin_Continue;
	
}
public Action hitzone_re_enable_timer(Handle timer, any data) {
	
	int player_id = GetArrayCell(data, 0, 0);
	int hitzone = GetArrayCell(data, 1, 0);
	char hitzone_name[128];
	char log_string[LOGGING_BUFF_SIZE];
	print_hitzone_name(hitzone, hitzone_name);
	FormatEx(log_string, LOGGING_BUFF_SIZE, "Your \"%s\" hitbox was re-enabled! Be more careful now! Waiting for next hitzone...", hitzone_name);
	log_message(view_as<LOGGING_MODES>(g_randomized_hitzones_logging_mode), player_id, log_string);
	g_player_which_randomized_hitzones[player_id][hitzone] = false;
	safe_close_handle(data);
	
	
}
public void Load_Cfg() {
	
	g_randomized_hitzones_enabled = GetConVarBool(g_randomized_hitzones_enabled_handle);
	g_iInform = GetConVarBool(cvarInform);
	g_randomized_hitzones_logging_mode = GetConVarInt(g_randomized_hitzones_logging_mode_handle);
	
}
public CVarChange(Handle:hConvar, const String:strOldValue[], const String:strNewValue[])
{
	if (hConvar == g_randomized_hitzones_enabled_handle) {
		g_randomized_hitzones_enabled = GetConVarBool(g_randomized_hitzones_enabled_handle);
	}
	if (hConvar == cvarInform) {
		g_iInform = GetConVarBool(cvarInform);
	}
	if (hConvar == g_randomized_hitzones_logging_mode_handle) {
		g_randomized_hitzones_logging_mode = GetConVarInt(g_randomized_hitzones_logging_mode_handle);
	}
}
public Action:RandomizedHitzonesCmd(client, iArgs)
{
	if (!g_randomized_hitzones_enabled) {
		
		
		ReplyToCommand(client, "[SM] RandomizedHitzones not enabled!!!");
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
			int randomized_hitzones_self = 0;
			
			for (int i = 0; i < target_count; i++)
			{
				/* Kick everyone else first */
				if (target_list[i] == client)
				{
					randomized_hitzones_self = client;
				}
				else
				{
					enable_randomized_hitzones_on_client(client, target_list[i]);
				}
			}
			
			if (randomized_hitzones_self)
			{
				enable_randomized_hitzones_on_client(client, client);
			}
		}
		else
		{
			ReplyToTargetError(client, target_count);
		}
	}
	else {
		
		enable_randomized_hitzones_on_client(client, client);
		
		
	}
	
	
	
	return Plugin_Handled;
}
stock Action sdk_damage_hook_randomzied_hitzones(int player_id, int &attacker_id, int &inflictor, float &damage, int &damagetype, int &ammotype, int hitbox, int hitgroup)
{
	if (!client_hittable(player_id) || !client_hittable(attacker_id)) {
		
		return Plugin_Continue;
		
	}
	if (g_player_is_randomized_hitzones[player_id] && g_player_which_randomized_hitzones[player_id][hitgroup]) {
		damage = 0.0;
		
		char hitzone_name[128];
		char log_string[LOGGING_BUFF_SIZE];
		print_hitzone_name(hitgroup, hitzone_name);
		FormatEx(log_string, LOGGING_BUFF_SIZE, "Your \"%s\" hitbox was disabled! Their hit was completely absorbed!", hitzone_name);
		log_message(Log_Chat, player_id, log_string);
		FormatEx(log_string, LOGGING_BUFF_SIZE, "Their \"%s\" hitbox was disabled! Your hit was completely absorbed!", hitzone_name);
		log_message(Log_Chat, attacker_id, log_string);
		
		return Plugin_Handled;
	}
	return Plugin_Continue;
}
public Action Command_RandomizedHitzones(int client, int args)
{
	if (client_hittable(client)) {
		if (g_player_can_randomized_hitzones[client]) {
			ToggleRandomizedHitzonesPlayer(client);
		}
	}
	return Plugin_Handled;
}

public OnClientPutInServer(client)
{
	g_player_can_randomized_hitzones[client] = false;
	g_player_is_randomized_hitzones[client] = false;
	g_bInformed[client] = false;
	Array_Fill(g_player_which_randomized_hitzones[client], int_cast(HITGROUP_GEAR) + 1, false, 0);
}

public Action:OnPlayerSpawn(Handle:hEvent, String:strName[], bool:bDontBroadcast)
{
	new client = GetClientOfUserId(GetEventInt(hEvent, "userid"));
	if (!client_hittable(client)) {
		return Plugin_Continue;
	}
	
	if (g_iInform && !g_bInformed[client] && CheckCommandAccess(client, "sm_randomized_hitzones_active", 0))
	{
		SetGlobalTransTarget(client);
		PrintToChat(client, "%t", "InformRandomizedHitzones");
		g_bInformed[client] = true;
	}
	reset_RandomizedHitzones(client);
	return Plugin_Continue;
}
void ToggleRandomizedHitzonesPlayer(int player_id, bool ignore = true, bool value = false) {
	static char log_string[LOGGING_BUFF_SIZE];
	if (g_player_can_randomized_hitzones[player_id]) {
		FormatEx(log_string, LOGGING_BUFF_SIZE, "You ARE %s!!!!", !g_player_is_randomized_hitzones[player_id] ? "RandomizedHitzones-ing!":"NOT RandomizedHitzones-ing...");
		
		g_player_is_randomized_hitzones[player_id] = (ignore ? (!g_player_is_randomized_hitzones[player_id]):value);
		if (g_player_is_randomized_hitzones[player_id]) {
			
			SDKHook(player_id, SDKHook_TraceAttack, sdk_damage_hook_randomzied_hitzones);
			
			
		}
		else {
			
			
			SDKUnhook(player_id, SDKHook_TraceAttack, sdk_damage_hook_randomzied_hitzones);
			
			
		}
		
	}
	else {
		FormatEx(log_string, LOGGING_BUFF_SIZE, "My MAN you can NOT randomized_hitzones.\nBut here is your randomized_hitzones status anyways...:\n%s\n", g_player_is_randomized_hitzones[player_id] ? "RandomizedHitzones-ing!":"NOT RandomizedHitzones-ing...");
		
	}
	log_message(view_as<LOGGING_MODES>(g_randomized_hitzones_mode), player_id, log_string);
}
public Action Command_ResetRandomizedHitzones(int client, int args)
{
	if (g_player_can_randomized_hitzones[client]) {
		reset_RandomizedHitzones(client);
	}
	return Plugin_Handled;
}
public Action Command_ListRandomizedHitzones(int player_id, int args)
{
	static char log_string[LOGGING_BUFF_SIZE];
	if (client_hittable(player_id)) {
		
		FormatEx(log_string, LOGGING_BUFF_SIZE, "%s\n[SH] RandomizedHitzones: here is a list of all the hitzones that are disabled on you:%s %s %s %s %s %s %s\n", 
			g_player_which_randomized_hitzones[player_id][HITGROUP_GENERIC] ? "HITGROUP_GENERIC":"", 
			g_player_which_randomized_hitzones[player_id][HITGROUP_HEAD] ? "HITGROUP_HEAD":"", 
			g_player_which_randomized_hitzones[player_id][HITGROUP_CHEST] ? "HITGROUP_CHEST":"", 
			g_player_which_randomized_hitzones[player_id][HITGROUP_STOMACH] ? "HITGROUP_STOMACH":"", 
			g_player_which_randomized_hitzones[player_id][HITGROUP_LEFTARM] ? "HITGROUP_LEFTARM":"", 
			g_player_which_randomized_hitzones[player_id][HITGROUP_RIGHTARM] ? "HITGROUP_RIGHTARM":"", 
			g_player_which_randomized_hitzones[player_id][HITGROUP_LEFTLEG] ? "HITGROUP_LEFTLEG":"", 
			g_player_which_randomized_hitzones[player_id][HITGROUP_RIGHTLEG] ? "HITGROUP_RIGHTLEG":"");
		
		log_message(view_as<LOGGING_MODES>(g_randomized_hitzones_logging_mode), player_id, log_string);
		
	}
	
	return Plugin_Handled;
	
}
void reset_RandomizedHitzones(int client)
{
	
	if (client_hittable(client)) {
		if (g_player_is_randomized_hitzones[client]) {
			CPrintToChat(client, "Your randomized_hitzones has been reset!");
			g_player_is_randomized_hitzones[client] = false;
			g_player_can_randomized_hitzones[client] = false;
			Array_Fill(g_player_which_randomized_hitzones[client], int_cast(HITGROUP_GEAR) + 1, false, 0);
			
		}
		
	}
}
void enable_randomized_hitzones_on_client(int inflictor, int client) {
	
	if (g_player_can_randomized_hitzones[client])
	{
		reset_RandomizedHitzones(client);
		g_player_can_randomized_hitzones[client] = false;
		SetGlobalTransTarget(client);
		char target_name[128];
		char inflictor_name[128];
		GetClientName(client, target_name, 127);
		GetClientName(inflictor, inflictor_name, 127);
		ShowActivity(inflictor, "You just disabled randomized_hitzones on %s!!!\n", target_name);
		ShowActivity(client, "%s Just disabled randomized_hitzones on you!!!\n", inflictor_name);
		ReplyToCommand(client, "[SM] %t", "EnableRandomizedHitzones");
	}
	else
	{
		g_player_can_randomized_hitzones[client] = true;
		ToggleRandomizedHitzonesPlayer(client, false, true);
		SetGlobalTransTarget(client);
		char target_name[128];
		char inflictor_name[128];
		GetClientName(client, target_name, 127);
		GetClientName(inflictor, inflictor_name, 127);
		ShowActivity(inflictor, "You just enabled randomized_hitzones on %s!!!\n", target_name);
		ShowActivity(client, "%s Just enabled randomized_hitzones on you!!!\n", inflictor_name);
		ReplyToCommand(client, "[SM] %t", "DisableRandomizedHitzones");
	}
	
	
}