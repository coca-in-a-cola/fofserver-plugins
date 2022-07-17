#include <sourcemod>
#include <sdktools>
#include <sdkhooks>

#pragma semicolon 1
#pragma newdecls required

#define PLUGIN_VERSION "1.00"

ConVar g_EnabledCvar;
ConVar g_ChatText;
ConVar g_CenterText;

bool IsEnabled()
{
	return g_EnabledCvar.BoolValue;
}

public Plugin myinfo = 
{
	name = "shit weapons fixer",
	author = "k0rae",
	description = "ez",
	version = PLUGIN_VERSION,
	url = ""
};

public void OnPluginStart()
{
	/**
	 * @note For the love of god, please stop using FCVAR_PLUGIN.
	 * Console.inc even explains this above the entry for the FCVAR_PLUGIN define.
	 * "No logic using this flag ever existed in a released game. It only ever appeared in the first hl2sdk."
	 */
	CreateConVar("sm_fix_version", PLUGIN_VERSION, "Standard plugin version ConVar. Please don't change me!", FCVAR_REPLICATED|FCVAR_NOTIFY|FCVAR_DONTRECORD);
	g_EnabledCvar = CreateConVar(
            "fixer_enabled", "1",
            "Enable fixer or don't",
            FCVAR_NOTIFY, true, 0.0, true, 1.0);
	g_ChatText = CreateConVar("fixer_chat", "ХВАТИТ ЖРАТЬ ГОВНО!", "Message in chat");
	g_CenterText = CreateConVar("fixer_center", "ГОВНОЕД ГОВНОЕД!", "Message in center");
	AutoExecConfig(true, "fixer");		
}

public void OnMapStart()
{
	/**
	 * @note Precache your models, sounds, etc. here!
	 * Not in OnConfigsExecuted! Doing so leads to issues.
	 */
}

public void OnClientPutInServer(int client) 
{
		if (!IsEnabled()) return;
		SDKHook(client, SDKHook_OnTakeDamage, Hook_OnTakeDamage);
}

bool IsShitWeapon(char weaponName[128])
{
	if((StrContains(weaponName, "shotgun") != -1) || StrEqual(weaponName, "weapon_coachgun"))
	{
		return true;
	}
	return false;
}

bool IsSmith(char weaponName[128])
{
	return StrEqual(weaponName, "weapon_carbine");
}

Action Hook_OnTakeDamage(int victim, int& attacker, int& inflictor,
        float& damage, int& damagetype, int& weapon, float damageForce[3],
        float damagePosition[3])
{
	if (!IsEnabled()) return Plugin_Continue;
	if (!IsClientIngame(attacker)) return Plugin_Continue;
	if (!IsClientIngame(victim)) return Plugin_Continue;
	if (attacker == victim)return Plugin_Continue;
	if (!IsValidEntity(weapon)) return Plugin_Continue;
	
	
	
	
	
	char weaponName[128];
	GetEntityClassname(weapon, weaponName, 128);
	
	if(IsSmith(weaponName))
	{
		if(damage > 99.0 && GetClientHealth(victim) == 100)
		{
			damage = GetRandomFloat(90.0, 99.0);
			return Plugin_Changed;
		}
	}
	
	if(IsShitWeapon(weaponName))
	{
		char chatText[128];
		char centerText[128];
		
		GetConVarString(g_ChatText, chatText, 128);
		GetConVarString(g_CenterText, centerText, 128);
		
		PrintToChat(attacker, chatText);
		PrintCenterText(attacker, centerText);
		
		float v[3];
		v[0] = 0.0; v[1] = 0.0; v[2] = 100.0;
		
		float pos[3];
		GetClientAbsAngles(attacker, pos);
		
		pos[2] = pos[2] + 1000.0;
		if(RoundToZero(damage) > GetClientHealth(victim))
		{
			SetEntityHealth(victim, 1);
		}
		SDKHooks_DropWeapon(attacker, weapon, pos, v);
		return Plugin_Handled;
	}
	
	SetEntPropFloat(weapon, Prop_Send, "m_flNextPrimaryAttack", GetEntPropFloat(weapon, Prop_Send, "m_flNextPrimaryAttack") - 30.0);
	SetEntPropFloat(weapon, Prop_Send, "m_flNextSecondaryAttack", GetEntPropFloat(weapon, Prop_Send, "m_flNextSecondaryAttack") - 30.0);
	if(StrEqual(weaponName, "weapon_knife"))
	{
		float attackerPos[3], victimPos[3], sub[2];
	
		GetClientAbsAngles(attacker, attackerPos);
		GetClientAbsAngles(victim, victimPos);
	
		sub[0] = attackerPos[0] - victimPos[0];
		sub[1] = attackerPos[1] - victimPos[1];
	
		float ang = sub[0] * sub[0] + sub[1] * sub[1];
		if(ang < 6500)
		{
			damage = 100.0;
			return Plugin_Changed;
		}
		damage = 10.0;
		return Plugin_Changed;
	}
	SetEntPropFloat(weapon, Prop_Send, "m_flAccuracyPenalty", 0.0);
	return Plugin_Continue;
}

stock bool IsClientIngame(int client)
{
	if (client > 4096) {
		client = EntRefToEntIndex(client);
	}

	if (client < 1 || client > MaxClients) {
		return false;
	}

	return IsClientInGame(client);
}
