#pragma semicolon 1

#include "../my_includes/sm_basic_stocks.inc"
#include "../my_includes/sm_misc_stocks.inc"
#include <superheromod>
#include <fpvm_interface>
#include "../my_Includes/superheroes/sm_lena_defines.inc"
enum lena_state{
	
	HasLena=0,
	HasWeaponOn=1,
	HasHooksOn=2
	
};
EngineVersion g_Game;

ConVar g_LenaLevel;
ConVar g_LenaFireRate;
ConVar g_LenaDamageMultiplier;
int g_iHeroIndex;
bool g_bHasLena[MAXPLAYERS + 1][int_cast(HasHooksOn)+1];
//indices are: curr_clip, curr_reserve, curr_max_clip, curr_max_reserve respectively 
int g_iLenaWeaponAmmoInfo[MAXPLAYERS + 1][4];
int g_bLenaJammed[MAXPLAYERS + 1][3];
int g_bLenaJustReloaded[MAXPLAYERS + 1][2];

public Plugin myinfo =
{
	name = "SuperHero Mod CS:GO Hero - Lena",
	author = PLUGIN_AUTHOR,
	description = "Lena hero",
	version = PLUGIN_VERSION,
	url = "https://localhost"
};

public void OnPluginStart()
{
	g_Game = GetEngineVersion();
	if(g_Game != Engine_CSGO)
	{
		SetFailState("This plugin is for CSGO only.");
	}
	g_LenaLevel = CreateConVar("superheromod_lena_level", "8");
	g_LenaFireRate = CreateConVar("superheromod_lena_attack_speed", "0.75", "Amount of times fire rate lenas ak47 should have");
	g_LenaDamageMultiplier = CreateConVar("superheromod_lena_ak74mult", "2", "Ak47 damage mult");
	AutoExecConfig(true, "Lena", "sourcemod/superheromod");
	
	HookEvent("weapon_fire", Event_WeaponFireUpdateUserWeapons, EventHookMode_Post);
	HookEvent("player_hurt",Event_PlayerHurt,EventHookMode_Pre);
	HookEvent("player_death",Event_PlayerDead,EventHookMode_Pre);
	for(int i=1;i<=MAXPLAYERS;i++){
		
		Array_Fill(g_bHasLena[i], sizeof g_bHasLena[], false, 0);
	}
	for(int i=1;i<=MAXPLAYERS;i++){
		
		Array_Fill(g_iLenaWeaponAmmoInfo[i], sizeof g_iLenaWeaponAmmoInfo[], 0, 0);
	}
	for(int i=1;i<=MAXPLAYERS;i++){
		
		Array_Fill(g_bLenaJammed[i], sizeof g_bLenaJammed[], 0, 0);
	}
	
	for(int i=1;i<=MAXPLAYERS;i++){
		
		Array_Fill(g_bLenaJustReloaded[i], sizeof g_bLenaJustReloaded[], false, 0);
	}
	
	
	g_iHeroIndex = SuperHero_CreateHero("Lena", g_LenaLevel.IntValue);
	SuperHero_SetHeroInfo(g_iHeroIndex, "lena", "lena");
	SuperHero_SetHeroPrimaryWeapon(g_iHeroIndex, view_as<int>(CSGOWeaponID_AWP));
	SuperHero_SetHeroBind(g_iHeroIndex);
	init_several_stocks();
	
}
public void SuperHero_OnHeroBind(int client, int heroIndex, int key)
{
	if(!client_has_lena(client)){
		
		return;
	}
	if(!client_hittable(client)){
		
		return;
	}
	if(heroIndex != g_iHeroIndex)
		return;
	
	int weapon_id= GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
	if(!weapon_is_some_lena_weapon_or_not(EntIndexToEntRef(weapon_id))){
		
		return;
	}
	switch(key)
	{
		case SH_KEYDOWN:
		{
			print_lena_weapon_details_to_console(client);
			lena_unjam_weapon(client);
		}
		case SH_KEYUP:{
			
			
		}
	}
}
stock void print_lena_weapon_details_to_console(int client){
	if(!client_has_lena(client)){
		
		return;
	}
	if(!client_hittable(client)){
		
		return;
	}
	int weapon_id= GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
	if(!weapon_is_some_lena_weapon_or_not(EntIndexToEntRef(weapon_id))){
		
		return;
	}
	PrintToConsole(client,"[SH] Lena: Here is the info about your L96A1:\n1- curr_clip= %d\n2- curr_reserve= %d\n3- curr_max_clip: %d\n4- curr_max_reserve: %d\n",
									g_iLenaWeaponAmmoInfo[client][0],
									g_iLenaWeaponAmmoInfo[client][1],
									g_iLenaWeaponAmmoInfo[client][2],
									g_iLenaWeaponAmmoInfo[client][3]);
	
	
}
public void LenaUnmorph(int client)
{
	if (g_bHasLena[client][0] || !client_traceable(client)){
		return;
	}
	
	char szModel[PLATFORM_MAX_PATH];
	int heroIndex = SuperHero_GetHighestPlayerModelLevel(client, szModel, sizeof(szModel));
	if(heroIndex < 0)
	{
		int team = GetClientTeam(client);
		if(team == CS_TEAM_T)
		Format(szModel, sizeof(szModel), SH_DEFAULT_MODEL_T);
		else if(team == CS_TEAM_CT)
		Format(szModel, sizeof(szModel), SH_DEFAULT_MODEL_CT);
	}
	
}
public OnMapStart(){
	
	precache_lena_resources();
	
}

