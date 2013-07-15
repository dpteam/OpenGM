#include <a_samp>
#include <core>
#include <float>

#pragma tabsize 0

new Text: Textdraw0;

main()
{
	print("GameMode.Init > Open-Source gamemode <github.com/dpteam>");
	print("GameMode.Init > on DPLv4.2 [License Free Information]");
	print("GameMode.Init > Gamemode Loaded");
}

#define COLOR_GREY 0xAFAFAFAA
#define COLOR_GREEN 0x33AA33AA
#define COLOR_RED 0xAA3333AA
#define COLOR_YELLOW 0xFFFF00AA
#define COLOR_WHITE 0xFFFFFFAA
#define COLOR_BLUE 0x3A47DEFF
#define INACTIVE_PLAYER_ID 255
#define GIVECASH_DELAY 5000 // Time in ms between /givecash commands.
#define NUMVALUES 4
forward MoneyGrubScoreUpdate();
forward Givecashdelaytimer(playerid);
forward SetPlayerRandomSpawn(playerid);
forward SetupPlayerForClassSelection(playerid);
forward GameModeExitFunc();
forward SendPlayerFormattedText(playerid, const str[], define);
forward public SendAllFormattedText(playerid, const str[], define);

new iSpawnSet[MAX_PLAYERS];

new Float:gRandomPlayerSpawns[23][3] = {
	{1958.3783,1343.1572,15.3746},
	{2199.6531,1393.3678,10.8203},
	{2483.5977,1222.0825,10.8203},
	{2637.2712,1129.2743,11.1797},
	{2000.0106,1521.1111,17.0625},
	{2024.8190,1917.9425,12.3386},
	{2261.9048,2035.9547,10.8203},
	{2262.0986,2398.6572,10.8203},
	{2244.2566,2523.7280,10.8203},
	{2335.3228,2786.4478,10.8203},
	{2150.0186,2734.2297,11.1763},
	{2158.0811,2797.5488,10.8203},
	{1969.8301,2722.8564,10.8203},
	{1652.0555,2709.4072,10.8265},
	{1564.0052,2756.9463,10.8203},
	{1271.5452,2554.0227,10.8203},
	{1441.5894,2567.9099,10.8203},
	{1480.6473,2213.5718,11.0234},
	{1400.5906,2225.6960,11.0234},
	{1598.8419,2221.5676,11.0625},
	{1318.7759,1251.3580,10.8203},
	{1558.0731,1007.8292,10.8125},
	{1705.2347,1025.6808,10.8203}
};

new Float:gCopPlayerSpawns[2][3] = {
	{2297.1064,2452.0115,10.8203},
	{2297.0452,2468.6743,10.8203}
};

new gActivePlayers[MAX_PLAYERS];
new gLastGaveCash[MAX_PLAYERS];

public OnPlayerPickUpPickup(playerid, pickupid)
{
	new s[256];
	format(s,256,"Picked up %d",pickupid);
	SendClientMessage(playerid,0xFFFFFFFF,s);
}

public OnGameModeInit()
{
	SetGameModeText("<github.com/dpteam/OpenDM>");
	SendRconCommand("mapname FreeWorld");
	EnableStuntBonusForAll(1);
	UsePlayerPedAnims();
	ShowNameTags(1);
	ShowPlayerMarkers(1);
	SetWorldTime(3);
	SetGravity(0.008);
	AllowInteriorWeapons(1);
	for(new s = 0; s < 300; s++)
	{
		if(IsInvalidSkin(s)) continue;
		else AddPlayerClass(s, 1958.3783, 1343.1572, 15.3746, 269.1425, 0, 0, 0, 0, 0, 0);
	}
	return 1;
}

forward SetupPlayerForClassSelection(playerid);
public SetupPlayerForClassSelection(playerid)
{
	SetPlayerInterior(playerid,14);
	SetPlayerPos(playerid,258.4893,-41.4008,1002.0234);
	SetPlayerFacingAngle(playerid, 90.0);
	SetPlayerCameraPos(playerid,256.0815,-43.0475,1003.0234);
	SetPlayerCameraLookAt(playerid,258.4893,-41.4008,1002.0234);
}

