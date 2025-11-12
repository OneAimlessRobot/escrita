#pragma semicolon 1
#pragma newdecls optional
/*

plugin description here

basically...
a trace is made everytime someone shoots a gun.
(melee does not count.
its technically a projectile)
if you hit an enemy who has the slowmotion cheat enabled,
the damage from the hitscan will be nullified for that enemy,
and,
in front of you,
a projectile will be shot from your eye position,
that will head in the direction of the original shot instead of the hitscan attacked


//UNFINISHED
*/
#include "../my_includes/sm_basic_stocks.inc"
#include "../my_includes/sm_arithmetic_stocks.inc"
#include "../my_includes/sm_vector_stocks.inc"
#include "../my_includes/sm_graphical_stocks.inc"
#include "../my_includes/sm_misc_stocks.inc"

#define PLUGIN_AUTHOR "MilkChanThaGoat"
#define PLUGIN_VERSION "1.0.0"
#define CHEAT_NAME slomo_bullets
public Plugin myinfo = 
{
	name = "Milk's filthy slomo_bullets plugin", 
	author = PLUGIN_AUTHOR, 
	description = "Let girls matrix in CS:GO lol", 
	version = PLUGIN_VERSION, 
	url = "http://localhost:11001/"
};

enum CHEAT_NAME_MODES {
	//cheat modes go here
	
	
};

stock bool:g_slomo_bullets_enabled, 
bool:g_iInform, 
bool:g_bInformed[MAXPLAYERS + 1], 
bool:g_player_can_slomo_bullets[MAXPLAYERS + 1];
bool:g_player_is_slomo_bullets[MAXPLAYERS + 1];

stock int g_slomo_bullets_mode;
stock int g_slomo_bullets_logging_mode;


stock float g_slomo_bullets_velocity;


stock Handle:cvarInform, 
Handle:g_slomo_bullets_enabled_handle, 
Handle:g_slomo_bullets_velocity_handle, 
Handle:g_slomo_bullets_radius_handle, 
Handle:g_slomo_bullets_mode_handle, 
Handle:g_slomo_bullets_logging_mode_handle;






public void OnPluginStart()
{
	CreateConVar("sm_slomo_bullets_version", PLUGIN_VERSION, "the version of this disgusting crap of slomo_bullets evil bad bad bad bad bad!!!1!!!", FCVAR_REPLICATED | FCVAR_SPONLY | FCVAR_DONTRECORD | FCVAR_NOTIFY);
	g_slomo_bullets_enabled_handle = CreateConVar("sm_slomo_bullets_enabled", "1", "0 = Disabled , 1 = Enables the Plugin.", _, true, 0.0, true, 1.0);
	//g_slomo_bullets_mode_handle = CreateConVar("sm_slomo_bullets_mode", "2", "there are several modes, including \"Cone\" and \"Rage\". Feel free to try them all out!", _, true, 0.0, true, float(view_as<int>(slomo_bullets_Cone)));
	g_slomo_bullets_logging_mode_handle = CreateConVar("sm_slomo_bullets_logging_mode", "2", "there are several logging modes, including \"NONE\" and \"Console\". Feel free to try them all out!", _, true, 0.0, true, float(view_as<int>(Log_Chat)));
	g_slomo_bullets_velocity_handle = CreateConVar("sm_slomo_bullets_velocity", "1200.0", "velocity of slomo bullets. between 0.0001 and 1600.0", _, true, 0.0001, true, 1600.0);
	HookConVarChange(g_slomo_bullets_enabled_handle, CVarChange);
	HookConVarChange(g_slomo_bullets_velocity_handle, CVarChange);
	HookConVarChange(g_slomo_bullets_logging_mode_handle, CVarChange);
	
	
	cvarInform = CreateConVar("sm_slomo_bullets_inform", "1", "Enable information notification\n0 = Disabled\n1 = Enabled", _, true, 0.0, true, 1.0);
	g_iInform = GetConVarBool(cvarInform);
	HookConVarChange(cvarInform, CVarChange);
	
	RegAdminCmd("sm_slomo_bullets_active", SlomoBulletsCmd, 0, "Enable/Disable SlowmoBullets");
	LoadTranslations("slomo_bullets.phrases");
	
	
	RegConsoleCmd("reset_slomo_bullets", Command_ResetSlomoBullets, "reset slomo_bullets");
	RegConsoleCmd("toggle_slomo_bullets", Command_SlomoBullets, "toggle slomo_bullets");
	
	AutoExecConfig(true, "sm_slomo_bullets");
	Load_Cfg();
	init_several_stocks();
}