stock bool client_has_lena(int client){
	if(!client_traceable(client)){
		
		return false;
		
	}
	if(!g_bHasLena[client][0]){
		
		return false;
	}
	return true;
	
	
}

stock bool weapon_is_some_lena_weapon_or_not(int weapon){
	if(!IsValidEntity(EntRefToEntIndex(weapon))){
		return false;
	}
	int owner_id=GetEntPropEnt(EntRefToEntIndex(weapon),Prop_Send,"m_hOwnerEntity");
	if(!client_hittable(owner_id)){
		
		return false;
	}
	
	if(!g_bHasLena[owner_id][0]){
		
		return false;
	}
	char classname[128];
	Entity_GetClassName(EntRefToEntIndex(weapon),classname,127);
	if(strncmp(LENA_WEAPON,classname,strlen(classname))){
		return false;
		
	}
	return true;
	
	
}
public Action OnPlayerRunCmd(int client, int &buttons, int &impulse, float vel[3], float angles[3], int &weapon, int &subtype, int &cmdnum, int &tickcount, int &seed, int mouse[2]){
	
	if(!client_hittable(client)){
		
		return Plugin_Continue;
	}
	if(!client_has_lena(client)){
		
		
		return Plugin_Continue;
	}
	int weapon_id= GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
	if(!weapon_is_some_lena_weapon_or_not(EntIndexToEntRef(weapon_id))){
		
		return Plugin_Continue;
	}
	if((buttons&IN_ATTACK)&&JAMMING_ENABLED){
			
		if(g_bLenaJammed[client][0]){
			buttons&=~IN_ATTACK;
			return Plugin_Changed;
		}
	}
	return Plugin_Continue;
	
}
public Action lena_unjam_weapon_timer(Handle timer, any data){
		
	int client= int_cast(data);
	g_bLenaJammed[client][0]=0;
	g_bLenaJammed[client][1]=1;
	g_bLenaJammed[client][2]=0;
	if(IsSoundPrecached(LENA_UNJAM_SHOT_SOUND)){
						
			EmitSoundToClient(client,LENA_UNJAM_SHOT_SOUND);
	}
	PrintToChat(client, "[SH] Lena: Hey! its fixed now! Wow... what the hell was that about? (:");
	return Plugin_Continue;
	
}
public void lena_unjam_weapon(int client){
	
	if(!client_hittable(client)){
		
		return;
	}
	if(!client_has_lena(client)){
		
		return;
		
	}
	if(g_bLenaJammed[client][0]){
		
		if(g_bLenaJammed[client][2]){
			PrintToChat(client, "[SH] Lena: Hey, I am already AT IT! STOP NAGGING ME... jeez... Still unjamming, alright?");
		}
		else{
			if(IsSoundPrecached(LENA_UNJAM_SHOT_SOUND)){
						
				EmitSoundToClient(client,LENA_UNJAM_SHOT_SOUND);
			}
			PrintToChat(client, "[SH] Lena: Ugh... God damn... Unjamming!");
			g_bLenaJammed[client][2]=1;
			CreateTimer(lena_JAM_TIMER_TIME,lena_unjam_weapon_timer,client);
			
			
		}
	}
	else{
		PrintToChat(client, "[SH] Lena: Uhm... I do not think the gun is jammed, now...");
	}
	
	
	return;
}
public void toggle_client_hook(int client,bool value, bool ignore_value_and_just_toggle){
	if(!client_has_lena(client)){
		
		
		return;
	}
	bool negator=true;
	if(!client_hittable(client)){
		
		
		negator=false;
	}
	int weapon_id=INVALID_ENT_REFERENCE;
	if(negator){
		weapon_id= GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
		if(!weapon_is_some_lena_weapon_or_not(EntIndexToEntRef(weapon_id))){
			
			return;
		}
	}
	bool toggle_result= (ignore_value_and_just_toggle?!g_bHasLena[client][1]:value);
	g_bHasLena[client][1]=(toggle_result&&negator);
	
	if(g_bHasLena[client][1]){
		bool hooked= SDKHookEx(EntRefToEntIndex(weapon_id),SDKHook_Reload,lena_weapon_reload_callback);
		if(hooked){
			
			PrintToChat(client, "You were HOOKED!");
			
		}
		else{
		
			PrintToChat(client, "You were NOT HOOKED!");
		}
		float interval=LENA_CLIP_CHECK_INTERVAL;
		Entity_ChangeOverTime(client, interval, lena_clipwatcher_think_callback);
	}
	else{
		SDKUnhook(EntRefToEntIndex(weapon_id),SDKHook_Reload,lena_weapon_reload_callback);
	}
	
}
stock void store_lena_user_weapon_ammo_info(int client,Lena_Store_Type store_type=Store_All){
	if(!client_has_lena(client)){
		
		return;
		
	}
	int weapon_id= GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
	if(!weapon_is_some_lena_weapon_or_not(EntIndexToEntRef(weapon_id))){
		
		return;
	}
	if(int_cast(store_type)<=0){
		
		return;
	}
	if((int_cast(store_type)==1)||(int_cast(store_type)>2)){
		int curr_bullets=GetEntProp( weapon_id, Prop_Data, "m_iClip1");
		if((curr_bullets>=0)&&(curr_bullets<=g_iLenaWeaponAmmoInfo[client][2])){
			g_iLenaWeaponAmmoInfo[client][0]=curr_bullets;
		}
	}
	if((int_cast(store_type)>=2)){
		int ammoType= GetEntProp( weapon_id,Prop_Send, "m_iPrimaryAmmoType");
		g_iLenaWeaponAmmoInfo[client][1]=GetEntProp(client,Prop_Send,"m_iAmmo",_,ammoType);
	}
	
}