public OnPlayerConnect(playerid)
{
	new pName[MAX_PLAYER_NAME], string[39 + MAX_PLAYER_NAME];
	GetPlayerName(playerid, pName, sizeof(pName));
	format(string, sizeof(string), "%s [ID:%d] connected to server.", pName, playerid);
	SendClientMessageToAll(COLOR_GREY, string);
	SendDeathMessage(INVALID_PLAYER_ID,playerid,200);
	SendClientMessage(playerid,COLOR_WHITE,"Welcome to Open-Source gamemode server");
	SendClientMessage(playerid,COLOR_WHITE,"=You may fork this project at=");
	SendClientMessage(playerid,COLOR_BLUE,"http://github.com/dpteam/OpenDM");
	SendClientMessage(playerid,COLOR_GREEN,"Please enter /help to see commands");
	gActivePlayers[playerid]++;
	gLastGaveCash[playerid] = GetTickCount();
	Textdraw0 = TextDrawCreate(415.000000, 2.000000, "Open-Source <fsf.org>");
	TextDrawBackgroundColor(Textdraw0, 255);
	TextDrawFont(Textdraw0, 2);
	TextDrawLetterSize(Textdraw0, 0.370000, 2.099999);
	TextDrawColor(Textdraw0, -16711681);
	TextDrawSetOutline(Textdraw0, 1);
	TextDrawSetProportional(Textdraw0, 1);
	TextDrawShowForAll(Textdraw0);
	return 1;
}

public OnPlayerDisconnect(playerid, reason)
{
	new pName[MAX_PLAYER_NAME], string[39 + MAX_PLAYER_NAME];
	GetPlayerName(playerid, pName, sizeof(pName));
	switch(reason)
	{
	case 0: format(string, sizeof(string), "%s [ID:%d] crashed/low-energy", pName, playerid);
	case 1: format(string, sizeof(string), "%s [ID:%d] out", pName, playerid);
	case 2: format(string, sizeof(string), "%s [ID:%d] kicked/banned", pName, playerid);
	}
	SendClientMessageToAll(COLOR_GREY, string);
	SendDeathMessage(INVALID_PLAYER_ID,playerid,201);
	gActivePlayers[playerid]--;
	return 1;
}

public OnPlayerSpawn(playerid)
{
	GivePlayerMoney(playerid, 10000);
	GivePlayerWeapon(playerid, 30, 350);
	GivePlayerWeapon(playerid, 34, 50);
	GivePlayerWeapon(playerid, 4, 1);
	GivePlayerWeapon(playerid, 24, 120);
	SetPlayerInterior(playerid,0);
	SetPlayerRandomSpawn(playerid);
	TogglePlayerClock(playerid,1);
	return 1;
}

public SetPlayerRandomSpawn(playerid)
{
	if (iSpawnSet[playerid] == 1)
	{
		new rand = random(sizeof(gCopPlayerSpawns));
		SetPlayerPos(playerid, gCopPlayerSpawns[rand][0], gCopPlayerSpawns[rand][1], gCopPlayerSpawns[rand][2]); // Warp the player
		SetPlayerFacingAngle(playerid, 270.0);
	}
	else if (iSpawnSet[playerid] == 0)
	{
		new rand = random(sizeof(gRandomPlayerSpawns));
		SetPlayerPos(playerid, gRandomPlayerSpawns[rand][0], gRandomPlayerSpawns[rand][1], gRandomPlayerSpawns[rand][2]); // Warp the player
	}
	return 1;
}

