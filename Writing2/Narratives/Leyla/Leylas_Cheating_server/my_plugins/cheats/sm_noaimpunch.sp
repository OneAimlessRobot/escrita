

#include "../my_includes/sm_basic_stocks.inc"
#include "../my_includes/sm_arithmetic_stocks.inc"
#include "../my_includes/sm_vector_stocks.inc"

#define PLUGIN_AUTHOR "MilkChanThaGoat"
#define PLUGIN_VERSION "1.0.0"

public Plugin myinfo = 
{
	name = "Milk's noaimpunch crutch shit plugin", 
	author = PLUGIN_AUTHOR, 
	description = "Let users have no punch angle", 
	version = PLUGIN_VERSION, 
	url = "http://localhost:11001/"
};

#define	weapon_recoil 0
#define weapon_accuracy_penalty 1
	
#define NUM_WEAPONS (view_as<int>(CSWeapon_SSG08)+1)

stock float default_weapon_properties[NUM_WEAPONS][weapon_accuracy_penalty+1];
stock bool:g_noaimpunch_enabled,
		bool:g_player_has_noaimpunch[MAXPLAYERS + 1],
		bool:g_iInform,
		bool:g_bInformed[MAXPLAYERS + 1];


stock Handle:cvarInform,
	Handle:g_noaimpunch_enabled_handle,
	Handle:g_noaimpunch_coeff_handle,
	Handle:g_noaimpunch_logging_mode_handle;

stock float g_noaimpunch_coeff;

stock int g_noaimpunch_logging_mode;