stock void retrieve_lena_user_weapon_ammo_info(int client,Lena_Retrieve_Type retrieve_what=Retrieve_All){
	if(!client_has_lena(client)){
		
		return;
		
	}
	
	int weapon_id= GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
	if(weapon_id==INVALID_ENT_REFERENCE){
		
		return;
	}
	if(!weapon_is_some_lena_weapon_or_not(EntIndexToEntRef(weapon_id))){
		
		return;
	}
	if(int_cast(retrieve_what)<=0){
		
		return;
	}
	if((int_cast(retrieve_what)==1)||(int_cast(retrieve_what)>2)){
		
		SetEntProp(weapon_id,Prop_Data,"m_iClip1",g_iLenaWeaponAmmoInfo[client][0]);
		SetEntProp(weapon_id,Prop_Send,"m_iClip1",g_iLenaWeaponAmmoInfo[client][0]);
	}
	if((int_cast(retrieve_what)>=2)){
		
		
		int ammoType= GetEntProp(weapon_id,Prop_Send, "m_iPrimaryAmmoType");
		SetEntProp(client,Prop_Send,"m_iAmmo",g_iLenaWeaponAmmoInfo[client][1],_,ammoType);
		SetEntProp(client,Prop_Data,"m_iAmmo",g_iLenaWeaponAmmoInfo[client][1],_,ammoType);
	}
}
stock void check_lena_user_weapon_ammo_info(int client,int clip_and_ammo[2]){
	if(!client_has_lena(client)){
		
		return;
		
	}
	int weapon_id= GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
	if(!weapon_is_some_lena_weapon_or_not(EntIndexToEntRef(weapon_id))){
		
		return;
	}
	clip_and_ammo[0]=GetEntProp(weapon_id,Prop_Data,"m_iClip1");

	int ammoType= GetEntProp(weapon_id,Prop_Send, "m_iPrimaryAmmoType");
	clip_and_ammo[1]=GetEntProp(client,Prop_Send,"m_iAmmo",_,ammoType);
}

