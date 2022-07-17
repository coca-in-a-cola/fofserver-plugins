#include <sourcemod>
#include <sdktools>

#pragma semicolon 1
#pragma newdecls required

#define PLUGIN_VERSION "0.00"

public Plugin myinfo = 
{
	name = "Levels for pipa",
	author = "k0rae",
	description = "Set a lot of notoriety",
	version = PLUGIN_VERSION,
	url = "Your website URL/AlliedModders profile URL"
};

public void OnPluginStart()
{
	/**
	 * @note For the love of god, please stop using FCVAR_PLUGIN.
	 * Console.inc even explains this above the entry for the FCVAR_PLUGIN define.
	 * "No logic using this flag ever existed in a released game. It only ever appeared in the first hl2sdk."
	 */
	CreateConVar("sm_levels_version", PLUGIN_VERSION, "Standard plugin version ConVar. Please don't change me!", FCVAR_REPLICATED|FCVAR_NOTIFY|FCVAR_DONTRECORD);
	RegConsoleCmd("ebat_pizdec", GiveNotoriety);
}

public Action GiveNotoriety(int client, int args)
{
	if (!client)return Plugin_Handled;

	SetEntPropFloat(client, Prop_Send, "m_flMaxspeed", 1000.0);
	SetEntPropFloat(client, Prop_Send, "m_flModelScale", 0.1);
	
	return Plugin_Handled;
}

public void OnMapStart()
{
	/**
	 * @note Precache your models, sounds, etc. here!
	 * Not in OnConfigsExecuted! Doing so leads to issues.
	 */
}
