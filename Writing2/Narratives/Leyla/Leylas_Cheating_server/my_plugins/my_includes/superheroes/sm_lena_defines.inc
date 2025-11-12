#if defined sm_lena_defines
	#endinput
#endif
#define sm_lena_defines

#define PLUGIN_AUTHOR "MilkChanTheGOAT"
#define PLUGIN_VERSION "1.03"
#define LENA_PLAYER_MODEL "models/player/custom_player/legacy/gxp/anime/anime_chell/chell_v1.mdl"
#define NUM_MATERIALS_PLAYER_MODEL 17
stock const char lena_player_model_materials_and_extra_crap[NUM_MATERIALS_PLAYER_MODEL][1024]={
	//model
	"models/player/custom_player/legacy/gxp/anime/anime_chell/chell_v1.dx90.vtx",
	"models/player/custom_player/legacy/gxp/anime/anime_chell/chell_v1.phy",
	"models/player/custom_player/legacy/gxp/anime/anime_chell/chell_v1.vvd",
	//arm
	"models/player/custom_player/legacy/gxp/anime/anime_chell/chell_arm_v1.vvd",
	"models/player/custom_player/legacy/gxp/anime/anime_chell/chell_arm_v1.dx90.vtx",
	//materials
	"materials/models/player/custom_player/legacy/gxp/anime/anime_chell/gxp_legs.vmt",
	"materials/models/player/custom_player/legacy/gxp/anime/anime_chell/gxp_legs.vtf",
	"materials/models/player/custom_player/legacy/gxp/anime/anime_chell/gxp_lightwarp.vtf",
	"materials/models/player/custom_player/legacy/gxp/anime/anime_chell/gxp_main1.vmt",
	"materials/models/player/custom_player/legacy/gxp/anime/anime_chell/gxp_main1.vtf",
	"materials/models/player/custom_player/legacy/gxp/anime/anime_chell/gxp_main1_hair.vmt",
	"materials/models/player/custom_player/legacy/gxp/anime/anime_chell/gxp_main1_skin.vmt",
	"materials/models/player/custom_player/legacy/gxp/anime/anime_chell/gxp_main2.vmt",
	"materials/models/player/custom_player/legacy/gxp/anime/anime_chell/gxp_main2.vtf",
	"materials/models/player/custom_player/legacy/gxp/anime/anime_chell/gxp_main2_eye.vmt",
	"materials/models/player/custom_player/legacy/gxp/anime/anime_chell/gxp_main2_nocull.vmt",
	"materials/models/player/custom_player/legacy/gxp/anime/anime_chell/gxp_main2_skin.vmt"
};


#define LENA_WEAPON_MODEL "models/weapons/v_rif_ak74.mdl"
#define NUM_MATERIALS_WEAPON_MODEL 13
stock const char lena_weapon_model_materials_and_extra_crap[NUM_MATERIALS_WEAPON_MODEL][1024]={
	//shit
	"models/weapons/v_rif_ak74.dx80.vtx",
	"models/weapons/v_rif_ak74.dx90.vtx",
	"models/weapons/v_rif_ak74.sw.vtx",
	"models/weapons/v_rif_ak74.vtx",
	"models/weapons/v_rif_ak74.vvd",
	
	//materials
	"materials/models/weapons/v_models/rif_aks74u/aks_diffuse.vtf",
	"materials/models/weapons/v_models/rif_aks74u/aks_gloss.vtf",
	"materials/models/weapons/v_models/rif_aks74u/aks_normal.vtf",
	"materials/models/weapons/v_models/rif_aks74u/bullet_diffuse.vmt",
	"materials/models/weapons/v_models/rif_aks74u/bullet_diffuse.vtf",
	"materials/models/weapons/v_models/rif_aks74u/bullet_gloss.vtf",
	"materials/models/weapons/v_models/rif_aks74u/bullet_normal.vtf",
	"materials/models/weapons/v_models/rif_aks74u/diffuse.vmt"
	
};
#define LENA_JAM_SHOT_SOUND "ambient/machines/steam_release_2.wav"
#define LENA_UNJAM_SHOT_SOUND "weapons/auto_semiauto_switch.wav"
#define LENA_INJAM_SHOT_SOUND "weapons/clipempty_rifle.wav"
#define WEAPON_DEFAULT_MODEL "models/weapons/v_rif_awp.mdl"
stock int g_LenaWEAPON_mdl_index;
stock int g_DefaultWEAPON_mdl_index;
stock void precache_lena_resources(){
	
	for(int i=0;i<sizeof lena_player_model_materials_and_extra_crap;i++){
		AddFileToDownloadsTable(lena_player_model_materials_and_extra_crap[i]);
	}
	
	for(int i=0;i<sizeof lena_weapon_model_materials_and_extra_crap;i++){
		AddFileToDownloadsTable(lena_weapon_model_materials_and_extra_crap[i]);
	}
	AddFileToDownloadsTable(LENA_PLAYER_MODEL);
	AddFileToDownloadsTable(LENA_WEAPON_MODEL);
	
	PrecacheModel(LENA_PLAYER_MODEL,true);
	g_LenaWEAPON_mdl_index=PrecacheModel(LENA_WEAPON_MODEL,true);
	g_DefaultWEAPON_mdl_index=PrecacheModel(WEAPON_DEFAULT_MODEL,true);
	PrecacheSound(LENA_JAM_SHOT_SOUND);
	PrecacheSound(LENA_INJAM_SHOT_SOUND);
	PrecacheSound(LENA_UNJAM_SHOT_SOUND);
	
	
	
}
#define LENA_WEAPON "weapon_awp"
#define LENA_CLIP_WATCHER_CLASSNAME "lena_clipwatcher"
#define MY_TIME_TO_TICKS(%1)	(RoundToCeil(((%1)/GetTickInterval())))
#define LENA_CLIP_CHECK_INTERVAL 0.2
#define LENA_RELOAD_TIME_WEAPON_DEFAULT 3.7
#define LENA_CLIP_MAX_WEAPON 7
#define CLIP_MAX_WEAPON_DEFAULT 7
#define LENA_RESERVE_MAX_WEAPON 1
#define RESERVE_MAX_WEAPON_DEFAULT 7
#define JAMMING_ENABLED true
enum Lena_Retrieve_Type{
	Retrieve_NONE=0,
	Retrieve_Clip=1,
	Retrieve_Ammo=2,
	Retrieve_All=3
	
	
};
enum Lena_Store_Type{
	Store_NONE=0,
	Store_Clip=1,
	Store_Ammo=2,
	Store_All=3
	
	
}
#define lena_MAX_FIRE_MULT_EXP (4)
#define lena_MIN_FIRE_MULT_EXP (-4)
#define lena_JAM_TIMER_TIME 4.0
#define LENA_FAIL_FRAC_NUMERATOR ((1.0))
#define LENA_FAIL_FRAC_DENOMINATOR ((10.0))
#define LENA_FAIL_FRAC ((LENA_FAIL_FRAC_NUMERATOR/LENA_FAIL_FRAC_DENOMINATOR))

#define LENA_CLIP_DIFFERENCE_WEAPON (max(0,(CLIP_MAX_WEAPON_DEFAULT-LENA_CLIP_MAX_WEAPON)))


