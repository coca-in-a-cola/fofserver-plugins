#include <sourcemod>
#include <sdktools>
#include <sdkhooks>

#pragma semicolon 1
#pragma newdecls required

#define PLUGIN_VERSION "228"

#define MIN(%0,%1) ((%0) > (%1) ? (%1) : (%0))
#define MAX(%0,%1) ((%0) < (%1) ? (%1) : (%0))

ConVar g_EnabledCvar;
ConVar g_VampirismPercent;

public Plugin myinfo = 
{
	name = "Sosalka (vamprism)",
	author = "k0rae",
	description = "Vampirism plugin",
	version = PLUGIN_VERSION,
	url = ""
};

bool IsEnabled()
{
	return g_EnabledCvar.BoolValue;
}

float GetVampirismRate()
{
	return g_VampirismPercent.FloatValue / 100;
}

public void OnPluginStart()
{
	/**
	 * @note For the love of god, please stop using FCVAR_PLUGIN.
	 * Console.inc even explains this above the entry for the FCVAR_PLUGIN define.
	 * "No logic using this flag ever existed in a released game. It only ever appeared in the first hl2sdk."
	 */
	CreateConVar("sm_sosalka_version", PLUGIN_VERSION, "Standard plugin version ConVar. Please don't change me!", FCVAR_REPLICATED|FCVAR_NOTIFY|FCVAR_DONTRECORD);
	g_EnabledCvar = CreateConVar(
            "sosalka_enabled", "1",
            "Enable sosalka or don't'",
            FCVAR_NOTIFY, true, 0.0, true, 1.0);
          
	g_VampirismPercent = CreateConVar("sm_sosalka_rate", "20", "Vampirism percent", FCVAR_NOTIFY, true, 0.0, true, 100.0);
	AutoExecConfig(true, "sosalka");
}

public void OnMapStart()
{
	/**
	 * @note Precache your models, sounds, etc. here!
	 * Not in OnConfigsExecuted! Doing so leads to issues.
	 */
}

int CalculateHealth(int client, float damage)
{
	int health = MIN(100, RoundToZero(GetClientHealth(client) + damage * GetVampirismRate()));
	return health;
}

Action Hook_OnTakeDamage(int victim, int& attacker, int& inflictor,
        float& damage, int& damagetype, int& weapon, float damageForce[3],
        float damagePosition[3])
{
	if (!IsEnabled()) return Plugin_Continue;
	if (!IsClientIngame(attacker)) return Plugin_Continue;
	if (!IsClientIngame(victim)) return Plugin_Continue;
	if (attacker == victim)return Plugin_Continue;
	
	int newHp = CalculateHealth(attacker, damage);
	SetEntityHealth(attacker, newHp);
	
	return Plugin_Continue;
}

public void OnClientPutInServer(int client) 
{
		if (!IsEnabled()) return;
		SDKHook(client, SDKHook_OnTakeDamage, Hook_OnTakeDamage);
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