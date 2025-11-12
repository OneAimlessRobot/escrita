#pragma semicolon 1


#include <sourcemod>
#include <sdktools>
#include <sdkhooks>
#include <cstrike>
#include <smlib/arrays>
#include <smlib/clients>
#include <clients>
#include <smlib/entities>
#include <colors>
#include <superheromod>
#include <fpvm_interface>

EngineVersion g_Game;

char g_szTorrorModel[]="models/player/custom_player/kolka/bandit_mask/bandit_mask.mdl";
char g_szTorrorGalilModel[]="models/weapons/v_rif_galilas.mdl";
char g_szdefault_galil[]="models/weapons/v_rif_galil.mdl";
int g_iMdlIndex;
int g_iDefaultGalilIndex;
ConVar g_TorrorLevel;
ConVar g_TorrorFireRate;
ConVar g_TorrorDamageMultiplier;
int g_iHeroIndex;
bool g_bHasTorror[MAXPLAYERS + 1];
//int g_iClientTeam[MAXPLAYERS + 1];

public Plugin myinfo = 
{
	name = "SuperHero Mod CS:GO Hero - Polineuropatik",
	author = "milkChan",
	description = "sdadijajiada askd hero",
	version = "1.0",
	url = "https://localhost"
};

public void OnPluginStart()
{
	g_Game = GetEngineVersion();
	if(g_Game != Engine_CSGO)
	{
		SetFailState("This plugin is for CSGO only.");	
	}
	g_TorrorLevel = CreateConVar("superheromod_Torror_level", "8");
	g_TorrorFireRate = CreateConVar("superheromod_Torror_attack_speed", "0.75", "Amount of times fire rate Torror galil should have");
	g_TorrorDamageMultiplier = CreateConVar("superheromod_torror_galilmult", "2", "Galil damage mult");
	AutoExecConfig(true, "Torror", "sourcemod/superheromod");
	
	HookEvent("weapon_fire", Event_WeaponFire, EventHookMode_Post);
	
	g_iHeroIndex = SuperHero_CreateHero("Torror", g_TorrorLevel.IntValue);
	SuperHero_SetHeroInfo(g_iHeroIndex, "Strong Galil", "Player model/Strong galil that fires slowly");
	SuperHero_SetHeroPrimaryWeapon(g_iHeroIndex, view_as<int>(CSGOWeaponID_GALILAR));
	HookEvent("player_spawn", Event_PlayerS, EventHookMode_Post);
	
}

public void OnMapStart()
{
	AddFileToDownloadsTable(g_szTorrorModel);
	AddFileToDownloadsTable(g_szTorrorGalilModel);
	PrecacheModel(g_szTorrorModel);
	g_iDefaultGalilIndex = PrecacheModel(g_szdefault_galil);
	g_iMdlIndex = PrecacheModel(g_szTorrorGalilModel);
	
}

public void TorrorUnmorph(int client)
{
	if (g_bHasTorror[client] || !IsValidClient(client)) 
		return;

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

	SetEntityModel(client, szModel);

}

public void OnConfigsExecuted()
{
	SuperHero_SetHeroAvailableLevel(g_iHeroIndex, g_TorrorLevel.IntValue);
	SuperHero_SetHeroDamageMultiplier(g_iHeroIndex, g_TorrorDamageMultiplier.FloatValue, view_as<int>(CSGOWeaponID_GALILAR));
}

public Action Event_WeaponFire(Event event, const char[] name, bool dontBroadcast)
{
	RequestFrame(SetNextPrimaryAttack, event.GetInt("userid"));
	return Plugin_Continue;
}
public void SetNextPrimaryAttack(any data)
{
	int client = GetClientOfUserId(data);
	
	if(!IsValidClient(client))
		return;
	
	if(!g_bHasTorror[client])
		return;
		
	int weapon = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
	if(weapon != INVALID_ENT_REFERENCE)
	{
		char szClassName[32];
		GetEntityClassname(weapon, szClassName, sizeof(szClassName));
		if(StrEqual(szClassName, "weapon_galilar"))
		{
			float nextAttack = GetGameTime() - GetEntPropFloat(weapon, Prop_Send, "m_flNextPrimaryAttack");
			nextAttack = FloatAbs(nextAttack);
			SetEntPropFloat(weapon, Prop_Send, "m_flNextPrimaryAttack", GetGameTime() + (nextAttack / g_TorrorFireRate.FloatValue));
			SetEntProp(weapon, Prop_Send, "m_iClip1", 35);
			
		}
	}
}

public Action Event_PlayerS(Handle event, const char[] name, bool dontBroadcast)
{
		int client = GetClientOfUserId(GetEventInt(event, "userid"));
		if(!g_bHasTorror[client]){
			return Plugin_Continue;
		}
		int team = GetEventInt(event, "team");	
		char teamname[128];
		GetTeamName(team, teamname, 127);
		PrintToChat(client,"Team name is: %s. Team ID is: %d",teamname,team);
		char string[128];
		if(IsModelPrecached(g_szTorrorGalilModel)){
			
			
			string="  ";
		}
		else{
			
			string=" not ";
			
		}
		PrintToChat(client,"Galil model is%sprecached",string);
		return Plugin_Handled;
}
public void SuperHero_OnHeroInitialized(int client, int heroIndex, int mode)
{
	if(heroIndex != g_iHeroIndex)
		return;
	
	switch(mode)
	{
		case SH_HERO_ADD:
		{
			g_bHasTorror[client] = true;
			//Change model
			if(SuperHero_GetHighestPrimaryWeaponLevel(client) == view_as<int>(CSGOWeaponID_GALILAR))
			{
				StripPrimary(client);
				GivePlayerItem(client, "weapon_galilar");
				if(IsModelPrecached(g_szTorrorModel)){
					SetEntityModel(client,g_szTorrorModel);
				}
				if(IsModelPrecached(g_szTorrorGalilModel)){
					FPVMI_SetClientModel(client,"weapon_galilar",g_iMdlIndex);
				}
			}
			
		}
		case SH_HERO_DROP:
		{
			g_bHasTorror[client] = false;
			TorrorUnmorph(client);
			FPVMI_SetClientModel(client,"weapon_galilar",g_iDefaultGalilIndex);
		}
	}	
}

public void SuperHero_OnPlayerSpawned(int client, bool newroundspawn)
{
	if(!g_bHasTorror[client])
		return;
	
	if(SuperHero_GetHighestPrimaryWeaponLevel(client) == view_as<int>(CSGOWeaponID_GALILAR))
	{
		StripPrimary(client);
		GivePlayerItem(client, "weapon_galilar");
		if(IsModelPrecached(g_szTorrorModel)){
				SetEntityModel(client,g_szTorrorModel);
		}
		if(IsModelPrecached(g_szTorrorGalilModel)){
				FPVMI_SetClientModel(client,"weapon_galilar",g_iMdlIndex);
		}
	}
}

public bool OnClientConnect(int client, char[]rejectmsg, int maxlen)
{
	g_bHasTorror[client] = false;
	return true;
}
