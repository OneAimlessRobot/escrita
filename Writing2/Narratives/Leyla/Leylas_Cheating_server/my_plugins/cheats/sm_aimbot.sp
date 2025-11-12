#pragma semicolon 1

#include "../my_includes/sm_basic_stocks.inc"
#include "../my_includes/sm_arithmetic_stocks.inc"
#include "../my_includes/sm_vector_stocks.inc"
#include "../my_includes/sm_graphical_stocks.inc"

#define PLUGIN_AUTHOR "MilkChanThaGoat"
#define PLUGIN_VERSION "1.0.0"

public Plugin myinfo = 
{
	name = "Milk's aimbot crutch shit plugin", 
	author = PLUGIN_AUTHOR, 
	description = "Let users aimbot", 
	version = PLUGIN_VERSION, 
	url = "http://localhost:11001/"
};


#define AIMBOT_REPEAT_PERIOD 0.1
#define AIMBOT_RENDER_PERIOD 0.1


enum AIMBOT_MODES {
	
	AimBot_Rage, 
	AimBot_Cone
	
	
};

stock bool:g_aimbot_enabled, 
bool:g_player_is_aimbotting[MAXPLAYERS + 1], 
g_player_is_homming[MAXPLAYERS + 1], 
bool:g_player_can_aimbot[MAXPLAYERS + 1], 
bool:g_player_is_rendering_aimbot[MAXPLAYERS + 1], 
bool:g_iInform, 
bool:g_bInformed[MAXPLAYERS + 1], 
bool:g_aimbot_rendering_enabled;



stock Handle:cvarInform, 
Handle:g_aimbot_enabled_handle, 
Handle:g_aimbot_radius_handle, 
Handle:g_aimbot_mode_handle, 
Handle:g_aimbot_cone_length_handle, 
Handle:g_aimbot_cone_fov_handle, 
Handle:g_aimbot_logging_mode_handle, 
Handle:g_aimbot_rendering_enabled_handle;

stock int g_aimbot_mode;
stock int g_aimbot_logging_mode;


stock float g_aimbot_radius;
stock float g_aimbot_cone_fov;
stock float g_aimbot_cone_length;



