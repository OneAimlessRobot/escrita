#if defined misc_stocks
	#endinput
#endif
#define misc_stocks
#include "sm_vector_stocks.inc"

stock float shell_damage[MAX_ENTITIES];
stock int shell_hitgroup[MAX_ENTITIES];
stock Handle shell_timer[MAX_ENTITIES];


public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	// No need for the old GetGameFolderName setup.
	EngineVersion g_engineversion = GetEngineVersion();
	if (g_engineversion != Engine_CSGO)
	{
		SetFailState("This cheat shit scum plugin was made for use with Counter-Strike: Global Offensive only.");
		return APLRes_Failure;
	} 
	return APLRes_Success;
	
}
stock void create_projectile_from_player(int attacker_id, float velocity, float damage,int hitgroup){
	
	if(FloatAbs(velocity)<MINIMUM_VELOCITY_MAGNITUDE){
		
		velocity *= (MINIMUM_VELOCITY_MAGNITUDE/FloatAbs(velocity));
	}
	static float aim_end[3],
	user_origin[3],
	aim_dir_raw[3],
	aim_dir_carthesian[3];
	
	GetClientEyePosition(attacker_id, user_origin);
	GetClientEyeAngles(attacker_id, aim_dir_raw);
	wall_bound_vector(attacker_id, user_origin, aim_dir_raw, aim_end);
	vector_sub(aim_end, user_origin, aim_dir_carthesian, 3);
	vector_norm(aim_dir_carthesian, aim_dir_carthesian, 3);
	//now its normed. multiply by velocity coeff!
	vector_mult(aim_dir_carthesian, aim_dir_carthesian, velocity, 3);
	
	//lets create the entity!
	/*
	
	Member: m_vecMins (offset 8) (type vector) (bits 0) (NoScale)
	Member: m_vecMaxs (offset 20) (type vector) (bits 0) (NoScale)
	Member: m_nSolidType (offset 34) (type integer) (bits 3) (Unsigned)
	
	What is this woke nonsense lol
	(this is fun I hope I dont rage too hard while coding this lol)
	*/
	int shell_id = CreateEntityByName("prop_physics_override");
	if(!IsValidEntity(shell_id)||(shell_id<0)){
		
		
		//log_message(Log_Console, attacker_id, "ERROR CREATING SHELL!\nNOTHING SPAWNED!\n");
		return;
		
	}
	shell_damage[shell_id]=damage;
	shell_hitgroup[shell_id]=hitgroup;
	static float vec_mins[3], vec_maxs[3];
	
	fill_vector(vec_mins, 3, -0.5 * SHELL_SIZE);
	fill_vector(vec_maxs, 3, 0.5 * SHELL_SIZE);
	SetEntProp(shell_id, Prop_Send, "m_usSolidFlags", FSOLID_TRIGGER);
	SetEntProp(shell_id, Prop_Data, "m_nSolidType", SOLID_BBOX);
	SetEntProp(shell_id, Prop_Send, "m_CollisionGroup", COLLISION_GROUP_PLAYER); 
	
	SetEntPropVector(shell_id,Prop_Send,"m_vecMins",vec_mins);
	SetEntPropVector(shell_id,Prop_Send,"m_vecMaxs",vec_maxs);
	SetEntityMoveType(shell_id,MOVETYPE_FLY);
	Entity_SetClassName(shell_id,SHELL_CLASSNAME);
	SetEntityModel(shell_id,shell_models[SHELL_50CAL]);
	//m_OnUser4 
	
	
	
	Entity_SetOwner(shell_id,attacker_id);
	Entity_EnableMotion(shell_id);
	/*char logstring[LOGGING_BUFF_SIZE];
	char user_name[128];
	GetClientName(Entity_GetOwner(shell_id),user_name,127);
	FormatEx(logstring,LOGGING_BUFF_SIZE,"this toucher entity index @ shell_touch is from a shell!!!\nHooking!\nit will deal %0.2f damage!\nThe owner of this shell is named: %s\n",shell_damage[shell_id],user_name);
	log_message(Log_Console,0,logstring);*/
	user_origin[2]+=10.0;
	DispatchSpawn(shell_id);
	//SDKHookCB
	TeleportEntity(shell_id, user_origin,aim_dir_raw, aim_dir_carthesian);
	shell_timer[shell_id]= CreateTimer(SHELL_TIMER_SECS, shell_touch, shell_id,TIMER_REPEAT);
	
	
}
/*
FSOLID_CUSTOMRAYTEST
Ignore solid type + always call into the entity for ray tests. [Todo]
FSOLID_CUSTOMBOXTEST
Ignore solid type + always call into the entity for swept box tests. [Todo]
FSOLID_NOT_SOLID
Entity becomes non-solid (without losing its underlying SolidType). prop_dynamic entities set to SOLID_NONE are upgraded to SOLID_OBB and FSOLID_NOT_SOLID when Spawned so that the bounding box will properly rotate.
FSOLID_TRIGGER
Touch() is triggered even if collisions are disabled.
FSOLID_NOT_STANDABLE
Players can't stand on this.
Todo: 	What happens when they try to?
FSOLID_VOLUME_CONTENTS
Contains a volumetric substance like water.
FSOLID_FORCE_WORLD_ALIGNED
Forces the collision rep to be world-aligned even if it's SOLID_BSP or SOLID_VPHYSICS. [Todo]
FSOLID_USE_TRIGGER_BOUNDS
Uses a special trigger bounds separate from the normal OBB. [Todo]
FSOLID_ROOT_PARENT_ALIGNED
Collisions are defined in the root parent's local coordinate space.
FSOLID_TRIGGER_TOUCH_DEBRIS
This FSOLID_TRIGGER entity will also Touch() debris objects.
*/
public Action shell_kill(Handle timer, any data){
	
	int shell_id=int_cast(data);
	/*
	int hitzone=shell_hitgroup[shell_id];
	float damage=shell_damage[shell_id];
	char hitzone_name[128];
	char log_string[LOGGING_BUFF_SIZE];
	print_hitzone_name(hitzone, hitzone_name);
	FormatEx(log_string, LOGGING_BUFF_SIZE, "The hitzone of this shell is: \"%s\"\nAnd its damage is: %0.2f\n", hitzone_name,damage);
	log_message(Log_Console, 0, log_string);
	*/
	shell_damage[shell_id]=0.0;
	shell_hitgroup[shell_id]=0;
	safe_close_handle(shell_timer[shell_id]);
	int ref = EntRefToEntIndex(shell_id);
	if(IsValidEntity(shell_id)&&(ref!=INVALID_ENT_REFERENCE)){
		
		if(entity_is_a_shell(shell_id)){
			AcceptEntityInput(ref, "Kill");
		}
		
	}
	return Plugin_Continue;
	
}