public OnPlayerDeath(playerid, killerid, reason)
{
	new playercash;
	if(killerid == INVALID_PLAYER_ID) {
		SendDeathMessage(INVALID_PLAYER_ID,playerid,reason);
		ResetPlayerMoney(playerid);
	} else {
		SendDeathMessage(killerid,playerid,reason);
		SetPlayerScore(killerid,GetPlayerScore(killerid)+1);
		playercash = GetPlayerMoney(playerid);
		if (playercash > 0)  {
			GivePlayerMoney(killerid, playercash);
			ResetPlayerMoney(playerid);
		}
		else
		{
		}
	}
	GameTextForPlayer(playerid,"~w~WASTED",6000,3);
	return 1;
}

public OnPlayerRequestClass(playerid, classid)
{
	iSpawnSet[playerid] = 0;
	SetupPlayerForClassSelection(playerid);
	return 1;
}

public OnPlayerText(playerid, text[])
{
	new PlayerName[MAX_PLAYER_NAME];
	new t = 0;
	while(text[t++] != 0x0) text[t] = tolower(text[t]);
	SetPlayerChatBubble(playerid, text, 0xAA3333AA, 80.0, 10000);
	GetPlayerName(playerid, PlayerName, sizeof(PlayerName));
	format(text, 1024, "%s(%d): {FFFFFF}%s", PlayerName, playerid, text);
	SendClientMessageToAll(GetPlayerColor(playerid), text);
}

public OnPlayerCommandText(playerid, cmdtext[])
{
	if(strcmp("/kill", cmdtext, true, 10) == 0)
	{
		SetPlayerHealth(playerid,0.0);
		return 1;
	}
	if(strcmp(cmdtext, "/fix", true, 10) == 0)
	{
		if(!IsPlayerInAnyVehicle(playerid)) return SendClientMessage(playerid, COLOR_RED, "You are not in a vehicle!");
		RepairVehicle(GetPlayerVehicleID(playerid));
		SendClientMessage(playerid, COLOR_WHITE, "Your vehicle has been successfully repaired!");
		return 1;
	}
	if(strcmp(cmdtext, "/flip", true, 10) == 0)
	{
		if(IsPlayerInAnyVehicle(playerid))
		{
			new Float:PX, Float:PY, Float:PZ, Float:PA;
			GetPlayerPos(playerid, PX, PY, PZ);
			GetVehicleZAngle(GetPlayerVehicleID(playerid), PA);
			SetVehiclePos(GetPlayerVehicleID(playerid), PX, PY, PZ+1);
			SetVehicleZAngle(GetPlayerVehicleID(playerid), PA);
			SendClientMessage(playerid, COLOR_WHITE, "Your vehicle has been successfully flipped!");
			PlayerPlaySound(playerid, 1085, 0.0, 0.0, 0.0);
		}
		else
		{
			SendClientMessage(playerid, COLOR_RED,"You need to be in a vehicle to use this command!");
		}
		return 1;
	}
	return SendClientMessage(playerid,COLOR_RED,"ERROR, Unknown Command - Use /help");
}

public SendPlayerFormattedText(playerid, const str[], define)
{
	new tmpbuf[256];
	format(tmpbuf, sizeof(tmpbuf), str, define);
	SendClientMessage(playerid, 0xFF004040, tmpbuf);
}

public SendAllFormattedText(playerid, const str[], define)
{
	new tmpbuf[256];
	format(tmpbuf, sizeof(tmpbuf), str, define);
	SendClientMessageToAll(0xFFFF00AA, tmpbuf);
}

stock IsInvalidSkin(skinid)
{
	#define MAX_BAD_SKINS  14
	if(skinid > 310) return true;
	new badSkins[MAX_BAD_SKINS] = {
		3, 4, 5, 6, 8, 42, 65, 74, 86,
		119, 149, 208, 273, 289
	};
	for (new i = 0; i < MAX_BAD_SKINS; i++)
	{
		if (skinid == badSkins[i]) return true;
	}
	return false;
}

stock GetOnlinePlayersCount()
{
	new
	totalPlayers
	;
	for(new i, j = GetMaxPlayers(); i != j; ++i)
	{
		if(IsPlayerConnected(i) && !IsPlayerNPC(i))
		{
			++totalPlayers;
		}
	}
	return totalPlayers;
}