stock bool index_is_not_weapon(int id){

	CSWeaponID index = view_as<CSWeaponID>(id);
	bool result= (view_as<int>(index) <= 0) || (view_as<int>(index) >= NUM_WEAPONS);
	result = result || (index == CSWeapon_HEGRENADE);
	result = result || (index == CSWeapon_SMOKEGRENADE);
	result = result || (index == CSWeapon_FLASHBANG);
	result = result || (index == CSWeapon_C4);
	result = result || (index == CSWeapon_GALIL);
	result = result || (index == CSWeapon_TASER);
	result = result || (index == CSWeapon_TMP);
	result = result || (index == CSWeapon_SCOUT);
	result = result || (index == CSWeapon_KNIFE);
	result = result || (index == CSWeapon_P228);
	result = result || (index == CSWeapon_SG550);
	result = result || (index == CSWeapon_GALIL);
	result = result || (index == CSWeapon_USP);
	result = result || (index == CSWeapon_MP5NAVY);
	result = result || (index == CSWeapon_M3);
	result = result || (index == CSWeapon_SG552);
	result = result || (index == CSWeapon_SHIELD);
	result = result || (index == CSWeapon_KEVLAR);
	result = result || (index == CSWeapon_ASSAULTSUIT);
	result = result || (index == CSWeapon_NIGHTVISION);
	result = result || (index == CSWeapon_SCAR17);
	return result;
	
	
}
stock void retrieve_weapon_properties(int i){
	
	static char weapon_alias[64];
	static char weapon_name[64];
	static char log_string[LOGGING_BUFF_SIZE];
	if(index_is_not_weapon(i))
	{
		return;
	}
	CS_WeaponIDToAlias(view_as<CSWeaponID>(i), weapon_alias, 63);
	FormatEx(weapon_name,63,"weapon_%s",weapon_alias);
	FormatEx(log_string,LOGGING_BUFF_SIZE,"Olha!...\nEncontramos o index de uma arma!\nO index e %d!!!!\nO seu nome e: %s\n", view_as<int>(i), weapon_name);
	log_message(Log_Console, 0, log_string);
	int weapon_id = CreateEntityByName(weapon_name);
	if(!IsValidEntity(weapon_id)){
		FormatEx(log_string,LOGGING_BUFF_SIZE,"Olha!...\nEntidade %d nao e valida!!!!\n",weapon_id);
		log_message(Log_Console, 0, log_string);
		return;
	}
	default_weapon_properties[i][weapon_recoil] = GetEntPropFloat(weapon_id, Prop_Send,"m_flRecoilIndex");
	default_weapon_properties[i][weapon_accuracy_penalty] = GetEntPropFloat(weapon_id, Prop_Send,"m_fAccuracyPenalty");
	RemoveEdict(weapon_id);
	
}
stock void store_weapon_class_id_properties(CSWeaponID i,float array[weapon_accuracy_penalty+1]){
	
	static char weapon_alias[64];
	static char weapon_name[64];
	if(index_is_not_weapon(i))
	{
		return;
	}
	array[weapon_recoil]=default_weapon_properties[i][weapon_recoil];
	array[weapon_accuracy_penalty]=default_weapon_properties[i][weapon_accuracy_penalty];
	
}
stock void store_weapon_id_properties(int weapon_id,float array[weapon_accuracy_penalty+1]){
	
	if(!IsValidEntity(weapon_id))
	{
		return;
	}
	array[weapon_recoil]= GetEntPropFloat(weapon_id, Prop_Send, "m_flRecoilIndex");
	array[weapon_accuracy_penalty]= GetEntPropFloat(weapon_id, Prop_Send,"m_fAccuracyPenalty");
	
}
stock void restore_weapon_properties(int i,int weapon_id){
	
	static char weapon_alias[64];
	static char weapon_name[64];
	if(index_is_not_weapon(i)||!IsValidEntity(weapon_id))
	{
		return;
	}
	SetEntPropFloat(weapon_id, Prop_Send,"m_flRecoilIndex",default_weapon_properties[i][weapon_recoil]);
	SetEntPropFloat(weapon_id, Prop_Send,"m_fAccuracyPenalty",default_weapon_properties[i][weapon_accuracy_penalty]);
	
}
stock void note_down_weapon_properties(){
	
	static char log_string[LOGGING_BUFF_SIZE];
	
	for(int i=0;i<NUM_WEAPONS;i++){
		if(index_is_not_weapon(i))
		{	
			FormatEx(log_string,LOGGING_BUFF_SIZE,"Nao consideramos um item index de %d uma arma!\nContinuando...",view_as<int>(i));
			log_message(Log_Console, 0, log_string);
			continue;
		}
		
		retrieve_weapon_properties(i);
		FormatEx(log_string,LOGGING_BUFF_SIZE,"As suas propriedades pre-definidas sao:\nRecoil index = %0.2f\nAccuracy penalty = %0.2f", default_weapon_properties[weapon_recoil],
													default_weapon_properties[weapon_accuracy_penalty]);
		log_message(Log_Console, 0, log_string);
	}
	
	
}
public void OnPluginStart()
{
	
	CreateConVar("sm_noaimpunch_version", PLUGIN_VERSION, "the version of this disgusting crap of noaimpunch evil bad bad bad bad bad!!!1!!!", FCVAR_REPLICATED | FCVAR_SPONLY | FCVAR_DONTRECORD | FCVAR_NOTIFY);
	g_noaimpunch_enabled_handle = CreateConVar("sm_noaimpunch_enabled", "1", "0 = Disabled , 1 = Enables the Plugin.", _, true, 0.0, true, 1.0);
	g_noaimpunch_coeff_handle = CreateConVar("sm_noaimpunch_coeff", "9.0", "Between 0.0 and whatever. Determines the size of the wallhack range",_,true,0.0,false);
	g_noaimpunch_logging_mode_handle = CreateConVar("sm_noaimpunch_logging_mode", "9.0", "Between 0.0 and whatever. Determines the size of the wallhack range",_,true,0.0,true,float(view_as<int>(Log_Chat)));
	HookConVarChange(g_noaimpunch_enabled_handle, CVarChange);
	HookConVarChange(g_noaimpunch_coeff_handle, CVarChange);
	HookConVarChange(g_noaimpunch_logging_mode_handle, CVarChange);
	Array_Fill(g_player_has_noaimpunch, MAXPLAYERS + 1, false, 0);
	
	HookEvent("player_spawn", OnPlayerSpawn);
	
	cvarInform = CreateConVar("sm_noaimpunch_inform", "1", "Enable information notification\n0 = Disabled\n1 = Enabled", _, true, 0.0, true, 1.0);
	g_iInform = GetConVarBool(cvarInform);
	HookConVarChange(cvarInform, CVarChange);
	
	RegAdminCmd("sm_noaimpunch_active", NoAimPunchCmd, 0, "Enable/Disable noaimpunch");
	LoadTranslations("noaimpunch.phrases");
	
	AutoExecConfig(true, "sm_noaimpunch");
	Load_Cfg();
	init_several_stocks();
	
}