public OnConfigsExecuted(){
	
	
	
	Load_Cfg();
	
	
}

public void Load_Cfg(){
	
	g_slomo_bullets_enabled = GetConVarBool(g_slomo_bullets_enabled_handle);
	g_iInform = GetConVarBool(cvarInform);
	g_slomo_bullets_logging_mode = GetConVarInt(g_slomo_bullets_logging_mode_handle);
	g_slomo_bullets_velocity = GetConVarFloat(g_slomo_bullets_velocity_handle);
	
}
public CVarChange(Handle:hConvar, const String:strOldValue[], const String:strNewValue[])
{
	if (hConvar == g_slomo_bullets_enabled_handle) {
		g_slomo_bullets_enabled = GetConVarBool(g_slomo_bullets_enabled_handle);
	}
	if (hConvar == cvarInform) {
		g_iInform = GetConVarBool(cvarInform);
	}
	if (hConvar == g_slomo_bullets_logging_mode_handle) {
		g_slomo_bullets_logging_mode = GetConVarInt(g_slomo_bullets_logging_mode_handle);
	}
	if(hConvar == g_slomo_bullets_velocity_handle){
		g_slomo_bullets_velocity = GetConVarFloat(g_slomo_bullets_velocity_handle);
	}
}

stock Action sdk_damage_hook_slowmo_bullets(int player_id, int &attacker_id, int &inflictor, float &damage, int &damagetype, int &ammotype, int hitbox, int hitgroup)
{
	if (!client_hittable(player_id) || !client_hittable(attacker_id)) {
		log_message(view_as<LOGGING_MODES>(g_slomo_bullets_logging_mode), player_id, "Client not hittable!!");
		
		return Plugin_Continue;
		
	}
	if (g_player_is_slomo_bullets[player_id]) {
		create_projectile_from_player(attacker_id, g_slomo_bullets_velocity,damage,hitgroup);
		log_message(view_as<LOGGING_MODES>(g_slomo_bullets_logging_mode), attacker_id, "Slowmo projectile created!");
		log_message(view_as<LOGGING_MODES>(g_slomo_bullets_logging_mode), player_id, "Slowmo projectile created!");
		
		damage = 0.0;
		
		return Plugin_Changed;
	}
	return Plugin_Continue;
}
public Action CS_OnTerminateRound(float &delay, CSRoundEndReason &reason){
	
	clear_all_slomo_shells();
	return Plugin_Continue;
	
}
public Action:SlomoBulletsCmd(client, iArgs)
{
	if (!g_slomo_bullets_enabled) {
		
		
		ReplyToCommand(client, "[SM] SlomoBullets not enabled!!!");
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
			int slomo_bullets_self = 0;
			
			for (int i = 0; i < target_count; i++)
			{
				/* Kick everyone else first */
				if (target_list[i] == client)
				{
					slomo_bullets_self = client;
				}
				else
				{
					enable_slomo_bullets_on_client(client, target_list[i]);
				}
			}
			
			if (slomo_bullets_self)
			{
				enable_slomo_bullets_on_client(client, client);
			}
		}
		else
		{
			ReplyToTargetError(client, target_count);
		}
	}
	else {
		
		enable_slomo_bullets_on_client(client, client);
		
		
	}
	
	
	
	return Plugin_Handled;
}

public Action Command_SlomoBullets(int client, int args)
{
	if (client_hittable(client)) {
		if (g_player_can_slomo_bullets[client]) {
			ToggleSlomoBulletsPlayer(client);
		}
	}
	return Plugin_Handled;
}

