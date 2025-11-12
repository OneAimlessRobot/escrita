
#if defined milk_defines
	#endinput
#endif
#define milk_defines
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
#define float_cast view_as<float>
#define char_cast view_as<char>
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

stock char shell_models[int_cast(SHELL_50CAL)+1][128]={
	"models/weapons/w_eq_fraggrenade_thrown.mdl",
	"models/shells/shell_9mm.mdl",
	"models/weapons/w_eq_fraggrenade_thrown.mdl"
	
	
};