stock void DealDamage(victim,damage,attacker=0,dmg_type=DMG_GENERIC,String:weapon[]="")
{
	if(victim>0 && IsValidEdict(victim) && IsClientInGame(victim) && IsPlayerAlive(victim) && damage>0)
	{
		new String:dmg_str[16];
		IntToString(damage,dmg_str,16);
		new String:dmg_type_str[32];
		IntToString(dmg_type,dmg_type_str,32);
		new pointHurt=CreateEntityByName("point_hurt");
		if(pointHurt)
		{
			DispatchKeyValue(victim,"targetname","hurt_me_daddy");
			DispatchKeyValue(pointHurt,"DamageTarget","hurt_me_daddy");
			DispatchKeyValue(pointHurt,"Damage",dmg_str);
			DispatchKeyValue(pointHurt,"DamageType",dmg_type_str);
			if(!StrEqual(weapon,""))
			{
				DispatchKeyValue(pointHurt,"classname",weapon);
			}
			DispatchSpawn(pointHurt);
			AcceptEntityInput(pointHurt,"Hurt",(attacker>0)?attacker:-1);
			DispatchKeyValue(pointHurt,"classname","point_hurt");
			DispatchKeyValue(victim,"targetname","no_more_dont_hurt_me_more_please_daddy");
			RemoveEdict(pointHurt);
		}
	}
}
public Action shell_touch(Handle timer, any data){
	
	int shell_id=int_cast(data);
	if(!IsValidEntity(shell_id)){
		
		//log_message(Log_None,0,"Invalid shell @ shell_touch!!");
		CreateTimer(SHELL_TIMER_SECS, shell_kill, shell_id);
		return Plugin_Handled;
		
	}
	if(!entity_is_a_shell(shell_id)){
		
		
		
		CreateTimer(SHELL_TIMER_SECS, shell_kill, shell_id);
		return Plugin_Handled;
		
		
	}
	int shell_owner=Entity_GetOwner(shell_id);
	for(int i=1;(i<=MAXPLAYERS)&&client_hittable(shell_owner);i++){
		float shell_origin[3];
		float opponent_origin[3];
		float diff_vector[3];
		if(!client_hittable(i)||(i==shell_owner)||(players_are_teamates(shell_owner,i)>0)){
			
			continue;
		}
		GetEntPropVector(shell_id, Prop_Send,"m_vecOrigin",shell_origin);
		GetClientEyePosition(i,opponent_origin);
		opponent_origin[2]-=(SUBTRACTED_HEIGHT*0.65);
		vector_sub(opponent_origin,shell_origin,diff_vector,3);
		float length_of_vector=vector_len(diff_vector,3);
		if(length_of_vector<=SLOMO_SHELL_THRESHOLD_DIST){
			
			int weapon_id = Client_GetActiveWeapon(shell_owner);
			char weapon_name[128]="NO_VALID_WPN";
			if(!IsValidEntity(weapon_id)){
				//log_message(Log_Console,0,"Invalid weapon @ shell_touch!!");
				weapon_id=-1;
			}
			else{
				
				Client_GetActiveWeaponName(shell_owner, weapon_name, 127);
			}
			DealDamage(i,RoundFloat(shell_damage[shell_id]),shell_owner,DMG_BULLET,weapon_name);
			CreateTimer(SHELL_TIMER_SECS, shell_kill, shell_id);
		}
		
		
	}
	return Plugin_Continue;
	
	
	
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
stock int choose_random_hitzone() {
	
	
	return GetRandomInt(view_as<int>(HITGROUP_GENERIC), view_as<int>(HITGROUP_RIGHTLEG));
	
}



stock void print_hitzone_name(int hitzone_index, char destination_string[128]) {
	
	switch (hitzone_index) {
		case HITGROUP_GENERIC: {
			
			FormatEx(destination_string, 127, "Hitzone %d: GENERIC", hitzone_index);
		}
		case HITGROUP_HEAD: {
			
			
			FormatEx(destination_string, 127, "Hitzone %d: HEAD", hitzone_index);
		}
		case HITGROUP_CHEST: {
			
			
			FormatEx(destination_string, 127, "Hitzone %d: CHEST", hitzone_index);
		}
		case HITGROUP_STOMACH: {
			
			
			FormatEx(destination_string, 127, "Hitzone %d: STOMACH", hitzone_index);
		}
		case HITGROUP_LEFTARM: {
			
			
			FormatEx(destination_string, 127, "Hitzone %d: LEFTARM", hitzone_index);
		}
		case HITGROUP_RIGHTARM: {
			
			
			FormatEx(destination_string, 127, "Hitzone %d: RIGHTARM", hitzone_index);
		}
		case HITGROUP_LEFTLEG: {
			
			
			FormatEx(destination_string, 127, "Hitzone %d: LEFTLEG", hitzone_index);
		}
		case HITGROUP_RIGHTLEG: {
			
			
			FormatEx(destination_string, 127, "Hitzone %d: RIGHTLEG", hitzone_index);
		}
		default: {
			
			FormatEx(destination_string, 127, "Hitzone %d: NON_EXISTENT", hitzone_index);
			
		}
	}
	
}
stock void clear_all_slomo_shells(){
	int entity= Entity_FindByClassName(-1, SHELL_CLASSNAME);
	
	while(entity_is_within_bounds_of_shells(entity)){
		shell_kill(INVALID_HANDLE,entity);
		entity= Entity_FindByClassName(entity, SHELL_CLASSNAME);
		
	}
	
}