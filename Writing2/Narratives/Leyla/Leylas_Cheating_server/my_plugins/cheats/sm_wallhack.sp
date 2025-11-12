#pragma semicolon 1

#include "../my_includes/sm_basic_stocks.inc"
#include "../my_includes/sm_arithmetic_stocks.inc"
#include "../my_includes/sm_vector_stocks.inc"
#include "../my_includes/sm_graphical_stocks.inc"

#define PLUGIN_AUTHOR "MilkChanThaGoat"
#define PLUGIN_VERSION "1.0.0"

public Plugin myinfo = 
{
	name = "Milk's filthy wallhack plugin", 
	author = PLUGIN_AUTHOR, 
	description = "Let girls have wallhack", 
	version = PLUGIN_VERSION, 
	url = "http://localhost:11001/"
};

#define WALLHACK_REPEAT_PERIOD 0.1
#define WALLHACK_RENDER_PERIOD 0.1

enum wallhack_MODES {
	
	wallhack_Rage, 
	wallhack_Cone
	
	
};


stock bool:g_wallhack_enabled, 
bool:g_player_is_tagging[MAXPLAYERS + 1][MAXPLAYERS + 1], 
bool:g_player_can_wallhack[MAXPLAYERS + 1], 
bool:g_player_is_rendering_wallhack[MAXPLAYERS + 1], 
bool:g_iInform, 
bool:g_bInformed[MAXPLAYERS + 1], 
bool:g_wallhack_rendering_enabled;


stock Handle:cvarInform, 
Handle:g_wallhack_enabled_handle, 
Handle:g_wallhack_radius_handle, 
Handle:g_wallhack_mode_handle, 
Handle:g_wallhack_logging_mode_handle, 
Handle:g_wallhack_cone_length_handle, 
Handle:g_wallhack_cone_fov_handle,
Handle:g_wallhack_rendering_enabled_handle;

stock int g_wallhack_mode;
stock int g_wallhack_logging_mode;


stock float g_wallhack_radius;
stock float g_wallhack_cone_fov;
stock float g_wallhack_cone_length;