public Action Event_PlayerHurt(Event event, const char[] name, bool dontBroadcast){
	int victim_id= GetClientOfUserId(GetEventInt(event,"userid"));
	int attacker_id= GetClientOfUserId(GetEventInt(event,"attacker"));
	int hitgroup= GetEventInt(event,"hitgroup");
	if(!client_hittable(attacker_id)||!g_bHasLena[attacker_id]||!client_hittable(victim_id)){
		
		return;
		
	}
	int weapon_id= GetEntPropEnt(attacker_id, Prop_Send, "m_hActiveWeapon");
	if(weapon_id==INVALID_ENT_REFERENCE){
		
		return;
	}
	if(!weapon_is_some_lena_weapon_or_not(EntIndexToEntRef(weapon_id))){
		
		return;
	}
	
	
	char hitgroup_name[128];
	
	print_hitzone_name(hitgroup,hitgroup_name);
	
	int bonus=0;
	switch(view_as<Hitzone_Index>(hitgroup)){
		case(HITGROUP_CHEST):{
			
			bonus=1;
			
		}
		case(HITGROUP_HEAD):{
			
			
			bonus=2;
		}
		default:{
		}
	}
	g_iLenaWeaponAmmoInfo[attacker_id][0]+=min(bonus,max(0,g_iLenaWeaponAmmoInfo[attacker_id][2]-g_iLenaWeaponAmmoInfo[attacker_id][0]));
	g_iLenaWeaponAmmoInfo[attacker_id][1]+=min(bonus,max(0,g_iLenaWeaponAmmoInfo[attacker_id][3]-g_iLenaWeaponAmmoInfo[attacker_id][1]));
	g_iLenaWeaponAmmoInfo[attacker_id][2]+=min(bonus,max(0,CLIP_MAX_WEAPON_DEFAULT-g_iLenaWeaponAmmoInfo[attacker_id][2]));
	PrintToChat(attacker_id,"The hitgroup was: %s Bonus= %d",hitgroup_name,bonus);
	retrieve_lena_user_weapon_ammo_info(attacker_id,Retrieve_Clip);
	
	
}
public Action lena_weapon_reload_callback(int weapon){
	if(!weapon_is_some_lena_weapon_or_not(weapon)){
		
		return Plugin_Continue;
	}
	int owner_id=GetEntPropEnt(weapon,Prop_Send, "m_hOwnerEntity");
	if(!client_hittable(owner_id)){
		
		return Plugin_Continue;
		
	}
	if(!g_bHasLena[owner_id][0]){
		
		return Plugin_Continue;
	}
	
	if(GetEntProp(weapon, Prop_Data, "m_iClip1")>=g_iLenaWeaponAmmoInfo[owner_id][2]){
		return Plugin_Handled;
	}
	int clip_and_ammo[2];
	int prev_clip_and_ammo[2];
	check_lena_user_weapon_ammo_info(owner_id,prev_clip_and_ammo);
	check_lena_user_weapon_ammo_info(owner_id,clip_and_ammo);
	int clip_diff=max(0,min(clip_and_ammo[1],g_iLenaWeaponAmmoInfo[owner_id][2]-clip_and_ammo[0]));
	clip_and_ammo[0]+=max(0,clip_diff);
	clip_and_ammo[1]-=max(0,clip_diff);
	g_iLenaWeaponAmmoInfo[owner_id][1]=clip_and_ammo[1];
	
	g_iLenaWeaponAmmoInfo[owner_id][0]=clip_and_ammo[0];
	
	retrieve_lena_user_weapon_ammo_info(owner_id,Retrieve_All);
	
	g_bLenaJustReloaded[owner_id][0]=int_cast(max(0,clip_diff)>prev_clip_and_ammo[1]);
	return Plugin_Continue;
	
	
	
}
public bool lena_clipwatcher_think_callback(int& client,float& delta,int& callno){
	if(!g_bHasLena[client][1]){
		
		return false;
		
	}
	
	if(!client_has_lena(client)){
		
		return false;
	}
	char user_name[128];
	GetClientName(client,user_name,127);
	bool result=true;
	
	int weapon_id= GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
	if(weapon_id==INVALID_ENT_REFERENCE){
		
		return true;
	}
	if(!weapon_is_some_lena_weapon_or_not(EntIndexToEntRef(weapon_id))){
		return true;
	}
	
	int curr_clip=GetEntProp(weapon_id, Prop_Data, "m_iClip1");
	if(((curr_clip!=0)&&(curr_clip>g_iLenaWeaponAmmoInfo[client][2]))||g_bLenaJustReloaded[client][0]){
		g_iLenaWeaponAmmoInfo[client][0]=g_iLenaWeaponAmmoInfo[client][2];
		retrieve_lena_user_weapon_ammo_info(client,Retrieve_Clip);
		if(g_bLenaJustReloaded[client][0]){
			PrintToChat(client,"[SH] Lena: just reloaded!!!!");
			g_bLenaJustReloaded[client][0]=0;
		}
	}
	
	
	int ammoType= GetEntProp(weapon_id,Prop_Send, "m_iPrimaryAmmoType");
	int curr_reserve=GetEntProp(client,Prop_Send,"m_iAmmo",_,ammoType);
	if((curr_reserve>g_iLenaWeaponAmmoInfo[client][3])){
		g_iLenaWeaponAmmoInfo[client][1]=g_iLenaWeaponAmmoInfo[client][3];
		retrieve_lena_user_weapon_ammo_info(client,Retrieve_Ammo);
	}
	else if(curr_reserve!=g_iLenaWeaponAmmoInfo[client][1]){
		
		retrieve_lena_user_weapon_ammo_info(client,Retrieve_Ammo);
		
		
	}
	//
	return result;
	
	
	
}

