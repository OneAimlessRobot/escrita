#include "sm_milks_defines.inc"


stock float error_correction_vecs[NUM_TEAMS + 1][3];


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

stock void precache_cheat_lib_fx() {
	
	PrecacheModel(MODEL_BEAM);
	for(int i=0;i<sizeof shell_models;i++){
		
		PrecacheModel(shell_models[i]);
		
	}
	
}

stock bool entity_is_within_bounds_of_shells(int entity){
	
	return ((entity>=0)&&(entity<MAX_ENTITIES));
	
}
stock bool entity_is_a_shell(int entity){
	
	char classname[128];
	Entity_GetClassName(entity,classname,127);
	
	bool is_shell_classname= (!strncmp(classname,SHELL_CLASSNAME,strlen(classname),true));
	
	return is_shell_classname;
	
	
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
stock bool client_traceable(int client) {
	
	if(!Client_IsValid(client)){
		
		return false;
		
	}
	if (!IsClientInGame(client)) {
		
		
		return false;
	}
	return true;
	
}

stock bool client_hittable(int client) {
	
	if(!client_traceable(client)){
		
		return false;
	}
	if (!IsPlayerAlive(client)) {
		
		
		return false;
	}
	
	return true;
	
}
stock void safe_close_handle(Handle & handle) {
	
	
	if (handle != INVALID_HANDLE) {
		CloseHandle(handle);
		handle = INVALID_HANDLE;
	}
	
	
}
