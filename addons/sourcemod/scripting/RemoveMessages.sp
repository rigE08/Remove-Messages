#pragma semicolon 1
#pragma newdecls required


#include <sourcemod>

ConVar sm_removemessages_cvar,
	   sm_removemessages_gametext,
	   sm_removemessages_radio,
	   sm_removemessages_changeteam,
	   sm_removemessages_changename,
	   sm_removemessages_connect,
	   sm_removemessages_disconnect;

bool cvar,
	 gametext,
	 radio,
	 changeteam,
	 changename,
	 connect,
	 disconnect;

static const char g_sBlockMsgs[][] =
{
    "#Player_Point_Award_Assist_Enemy_Plural",
    "#Player_Point_Award_Assist_Enemy",
    "#Player_Point_Award_Killed_Enemy_Plural",
    "#Player_Point_Award_Killed_Enemy",
    "#Player_Cash_Award_Kill_Hostage",
    "#Player_Cash_Award_Damage_Hostage",
    "#Player_Cash_Award_Get_Killed",
    "#Player_Cash_Award_Respawn",
    "#Player_Cash_Award_Interact_Hostage",
    "#Player_Cash_Award_Killed_Enemy",
    "#Player_Cash_Award_Rescued_Hostage",
    "#Player_Cash_Award_Bomb_Defused",
    "#Player_Cash_Award_Bomb_Planted",
    "#Player_Cash_Award_Killed_Enemy_Generic",
    "#Player_Cash_Award_Killed_VIP",
    "#Player_Cash_Award_Kill_Teammate",
    "#Player_Cash_Award_ExplainSuicide_YouGotCash",
    "#Player_Cash_Award_ExplainSuicide_TeammateGotCash",
    "#Player_Cash_Award_ExplainSuicide_EnemyGotCash",
    "#Player_Cash_Award_ExplainSuicide_Spectators",
    "#Team_Cash_Award_Win_Hostages_Rescue",
    "#Team_Cash_Award_Win_Defuse_Bomb",
    "#Team_Cash_Award_Win_Time",
    "#Team_Cash_Award_Elim_Bomb",
    "#Team_Cash_Award_Elim_Hostage",
    "#Team_Cash_Award_T_Win_Bomb",
    "#Team_Cash_Award_Win_Hostage_Rescue",
    "#Team_Cash_Award_Loser_Bonus",
    "#Team_Cash_Award_Loser_Zero",
    "#Team_Cash_Award_Rescued_Hostage",
    "#Team_Cash_Award_Hostage_Interaction",
    "#Team_Cash_Award_Hostage_Alive",
    "#Team_Cash_Award_Planted_Bomb_But_Defused",
    "#Team_Cash_Award_CT_VIP_Escaped",
    "#Team_Cash_Award_T_VIP_Killed",
    "#Team_Cash_Award_no_income",
    "#Team_Cash_Award_Generic",
    "#Team_Cash_Award_Custom",
    "#Team_Cash_Award_Bonus_Shorthanded",
    "#Team_Cash_Award_Loser_Bonus_Neg",
    "#Team_Cash_Award_no_income_suicide",
    "#SFUI_Notice_Warmup_Has_Ended",
    "#SFUI_Notice_Match_Will_Start_Chat",
    "#hostagerescuetime",
    "#Chat_SavePlayer_Savior",
    "#Chat_SavePlayer_Saved",
    "#Chat_SavePlayer_Spectator",
	"#Cstrike_TitlesTXT_Game_teammate_attack",
    "#Notice_Bonus_Shorthanded_Eligibility",
    "#Notice_Bonus_Shorthanded_Eligibility_Single",
    "#Notice_Bonus_Enemy_Team",
    "#Item_Traded",
    "#Item_FoundInCrate",
    "#SendPlayerItemFound",
};

public Plugin myinfo = 
{
    name = "[CS:GO] Remove Messages", 
    author = "Fox1qqq, NiGHT", 
    version = "2.7",
    description = "Disable messages in the Chat, Radio.",
    url = "hlmod.ru"
};

