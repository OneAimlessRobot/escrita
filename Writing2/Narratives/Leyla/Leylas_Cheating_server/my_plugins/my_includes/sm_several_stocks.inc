#pragma semicolon 1
//Various stocks:
#include <sourcemod>
#include <sdktools>
#include <sdkhooks>
#include <cstrike>
#include <smlib/arrays>
#include <smlib/clients>
#include <clients>
#include <smlib/entities>
#include <colors>
/*
Cross Product - Let we have given two vector 
A = a1 * i + a2 * j + a3 * k 
and 
B = b1 * i + b2 * j + b3 * k. 

Then cross product is calculated as:
cross product = (a2 * b3 - a3 * b2) * i 
				+ (a3 * b1 - a1 * b3) * j
				+ (a1 * b2 - a2 * b1) * k,

where [(a2 * b3 - a3 * b2), (a3 * b1 - a1 * b3), (a1 * b2 - a2 * b1)] 
are the coefficient of unit vector along i, j and k directions.
*/
#define MATH_PI  3.14159265358979323846264
#define BEAM_LIFE "2"
#define DEFAULT_BEAM_KILL_TIMER 0.1
#define HOOK_REFRESH_TIME 0.1
#define MODEL_BEAM "materials/sprites/purplelaser1.vmt"
#define MINIMUM_VELOCITY_MAGNITUDE 0.1

#define SHELL_CLASSNAME "shell_slowmo"
#define SHELL_SIZE 2.0
#define SHELL_TIMER_SECS 0.05

#define PLAYERS_ONLY_MASK (MASK_SHOT|MASK_SOLID|MASK_PLAYERSOLID)
#define LOGGING_BUFF_SIZE 1024
#define LASER_ARRAY_NUMBER 20
#define LASER_ARRAY_SPREAD 20.0
#define MAX_MAP_SIZE_LENGTH 16384.0
#define NUM_TEAMS 4
#define EXTRA_VEC NUM_TEAMS
#define EXTRA_DIST 6.0
#define SUBTRACTED_HEIGHT 50.0
#define SLOMO_SHELL_THRESHOLD_DIST 100.0
#define MAX_ENTITIES 16384

#define int_cast view_as<int>
/*
// ---------------------------
//  Hit Group standards
// ---------------------------
#define HITGROUP_GENERIC     0
#define HITGROUP_HEAD        1
#define HITGROUP_CHEST       2
#define HITGROUP_STOMACH     3
#define HITGROUP_LEFTARM     4    
#define HITGROUP_RIGHTARM    5
#define HITGROUP_LEFTLEG     6
#define HITGROUP_RIGHTLEG    7
#define HITGROUP_GEAR        10            // alerts NPC, but doesn't do damage or bleed (1/100th damage)*/


// ---------------------------
//  Hit Group standards
// ---------------------------
enum Hitzone_Index {
	HITGROUP_GENERIC = 0, 
	HITGROUP_HEAD = 1, 
	HITGROUP_CHEST = 2, 
	HITGROUP_STOMACH = 3, 
	HITGROUP_LEFTARM = 4, 
	HITGROUP_RIGHTARM = 5, 
	HITGROUP_LEFTLEG = 6, 
	HITGROUP_RIGHTLEG = 7, 
	HITGROUP_GEAR = 10 // alerts NPC, but doesn't do damage or bleed (1/100th damage)*/
};

enum LOGGING_MODES {
	
	Log_NONE, 
	Log_Console, 
	Log_Chat
	
	
};
/*
models/models/weapons/shared/shell_9mm_hr.mdl
models/models/weapons/shared/shell_50cal_hr.mdl
models/models/weapons/shared/shell_762_hr.mdl

*/
enum shell_index{
	SHELL_762=0,
	SHELL_9MM=1,
	SHELL_50CAL=2
	
};
stock float error_correction_vecs[NUM_TEAMS + 1][3];
stock float shell_damage[MAX_ENTITIES];
stock int shell_hitgroup[MAX_ENTITIES];
stock Handle shell_timer[MAX_ENTITIES];
stock char shell_models[int_cast(SHELL_50CAL)+1][128]={
	"models/weapons/w_eq_fraggrenade_thrown.mdl",
	"models/shells/shell_9mm.mdl",
	"models/weapons/w_eq_fraggrenade_thrown.mdl"
	
	
};