public void OnPluginStart()
{
	CreateConVar("sm_aimbot_version", PLUGIN_VERSION, "the version of this disgusting crap of aimbot evil bad bad bad bad bad!!!1!!!", FCVAR_REPLICATED | FCVAR_SPONLY | FCVAR_DONTRECORD | FCVAR_NOTIFY);
	g_aimbot_enabled_handle = CreateConVar("sm_aimbot_enabled", "1", "0 = Disabled , 1 = Enables the Plugin.", _, true, 0.0, true, 1.0);
	g_aimbot_radius_handle = CreateConVar("sm_aimbot_radius", "500.0", "Between 0.0 and whatever. Determines the size of the aimbot range", _, true, 0.0, false, _);
	g_aimbot_cone_fov_handle = CreateConVar("sm_aimbot_cone_fov", "50.0", "Between 0.0 and 179.0 degrees. Determines the angle of the aimbot in cone mode", _, true, 0.0, true, 179.0);
	g_aimbot_cone_length_handle = CreateConVar("sm_aimbot_cone_length", "500.0", "Between 0.0 and whatever. Determines the length of the aimbot in cone mode", _, true, 0.0, false, _);
	g_aimbot_rendering_enabled_handle = CreateConVar("sm_aimbot_rendering_enabled", "1", "0 or 1. Disables/enables rendering of the aiming domains", _, true, 0.0, true, 1.0);
	g_aimbot_mode_handle = CreateConVar("sm_aimbot_mode", "1", "there are several modes, including \"Cone\" and \"Rage\". Feel free to try them all out!", _, true, 0.0, true, float(view_as<int>(AimBot_Cone)));
	g_aimbot_logging_mode_handle = CreateConVar("sm_aimbot_logging_mode", "2", "there are several logging modes, including \"NONE\" and \"Console\". Feel free to try them all out!", _, true, 0.0, true, float(view_as<int>(Log_Chat)));
	HookConVarChange(g_aimbot_enabled_handle, CVarChange);
	HookConVarChange(g_aimbot_radius_handle, CVarChange);
	HookConVarChange(g_aimbot_cone_fov_handle, CVarChange);
	HookConVarChange(g_aimbot_cone_length_handle, CVarChange);
	HookConVarChange(g_aimbot_rendering_enabled_handle, CVarChange);
	HookConVarChange(g_aimbot_mode_handle, CVarChange);
	HookConVarChange(g_aimbot_logging_mode_handle, CVarChange);
	Array_Fill(g_player_is_aimbotting, MAXPLAYERS + 1, false, 0);
	Array_Fill(g_player_can_aimbot, MAXPLAYERS + 1, false, 0);
	Array_Fill(g_player_is_homming, MAXPLAYERS + 1, -1, 0);
	
	HookEvent("player_spawn", OnPlayerSpawn);
	
	
	cvarInform = CreateConVar("sm_aimbot_inform", "1", "Enable information notification\n0 = Disabled\n1 = Enabled", _, true, 0.0, true, 1.0);
	g_iInform = GetConVarBool(cvarInform);
	HookConVarChange(cvarInform, CVarChange);
	
	RegAdminCmd("sm_aimbot_active", AimBotCmd, 0, "Enable/Disable Aim bot");
	LoadTranslations("aimbot.phrases");
	RegConsoleCmd("unhome_aimbot", Command_ResetAimbot, "Unhome aimbot");
	RegConsoleCmd("home_aimbot", Command_AimBot, "home aimbot");
	RegConsoleCmd("list_aimbot", Command_AimBot_List, "list aimbot");
	RegConsoleCmd("render_aimbot", Command_AimBot_Toggle_Render, "toggle aimbot render");
	
	AutoExecConfig(true, "sm_aimbot");
	Load_Cfg();
	init_several_stocks();
	CreateTimer(AIMBOT_REPEAT_PERIOD, aimbot_timer_func, _, TIMER_REPEAT);
	CreateTimer(AIMBOT_RENDER_PERIOD, aimbot_render_func, _, TIMER_REPEAT );
	
}
public OnConfigsExecuted(){
	
	
	
	Load_Cfg();
	
	
}
public void Load_Cfg() {
	
	g_aimbot_enabled = GetConVarBool(g_aimbot_enabled_handle);
	g_iInform = GetConVarBool(cvarInform);
	g_aimbot_radius = GetConVarFloat(g_aimbot_radius_handle);
	g_aimbot_cone_fov = GetConVarFloat(g_aimbot_cone_fov_handle);
	g_aimbot_cone_length = GetConVarFloat(g_aimbot_cone_length_handle);
	g_aimbot_rendering_enabled = GetConVarBool(g_aimbot_rendering_enabled_handle);
	g_aimbot_logging_mode = GetConVarInt(g_aimbot_logging_mode_handle);
	g_aimbot_mode = GetConVarInt(g_aimbot_mode_handle);
	
}

public void OnMapStart() {
	
	precache_cheat_lib_fx();
}