public OnConfigsExecuted(){
	
	
	
	Load_Cfg();
	
	
}
public OnMapStart(){

	note_down_weapon_properties();
}
public CVarChange(Handle:hConvar, const String:strOldValue[], const String:strNewValue[])
{
	if (hConvar == g_noaimpunch_enabled_handle) {
		g_noaimpunch_enabled = GetConVarBool(g_noaimpunch_enabled_handle);
	}
	if (hConvar == cvarInform) {
		g_iInform = GetConVarBool(cvarInform);
	}
	if (hConvar == g_noaimpunch_coeff_handle) {
		g_noaimpunch_coeff = GetConVarFloat(g_noaimpunch_coeff_handle);
	}
	if(hConvar==g_noaimpunch_logging_mode_handle){
		g_noaimpunch_logging_mode = GetConVarInt(g_noaimpunch_logging_mode_handle);
		
		
	}
}
public void Load_Cfg(){

	g_noaimpunch_enabled = GetConVarBool(g_noaimpunch_enabled_handle);
	g_iInform = GetConVarBool(cvarInform);
	g_noaimpunch_coeff = GetConVarFloat(g_noaimpunch_coeff_handle);
	g_noaimpunch_logging_mode = GetConVarInt(g_noaimpunch_logging_mode_handle);

}
public Action:OnPlayerRunCmd(int player_id,int  &buttons,int  &impulse,  Float:vel[3], Float:angles[3],int &entity)
{
	char log_string[LOGGING_BUFF_SIZE];
	char weapon_name[64];
	float weapon_properties_tmp[weapon_accuracy_penalty+1];
	float weapon_aim_punch_angle[3];
	float weapon_view_punch_angle[3]; 
	float weapon_aim_punch_angle_vel[3];
	if (!client_hittable(player_id)){
		return Plugin_Continue;
	}
	if ((buttons & IN_ATTACK) == IN_ATTACK){
	    if(g_player_has_noaimpunch[player_id])
		{
		int weapon_id = Client_GetActiveWeapon(player_id);
		if(!IsValidEntity(weapon_id)){
			
			FormatEx(log_string, LOGGING_BUFF_SIZE, "Not a valid entity!\nNot fair!!!!!");
			log_message(view_as<LOGGING_MODES>(g_noaimpunch_logging_mode), player_id, log_string);
			return Plugin_Continue;
		}
		FormatEx(log_string, LOGGING_BUFF_SIZE, "I know...\nThat you just fired your weapon, you know that?\nDont believe me?\nTsk...\nI can even tell you what weapon it was that you fired!");
		log_message(view_as<LOGGING_MODES>(g_noaimpunch_logging_mode), player_id, log_string); 
		/*
		Member: m_viewPunchAngle (offset 120) (type vector) (bits 0) (Coord|ChangesOften)
   		Member: m_aimPunchAngle
   		Member: m_aimPunchAngleVel
   		*/
		store_weapon_id_properties(weapon_id, weapon_properties_tmp);
		Client_GetActiveWeaponName(player_id, weapon_name, 64);
   		GetEntPropVector(player_id, Prop_Send,"m_viewPunchAngle",weapon_view_punch_angle);
   		GetEntPropVector(player_id, Prop_Send,"m_aimPunchAngle",weapon_aim_punch_angle);
   		GetEntPropVector(player_id, Prop_Send,"m_aimPunchAngleVel",weapon_aim_punch_angle_vel);
		FormatEx(log_string, LOGGING_BUFF_SIZE, 
							"Your weapon... was... a... %s!\nAnnnnd...\nThat its recoil_index is...: %0.2f...\nAnd That its accuracy penalty is...: %0.2f!",
							weapon_name,
							weapon_properties_tmp[weapon_recoil],
							weapon_properties_tmp[weapon_accuracy_penalty]);
		vector_mult(weapon_view_punch_angle, weapon_view_punch_angle, g_noaimpunch_coeff, 3);
		vector_mult(weapon_aim_punch_angle, weapon_aim_punch_angle, g_noaimpunch_coeff, 3);
		vector_mult(weapon_aim_punch_angle_vel, weapon_aim_punch_angle_vel, g_noaimpunch_coeff, 3);
		vector_mult(weapon_properties_tmp, weapon_properties_tmp, g_noaimpunch_coeff, weapon_accuracy_penalty+1);
		
		SetEntPropFloat(weapon_id, Prop_Send,"m_flRecoilIndex",weapon_properties_tmp[weapon_recoil]);
		SetEntPropFloat(weapon_id, Prop_Send,"m_fAccuracyPenalty",weapon_properties_tmp[weapon_accuracy_penalty]);
		SetEntPropVector(player_id, Prop_Send,"m_viewPunchAngle",weapon_view_punch_angle);
   		SetEntPropVector(player_id, Prop_Send,"m_aimPunchAngle",weapon_aim_punch_angle);
   		SetEntPropVector(player_id, Prop_Send,"m_aimPunchAngleVel",weapon_aim_punch_angle_vel);
   		
   		log_message(view_as<LOGGING_MODES>(g_noaimpunch_logging_mode), player_id, log_string);
		}
		else{
			FormatEx(log_string, LOGGING_BUFF_SIZE, "Pssshhht.... Tsk... Tsk... Tsk... Have fun with the recoil, bozo...");
			log_message(view_as<LOGGING_MODES>(g_noaimpunch_logging_mode), player_id, log_string);
			
		}
	}
	return Plugin_Continue;
}
public Action:OnPlayerSpawn(Handle:hEvent, String:strName[], bool:bDontBroadcast)
{
	new iClient = GetClientOfUserId(GetEventInt(hEvent, "userid"));
	if (!client_hittable(iClient))
		return Plugin_Continue;
	
	if (g_iInform && !g_bInformed[iClient] && CheckCommandAccess(iClient, "sm_noaimpunch_active", 0))
	{
		SetGlobalTransTarget(iClient);
		PrintToChat(iClient, "%t", "InformNoAimPunch");
		g_bInformed[iClient] = true;
	}
	reset_NoAimPunch(iClient);
	return Plugin_Continue;
}
void reset_NoAimPunch(int client)
{
	
	if (client_hittable(client)) {
		if(g_player_has_noaimpunch[client]){
			CPrintToChat(client, "Your noaimpunch has been reset!");
			g_player_has_noaimpunch[client] = false;
			
		}
		
	}
}
public OnClientPutInServer(iClient)
{
	g_player_has_noaimpunch[iClient] = false;
	g_bInformed[iClient] = false;
}
public void ToggleAimPunch(int client)
{
	static char log_string[LOGGING_BUFF_SIZE];
	if(client_hittable(client)){
		if (g_noaimpunch_enabled) {
			FormatEx(log_string, LOGGING_BUFF_SIZE, "You ARE %s!!!!", 
			!g_player_has_noaimpunch[client] ? "noaimpunching!":"NOT noaimpunching...");
			
			g_player_has_noaimpunch[client] = !g_player_has_noaimpunch[client];
		}
		else {
			CPrintToChat(client, "My MAN you can NOT noaimpunch.\nBut here is your noaimpunch status anyways...:\n%s", 
						g_player_has_noaimpunch[client] ? "noaimpunching!":"NOT noaimpunching...");
			
		}
	}
	
	log_message(view_as<LOGGING_MODES>(g_noaimpunch_logging_mode), client, log_string);
}