enum TEAM_COLOR {
	BLUE = 0, 
	RED, 
	WHITE, 
	YELLOW
}
enum OPPOSING_COLOR {
	ENEMY = 0, 
	FRIEND
};


stock const char Team_Colors[view_as<int>(YELLOW) + 1][17] = {
	"000 000 255 255", 
	"255 000 000 255", 
	"255 255 255 255", 
	"000 255 255 255"
};
stock const char Polarity_Colors[view_as<int>(FRIEND) + 1][17] = {
	"255 000 000 255", 
	"000 000 255 255"
};


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


stock int players_are_teamates(int player_a, int player_b) {
	
	int result = (client_hittable(player_a) && client_hittable(player_b)) ? 1:0;
	if (!result) {
		
		return -1;
	}
	return (GetClientTeam(player_a) == GetClientTeam(player_b)) ? 1:0;
	
}
stock void log_message(LOGGING_MODES log_mode, int player_id, char[] string) {
	switch (log_mode) {
		case Log_NONE: {
			
			
		}
		case Log_Console: {
			
			PrintToConsole(player_id, "%s", string);
		}
		case Log_Chat: {
			
			
			PrintToChat(player_id, "%s", string);
			
		}
		default: {
			
			return;
		}
		
		
	}
	
	
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
bool entity_is_within_bounds_of_shells(int entity){
	
	return ((entity>=0)&&(entity<MAX_ENTITIES));
	
}
bool entity_is_a_shell(int entity){
	
	char classname[128];
	Entity_GetClassName(entity,classname,127);
	
	bool is_shell_classname= (!strncmp(classname,SHELL_CLASSNAME,strlen(classname),true));
	
	return is_shell_classname;
	
	
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
stock void init_several_stocks() {
	
	
	error_correction_vecs[CS_TEAM_CT][0] = -8.0;
	error_correction_vecs[CS_TEAM_CT][1] = -8.0;
	error_correction_vecs[CS_TEAM_CT][2] = 0.0;
	
	error_correction_vecs[CS_TEAM_T][0] = 3.0;
	error_correction_vecs[CS_TEAM_T][1] = 3.0;
	error_correction_vecs[CS_TEAM_T][2] = 0.0;
	
	error_correction_vecs[EXTRA_VEC][0] = 0.0;
	error_correction_vecs[EXTRA_VEC][1] = 0.0;
	error_correction_vecs[EXTRA_VEC][2] = 2.0;
	
	
	SetRandomSeed(GetTime());
	
}

stock int choose_random_hitzone() {
	
	
	return GetRandomInt(view_as<int>(HITGROUP_GENERIC), view_as<int>(HITGROUP_RIGHTLEG));
	
}

stock void precache_cheat_lib_fx() {
	
	PrecacheModel(MODEL_BEAM);
	for(int i=0;i<sizeof shell_models;i++){
		
		PrecacheModel(shell_models[i]);
		
	}
	
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
stock bool client_hittable(int client) {
	
	if(!Client_IsValid(client)){
		
		return false;
		
	}
	if (!IsClientInGame(client)) {
		
		
		return false;
	}
	
	if (!IsPlayerAlive(client)) {
		
		
		return false;
	}
	
	return true;
	
}
stock bool filter_func_for_wallhack(int entityhit, int mask, any entity) {
	
	if ((entity != 0) && (entityhit != entity)) {
		return true;
	}
	
	return false;
	
	
	
}
stock float angle_convert(float angle, bool false_for_degrees_to_radians_true_for_radians_to_degrees = true) {
	
	return (false_for_degrees_to_radians_true_for_radians_to_degrees ? (angle * (180.0 / MATH_PI)):(angle * (MATH_PI / 180.0)));
	
}
//pseudo code for the angle
//dot_product_between_vecs == vector_len(vec_a,3)*vector_len(vec_b,3)*Cosine(angle_between_vec_a_and_vec_b)
//(dot_product_between_vecs/(vector_len(vec_a,3)*vector_len(vec_b,3))) == Cosine(angle_between_vec_a_and_vec_b)
//(dot_product_between_vecs/(vector_len(vec_a,3)*vector_len(vec_b,3))) == Cosine(angle_between_vec_a_and_vec_b)
//ArcCosine((dot_product/(vector_len(vec_a,3)*vector_len(vec_b,3)))) == angle_between_vec_a_and_vec_b
stock bool check_in_fov(int player_id, int player_hit, float fov_to_check, float distance_to_check, float fov_to_store[1], int mask) {
	static float
	origin_a[3], 
	origin_b[3], 
	aimorigin_a[3], 
	aimorigin_b[3], 
	vec_a[3], 
	vec_b[3];
	
	GetClientEyePosition(player_id, origin_a);
	GetClientEyePosition(player_hit, origin_b);
	origin_a[2] -= SUBTRACTED_HEIGHT;
	origin_b[2] -= SUBTRACTED_HEIGHT;
	get_player_aim_vector_raw(player_id, vec_a, mask);
	get_entity_direction_vector_raw(player_id, player_hit, vec_b, mask);
	float length_a = vector_len(vec_a, 3);
	float new_length_a = floatmin(distance_to_check, vector_len(vec_a, 3));
	float length_b = vector_len(vec_b, 3);
	vector_mult(vec_a, vec_a, new_length_a / length_a, 3);
	vector_mult(vec_b, vec_b, new_length_a / length_b, 3);
	vector_add(origin_a, vec_a, aimorigin_a);
	vector_add(origin_a, vec_b, aimorigin_b);
	aimorigin_b[2] = aimorigin_a[2] = origin_a[2];
	float radians_to_check = angle_convert(fov_to_check * 0.5, false);
	float our_angle = angle_between_vectors_radians(vec_a, vec_b, 3);
	fov_to_store[0] = angle_convert(our_angle, true);
	
	bool we_got_em = (our_angle < radians_to_check);
	return we_got_em;
}

stock int clamp(int value, int min, int max)
{
	if (value > max)
	return max;
	if (value < min)
	return min;
	
	return value;
}

stock float floatclamp(float value, float minf, float maxf)
{
	if (value > maxf)
	return maxf;
	if (value < minf)
	return minf;
	
	return value;
}

stock int max(int x, int y)
{
	return x >= y ? x : y;
}

stock int min(int x, int y)
{
	return x <= y ? x : y;
}

stock float floatmax(float x, float y)
{
	return x >= y ? x : y;
}

stock float floatmin(float x, float y)
{
	return x <= y ? x : y;
}
stock float angle_between_vectors_radians(float[] vec_a, float[] vec_b, int vec_size) {
	
	
	float dot_product_between_vecs = dot_product(vec_a, vec_b, vec_size);
	float vector_len_product = vector_len(vec_a, 3) * vector_len(vec_b, 3);
	float before_last = (dot_product_between_vecs / (vector_len_product));
	before_last = floatclamp(before_last, -1.0, 1.0);
	float angle_between_vec_a_and_vec_b = ArcCosine(before_last);
	return angle_between_vec_a_and_vec_b;
	
}
stock void rotate_vector3(float vec_result[3], float vec_input[3], float angle_to_rotate_by_in_radians) {
	
	/*
	float reference_vector[3] = { 1.0, 0.0, 0.0 };
	float original_angle = angle_between_vectors_radians(normalized_in_vec, reference_vector, 3);
	*/
	
	vec_result[0] = Cosine(angle_to_rotate_by_in_radians) * vec_input[0] - Sine(angle_to_rotate_by_in_radians) * vec_input[1];
	vec_result[1] = Sine(angle_to_rotate_by_in_radians) * vec_input[0] + Cosine(angle_to_rotate_by_in_radians) * vec_input[1];
	vec_result[2] = vec_input[2];
	
	
	
}
stock void draw_view_cone(int player_id, float fov_to_contain, float distance_limit, int mask) {
	
	static float
	origin_a[3], 
	aimorigin_a[3], 
	aimorigin_left[3], 
	aimorigin_right[3], 
	vec_a[3], 
	vec_left[3], 
	vec_right[3];
	
	GetClientEyePosition(player_id, origin_a);
	get_player_aim_vector_raw(player_id, vec_a, mask);
	float length_a = vector_len(vec_a, 3);
	vector_mult(vec_a, vec_a, distance_limit / length_a, 3);
	fov_to_contain = angle_convert(fov_to_contain, false);
	rotate_vector3(vec_left, vec_a, -0.5 * (fov_to_contain));
	rotate_vector3(vec_right, vec_a, 0.5 * (fov_to_contain));
	vector_add(origin_a, vec_a, aimorigin_a);
	vector_add(origin_a, vec_right, aimorigin_right);
	vector_add(origin_a, vec_left, aimorigin_left);
	
	origin_a[2] -= SUBTRACTED_HEIGHT;
	aimorigin_a[2] = aimorigin_right[2] = aimorigin_left[2] = origin_a[2];
	make_laser_beam(player_id, origin_a, aimorigin_a, "255 000 255 255", DEFAULT_BEAM_KILL_TIMER);
	make_laser_beam(player_id, origin_a, aimorigin_right, "255 255 000 255", DEFAULT_BEAM_KILL_TIMER);
	make_laser_beam(player_id, origin_a, aimorigin_left, "255 255 000 255", DEFAULT_BEAM_KILL_TIMER);
	
}
stock void get_player_aim_end(int player_id, float user_aimend[3], int mask = MASK_ALL) {
	if (!client_hittable(player_id)) {
		return;
	}
	static float user_coords[3];
	static float user_aimvec[3];
	
	GetClientEyePosition(player_id, user_coords);
	GetClientEyeAngles(player_id, user_aimvec);
	Handle tr_h = TR_TraceRayFilterEx(user_coords, user_aimvec, mask, RayType_Infinite, filter_func_for_wallhack, player_id);
	if (TR_DidHit(tr_h)) {
		TR_GetEndPosition(user_aimend, tr_h);
		TR_GetEntityIndex(tr_h);
	}
	safe_close_handle(tr_h);
	
	
}
stock void wall_bound_vector(int player_id, 
	float in_start_coords[3], 
	float in_vec[3], 
	float out_end_pos[3]) {
	
	Handle tr_h = TR_TraceRayFilterEx(in_start_coords, in_vec, PLAYERS_ONLY_MASK, RayType_Infinite, filter_func_for_wallhack, player_id);
	if (TR_DidHit(tr_h)) {
		TR_GetEndPosition(out_end_pos, tr_h);
	}
	safe_close_handle(tr_h);
	
	
	
}
stock void safe_close_handle(Handle & handle) {
	
	
	if (handle != INVALID_HANDLE) {
		CloseHandle(handle);
		handle = INVALID_HANDLE;
	}
	
	
}

stock void draw_player_aimlaser(int player_id) {
	if (!client_hittable(player_id)) {
		return;
	}
	float user_coords[3];
	float user_aimvec[3];
	float user_aimend[3];
	GetClientEyePosition(player_id, user_coords);
	GetClientEyeAngles(player_id, user_aimvec);
	
	get_player_aim_end(player_id, user_aimend);
	make_laser_beam(player_id, user_coords, user_aimend, "255 000 255 255");
}
stock void get_player_aim_vector_raw(int player_id, float raw_aim_dir[3], int mask) {
	if (!client_hittable(player_id)) {
		return;
	}
	float user_coords[3];
	float user_aimend[3];
	GetClientEyePosition(player_id, user_coords);
	get_player_aim_end(player_id, user_aimend, mask);
	
	vector_sub(user_aimend, user_coords, raw_aim_dir, 3);
	
}
stock void get_entity_direction_vector_raw(int player_id, int aimed_at_entity, float raw_aim_dir[3], int mask) {
	if (!client_hittable(player_id) || !client_hittable(aimed_at_entity)) {
		return;
	}
	float user_coords[3];
	float tg_coords[3];
	float tg_aim_vector_raw[3];
	float user_aim_vector_raw[3];
	GetClientEyePosition(player_id, user_coords);
	GetClientEyePosition(aimed_at_entity, tg_coords);
	get_player_aim_vector_raw(player_id, user_aim_vector_raw, mask);
	get_player_aim_vector_raw(aimed_at_entity, tg_aim_vector_raw, mask);
	vector_norm(user_aim_vector_raw, user_aim_vector_raw, 3);
	vector_norm(tg_aim_vector_raw, tg_aim_vector_raw, 3);
	vector_mult(tg_aim_vector_raw, tg_aim_vector_raw, EXTRA_DIST, 3);
	
	vector_add(error_correction_vecs[EXTRA_VEC], tg_coords, tg_coords, 3);
	vector_add(tg_aim_vector_raw, tg_coords, tg_coords, 3);
	vector_sub(tg_coords, user_coords, raw_aim_dir, 3);
	
}
stock void make_ent_offset_bbox(int player_id, int ent_id, float bbox_orig[3], 
	char color[17], 
	float killtime = DEFAULT_BEAM_KILL_TIMER)
{
	if (!client_hittable(player_id) || !IsValidEntity(ent_id)) {
		
		return;
	}
	float bbox_mins[3], bbox_maxs[3];
	
	//Example: vex_rld = vex rear left down (z, y, x)
	//left= min
	//right= max
	
	
	GetEntPropVector(ent_id, Prop_Send, "m_vecMins", bbox_mins);
	GetEntPropVector(ent_id, Prop_Send, "m_vecMaxs", bbox_maxs);
	float vex_rld[3], vex_rlu[3], vex_rrd[3], vex_rru[3];
	float vex_fld[3], vex_flu[3], vex_frd[3], vex_fru[3];
	
	// Rear left down
	vex_rld[0] = bbox_orig[0] + bbox_mins[0];
	vex_rld[1] = bbox_orig[1] + bbox_mins[1];
	vex_rld[2] = bbox_orig[2] + bbox_mins[2];
	
	// Rear left up
	vex_rlu[0] = bbox_orig[0] + bbox_mins[0];
	vex_rlu[1] = bbox_orig[1] + bbox_mins[1];
	vex_rlu[2] = bbox_orig[2] + bbox_maxs[2];
	
	// Rear right down
	vex_rrd[0] = bbox_orig[0] + bbox_maxs[0];
	vex_rrd[1] = bbox_orig[1] + bbox_mins[1];
	vex_rrd[2] = bbox_orig[2] + bbox_mins[2];
	
	// Rear right up
	vex_rru[0] = bbox_orig[0] + bbox_maxs[0];
	vex_rru[1] = bbox_orig[1] + bbox_mins[1];
	vex_rru[2] = bbox_orig[2] + bbox_maxs[2];
	
	// Front left down
	vex_fld[0] = bbox_orig[0] + bbox_mins[0];
	vex_fld[1] = bbox_orig[1] + bbox_maxs[1];
	vex_fld[2] = bbox_orig[2] + bbox_mins[2];
	
	// Front left up
	vex_flu[0] = bbox_orig[0] + bbox_mins[0];
	vex_flu[1] = bbox_orig[1] + bbox_maxs[1];
	vex_flu[2] = bbox_orig[2] + bbox_maxs[2];
	
	// Front right down
	vex_frd[0] = bbox_orig[0] + bbox_maxs[0];
	vex_frd[1] = bbox_orig[1] + bbox_maxs[1];
	vex_frd[2] = bbox_orig[2] + bbox_mins[2];
	
	// Front right up
	vex_fru[0] = bbox_orig[0] + bbox_maxs[0];
	vex_fru[1] = bbox_orig[1] + bbox_maxs[1];
	vex_fru[2] = bbox_orig[2] + bbox_maxs[2];
	
	//draw lines
	
	make_laser_beam(player_id, vex_rld, vex_rrd, color, killtime);
	make_laser_beam(player_id, vex_rld, vex_rlu, color, killtime);
	make_laser_beam(player_id, vex_rrd, vex_rru, color, killtime);
	make_laser_beam(player_id, vex_rlu, vex_rru, color, killtime);
	
	// Front face
	make_laser_beam(player_id, vex_fld, vex_frd, color, killtime);
	make_laser_beam(player_id, vex_fld, vex_flu, color, killtime);
	make_laser_beam(player_id, vex_frd, vex_fru, color, killtime);
	make_laser_beam(player_id, vex_flu, vex_fru, color, killtime);
	
	// Connecting lines
	make_laser_beam(player_id, vex_rld, vex_fld, color, killtime);
	make_laser_beam(player_id, vex_rlu, vex_flu, color, killtime);
	make_laser_beam(player_id, vex_rrd, vex_frd, color, killtime);
	make_laser_beam(player_id, vex_rru, vex_fru, color, killtime);
}

stock void make_laser_beam(int player_id, float init_pos[3], float end_pos[3], char color[17], float killtime = DEFAULT_BEAM_KILL_TIMER) {
	if (!client_hittable(player_id)) {
		return;
	}
	
	int beam = CreateEntityByName("env_beam");
	
	
	SetEntityModel(beam,MODEL_BEAM);
	DispatchKeyValue(beam, "rendercolor", color);
	DispatchKeyValue(beam, "renderamt", "200");
	DispatchKeyValue(beam, "decalname", "Bigshot");
	DispatchKeyValue(beam, "life", BEAM_LIFE);
	DispatchKeyValue(beam, "TouchType", "0");
	DispatchSpawn(beam);
	
	TeleportEntity(beam, init_pos, NULL_VECTOR, NULL_VECTOR);
	
	//PROP
	int prop = CreateEntityByName("info_target");
	if(IsValidEntity(prop)){
		DispatchSpawn(prop);
		TeleportEntity(prop, end_pos, NULL_VECTOR, NULL_VECTOR);
		
		SetEntPropEnt(beam, Prop_Send, "m_hAttachEntity", beam);
		SetEntPropEnt(beam, Prop_Send, "m_hAttachEntity", prop, 1);
		SetEntProp(beam, Prop_Send, "m_nNumBeamEnts", 2);
		SetEntProp(beam, Prop_Send, "m_nBeamType", 2);
		
		SetEntPropFloat(beam, Prop_Data, "m_fWidth", 5.0);
		SetEntPropFloat(beam, Prop_Data, "m_fEndWidth", 5.0);
		
		AcceptEntityInput(beam, "TurnOn");
		
		Handle laser_data = CreateArray(2);
		PushArrayCell(laser_data, EntIndexToEntRef(beam));
		PushArrayCell(laser_data, EntIndexToEntRef(prop));
		CreateTimer(killtime, future_kill_beam, laser_data);
	}
	else{
		AcceptEntityInput(beam, "Kill");
		
	}
}
public Action future_kill_beam(Handle timer, any data) {
	
	kill_beam(data);
	safe_close_handle(data);
	return Plugin_Stop;
}
stock void kill_beam(any data)
{
	int beam = EntRefToEntIndex(GetArrayCell(data, 0, 0));
	int prop = EntRefToEntIndex(GetArrayCell(data, 1, 0));
	if (beam != INVALID_ENT_REFERENCE) {
		AcceptEntityInput(beam, "Kill");
	}
	if (prop != INVALID_ENT_REFERENCE) {
		AcceptEntityInput(prop, "Kill");
	}
}

stock void vector_sub(float[] vec_b, float[] vec_a, float[] vec_result, int vec_size = 3) {
	
	
	for (int i = 0; i < vec_size; i++) {
		vec_result[i] = vec_b[i] - vec_a[i];
	}
	
}
stock void vector_add(float[] vec_b, float[] vec_a, float[] vec_result, int vec_size = 3) {
	
	
	for (int i = 0; i < vec_size; i++) {
		vec_result[i] = vec_b[i] + vec_a[i];
	}
	
}

stock void vector_mult(float[] vec_result, float[] vec_in, float num, int vec_size = 3) {
	
	
	for (int i = 0; i < vec_size; i++) {
		vec_result[i] = vec_in[i] * num;
	}
	
}
stock void vector_norm(float[] vec_result, float[] vec_in, int vec_size = 3) {
	
	float len = vector_len(vec_in, vec_size);
	float inv_len = 1.0 / len;
	vector_mult(vec_result, vec_in, inv_len, vec_size);
	
}
stock float dot_product(float[] input_a, float[] input_b, int vec_size = 3) {
	
	float result = 0.0;
	for (int i = 0; i < vec_size; i++) {
		
		result += input_a[i] * input_b[i];
		
	}
	return result;
	
}
stock float cross_product(float[] result, float[] input_a, float[] input_b, int vec_size = 3) {
	//[(a1 * b2 - a2 * b1), (a2 * b0 - a0 * b2), (a0 * b1 - a1 * b0)]
	
	result[0] = (input_a[1] * input_b[2]) - (input_a[2] * input_b[1]);
	result[1] = (input_a[2] * input_b[0]) - (input_a[0] * input_b[2]);
	result[2] = (input_a[0] * input_b[1]) - (input_a[1] * input_b[0]);
	
	float length = vector_len(result, 3);
	vector_norm(result, result, vec_size);
	return length;
	
}
stock void dir_vector_to_yaw_pitch_roll(float[] vec_result, float[] vec_in, int vec_size = 3) {
	
	if (vec_size > 3) {
		
		return;
	}
	vector_norm(vec_in, vec_in, vec_size);
	vec_result[0] = -1.0 * ArcSine(1.0 * (vec_in[2])) * (180.0 / MATH_PI);
	//vec_result[1] = ArcTangent2((1.0 * vec_result[0]),(1.0 * vec_result[2])) * (180.0 / MATH_PI);
	vec_result[1] = ArcTangent2((1.0 * vec_in[1]), (1.0 * vec_in[0])) * (180.0 / MATH_PI);
	//vec_result[1] = ArcCosine((1.0 * vec_in[1])) * (180.0 / MATH_PI);
	vec_result[2] = 0.0;
}
stock float vector_len(float[] vec_result, int vec_size = 3) {
	
	float result = 0.0;
	for (int i = 0; i < vec_size; i++) {
		result = result + (vec_result[i] * vec_result[i]);
	}
	float final_result = SquareRoot(result);
	return final_result;
}
stock void fill_vector(any[] vec_result, int vec_size = 3, any value) {
	
	Array_Fill(vec_result, vec_size, value, 0);
	
}
stock void print_vector(int client, const char[] vector_name, float vec_to_print[3]) {
	
	PrintToConsole(client, "Vector name:%s ", vector_name);
	PrintToConsole(client, "coords: (%0.2f, %0.2f, %0.2f)!!!!!", vec_to_print[0], vec_to_print[1], vec_to_print[2]);
	
	
} 