public void OnPluginStart()
{
	CreateConVar("sm_wallhack_version", PLUGIN_VERSION, "the version of this disgusting crap of wallhack evil bad bad bad bad bad!!!1!!!", FCVAR_REPLICATED | FCVAR_SPONLY | FCVAR_DONTRECORD | FCVAR_NOTIFY);
	g_wallhack_enabled_handle = CreateConVar("sm_wallhack_enabled", "1", "0 = Disabled , 1 = Enables the Plugin.", _, true, 0.0, true, 1.0);
	g_wallhack_radius_handle = CreateConVar("sm_wallhack_radius", "500.0", "Between 0.0 and whatever. Determines the size of the wallhack range", _, true, 0.0, false, _);
	g_wallhack_cone_fov_handle = CreateConVar("sm_wallhack_cone_fov", "50.0", "Between 0.0 and 179.0 degrees. Determines the angle of the wallhack in cone mode", _, true, 0.0, true, 179.0);
	g_wallhack_cone_length_handle = CreateConVar("sm_wallhack_cone_length", "500.0", "Between 0.0 and whatever. Determines the length of the wallhack in cone mode", _, true, 0.0, false, _);
	g_wallhack_rendering_enabled_handle = CreateConVar("sm_wallhack_rendering_enabled", "1", "0 or 1. Disables/enables rendering of the aiming domains", _, true, 0.0, true, 1.0);
	g_wallhack_mode_handle = CreateConVar("sm_wallhack_mode", "1", "there are several modes, including \"Cone\" and \"Rage\". Feel free to try them all out!", _, true, 0.0, true, float(view_as<int>(wallhack_Cone)));
	g_wallhack_logging_mode_handle = CreateConVar("sm_wallhack_logging_mode", "2", "there are several logging modes, including \"NONE\" and \"Console\". Feel free to try them all out!", _, true, 0.0, true, float(view_as<int>(Log_Chat)));
	HookConVarChange(g_wallhack_enabled_handle, CVarChange);
	HookConVarChange(g_wallhack_radius_handle, CVarChange);
	HookConVarChange(g_wallhack_cone_fov_handle, CVarChange);
	HookConVarChange(g_wallhack_cone_length_handle, CVarChange);
	HookConVarChange(g_wallhack_rendering_enabled_handle, CVarChange);
	HookConVarChange(g_wallhack_mode_handle, CVarChange);
	HookConVarChange(g_wallhack_logging_mode_handle, CVarChange);
	Array_Fill(g_player_is_rendering_wallhack, MAXPLAYERS + 1, false, 0);
	Array_Fill(g_player_can_wallhack, MAXPLAYERS + 1, false, 0);
	for (int i = 1; i <= MAXPLAYERS; i++) {
		
		Array_Fill(g_player_is_tagging[i], MAXPLAYERS + 1, false, 0);
		
	}
	
	HookEvent("player_spawn", OnPlayerSpawn);
	
	
	cvarInform = CreateConVar("sm_wallhack_inform", "1", "Enable information notification\n0 = Disabled\n1 = Enabled", _, true, 0.0, true, 1.0);
	g_iInform = GetConVarBool(cvarInform);
	HookConVarChange(cvarInform, CVarChange);
	
	RegAdminCmd("sm_wallhack_active", WallHackCmd, 0, "Enable/Disable wallhack");
	LoadTranslations("wallhack.phrases");
	RegConsoleCmd("unwallhack", Command_ResetWallHack, "reset wallhack");
	RegConsoleCmd("list_wallhack", Command_WallHack_List, "list wallhack");
	RegConsoleCmd("render_wallhack", Command_WallHack_Toggle_Render, "toggle wallhack render");
	
	AutoExecConfig(true, "sm_wallhack");
	Load_Cfg();
	init_several_stocks();
	CreateTimer(WALLHACK_RENDER_PERIOD, wallhack_render_func, _, TIMER_REPEAT);
	CreateTimer(WALLHACK_REPEAT_PERIOD, acquire_target_func, _, TIMER_REPEAT);
	
}
public void Load_Cfg() {
	
	g_wallhack_enabled = GetConVarBool(g_wallhack_enabled_handle);
	g_iInform = GetConVarBool(cvarInform);
	g_wallhack_radius = GetConVarFloat(g_wallhack_radius_handle);
	g_wallhack_cone_fov = GetConVarFloat(g_wallhack_cone_fov_handle);
	g_wallhack_cone_length = GetConVarFloat(g_wallhack_cone_length_handle);
	g_wallhack_rendering_enabled = GetConVarBool(g_wallhack_rendering_enabled_handle);
	g_wallhack_logging_mode = GetConVarInt(g_wallhack_logging_mode_handle);
	g_wallhack_mode = GetConVarInt(g_wallhack_mode_handle);
	
}
public CVarChange(Handle:hConvar, const String:strOldValue[], const String:strNewValue[])
{
	if (hConvar == g_wallhack_enabled_handle) {
		g_wallhack_enabled = GetConVarBool(g_wallhack_enabled_handle);
	}
	if (hConvar == cvarInform) {
		g_iInform = GetConVarBool(cvarInform);
	}
	if (hConvar == g_wallhack_logging_mode_handle) {
		g_wallhack_logging_mode = GetConVarInt(g_wallhack_logging_mode_handle);
	}
	if (hConvar == g_wallhack_radius_handle) {
		g_wallhack_radius = GetConVarFloat(g_wallhack_radius_handle);
	}
	if (hConvar == g_wallhack_cone_fov_handle) {
		g_wallhack_cone_fov = GetConVarFloat(g_wallhack_cone_fov_handle);
	}
	if (hConvar == g_wallhack_cone_length_handle) {
		g_wallhack_cone_length = GetConVarFloat(g_wallhack_cone_length_handle);
	}
	if (hConvar == g_wallhack_rendering_enabled_handle) {
		g_wallhack_rendering_enabled = GetConVarBool(g_wallhack_rendering_enabled_handle);
	}
	if (hConvar == g_wallhack_mode_handle) {
		g_wallhack_mode = GetConVarInt(g_wallhack_mode_handle);
	}
}
stock Action acquire_target_func(Handle timer, any data) {
	
	for (int player_id = 1; player_id <= MAXPLAYERS; player_id++) {
		if (client_hittable(player_id) && g_player_is_rendering_wallhack[player_id]) {
			
			static int player_list[MAXPLAYERS];
			int num_clients_found = Client_GetPlayersInRadius(player_id, player_list, (g_wallhack_mode == (view_as<int>(wallhack_Rage))) ? g_wallhack_radius:g_wallhack_cone_length, true);
			static char log_string[256];
			FormatEx(log_string, LOGGING_BUFF_SIZE, "We have found %d players within a radius of %0.2f around us!!!", num_clients_found, g_wallhack_radius);
			log_message(view_as<LOGGING_MODES>(g_wallhack_logging_mode), player_id, log_string);
			FormatEx(log_string, LOGGING_BUFF_SIZE, "We are in cone mode! Really???? %s", (g_wallhack_mode == (view_as<int>(wallhack_Cone))) ? "Yes!":"No..");
			
			for (int i = 0; i < num_clients_found; i++) {
				int player_tg = player_list[i];
				log_message(view_as<LOGGING_MODES>(g_wallhack_logging_mode), player_id, log_string);
				g_player_is_tagging[player_id][player_tg] = (client_hittable(player_tg) && player_in_fov(player_id, player_tg));
			}
		}
	}
	return Plugin_Continue;
}
public Action wallhack_render_func(Handle timer, any data) {
	
	for (int player_id = 1; player_id <= MAXPLAYERS; player_id++) {
		if (client_hittable(player_id) && g_player_is_rendering_wallhack[player_id]) {
			for (int player_tg = 1; player_tg <= MAXPLAYERS; player_tg++) {
				
				
				if (client_hittable(player_tg) && g_player_is_tagging[player_id][player_tg] && (player_tg != player_id)) {
					float hacker_orig[3], 
					draw_end_orig[3], 
					vector_between[3], 
					vector_between_rot[3];
					GetClientEyePosition(player_id, hacker_orig);
					get_entity_direction_vector_raw(player_id, player_tg, vector_between, MASK_ALL);
					dir_vector_to_yaw_pitch_roll(vector_between_rot, vector_between, 3);
					wall_bound_vector(player_id, hacker_orig, vector_between_rot, draw_end_orig);
					hacker_orig[2] -= (SUBTRACTED_HEIGHT*0.65);
					draw_end_orig[2] -= (SUBTRACTED_HEIGHT*0.65);
					make_ent_offset_bbox(player_id, player_tg, draw_end_orig, Polarity_Colors[players_are_teamates(player_tg,player_id)]);
					make_laser_beam(player_id, hacker_orig, draw_end_orig, Polarity_Colors[players_are_teamates(player_tg,player_id)]);
					
				}
			}
		}
	}
	return Plugin_Continue;
}