public Action:NoAimPunchCmd(int iClient, int iArgs)
{
	if (!g_noaimpunch_enabled) {
		
		
		ReplyToCommand(iClient, "[SM] noaimpunch not enabled!!!");
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
					iClient, 
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
				if (target_list[i] == iClient)
				{
					wallhack_self = iClient;
				}
				else
				{
					enable_noaimpunch_on_client(iClient,target_list[i]);
				}
			}
			
			if (wallhack_self)
			{
				enable_noaimpunch_on_client(iClient,iClient);
			}
		}
		else
		{
			ReplyToTargetError(iClient, target_count);
		}
	}
	else{
		
		enable_noaimpunch_on_client(iClient,iClient);
		
		
	}
	
	
	
	return Plugin_Handled;
}

void enable_noaimpunch_on_client(int inflictor, int iClient) {
	
	if (g_player_has_noaimpunch[iClient])
	{
		SetGlobalTransTarget(iClient);
		char target_name[128];
		char inflictor_name[128];
		GetClientName(iClient, target_name, 127);
		GetClientName(inflictor, inflictor_name, 127);
		ShowActivity(inflictor,"You just disabled noaimpunch on %s!!!\n",target_name);
		ShowActivity(iClient,"%s Just disabled noaimpunch on you!!!\n",inflictor_name);
		ReplyToCommand(iClient, "[SM] %t", "EnableNoAimPunch");
	}
	else
	{
		SetGlobalTransTarget(iClient);
		char target_name[128];
		char inflictor_name[128];
		GetClientName(iClient, target_name, 127);
		GetClientName(inflictor, inflictor_name, 127);
		ShowActivity(inflictor,"You just enabled wallhack on %s!!!\n",target_name);
		ShowActivity(iClient,"%s Just enabled wallhack on you!!!\n",inflictor_name);
		ReplyToCommand(iClient, "[SM] %t", "DisableNoAimPunch");
	}
	ToggleAimPunch(iClient);
	
	
}

public void OnPluginEnd()
{
	
	safe_close_handle(g_noaimpunch_coeff_handle);
	safe_close_handle(g_noaimpunch_logging_mode_handle);
	safe_close_handle(g_noaimpunch_enabled_handle);
	safe_close_handle(cvarInform);
}