public CVarChange(Handle:hConvar, const String:strOldValue[], const String:strNewValue[])
{
	if (hConvar == g_aimbot_enabled_handle) {
		g_aimbot_enabled = GetConVarBool(g_aimbot_enabled_handle);
	}
	if (hConvar == cvarInform) {
		g_iInform = GetConVarBool(cvarInform);
	}
	if (hConvar == g_aimbot_logging_mode_handle) {
		g_aimbot_logging_mode = GetConVarInt(g_aimbot_logging_mode_handle);
	}
	if (hConvar == g_aimbot_radius_handle) {
		g_aimbot_radius = GetConVarFloat(g_aimbot_radius_handle);
	}
	if (hConvar == g_aimbot_cone_fov_handle) {
		g_aimbot_cone_fov = GetConVarFloat(g_aimbot_cone_fov_handle);
	}
	if (hConvar == g_aimbot_cone_length_handle) {
		g_aimbot_cone_length = GetConVarFloat(g_aimbot_cone_length_handle);
	}
	if (hConvar == g_aimbot_rendering_enabled_handle) {
		g_aimbot_rendering_enabled = GetConVarBool(g_aimbot_rendering_enabled_handle);
	}
	if (hConvar == g_aimbot_mode_handle) {
		g_aimbot_mode = GetConVarInt(g_aimbot_mode_handle);
	}
}
stock void acquire_target(int player_id) {
	
	if (client_hittable(player_id)) {
		if (g_player_is_aimbotting[player_id]) {
			
			static int player_list[MAXPLAYERS];
			static char targeted_player_name[128];
			int num_clients_found = Client_GetPlayersInRadius(player_id, player_list, (g_aimbot_mode == (view_as<int>(AimBot_Rage))) ? GetConVarFloat(g_aimbot_radius_handle):GetConVarFloat(g_aimbot_cone_length_handle), true);
			static char log_string[LOGGING_BUFF_SIZE];
			FormatEx(log_string, LOGGING_BUFF_SIZE, "We have found %d players within a radius of %0.2f around us!!!", num_clients_found, GetConVarFloat(g_aimbot_radius_handle));
			log_message(view_as<LOGGING_MODES>(g_aimbot_logging_mode), player_id, log_string);
			FormatEx(log_string, LOGGING_BUFF_SIZE, "We are in cone mode! Really???? %s", (g_aimbot_mode == (view_as<int>(AimBot_Cone))) ? "Yes!":"No..");
			
			for (int i = 0; i < num_clients_found; i++) {
				int player_hit = player_list[i];
				log_message(view_as<LOGGING_MODES>(g_aimbot_logging_mode), player_id, log_string);
				if (client_hittable(player_hit) && player_in_fov(player_id, player_hit) && (!players_are_teamates(player_id, player_hit))) {
					
					bool changed = (player_hit != g_player_is_homming[player_id]);
					
					g_player_is_homming[player_id] = player_hit;
					
					GetClientName(g_player_is_homming[player_id], targeted_player_name, 127);
					if (changed) {
						FormatEx(log_string, LOGGING_BUFF_SIZE, "We have acquired a new target named %s!!!!!", targeted_player_name);
						log_message(view_as<LOGGING_MODES>(g_aimbot_logging_mode), player_id, log_string);
					}
					break;
				}
			}
		}
	}
}
public Action aimbot_render_func(Handle timer, any data) {
	
	for (int player_id = 1; player_id <= MAXPLAYERS; player_id++) {
		
		if (client_hittable(player_id)) {
			if (GetConVarBool(g_aimbot_rendering_enabled_handle) && g_player_is_rendering_aimbot[player_id]) {
				
				if (g_aimbot_mode == (view_as<int>(AimBot_Cone))) {
					draw_view_cone(player_id, g_aimbot_cone_fov, g_aimbot_cone_length, PLAYERS_ONLY_MASK);
				}
				
				
			}
		}
	}
	return Plugin_Continue;
}
public Action aimbot_timer_func(Handle timer, any data) {
	
	static float raw_aim_dir[3];
	static float aim_dir[3];
	for (int player_id = 1; player_id <= MAXPLAYERS; player_id++) {
		
		if (client_hittable(player_id)) {
			
			if (client_hittable(g_player_is_homming[player_id])) {
				
				
				get_entity_direction_vector_raw(player_id, g_player_is_homming[player_id], raw_aim_dir, PLAYERS_ONLY_MASK);
				dir_vector_to_yaw_pitch_roll(aim_dir, raw_aim_dir, 3);
				TeleportEntity(player_id, NULL_VECTOR, aim_dir, NULL_VECTOR);
				
				
			}
			else if (g_player_is_aimbotting[player_id]) {
				
				g_player_is_homming[player_id] = -1;
				acquire_target(player_id);
				
			}
		}
	}
	return Plugin_Continue;
}