public OnConfigsExecuted(){
	
	
	
	Load_Cfg();
	
	
}
public void OnMapStart() {
	
	precache_cheat_lib_fx();
}

public Action Command_WallHack_Toggle_Render(int client, int args)
{
	if (client_hittable(client)) {
		if (g_wallhack_rendering_enabled) {
			ToggleWallHackPlayerRender(client);
		}
	}
	return Plugin_Handled;
}
public bool player_in_fov(int player_id, int player_hit) {
	
	bool result = true;
	static char log_string[256];
	if (g_wallhack_mode == (view_as<int>(wallhack_Cone))) {
		static float radians_to_check[1] = { 0.0 };
		if (!(result = check_in_fov(player_id, player_hit, g_wallhack_cone_fov, g_wallhack_cone_length, radians_to_check, MASK_ALL))) {
			
			FormatEx(log_string, LOGGING_BUFF_SIZE, "We Found no one... sorry...");
		}
		else {
			
			FormatEx(log_string, LOGGING_BUFF_SIZE, "We did find someone, man! (We did! We found someone at %0.2f degrees.)", radians_to_check[0]);
		}
		log_message(view_as<LOGGING_MODES>(g_wallhack_logging_mode), player_id, log_string);
		
	}
	return result;
}
public Action Command_WallHack_List(int player_id, int args)
{
	static int player_list[MAXPLAYERS];
	static char user_name[128];
	static char mode_name[128];
	static char log_string[LOGGING_BUFF_SIZE];
	int num_clients_found = Client_GetPlayersInRadius(player_id, player_list, (g_wallhack_mode == (view_as<int>(wallhack_Rage))) ? g_wallhack_radius:g_wallhack_cone_length, true);
	FormatEx(log_string, LOGGING_BUFF_SIZE, "We have found %d players within a radius of %0.2f around us!!!\nWe are in cone mode! Really???? %s", num_clients_found, g_wallhack_radius, (g_wallhack_mode == (view_as<int>(wallhack_Cone))) ? "Yes!":"No..");
	
	
	if ((num_clients_found > 0)) {
		int player_hit = player_list[0];
		if (client_hittable(player_id) && player_in_fov(player_id, player_hit)) {
			
			if (g_player_can_wallhack[player_id]) {
				GetClientName(player_hit, user_name, 127);
			}
			FormatEx(log_string, LOGGING_BUFF_SIZE, "%s\n[SH] wallhack: Closest player: %s\n", log_string,user_name);
		}
		else {
			
			FormatEx(log_string, LOGGING_BUFF_SIZE, "%s\n[SH] wallhack: We have not found anyone\n", log_string);
			
			
		}
	}
	else {
		
		FormatEx(log_string, LOGGING_BUFF_SIZE, "%s\n[SH] wallhack: We have not found anyone\n", log_string);
		
		
	}
	
	convert_wallhack_mode_to_string(g_wallhack_mode, mode_name, 127);
	FormatEx(log_string, LOGGING_BUFF_SIZE, "%s\nwallhack Rage radius is: %0.2f\nwallhack cone length is: %0.2f\nwallhack cone fov is: %0.2f\nwallhack mode is: %d, which corresponds to: %s\nwallhack rendering is: %d\n", log_string, 
		g_wallhack_radius, 
		g_wallhack_cone_length, 
		g_wallhack_cone_fov, 
		g_wallhack_mode, mode_name, 
		g_wallhack_rendering_enabled);
	
	
	log_message(view_as<LOGGING_MODES>(g_wallhack_logging_mode), player_id, log_string);
	return Plugin_Handled;
}
public void convert_wallhack_mode_to_string(int mode, char[] string, int size) {
	
	switch (mode) {
		case wallhack_Rage: {
			strcopy(string, size, "wallhack_Rage");
		}
		case wallhack_Cone: {
			strcopy(string, size, "wallhack_Cone");
		}
		default: {
			strcopy(string, size, "NOT_A_VALID_MODE");
		}
		
		
	}
	
}
public Action Command_ResetWallHack(int client, int args)
{
	if (g_player_can_wallhack[client]) {
		reset_wallhack(client);
	}
	return Plugin_Handled;
}
void reset_wallhack(int client)
{
	
	if (client_hittable(client)) {
		if (g_player_is_rendering_wallhack[client]) {
			CPrintToChat(client, "Your wallhack has been reset!");
			g_player_is_rendering_wallhack[client] = false;
			g_player_can_wallhack[client] = false;
			Array_Fill(g_player_is_tagging[client], MAXPLAYERS + 1, false, 0);
			
		}
		
	}
}
public OnClientPutInServer(client)
{
	g_player_can_wallhack[client] = false;
	g_player_is_rendering_wallhack[client] = false;
	Array_Fill(g_player_is_tagging[client], MAXPLAYERS + 1, false, 0);
	g_bInformed[client] = false;
}
public Action:OnPlayerSpawn(Handle:hEvent, String:strName[], bool:bDontBroadcast)
{
	new client = GetClientOfUserId(GetEventInt(hEvent, "userid"));
	if (!client_hittable(client)) {
		return Plugin_Continue;
	}
	
	if (g_iInform && !g_bInformed[client] && CheckCommandAccess(client, "sm_wallhack_active", 0))
	{
		SetGlobalTransTarget(client);
		PrintToChat(client, "%t", "InformWallhack");
		g_bInformed[client] = true;
	}
	reset_wallhack(client);
	return Plugin_Continue;
}
void ToggleWallHackPlayerRender(int player_id, bool ignore = true, bool value = false) {
	static char log_string[LOGGING_BUFF_SIZE];
	if (g_wallhack_rendering_enabled) {
		FormatEx(log_string, LOGGING_BUFF_SIZE, "You ARE %s!!!!", !g_player_is_rendering_wallhack[player_id] ? "rendering wall hack!":"NOT rendering wall hack...");
		g_player_is_rendering_wallhack[player_id] = (ignore ? (!g_player_is_rendering_wallhack[player_id]):value);
	}
	else {
		FormatEx(log_string, LOGGING_BUFF_SIZE, "My MAN you can NOT render wall hack.\nBut here is your wall hack rendering status anyways...:\n%s\n", g_player_is_rendering_wallhack[player_id] ? "rendering wall hack!":"NOT rendering wall hack...");
		
	}
	log_message(view_as<LOGGING_MODES>(g_wallhack_logging_mode), player_id, log_string);
}
public Action:WallHackCmd(client, iArgs)
{
	if (!g_wallhack_enabled) {
		
		
		ReplyToCommand(client, "[SM] wallhack not enabled!!!");
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
			int wallhack_self = 0;
			
			for (int i = 0; i < target_count; i++)
			{
				/* Kick everyone else first */
				if (target_list[i] == client)
				{
					wallhack_self = client;
				}
				else
				{
					enable_wallhack_on_client(client, target_list[i]);
				}
			}
			
			if (wallhack_self)
			{
				enable_wallhack_on_client(client, client);
			}
		}
		else
		{
			ReplyToTargetError(client, target_count);
		}
	}
	else {
		
		enable_wallhack_on_client(client, client);
		
		
	}
	
	
	
	return Plugin_Handled;
}