public void SuperHero_OnHeroInitialized(int client, int heroIndex, int mode)
{
	if(heroIndex != g_iHeroIndex)
	return;
	
	switch(mode)
	{
		case SH_HERO_ADD:
		{
			g_bHasLena[client][0] = true;
			init_lena_user(client);
		}
		case SH_HERO_DROP:
		{
			g_bHasLena[client][0] = false;
			clear_lena_user(client);
		}
	}
}

void lena_weapons(int client){
	
	if(!client_hittable(client)){
		return;
	}
	if(!g_bHasLena[client][0]){
		return;
	}
	if(SuperHero_GetHighestPrimaryWeaponLevel(client) == view_as<int>(CSGOWeaponID_AWP))
	{
		StripPrimary(client);
		int weapon_ref=Client_GiveWeapon(client, LENA_WEAPON, false);
		if(weapon_ref!= INVALID_ENT_REFERENCE)
		{
			SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon",weapon_ref);
			g_iLenaWeaponAmmoInfo[client][0]=LENA_CLIP_MAX_WEAPON;
			g_iLenaWeaponAmmoInfo[client][1]=1;
			g_iLenaWeaponAmmoInfo[client][2]=LENA_CLIP_MAX_WEAPON;
			g_iLenaWeaponAmmoInfo[client][3]=RESERVE_MAX_WEAPON_DEFAULT;
			retrieve_lena_user_weapon_ammo_info(client,Retrieve_All);
			g_bLenaJammed[client][0]=0;
		}
		else{
			
			SetFailState("Invalid ent ref at lena_weapons!\nweapon_ref= %d\n",weapon_ref);
			
		}
		
	}
	
}
public void OnConfigsExecuted()
{
	SuperHero_SetHeroAvailableLevel(g_iHeroIndex, g_LenaLevel.IntValue);
	SuperHero_SetHeroDamageMultiplier(g_iHeroIndex, g_LenaDamageMultiplier.FloatValue, view_as<int>(CSGOWeaponID_AWP));
}