public void OnPluginStart()
{
	sm_removemessages_cvar = CreateConVar("sm_removemessages_cvar",     			  "1",            "[(1) On / (0) Off] Delete messages about cvar change.", _, true, 0.0, true, 1.0);
	sm_removemessages_gametext = CreateConVar("sm_removemessages_gametext",           "1",            "[(1) On / (0) Off] Delete messages from the game.", _, true, 0.0, true, 1.0);
	sm_removemessages_radio = CreateConVar("sm_removemessages_radio",   			  "1",            "[(1) On / (0) Off] Deletes all radio messages.", _, true, 0.0, true, 1.0);
	sm_removemessages_changeteam = CreateConVar("sm_removemessages_changeteam",       "1",            "[(1) On / (0) Off] Deletes players' changeover messages.", _, true, 0.0, true, 1.0);
	sm_removemessages_changename = CreateConVar("sm_removemessages_changename",       "1",            "[(1) On / (0) Off] Delete nickname change messages.", _, true, 0.0, true, 1.0);
	sm_removemessages_connect = CreateConVar("sm_removemessages_connect",             "1",            "[(1) On / (0) Off] Clears messages about connecting players.", _, true, 0.0, true, 1.0);
	sm_removemessages_disconnect = CreateConVar("sm_removemessages_disconnect",       "1",            "[(1) On / (0) Off] Delete messages about disconnected players.", _, true, 0.0, true, 1.0);
	
	HookUserMessage(GetUserMessageId("TextMsg"), UserMsgText, true);
	HookUserMessage(GetUserMessageId("RadioText"), UserMsgRadio1, true);
	HookUserMessage(GetUserMessageId("SayText2"), SayText2, true);
	HookUserMessage(GetUserMessageId("SendPlayerItemFound"), SendPlayerItemFound, true);

	HookEvent("player_team", OnTeam, EventHookMode_Pre);
	HookEvent("server_cvar", Event_Cvar, EventHookMode_Pre);
	HookEvent("player_connect", Event_PlayerConnect, EventHookMode_Pre);
	HookEvent("player_disconnect", Event_PlayerDisconnect, EventHookMode_Pre);
	
	char r[][]={"cheer", "compliment", "coverme", "fallback", "followme", "enemydown", "enemyspot", "getinpos", "getout", "go", "holdpos", "inposition",
		"needbackup", "negative", "nice", "regroup", "report", "reportingin", "roger", "sectorclear", "sticktog", "stormfront", "takingfire", "takepoint", "thanks"};
	int i=sizeof(r)-1;
	do AddCommandListener(UserMsgRadio2, r[i]); 
	while(i--);
	
	AutoExecConfig(true, "remove_messages", "sourcemod");
}

public void OnConfigsExecuted()
{
	FindConVar("sv_ignoregrenaderadio").IntValue = sm_removemessages_radio.IntValue;
	cvar = sm_removemessages_cvar.BoolValue;
	gametext = sm_removemessages_gametext.BoolValue;
	radio = sm_removemessages_radio.BoolValue;
	changeteam = sm_removemessages_changeteam.BoolValue;
	changename = sm_removemessages_changename.BoolValue;
	connect = sm_removemessages_connect.BoolValue;
	disconnect = sm_removemessages_disconnect.BoolValue;
}

public void OnConVarChanged(ConVar convar, const char[] oldValue, const char[] newValue)
{
    if (convar == sm_removemessages_cvar)
    {
        cvar = convar.BoolValue;
    }
    else if (convar == sm_removemessages_gametext)
    {
        gametext = convar.BoolValue;
    }
    else if (convar == sm_removemessages_radio)
    {
        radio = convar.BoolValue;
    }
    else if (convar == sm_removemessages_changeteam)
    {
        changeteam = convar.BoolValue;
    }
    else if (convar == sm_removemessages_changename)
    {
        changename = convar.BoolValue;
    }
    else if (convar == sm_removemessages_connect)
    {
        connect = convar.BoolValue;
    }
    else if (convar == sm_removemessages_disconnect)
    {
        disconnect = convar.BoolValue;
    }
}

public Action Event_Cvar(Event event, const char[] name, bool dontBroadcast)
{
	return cvar ? Plugin_Handled : Plugin_Continue;
}

public Action UserMsgText(UserMsg msg_id, Handle msg, const int[] players, int playersNum, bool reliable, bool init)
{
    if(gametext)
	{
        static char buffer[64];
        PbReadString(msg, "params", buffer, sizeof(buffer), 0);
        
        for(int i = 0; i < sizeof(g_sBlockMsgs); ++i)
        {
            if(!strcmp(buffer, g_sBlockMsgs[i]))
            {
                return Plugin_Handled;
            }
        }
    }
    return Plugin_Continue;
}

public Action UserMsgRadio1(UserMsg msg_id, Handle pb, int[] players, int playersNum, bool reliable, bool init)
{
	return radio ? Plugin_Handled : Plugin_Continue;
}

public Action SendPlayerItemFound(UserMsg msg_id, Handle pb, int[] players, int playersNum, bool reliable, bool init)
{
	return Plugin_Handled;
}

public Action UserMsgRadio2(int C, char[] N, int A)
{
	return radio ? Plugin_Handled : Plugin_Continue;
}

public Action OnTeam(Event event, const char[] name, bool dontBroadcast)
{
	if(changeteam)
	{
		if(!event.GetBool("disconnect"))
			event.SetBool("silent", true);
	}	
	return Plugin_Continue;
}

public Action SayText2(UserMsg msg_id, Handle bf, int[] players, int playersNum, bool reliable, bool init)
{
    if(changename)
	{
        if(!reliable)
        {
            return Plugin_Continue;
        }

        static char buffer[25];

        if(GetUserMessageType() == UM_Protobuf)
        {
            PbReadString(bf, "msg_name", buffer, sizeof(buffer));

            if(strcmp(buffer, "#Cstrike_Name_Change") == 0)
            {
                return Plugin_Handled;
            }
        }
    }
    return Plugin_Continue;
}

public Action Event_PlayerConnect(Event event, const char[] name, bool dontBroadcast)
{
	return connect ? Plugin_Handled : Plugin_Continue;
}

public Action Event_PlayerDisconnect(Event event, const char[] name, bool dontBroadcast)
{
	return disconnect ? Plugin_Handled : Plugin_Continue;
}