void enable_wallhack_on_client(int inflictor, int client) {
	
	if (g_player_can_wallhack[client])
	{
		reset_wallhack(client);
		g_player_can_wallhack[client] = false;
		SetGlobalTransTarget(client);
		char target_name[128];
		char inflictor_name[128];
		GetClientName(client, target_name, 127);
		GetClientName(inflictor, inflictor_name, 127);
		ShowActivity(inflictor, "You just disabled wallhack on %s!!!\n", target_name);
		ShowActivity(client, "%s Just disabled wallhack on you!!!\n", inflictor_name);
		ReplyToCommand(client, "[SM] %t", "EnableWallhack");
	}
	else
	{
		g_player_can_wallhack[client] = true;
		ToggleWallHackPlayerRender(client, false, true);
		SetGlobalTransTarget(client);
		char target_name[128];
		char inflictor_name[128];
		GetClientName(client, target_name, 127);
		GetClientName(inflictor, inflictor_name, 127);
		ShowActivity(inflictor, "You just enabled wallhack on %s!!!\n", target_name);
		ShowActivity(client, "%s Just enabled wallhack on you!!!\n", inflictor_name);
		ReplyToCommand(client, "[SM] %t", "DisableWallhack");
	}
	
	
}

public void OnPluginEnd()
{
	
	safe_close_handle(g_wallhack_enabled_handle);
	safe_close_handle(g_wallhack_radius_handle); 
	safe_close_handle(g_wallhack_mode_handle);
	safe_close_handle(g_wallhack_cone_length_handle); 
	safe_close_handle(g_wallhack_cone_fov_handle);
	safe_close_handle(g_wallhack_logging_mode_handle);
	safe_close_handle(g_wallhack_rendering_enabled_handle);
	safe_close_handle(g_wallhack_enabled_handle);
	safe_close_handle(cvarInform);
}
