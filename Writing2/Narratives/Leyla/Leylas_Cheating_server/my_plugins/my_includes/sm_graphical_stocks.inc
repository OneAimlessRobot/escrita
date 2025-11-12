#if defined graphical_stocks
	#endinput
#endif
#define graphical_stocks
#include "sm_milks_defines.inc"

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

stock bool filter_func_for_wallhack(int entityhit, int mask, any entity) {
	
	if ((entity != 0) && (entityhit != entity)) {
		return true;
	}
	
	return false;
	
	
	
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
