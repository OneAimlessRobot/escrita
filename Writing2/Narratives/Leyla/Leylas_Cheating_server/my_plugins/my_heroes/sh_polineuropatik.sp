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
#define TASKID 5555
char g_szPolySwordModel[]="models/weapons/v_sword.mdl";
char g_szDefaultKnifeModel[]="models/weapons/v_knife_default_ct.mdl";
int g_iMdlIndex;
int g_iDefaultKnifeIndex;
ConVar g_PolineuropatikLevel;
ConVar g_PolineuropatikKnifeSpeed;
ConVar g_PolineuropatikDamageMultiplier;
ConVar g_PolineuropatikHealPoints;
ConVar g_PolineuropatikAlpha;
int g_iHeroIndex;
bool g_bHasPolineuropatik[MAXPLAYERS + 1];
bool g_bInvisible[MAXPLAYERS + 1];

public Plugin myinfo = 
{
	name = "SuperHero Mod CS:GO Hero - Polineuropatik",
	author = "milkChan",
	description = "Polineuropatik hero",
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
	g_PolineuropatikLevel = CreateConVar("superheromod_Polineuropatik_level", "7");
	g_PolineuropatikAlpha = CreateConVar("superheromod_Polineuropatik_alpha", "70");
	g_PolineuropatikKnifeSpeed = CreateConVar("superheromod_Polineuropatik_knife_speed", "1.5", "Speed when holding knife");
	g_PolineuropatikDamageMultiplier = CreateConVar("superheromod_Polineuropatik_knife_damage_multiplier", "1.35", "Amount if times damage knife should do");
	g_PolineuropatikHealPoints = CreateConVar("superheromod_Polineuropatik_health_per_seconds", "3", "Amount of health healed per second");
	AutoExecConfig(true, "Polineuropatik", "sourcemod/superheromod");
	
	g_iHeroIndex = SuperHero_CreateHero("Polineuropatik", g_PolineuropatikLevel.IntValue);
	SuperHero_SetHeroInfo(g_iHeroIndex, "Become a polineuropatik", "Auto-Heal, Extra knife damage and speed boost (cheap chinese wolverine knockoff with bigger numbers)");
	
	int weapons[42];
	weapons[0] = view_as<int>(CSGOWeaponID_KNIFE);
	SuperHero_SetHeroSpeed(g_iHeroIndex, g_PolineuropatikKnifeSpeed.FloatValue, weapons, 1);
	SuperHero_SetHeroDamageMultiplier(g_iHeroIndex, g_PolineuropatikDamageMultiplier.FloatValue, view_as<int>(CSGOWeaponID_KNIFE));

	HookEvent("player_spawn", Event_PlayerS, EventHookMode_Post);
}

public void OnMapStart()
{
	AddFileToDownloadsTable(g_szPolySwordModel);
	PrecacheModel(g_szPolySwordModel);
	g_iMdlIndex = PrecacheModel(g_szPolySwordModel);
	g_iDefaultKnifeIndex = PrecacheModel(g_szDefaultKnifeModel);
	
}

public Action Event_PlayerS(Handle event, const char[] name, bool dontBroadcast)
{
		int client = GetClientOfUserId(GetEventInt(event, "userid"));
		if(!g_bHasPolineuropatik[client]){
			
			return Plugin_Continue;
		}
		int team = GetEventInt(event, "team");	
		char teamname[128];
		GetTeamName(team, teamname, 127);
		PrintToChat(client,"Team name is: %s. Team ID is: %d",teamname,team);
		char string[128];
		if(IsModelPrecached(g_szPolySwordModel)){
			
			
			string="  ";
		}
		else{
			
			string=" not ";
			
		}
		PrintToChat(client,"Galil model is%sprecached",string);
		return Plugin_Handled;
}
public void OnConfigsExecuted()
{
	int weapons[42];
	weapons[0] = view_as<int>(CSGOWeaponID_KNIFE);
	SuperHero_SetHeroAvailableLevel(g_iHeroIndex, g_PolineuropatikLevel.IntValue);
	SuperHero_SetHeroSpeed(g_iHeroIndex, g_PolineuropatikKnifeSpeed.FloatValue, weapons, 1);
	SuperHero_SetHeroDamageMultiplier(g_iHeroIndex, g_PolineuropatikDamageMultiplier.FloatValue, view_as<int>(CSGOWeaponID_KNIFE));
}

public Action Timer_Heal(Handle timer, any data)
{
	for (int i = 1; i <= MaxClients; i++)
	{
		if(!IsValidClient(i) || !IsPlayerAlive(i))
			continue;
		
		if(g_bHasPolineuropatik[i]){
			SuperHero_AddHealth(i, g_PolineuropatikHealPoints.IntValue);
			
		}
	}
	return Plugin_Continue;
}
public Action Timer_Invis(Handle timer, any data){
	
	int client = GetClientOfUserId(data - TASKID);
	if(!IsValidClient(client) || !IsPlayerAlive(client)){
		return Plugin_Handled;
	}
	g_bInvisible[client] = g_bHasPolineuropatik[client];
	
		
	
	setClientRendering(client);
	return Plugin_Continue;
	
	
}
public void setClientRendering(int client){
	
	int color[4];
	GetEntityRenderColor(client, color[0], color[1], color[2], color[3]);

	if(g_bInvisible[client]){
		SetEntityRenderMode(client, RENDER_TRANSALPHA);
		SetEntityRenderColor(client, color[0], color[1], color[2], g_PolineuropatikAlpha.IntValue);
	
	}
	else{
		SetHudTextParams(0.4, 0.8, 2.0, 0, 255, 0, 255);
		SetEntityRenderColor(client, color[0], color[1], color[2], 255);
	}
}
public void SuperHero_OnHeroInitialized(int client, int heroIndex, int mode)
{
	if(heroIndex != g_iHeroIndex)
		return;
		
	switch(mode)
	{
		case SH_HERO_ADD:
		{
			g_bHasPolineuropatik[client] = true;
			//Switch model
			if(IsModelPrecached(g_szPolySwordModel)){
				FPVMI_SetClientModel(client,"weapon_knife",g_iMdlIndex);
			}
			CreateTimer(0.5, Timer_Invis, GetClientUserId(client)+TASKID,TIMER_REPEAT);
		}
		case SH_HERO_DROP:
		{
			g_bHasPolineuropatik[client] = false;
			g_bInvisible[client] = false;
			FPVMI_SetClientModel(client,"weapon_knife",g_iDefaultKnifeIndex);
		}
	}
	
}
public void SuperHero_OnPlayerSpawned(int client, bool newroundspawn)
{
	if(!g_bHasPolineuropatik[client])
		return;
	
	if(IsModelPrecached(g_szPolySwordModel)){
		FPVMI_SetClientModel(client,"weapon_knife",g_iMdlIndex);
	}
}
public bool OnClientConnect(int client, char[] rejectmsg, int maxlen)
{
	g_bHasPolineuropatik[client] = false;
	return true;
}