public Action Command_AimBot(int client, int args)
{
	if (client_hittable(client)) {
		if (g_player_can_aimbot[client]) {
			ToggleAimBotPlayer(client);
		}
	}
	return Plugin_Handled;
}
public Action Command_AimBot_Toggle_Render(int client, int args)
{
	if (client_hittable(client)) {
		if (g_aimbot_rendering_enabled) {
			ToggleAimBotPlayerRender(client);
		}
	}
	return Plugin_Handled;
}
public bool player_in_fov(int player_id, int player_hit) {
	
	bool result = true;
	static char log_string[LOGGING_BUFF_SIZE];
	if (g_aimbot_mode == (view_as<int>(AimBot_Cone))) {
		static float radians_to_check[1] = { 0.0 };
		if (!(result = check_in_fov(player_id, player_hit, g_aimbot_cone_fov, g_aimbot_cone_length, radians_to_check, PLAYERS_ONLY_MASK))) {
			
			FormatEx(log_string, LOGGING_BUFF_SIZE, "We Found no one... sorry...");
		}
		else {
			
			FormatEx(log_string, LOGGING_BUFF_SIZE, "We did find someone, man! (We did! We found someone at %0.2f degrees.)", radians_to_check[0]);
		}
		log_message(view_as<LOGGING_MODES>(g_aimbot_logging_mode), player_id, log_string);
		
	}
	return result;
}
public Action Command_AimBot_List(int player_id, int args)
{
	static int player_list[MAXPLAYERS];
	static char user_name[128];
	static char mode_name[128];
	static char log_string[LOGGING_BUFF_SIZE];
	int num_clients_found = Client_GetPlayersInRadius(player_id, player_list, (g_aimbot_mode == (view_as<int>(AimBot_Rage))) ? g_aimbot_radius:g_aimbot_cone_length, true);
	FormatEx(log_string, LOGGING_BUFF_SIZE, "We have found %d players within a radius of %0.2f around us!!!\nWe are in cone mode! Really???? %s", num_clients_found,g_aimbot_radius, (g_aimbot_mode == (view_as<int>(AimBot_Cone))) ? "Yes!":"No..");
	
	
	if ((num_clients_found > 0)) {
		int player_hit = player_list[0];
		if (client_hittable(player_id) && player_in_fov(player_id, player_hit)) {
			if (g_player_can_aimbot[player_id]) {
				GetClientName(player_hit, user_name, 127);
			}
			FormatEx(log_string, LOGGING_BUFF_SIZE, "%s\n[SH] Aimbot: Closest player: %s\n", log_string,user_name);
			
		}
		else {
			
			FormatEx(log_string, LOGGING_BUFF_SIZE, "%s\n[SH] Aimbot: We have not found anyone\n", log_string);
			
			
		}
	}
	else {
		
		FormatEx(log_string, LOGGING_BUFF_SIZE, "%s\n[SH] Aimbot: We have not found anyone\n", log_string);
		
		
	}
	
	convert_aimbot_mode_to_string(g_aimbot_mode, mode_name, 127);
	FormatEx(log_string, LOGGING_BUFF_SIZE, "%s\nAimbot Rage radius is: %0.2f\nAimbot cone length is: %0.2f\nAimbot cone fov is: %0.2f\nAimbot mode is: %d, which corresponds to: %s\nAimbot rendering is: %d\n", log_string, 
		g_aimbot_radius, 
		g_aimbot_cone_length, 
		g_aimbot_cone_fov, 
		g_aimbot_mode, mode_name, 
		g_aimbot_rendering_enabled);
	
	
	log_message(view_as<LOGGING_MODES>(g_aimbot_logging_mode), player_id, log_string);
	return Plugin_Handled;
}
public void convert_aimbot_mode_to_string(int mode, char[] string, int size) {
	
	switch (mode) {
		case AimBot_Rage: {
			strcopy(string, size, "AimBot_Rage");
		}
		case AimBot_Cone: {
			strcopy(string, size, "AimBot_Cone");
		}
		default: {
			strcopy(string, size, "NOT_A_VALID_MODE");
		}
		
		
	}
	
}
public Action Command_ResetAimbot(int client, int args)
{
	if (g_player_can_aimbot[client]) {
		reset_AimBot(client);
	}
	return Plugin_Handled;
}
void reset_AimBot(int client)
{
	
	if (client_hittable(client)) {
		if (g_player_is_aimbotting[client] || client_hittable(g_player_is_homming[client])) {
			CPrintToChat(client, "Your aimbot has been reset!");
			g_player_is_aimbotting[client] = false;
			g_player_can_aimbot[client] = false;
			g_player_is_rendering_aimbot[client] = false;
			g_player_is_homming[client] = -1;
			
		}
		
	}
}
public OnClientPutInServer(client)
{
	g_player_can_aimbot[client] = false;
	g_player_is_aimbotting[client] = false;
	g_player_is_rendering_aimbot[client] = false;
	g_player_is_homming[client] = -1;
	g_bInformed[client] = false;
}
public Action:OnPlayerSpawn(Handle:hEvent, String:strName[], bool:bDontBroadcast)
{
	new client = GetClientOfUserId(GetEventInt(hEvent, "userid"));
	if (!client_hittable(client)) {
		return Plugin_Continue;
	}
	
	if (g_iInform && !g_bInformed[client] && CheckCommandAccess(client, "sm_aimbot_active", 0))
	{
		SetGlobalTransTarget(client);
		PrintToChat(client, "%t", "InformAimBot");
		g_bInformed[client] = true;
	}
	reset_AimBot(client);
	return Plugin_Continue;
}
void ToggleAimBotPlayer(int player_id, bool ignore = true, bool value = false) {
	static char log_string[256];
	if (g_aimbot_enabled&&g_player_can_aimbot[player_id]) {
		FormatEx(log_string, LOGGING_BUFF_SIZE, "You ARE %s!!!!", !g_player_is_aimbotting[player_id] ? "Aimbotting!":"NOT Aimbotting...");
		g_player_is_aimbotting[player_id] = (ignore ? (!g_player_is_aimbotting[player_id]):value);
	}
	else {
		FormatEx(log_string, LOGGING_BUFF_SIZE, "My MAN you can NOT aimbot.\nBut here is your aimbot status anyways...:\n%s\n", g_player_is_aimbotting[player_id] ? "Aimbotting!":"NOT Aimbotting...");
		
	}
	log_message(view_as<LOGGING_MODES>(g_aimbot_logging_mode), player_id, log_string);
}
void ToggleAimBotPlayerRender(int player_id, bool ignore = true, bool value = false) {
	static char log_string[LOGGING_BUFF_SIZE];
	if (g_aimbot_rendering_enabled&&g_player_can_aimbot[player_id]) {
		FormatEx(log_string, LOGGING_BUFF_SIZE, "You are %s!!!!", !g_player_is_rendering_aimbot[player_id] ? "rendering aimbot!":"NOT rendering aimbot...");
		g_player_is_rendering_aimbot[player_id] = (ignore ? (!g_player_is_rendering_aimbot[player_id]):value);
	}
	else {
		FormatEx(log_string, LOGGING_BUFF_SIZE, "My MAN you can NOT render aimbot.\nBut here is your aimbot rendering status anyways...:\n%s\n", g_player_is_aimbotting[player_id] ? "rendering aimbot!":"NOT rendering aimbot...");
		
	}
	log_message(view_as<LOGGING_MODES>(g_aimbot_logging_mode), player_id, log_string);
}
public Action:AimBotCmd(client, iArgs)
{
	if (!g_aimbot_enabled) {
		
		
		ReplyToCommand(client, "[SM] Aimbot not enabled!!!");
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
			int aimbot_self = 0;
			
			for (int i = 0; i < target_count; i++)
			{
				/* Kick everyone else first */
				if (target_list[i] == client)
				{
					aimbot_self = client;
				}
				else
				{
					enable_aimbot_on_client(client, target_list[i]);
				}
			}
			
			if (aimbot_self)
			{
				enable_aimbot_on_client(client, client);
			}
		}
		else
		{
			ReplyToTargetError(client, target_count);
		}
	}
	else {
		
		enable_aimbot_on_client(client, client);
		
		
	}
	
	
	
	return Plugin_Handled;
}