public Action Event_WeaponFireUpdateUserWeapons(Event event, const char[] name, bool dontBroadcast)
{
	int client_id=GetClientOfUserId(GetEventInt(event,"userid"));
	if(!client_hittable(client_id)||!g_bHasLena[client_id]){
		
		return Plugin_Continue;
		
	}
	
	RequestFrame(SetNextPrimaryAttack,client_id);
	return Plugin_Continue;
}
public void SetNextPrimaryAttack(any data)
{
	int client_id = view_as<int>(data);
	int weapon_id= GetEntPropEnt(client_id, Prop_Send, "m_hActiveWeapon");
	if(weapon_id==INVALID_ENT_REFERENCE){
		
		return;
	}
	if(!weapon_is_some_lena_weapon_or_not(EntIndexToEntRef(weapon_id))){
		
		return;
	}
	if(g_bLenaJammed[client_id][0]){
		
		if(IsSoundPrecached(LENA_INJAM_SHOT_SOUND)){
				
			EmitSoundToClient(client_id,LENA_INJAM_SHOT_SOUND);
		}
		PrintToChat(client_id, "[SH] Lena: Still jammed! H- Hang on! (:");
		return;
	}
	g_bLenaJustReloaded[client_id][0]=0;
	g_bLenaJammed[client_id][1]=GetRandomInt(0,RoundFloat(LENA_FAIL_FRAC_DENOMINATOR)-1);
	PrintToChat(client_id, "[SH] Lena: (value= %d between %d and %d)",g_bLenaJammed[client_id][1],0,RoundFloat(LENA_FAIL_FRAC_DENOMINATOR)-1);
	if(!g_bLenaJammed[client_id][1]){
				
		g_bLenaJammed[client_id][0]=1;
		if(IsSoundPrecached(LENA_JAM_SHOT_SOUND)){
					
			PrintToChat(client_id, "[SH] Lena: JAMMED! Sorry (value= %d between %d and %d)",g_bLenaJammed[client_id][1],0,RoundFloat(LENA_FAIL_FRAC_DENOMINATOR)-1);
			EmitSoundToClient(client_id,LENA_JAM_SHOT_SOUND);
		}
		
		SetEntPropFloat(weapon_id, Prop_Send, "m_flNextPrimaryAttack", GetGameTime() + lena_JAM_TIMER_TIME*(g_LenaFireRate.FloatValue/g_LenaFireRate.FloatValue));
		
	}
	store_lena_user_weapon_ammo_info(client_id,Store_Clip);

}
public void SuperHero_OnPlayerSpawned(int client, bool newroundspawn)
{
	if(!g_bHasLena[client][0]){
		return;
	}
	init_lena_user(client);
	return;
}
stock void init_lena_user(int client){
	
	g_bLenaJammed[client][1]=1;
	lena_weapons(client);
	if(IsModelPrecached(LENA_PLAYER_MODEL)){
		SetEntityModel(client,LENA_PLAYER_MODEL);
	}
					
	toggle_client_hook(client,true,false);
}
public bool OnClientConnect(int client, char[]rejectmsg, int maxlen)
{
	clear_lena_user(client);
	return true;
}
public OnClientDisconnect(int client)
{
	
	clear_lena_user(client);
}

stock void clear_lena_user(int client){
	
	toggle_client_hook(client,false,false);
	Array_Fill(g_iLenaWeaponAmmoInfo[client], sizeof g_iLenaWeaponAmmoInfo[], 0, 0);
	Array_Fill(g_bLenaJammed[client], sizeof g_bLenaJammed[], 0, 0);
	Array_Fill(g_bLenaJustReloaded[client], sizeof g_bLenaJustReloaded[], 0, 0);
	
	LenaUnmorph(client);
	
}
public Action Event_PlayerDead(Event event, const char[] name, bool dontBroadcast){
	
	int victim= GetClientOfUserId(GetEventInt(event,"userid"));
	if(!client_traceable(victim)){
		
		
		return Plugin_Continue;
	}
	clear_lena_user(victim);
	return Plugin_Continue;
	
}