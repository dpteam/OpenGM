#include <a_samp>

new Text: Textdraw0;

main()
{
	print("GameMode.Init > Open-Source gamemode <github.com/dpteam>");
	print("GameMode.Init > on DPLv4.2 [License Free Information]");
	print("GameMode.Init > Gamemode Loaded");
}

#define COLOR_RED			0xCC0000AA
#define COLOR_GREY			0xAFAFAFAA
#define COLOR_GREEN			0x33AA33AA
#define COLOR_BRIGHTRED		0xFF0000AA
#define COLOR_YELLOW		0xFFFF00AA
#define COLOR_PINK			0xFF66FFAA
#define COLOR_BLUE			0x3A47DEFF
#define COLOR_TAN			0xBDB76BAA
#define COLOR_PURPLE		0x800080AA
#define COLOR_WHITE			0xFFFFFFAA
#define COLOR_LIGHTBLUE		0x33CCFFAA
#define COLOR_ORANGE		0xFF9900AA
#define COLOR_INDIGO		0x4B00B0AA
#define COLOR_BLACK			0x00000000
#define COLOR_DARKGREY		0x696969FF

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
	SendClientMessage(playerid,COLOR_WHITE,"Welcome to Open-Source gamemode server");
	SendClientMessage(playerid,COLOR_WHITE,"=You may fork this project at=");
	SendClientMessage(playerid,COLOR_BLUE,"http://github.com/dpteam/OpenDM");
	SendClientMessage(playerid,COLOR_GREEN,"Please enter /help to see commands");
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
	return 1;
}

public OnPlayerSpawn(playerid)
{
	GivePlayerWeapon(playerid,WEAPON_COLT45,100);
	GivePlayerWeapon(playerid,WEAPON_SHOTGUN,100);
	GivePlayerWeapon(playerid,WEAPON_M4,200);
	return 1;
}

public OnPlayerDeath(playerid, killerid, reason)
{
	GameTextForPlayer(playerid,"~w~WASTED",6000,3);
	return 1;
}

public OnPlayerText(playerid, text[])
{
	new txt[128];
	format(txt,sizeof(txt),"[%d]: %s",playerid, text);
	SendPlayerMessageToAll(playerid, txt);
	SetPlayerChatBubble(playerid, text, 0xAA3333AA, 80.0, 10000);
	return 0;
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