void enable_aimbot_on_client(int inflictor, int client) {
	
	if (g_player_can_aimbot[client])
	{
		reset_AimBot(client);
		SetGlobalTransTarget(client);
		char target_name[128];
		char inflictor_name[128];
		GetClientName(client, target_name, 127);
		GetClientName(inflictor, inflictor_name, 127);
		ShowActivity(inflictor, "You just disabled aimbot on %s!!!\n", target_name);
		ShowActivity(client, "%s Just disabled aimbot on you!!!\n", inflictor_name);
		ReplyToCommand(client, "[SM] %t", "EnableAimBot");
	}
	else
	{
		g_player_can_aimbot[client] = true;
		ToggleAimBotPlayer(client, false, true);
		ToggleAimBotPlayerRender(client, false, true);
		SetGlobalTransTarget(client);
		char target_name[128];
		char inflictor_name[128];
		GetClientName(client, target_name, 127);
		GetClientName(inflictor, inflictor_name, 127);
		ShowActivity(inflictor, "You just enabled aimbot on %s!!!\n", target_name);
		ShowActivity(client, "%s Just enabled aimbot on you!!!\n", inflictor_name);
		ReplyToCommand(client, "[SM] %t", "DisableAimBot");
	}
	
	
}

public void OnPluginEnd()
{
	
	safe_close_handle(g_aimbot_enabled_handle);
	safe_close_handle(g_aimbot_radius_handle);
	safe_close_handle(g_aimbot_mode_handle);
	safe_close_handle(g_aimbot_cone_length_handle);
	safe_close_handle(g_aimbot_cone_fov_handle);
	safe_close_handle(g_aimbot_logging_mode_handle);
	safe_close_handle(g_aimbot_rendering_enabled_handle);
	safe_close_handle(cvarInform);
}