public OnClientPutInServer(client)
{
	g_player_can_slomo_bullets[client] = false;
	g_player_is_slomo_bullets[client] = false;
	g_bInformed[client] = false;
}

public Action:OnPlayerSpawn(Handle:hEvent, String:strName[], bool:bDontBroadcast)
{
	new client = GetClientOfUserId(GetEventInt(hEvent, "userid"));
	if (!client_hittable(client)) {
		return Plugin_Continue;
	}
	
	if (g_iInform && !g_bInformed[client] && CheckCommandAccess(client, "sm_slomo_bullets_active", 0))
	{
		SetGlobalTransTarget(client);
		PrintToChat(client, "%t", "InformSlomoBullets");
		g_bInformed[client] = true;
	}
	reset_SlomoBullets(client);
	return Plugin_Continue;
}
void ToggleSlomoBulletsPlayer(int player_id, bool ignore = true, bool value = false) {
	static char log_string[256];
	if (g_player_can_slomo_bullets[player_id]) {
		FormatEx(log_string, LOGGING_BUFF_SIZE, "You are %s!!!!", !g_player_is_slomo_bullets[player_id] ? "SlomoBullets-ing!":"NOT SlomoBullets-ing...");
		g_player_is_slomo_bullets[player_id] = (ignore ? (!g_player_is_slomo_bullets[player_id]):value);
		if (g_player_is_slomo_bullets[player_id]) {
			
			SDKHook(player_id, SDKHook_TraceAttack, sdk_damage_hook_slowmo_bullets);
			
			
		}
		else {
			
			
			SDKUnhook(player_id, SDKHook_TraceAttack, sdk_damage_hook_slowmo_bullets);
			
			
		}	
	}
	else {
		FormatEx(log_string, LOGGING_BUFF_SIZE, "My MAN you can NOT slomo_bullets.\nBut here is your slomo_bullets status anyways...:\n%s\n", g_player_is_slomo_bullets[player_id] ? "SlomoBullets-ing!":"NOT SlomoBullets-ing...");
		
	}
	log_message(view_as<LOGGING_MODES>(g_slomo_bullets_logging_mode), player_id, log_string);
}
public Action Command_ResetSlomoBullets(int client, int args)
{
	if (g_player_can_slomo_bullets[client]) {
		reset_SlomoBullets(client);
	}
	return Plugin_Handled;
}
void reset_SlomoBullets(int client)
{
	
	if (client_hittable(client)) {
		if (g_player_is_slomo_bullets[client]) {
			CPrintToChat(client, "Your slomo_bullets has been reset!");
			g_player_is_slomo_bullets[client] = false;
			
		}
		
	}
}
void enable_slomo_bullets_on_client(int inflictor, int client) {
	
	if (g_player_can_slomo_bullets[client])
	{
		reset_SlomoBullets(client);
		g_player_can_slomo_bullets[client] = false;
		SetGlobalTransTarget(client);
		char target_name[128];
		char inflictor_name[128];
		GetClientName(client, target_name, 127);
		GetClientName(inflictor, inflictor_name, 127);
		ShowActivity(inflictor, "You just disabled slomo_bullets on %s!!!\n", target_name);
		ShowActivity(client, "%s Just disabled slomo_bullets on you!!!\n", inflictor_name);
		ReplyToCommand(client, "[SM] %t", "EnableSlomoBullets");
	}
	else
	{
		g_player_can_slomo_bullets[client] = true;
		ToggleSlomoBulletsPlayer(client,false,true);
		SetGlobalTransTarget(client);
		char target_name[128];
		char inflictor_name[128];
		GetClientName(client, target_name, 127);
		GetClientName(inflictor, inflictor_name, 127);
		ShowActivity(inflictor, "You just enabled slomo_bullets on %s!!!\n", target_name);
		ShowActivity(client, "%s Just enabled slomo_bullets on you!!!\n", inflictor_name);
		ReplyToCommand(client, "[SM] %t", "DisableSlomoBullets");
	}
	
	
}
public void OnMapStart() {
	
	precache_cheat_lib_fx();
}
