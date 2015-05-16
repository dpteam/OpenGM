// OpenGM - Freeroam
// v: 16.05.2015, 00:30

#include <a_samp>
#include "../include/gl_common.inc"
#include "../include/gl_spawns.inc"
#include <dc_cmd>
#include <sscanf2>

//Gamemode Common
#define INACTIVE_PLAYER_ID 255
#define GIVECASH_DELAY 5000
#define NUMVALUES 4
#define CITY_LOS_SANTOS 	0
#define CITY_SAN_FIERRO 	1
#define CITY_LAS_VENTURAS 	2

//Very Common Colors
#define COLOR_NORMAL_PLAYER 0xFFBB7777
#define COLOR_DPT 0x0088FFFF

//Default Colors
#define COLOR_BASIC             0x0066FFAA
#define COLOR_RED               0xCC0000AA
#define COLOR_GREY              0xAFAFAFAA
#define COLOR_GREEN             0x33AA33AA
#define COLOR_YELLOW            0xFFFF00AA
#define COLOR_WHITE             0xFFFFFFAA
#define COLOR_BLUE              0x0000BBAA
#define COLOR_LIGHTBLUE         0x33CCFFAA
#define COLOR_ORANGE            0xFF9900AA
#define COLOR_LIME              0x10F441AA
#define COLOR_MAGENTA           0xFF00FFFF
#define COLOR_NAVY              0x000080AA
#define COLOR_AQUA              0xF0F8FFAA
#define COLOR_CRIMSON           0xDC143CAA
#define COLOR_FLBLUE            0x6495EDAA
#define COLOR_BISQUE            0xFFE4C4AA
#define COLOR_BLACK             0x000000AA
#define COLOR_CHARTREUSE        0x7FFF00AA
#define COLOR_BROWN             0xA52A2AAA
#define COLOR_CORAL             0xFF7F50AA
#define COLOR_GOLD              0xB8860BAA
#define COLOR_GREENYELLOW       0xADFF2FAA
#define COLOR_INDIGO            0x4B00B0AA
#define COLOR_IVORY             0xFFFF82AA
#define COLOR_LAWNGREEN         0x7CFC00AA
#define COLOR_SEAGREEN          0x20B2AAAA
#define COLOR_LIMEGREEN         0x32CD32AA
#define COLOR_MIDNIGHTBLUE      0x191970AA
#define COLOR_MAROON            0x800000AA
#define COLOR_OLIVE             0x808000AA
#define COLOR_ORANGERED         0xFF4500AA
#define COLOR_PINK              0xFFC0CBAA
#define COLOR_SPRINGGREEN       0x00FF7FAA
#define COLOR_TOMATO            0xFF6347AA
#define COLOR_YELLOWGREEN       0x9ACD32AA
#define COLOR_MEDIUMAQUA        0x83BFBFAA
#define COLOR_MEDIUMMAGENTA     0x8B008BAA
#define COLOR_WATER				0x33AAAA33

//Forwards
forward MoneyGrubScoreUpdate();
forward Givecashdelaytimer(playerid);
forward SetPlayerRandomSpawn(playerid);
forward SetupPlayerForClassSelection(playerid);
forward GameModeExitFunc();
forward SendPlayerFormattedText(playerid, const str[], define);
forward SendAllFormattedText(playerid, const str[], define); //forward public - ???
forward UpdateTime();
forward RandMessagesx();
forward TuneCar();
forward InfiniteNitro();

//Gamemode Common
new total_vehicles_from_files=0;
new gPlayerCitySelection[MAX_PLAYERS];
new gPlayerHasCitySelected[MAX_PLAYERS];
new gPlayerLastCitySelectionTick[MAX_PLAYERS];
new Text:txtClassSelHelper;
new Text:txtLosSantos;
new Text:txtSanFierro;
new Text:txtLasVenturas;
new gActivePlayers[MAX_PLAYERS];
new gLastGaveCash[MAX_PLAYERS];
new God[MAX_PLAYERS] = 0;

//Tune Cars
new Flash1;
new Sultan1;
new Sultan2;
new Elegy1;
new Elegy2;
new Uranus1;
new Uranus2;

//Clock
new Text:txtTimeDisp;
new hour, minute;
new timestr[32];

//Online Players TextDraw
new Text: Textdraw0;

main()
{
	print("GameMode.Info > Open-Source gamemode <github.com/dpteam/OpenGM>");
	print("GameMode.Info > code is maintained at LFI [License Free Information] license");
	print("GameMode.Info > Scripted by DartPower");
	print("GameMode.Info > Function ideas by NickBock, DartPower ");
	print("GameMode.Info > Bug fixing by SerejaN");
}

//Random Messages//
static const RandMessages[][] =
{
	"{0088FF}СОВЕТ: {FFFFFF}Горит машина? Введи /fix и нет проблем!",
	"{0088FF}СОВЕТ: {FFFFFF}Хочешь быть элитным нубоганером? Введи /noobpack и погрузись в экшн."
};

public OnPlayerPickUpPickup(playerid, pickupid)
{
	new s[256];
	format(s,256,"Picked up %d",pickupid);
	SendClientMessage(playerid,COLOR_WHITE,s);
}

public UpdateTime()
{
	gettime(hour, minute);
	format(timestr,32,"%02d:%02d",hour,minute);
	TextDrawSetString(txtTimeDisp,timestr);
}

public OnGameModeInit()
{
	print("GameMode.Init > Gamemode Loaded");
	SetGameModeText("Stunt/Drift/Freeroam/Race/Fun");
	EnableStuntBonusForAll(1);
	UsePlayerPedAnims();
	ShowPlayerMarkers(PLAYER_MARKERS_MODE_GLOBAL);
	ShowNameTags(1);
	SetNameTagDrawDistance(40.0);
	AllowInteriorWeapons(1);
	SetWeather(0);
	SetTimer("RandMessagesx",100000,1);
	SetTimer("InfiniteNitro",1000,1);
	ClassSel_InitTextDraws();
	for(new s = 0; s < 312; s++) if(!IsInvalidSkin(s)) AddPlayerClass(s, 1958.3783, 1343.1572, 15.3746, 269.1425, 0, 0, 0, 0, 0, 0);
	// SPECIAL
	total_vehicles_from_files += LoadStaticVehiclesFromFile("vehicles/trains.txt");
	total_vehicles_from_files += LoadStaticVehiclesFromFile("vehicles/pilots.txt");
	// LAS VENTURAS
	total_vehicles_from_files += LoadStaticVehiclesFromFile("vehicles/lv_law.txt");
	total_vehicles_from_files += LoadStaticVehiclesFromFile("vehicles/lv_airport.txt");
	total_vehicles_from_files += LoadStaticVehiclesFromFile("vehicles/lv_gen.txt");
	// SAN FIERRO
	total_vehicles_from_files += LoadStaticVehiclesFromFile("vehicles/sf_law.txt");
	total_vehicles_from_files += LoadStaticVehiclesFromFile("vehicles/sf_airport.txt");
	total_vehicles_from_files += LoadStaticVehiclesFromFile("vehicles/sf_gen.txt");
	// LOS SANTOS
	total_vehicles_from_files += LoadStaticVehiclesFromFile("vehicles/ls_law.txt");
	total_vehicles_from_files += LoadStaticVehiclesFromFile("vehicles/ls_airport.txt");
	total_vehicles_from_files += LoadStaticVehiclesFromFile("vehicles/ls_gen_inner.txt");
	total_vehicles_from_files += LoadStaticVehiclesFromFile("vehicles/ls_gen_outer.txt");
	// OTHER AREAS
	total_vehicles_from_files += LoadStaticVehiclesFromFile("vehicles/whetstone.txt");
	total_vehicles_from_files += LoadStaticVehiclesFromFile("vehicles/bone.txt");
	total_vehicles_from_files += LoadStaticVehiclesFromFile("vehicles/flint.txt");
	total_vehicles_from_files += LoadStaticVehiclesFromFile("vehicles/tierra.txt");
	total_vehicles_from_files += LoadStaticVehiclesFromFile("vehicles/red_county.txt");
	txtTimeDisp = TextDrawCreate(605.0,45.0,"00:00");
	TextDrawUseBox(txtTimeDisp, 0);
	TextDrawFont(txtTimeDisp, 3);
	TextDrawSetShadow(txtTimeDisp,0); // no shadow
	TextDrawSetOutline(txtTimeDisp,2); // thickness 1
	TextDrawBackgroundColor(txtTimeDisp,0x000000FF);
	TextDrawColor(txtTimeDisp,0xFFFFFFFF);
	TextDrawAlignment(txtTimeDisp,3);
	TextDrawLetterSize(txtTimeDisp,0.399999,1.600000);
	UpdateTime();
	SetTimer("UpdateTime",1000 * 60,1);
	Textdraw0 = TextDrawCreate(555.000000, 2.000000, "hz");
	TextDrawBackgroundColor(Textdraw0, 255);
	TextDrawFont(Textdraw0, 2);
	TextDrawLetterSize(Textdraw0, 0.370000, 2.099999);
	TextDrawColor(Textdraw0, -16711681);
	TextDrawSetOutline(Textdraw0, 1);
	TextDrawSetProportional(Textdraw0, 1);
	for(new playerid = 0; playerid <= GetPlayerPoolSize(); playerid++)
	{
		if(!IsPlayerConnected(playerid)) continue;
		TextDrawShowForPlayer(playerid, Textdraw0);
	}
	return true;
}

public OnGameModeExit()
{
	print("GameMode.Init > Gamemode Unloaded");
	TextDrawHideForAll(Textdraw0);
	TextDrawDestroy(Textdraw0);
	return true;
}

forward SetupPlayerForClassSelection(playerid);
public SetupPlayerForClassSelection(playerid)
{
	SetPlayerInterior(playerid,14);
	SetPlayerPos(playerid,258.4893,-41.4008,1002.0234);
	SetPlayerFacingAngle(playerid, 90.0);
	SetPlayerCameraPos(playerid,256.0815,-43.0475,1003.0234);
	SetPlayerCameraLookAt(playerid,258.4893,-41.4008,1002.0234);
	return true;
}

public OnPlayerConnect(playerid)
{
	gPlayerCitySelection[playerid] = -1;
	gPlayerHasCitySelected[playerid] = 0;
	gPlayerLastCitySelectionTick[playerid] = GetTickCount();
	new pName[MAX_PLAYER_NAME], string[39 + MAX_PLAYER_NAME];
	GetPlayerName(playerid, pName, sizeof(pName));
	format(string, sizeof(string), "%s [ID:%d] подключился.", pName, playerid);
	SendClientMessageToAll(COLOR_GREY, string);
	SendDeathMessage(INVALID_PLAYER_ID,playerid,200);
	SendClientMessage(playerid,COLOR_WHITE,"Добро пожаловать на сервер DartPower Team.");
	SendClientMessage(playerid,COLOR_YELLOW,"Введите /help чтобы посмотреть помощь");
	SendClientMessage(playerid,COLOR_ORANGE,"Введите /rules чтобы посмотреть правила");
	SendClientMessage(playerid,COLOR_DPT,"Прятной игры ^^");
	gActivePlayers[playerid]++;
	gLastGaveCash[playerid] = GetTickCount();
	new strings[15];
	format(strings, 15, "%d/50",GetOnlinePlayersCount());
	TextDrawSetString(Textdraw0, strings);
	TextDrawShowForPlayer(playerid, Textdraw0);
	return true;
}

static const InvalidNOSVehicles[] = {522,481,441,468,448,446,513,521,510,430,520,476,463};
public InfiniteNitro()
{
	new vehicleid, modelid;
	for(new playerid = 0; playerid <= GetPlayerPoolSize(); playerid++)
	{
		if(!IsPlayerConnected(playerid)) continue;
		if(GetPlayerState(playerid) != 2) continue;
		vehicleid = GetPlayerVehicleID(playerid);
		modelid = GetVehicleModel(vehicleid);
		if(!IsVehicle_NOSRestricted(modelid)) AddVehicleComponent(vehicleid,1010);
	}
	return true;
}

stock IsVehicle_NOSRestricted(modelid)
{
	for(new i = 0; i < sizeof(InvalidNOSVehicles); i++) if(modelid == InvalidNOSVehicles[i]) return true;
	return false;
}

static const reasons[3][64] =
{
	"Lost Connection",
	"Leaving",
	"Kicked/Banned"
};

public OnPlayerDisconnect(playerid, reason)
{
	new pName[MAX_PLAYER_NAME], string[39 + MAX_PLAYER_NAME];
	GetPlayerName(playerid, pName, sizeof(pName));
	format(string, sizeof(string), "%s [ID:%d] отключился. %s", pName, playerid, reasons[reason]);
	SendClientMessageToAll(COLOR_GREY, string);
	SendDeathMessage(INVALID_PLAYER_ID,playerid,201);
	gActivePlayers[playerid]--;
	return true;
}

public OnPlayerSpawn(playerid)
{
	if(IsPlayerNPC(playerid)) return true;
	new randSpawn = 0;
	SetPlayerInterior(playerid,0);
	TogglePlayerClock(playerid,0);
	ResetPlayerMoney(playerid);
	if(CITY_LOS_SANTOS == gPlayerCitySelection[playerid]) {
		randSpawn = random(sizeof(gRandomSpawns_LosSantos));
		SetPlayerPos(playerid,
		gRandomSpawns_LosSantos[randSpawn][0],
		gRandomSpawns_LosSantos[randSpawn][1],
		gRandomSpawns_LosSantos[randSpawn][2]);
		SetPlayerFacingAngle(playerid,gRandomSpawns_LosSantos[randSpawn][3]);
	}
	else if(CITY_SAN_FIERRO == gPlayerCitySelection[playerid]) {
		randSpawn = random(sizeof(gRandomSpawns_SanFierro));
		SetPlayerPos(playerid,
		gRandomSpawns_SanFierro[randSpawn][0],
		gRandomSpawns_SanFierro[randSpawn][1],
		gRandomSpawns_SanFierro[randSpawn][2]);
		SetPlayerFacingAngle(playerid,gRandomSpawns_SanFierro[randSpawn][3]);
	}
	else if(CITY_LAS_VENTURAS == gPlayerCitySelection[playerid]) {
		randSpawn = random(sizeof(gRandomSpawns_LasVenturas));
		SetPlayerPos(playerid,
		gRandomSpawns_LasVenturas[randSpawn][0],
		gRandomSpawns_LasVenturas[randSpawn][1],
		gRandomSpawns_LasVenturas[randSpawn][2]);
		SetPlayerFacingAngle(playerid,gRandomSpawns_LasVenturas[randSpawn][3]);
	}
	SetPlayerInterior(playerid,0);
	TogglePlayerClock(playerid,1);
	/* 	SetPlayerSkillLevel(playerid,WEAPONSKILL_PISTOL,200);
	SetPlayerSkillLevel(playerid,WEAPONSKILL_PISTOL_SILENCED,200);
	SetPlayerSkillLevel(playerid,WEAPONSKILL_DESERT_EAGLE,200);
	SetPlayerSkillLevel(playerid,WEAPONSKILL_SHOTGUN,200);
	SetPlayerSkillLevel(playerid,WEAPONSKILL_SAWNOFF_SHOTGUN,200);
	SetPlayerSkillLevel(playerid,WEAPONSKILL_SPAS12_SHOTGUN,200);
	SetPlayerSkillLevel(playerid,WEAPONSKILL_MICRO_UZI,200);
	SetPlayerSkillLevel(playerid,WEAPONSKILL_MP5,200);
	SetPlayerSkillLevel(playerid,WEAPONSKILL_AK47,200);
	SetPlayerSkillLevel(playerid,WEAPONSKILL_M4,200);
	SetPlayerSkillLevel(playerid,WEAPONSKILL_SNIPERRIFLE,200); */
	TextDrawShowForPlayer(playerid,txtTimeDisp);
	gettime(hour, minute);
	return true;
}

public OnPlayerDeath(playerid, killerid, reason)
{
	new playercash;
	gPlayerHasCitySelected[playerid] = 0;
	if(killerid == INVALID_PLAYER_ID) {
		SendDeathMessage(INVALID_PLAYER_ID,playerid,reason);
	} else {
		SendDeathMessage(killerid,playerid,reason);
		SetPlayerScore(killerid,GetPlayerScore(killerid)+1);
		playercash = GetPlayerMoney(playerid);
		GivePlayerMoney(killerid, playercash);
	}
	ResetPlayerMoney(playerid);
	if(God[playerid] == 1)
	{
		God[playerid] = 0;
		return true;
	}
	GameTextForPlayer(playerid,"~w~WASTED",6000,3);
	TextDrawHideForPlayer(playerid,txtTimeDisp);
	return true;
}

public OnVehicleSpawn(vehicleid)
{
	SetTimer("TuneCar", 1000, 0);
	return true;
}

public TuneCar()
{
	AddVehicleComponent(Uranus1,1092);
	AddVehicleComponent(Uranus1,1088);
	AddVehicleComponent(Uranus1,1090);
	AddVehicleComponent(Uranus1,1094);
	AddVehicleComponent(Uranus1,1166);
	AddVehicleComponent(Uranus1,1168);
	AddVehicleComponent(Uranus1,1163);
	AddVehicleComponent(Uranus1,1010);
	ChangeVehiclePaintjob(Uranus1,2);
	AddVehicleComponent(Elegy1,1034);
	AddVehicleComponent(Elegy1,1036);
	AddVehicleComponent(Elegy1,1038);
	AddVehicleComponent(Elegy1,1040);
	AddVehicleComponent(Elegy1,1146);
	AddVehicleComponent(Elegy1,1149);
	AddVehicleComponent(Elegy1,1171);
	AddVehicleComponent(Elegy1,1010);
	ChangeVehiclePaintjob(Elegy1,1);
	AddVehicleComponent(Sultan1,1026);
	AddVehicleComponent(Sultan1,1027);
	AddVehicleComponent(Sultan1,1028);
	AddVehicleComponent(Sultan1,1033);
	AddVehicleComponent(Sultan1,1139);
	AddVehicleComponent(Sultan1,1141);
	AddVehicleComponent(Sultan1,1169);
	AddVehicleComponent(Sultan1,1010);
	ChangeVehiclePaintjob(Sultan1,2);
	AddVehicleComponent(Flash1,1046);
	AddVehicleComponent(Flash1,1047);
	AddVehicleComponent(Flash1,1051);
	AddVehicleComponent(Flash1,1049);
	AddVehicleComponent(Flash1,1053);
	AddVehicleComponent(Flash1,1150);
	AddVehicleComponent(Flash1,1153);
	AddVehicleComponent(Flash1,1010);
	ChangeVehiclePaintjob(Flash1,2);
	AddVehicleComponent(Uranus2,1092);
	AddVehicleComponent(Uranus2,1088);
	AddVehicleComponent(Uranus2,1090);
	AddVehicleComponent(Uranus2,1094);
	AddVehicleComponent(Uranus2,1166);
	AddVehicleComponent(Uranus2,1168);
	AddVehicleComponent(Uranus2,1163);
	AddVehicleComponent(Uranus2,1010);
	ChangeVehiclePaintjob(Uranus2,2);
	AddVehicleComponent(Elegy2,1034);
	AddVehicleComponent(Elegy2,1036);
	AddVehicleComponent(Elegy2,1038);
	AddVehicleComponent(Elegy2,1040);
	AddVehicleComponent(Elegy2,1146);
	AddVehicleComponent(Elegy2,1149);
	AddVehicleComponent(Elegy2,1171);
	AddVehicleComponent(Elegy2,1010);
	ChangeVehiclePaintjob(Elegy2,1);
	AddVehicleComponent(Sultan2,1026);
	AddVehicleComponent(Sultan2,1027);
	AddVehicleComponent(Sultan2,1028);
	AddVehicleComponent(Sultan2,1033);
	AddVehicleComponent(Sultan2,1139);
	AddVehicleComponent(Sultan2,1141);
	AddVehicleComponent(Sultan2,1169);
	AddVehicleComponent(Sultan2,1010);
	ChangeVehiclePaintjob(Sultan2,2);
	return true;
}

public RandMessagesx()
{
	SendClientMessageToAll(COLOR_WHITE, RandMessages[random(sizeof(RandMessages))]);
	return true;
}

ClassSel_SetupCharSelection(playerid)
{
	if(gPlayerCitySelection[playerid] == CITY_LOS_SANTOS) {
		SetPlayerInterior(playerid,11);
		SetPlayerPos(playerid,508.7362,-87.4335,998.9609);
		SetPlayerFacingAngle(playerid,0.0);
		SetPlayerCameraPos(playerid,508.7362,-83.4335,998.9609);
		SetPlayerCameraLookAt(playerid,508.7362,-87.4335,998.9609);
	}
	else if(gPlayerCitySelection[playerid] == CITY_SAN_FIERRO) {
		SetPlayerInterior(playerid,3);
		SetPlayerPos(playerid,-2673.8381,1399.7424,918.3516);
		SetPlayerFacingAngle(playerid,181.0);
		SetPlayerCameraPos(playerid,-2673.2776,1394.3859,918.3516);
		SetPlayerCameraLookAt(playerid,-2673.8381,1399.7424,918.3516);
	}
	else if(gPlayerCitySelection[playerid] == CITY_LAS_VENTURAS) {
		SetPlayerInterior(playerid,3);
		SetPlayerPos(playerid,349.0453,193.2271,1014.1797);
		SetPlayerFacingAngle(playerid,286.25);
		SetPlayerCameraPos(playerid,352.9164,194.5702,1014.1875);
		SetPlayerCameraLookAt(playerid,349.0453,193.2271,1014.1797);
	}
}

ClassSel_InitCityNameText(Text:txtInit)
{
	TextDrawUseBox(txtInit, 0);
	TextDrawLetterSize(txtInit,1.25,3.0);
	TextDrawFont(txtInit, 0);
	TextDrawSetShadow(txtInit,0);
	TextDrawSetOutline(txtInit,1);
	TextDrawColor(txtInit,0xEEEEEEFF);
	TextDrawBackgroundColor(txtClassSelHelper,0x000000FF);
}

ClassSel_InitTextDraws()
{
	txtLosSantos = TextDrawCreate(10.0, 380.0, "Los Santos");
	ClassSel_InitCityNameText(txtLosSantos);
	txtSanFierro = TextDrawCreate(10.0, 380.0, "San Fierro");
	ClassSel_InitCityNameText(txtSanFierro);
	txtLasVenturas = TextDrawCreate(10.0, 380.0, "Las Venturas");
	ClassSel_InitCityNameText(txtLasVenturas);
	txtClassSelHelper = TextDrawCreate(10.0, 415.0,	" Press ~b~~k~~GO_LEFT~ ~w~or ~b~~k~~GO_RIGHT~ ~w~to switch cities.~n~ Press ~r~~k~~PED_FIREWEAPON~ ~w~to select.");
	TextDrawUseBox(txtClassSelHelper, 1);
	TextDrawBoxColor(txtClassSelHelper,0x222222BB);
	TextDrawLetterSize(txtClassSelHelper,0.3,1.0);
	TextDrawTextSize(txtClassSelHelper,400.0,40.0);
	TextDrawFont(txtClassSelHelper, 2);
	TextDrawSetShadow(txtClassSelHelper,0);
	TextDrawSetOutline(txtClassSelHelper,1);
	TextDrawBackgroundColor(txtClassSelHelper,0x000000FF);
	TextDrawColor(txtClassSelHelper,0xFFFFFFFF);
}

ClassSel_SetupSelectedCity(playerid)
{
	if(gPlayerCitySelection[playerid] == -1) {
		gPlayerCitySelection[playerid] = CITY_LOS_SANTOS;
	}
	if(gPlayerCitySelection[playerid] == CITY_LOS_SANTOS) {
		SetPlayerInterior(playerid,0);
		SetPlayerCameraPos(playerid,1630.6136,-2286.0298,110.0);
		SetPlayerCameraLookAt(playerid,1887.6034,-1682.1442,47.6167);
		TextDrawShowForPlayer(playerid,txtLosSantos);
		TextDrawHideForPlayer(playerid,txtSanFierro);
		TextDrawHideForPlayer(playerid,txtLasVenturas);
	}
	else if(gPlayerCitySelection[playerid] == CITY_SAN_FIERRO) {
		SetPlayerInterior(playerid,0);
		SetPlayerCameraPos(playerid,-1300.8754,68.0546,129.4823);
		SetPlayerCameraLookAt(playerid,-1817.9412,769.3878,132.6589);
		TextDrawHideForPlayer(playerid,txtLosSantos);
		TextDrawShowForPlayer(playerid,txtSanFierro);
		TextDrawHideForPlayer(playerid,txtLasVenturas);
	}
	else if(gPlayerCitySelection[playerid] == CITY_LAS_VENTURAS) {
		SetPlayerInterior(playerid,0);
		SetPlayerCameraPos(playerid,1310.6155,1675.9182,110.7390);
		SetPlayerCameraLookAt(playerid,2285.2944,1919.3756,68.2275);
		TextDrawHideForPlayer(playerid,txtLosSantos);
		TextDrawHideForPlayer(playerid,txtSanFierro);
		TextDrawShowForPlayer(playerid,txtLasVenturas);
	}
}

ClassSel_SwitchToNextCity(playerid)
{
	gPlayerCitySelection[playerid]++;
	if(gPlayerCitySelection[playerid] > CITY_LAS_VENTURAS) {
		gPlayerCitySelection[playerid] = CITY_LOS_SANTOS;
	}
	PlayerPlaySound(playerid,1052,0.0,0.0,0.0);
	gPlayerLastCitySelectionTick[playerid] = GetTickCount();
	ClassSel_SetupSelectedCity(playerid);
}

ClassSel_SwitchToPreviousCity(playerid)
{
	gPlayerCitySelection[playerid]--;
	if(gPlayerCitySelection[playerid] < CITY_LOS_SANTOS) {
		gPlayerCitySelection[playerid] = CITY_LAS_VENTURAS;
	}
	PlayerPlaySound(playerid,1053,0.0,0.0,0.0);
	gPlayerLastCitySelectionTick[playerid] = GetTickCount();
	ClassSel_SetupSelectedCity(playerid);
}

ClassSel_HandleCitySelection(playerid)
{
	new Keys,ud,lr;
	GetPlayerKeys(playerid,Keys,ud,lr);
	if(gPlayerCitySelection[playerid] == -1) {
		ClassSel_SwitchToNextCity(playerid);
		return;
	}
	if( (GetTickCount() - gPlayerLastCitySelectionTick[playerid]) < 500 ) return;
	if(Keys & KEY_FIRE) {
		gPlayerHasCitySelected[playerid] = 1;
		TextDrawHideForPlayer(playerid,txtClassSelHelper);
		TextDrawHideForPlayer(playerid,txtLosSantos);
		TextDrawHideForPlayer(playerid,txtSanFierro);
		TextDrawHideForPlayer(playerid,txtLasVenturas);
		TogglePlayerSpectating(playerid,0);
		return;
	}
	if(lr > 0) {
		ClassSel_SwitchToNextCity(playerid);
	}
	else if(lr < 0) {
		ClassSel_SwitchToPreviousCity(playerid);
	}
}

public OnPlayerRequestClass(playerid, classid)
{
	if(IsPlayerNPC(playerid)) return true;
	if(gPlayerHasCitySelected[playerid]) {
		ClassSel_SetupCharSelection(playerid);
		return true;
	} else {
		if(GetPlayerState(playerid) != PLAYER_STATE_SPECTATING) {
			TogglePlayerSpectating(playerid,1);
			TextDrawShowForPlayer(playerid, txtClassSelHelper);
			gPlayerCitySelection[playerid] = -1;
		}
	}
	switch(GetPlayerSkin(playerid))
	{
	case 0: GameTextForPlayer(playerid, "Carl 'CJ' Johnson", 2000, 4);
	case 1: GameTextForPlayer(playerid, "The Truth", 2000, 4);
	case 2: GameTextForPlayer(playerid, "Maccer", 2000, 4);
	case 3: GameTextForPlayer(playerid, "Andre", 2000, 4);
	case 4: GameTextForPlayer(playerid, "Barry 'Big Bear' Thorne (Thin)", 2000, 4);
	case 5: GameTextForPlayer(playerid, "Barry 'Big Bear' Thorne (Big)", 2000, 4);
	case 6: GameTextForPlayer(playerid, "Emmet", 2000, 4);
	case 7: GameTextForPlayer(playerid, "Taxi Driver/Train Driver", 2000, 4);
	case 8: GameTextForPlayer(playerid, "Janitor", 2000, 4);
	case 9: GameTextForPlayer(playerid, "Normal Ped", 2000, 4);
	case 10: GameTextForPlayer(playerid, "Old Woman", 2000, 4);
	case 11: GameTextForPlayer(playerid, "Casino Croupier", 2000, 4);
	case 12: GameTextForPlayer(playerid, "Rich Woman", 2000, 4);
	case 13: GameTextForPlayer(playerid, "Street Girl", 2000, 4);
	case 14: GameTextForPlayer(playerid, "Normal Ped", 2000, 4);
	case 15: GameTextForPlayer(playerid, "Mr.Whittaker (RS Haul Owner)", 2000, 4);
	case 16: GameTextForPlayer(playerid, "Airport Ground Worker", 2000, 4);
	case 17: GameTextForPlayer(playerid, "Businessman", 2000, 4);
	case 18: GameTextForPlayer(playerid, "Beach Visitor", 2000, 4);
	case 19: GameTextForPlayer(playerid, "DJ", 2000, 4);
	case 20: GameTextForPlayer(playerid, "Rich Guy (Madd Dogg's Manager", 2000, 4);
	case 21: GameTextForPlayer(playerid, "Normal Ped", 2000, 4);
	case 22: GameTextForPlayer(playerid, "Normal Ped", 2000, 4);
	case 23: GameTextForPlayer(playerid, "BMXer", 2000, 4);
	case 24: GameTextForPlayer(playerid, "Madd Dogg's Bodyguard", 2000, 4);
	case 25: GameTextForPlayer(playerid, "Madd Dogg's Bodyguard", 2000, 4);
	case 26: GameTextForPlayer(playerid, "Backpacker", 2000, 4);
	case 27: GameTextForPlayer(playerid, "Construction Work", 2000, 4);
	case 28: GameTextForPlayer(playerid, "Drug Dealer", 2000, 4);
	case 29: GameTextForPlayer(playerid, "Drug Dealer", 2000, 4);
	case 30: GameTextForPlayer(playerid, "Drug Dealer", 2000, 4);
	case 31: GameTextForPlayer(playerid, "Farm Town Inhabitant", 2000, 4);
	case 32: GameTextForPlayer(playerid, "Farm Town Inhabitant", 2000, 4);
	case 33: GameTextForPlayer(playerid, "Farm Town Inhabitant", 2000, 4);
	case 34: GameTextForPlayer(playerid, "Farm Town Inhabitant", 2000, 4);
	case 35: GameTextForPlayer(playerid, "Gardener", 2000, 4);
	case 36: GameTextForPlayer(playerid, "Golfer", 2000, 4);
	case 37: GameTextForPlayer(playerid, "Golfer", 2000, 4);
	case 38: GameTextForPlayer(playerid, "Normal Ped", 2000, 4);
	case 39: GameTextForPlayer(playerid, "Normal Ped", 2000, 4);
	case 40: GameTextForPlayer(playerid, "Normal Ped", 2000, 4);
	case 41: GameTextForPlayer(playerid, "Normal Ped", 2000, 4);
	case 42: GameTextForPlayer(playerid, "Jethro", 2000, 4);
	case 43: GameTextForPlayer(playerid, "Normal Ped", 2000, 4);
	case 44: GameTextForPlayer(playerid, "Normal Ped", 2000, 4);
	case 45: GameTextForPlayer(playerid, "Beach Visitor", 2000, 4);
	case 46: GameTextForPlayer(playerid, "Normal Ped", 2000, 4);
	case 47: GameTextForPlayer(playerid, "Normal Ped", 2000, 4);
	case 48: GameTextForPlayer(playerid, "Normal Ped", 2000, 4);
	case 49: GameTextForPlayer(playerid, "Snakehead (Da Nang)", 2000, 4);
	case 50: GameTextForPlayer(playerid, "Mechanic", 2000, 4);
	case 51: GameTextForPlayer(playerid, "Mountain Biker", 2000, 4);
	case 52: GameTextForPlayer(playerid, "Unknown", 2000, 4);
	case 53: GameTextForPlayer(playerid, "Street Girl", 2000, 4);
	case 54: GameTextForPlayer(playerid, "Normal Ped", 2000, 4);
	case 55: GameTextForPlayer(playerid, "Normal Ped", 2000, 4);
	case 56: GameTextForPlayer(playerid, "Normal Ped", 2000, 4);
	case 57: GameTextForPlayer(playerid, "Feds", 2000, 4);
	case 58: GameTextForPlayer(playerid, "Normal Ped", 2000, 4);
	case 59: GameTextForPlayer(playerid, "Normal Ped", 2000, 4);
	case 60: GameTextForPlayer(playerid, "Normal Ped", 2000, 4);
	case 61: GameTextForPlayer(playerid, "Pilot", 2000, 4);
	case 62: GameTextForPlayer(playerid, "Colonel Fuhrberger", 2000, 4);
	case 63: GameTextForPlayer(playerid, "Prostitute", 2000, 4);
	case 64: GameTextForPlayer(playerid, "Prostitute", 2000, 4);
	case 65: GameTextForPlayer(playerid, "Kendl Johnson", 2000, 4);
	case 66: GameTextForPlayer(playerid, "Pool Player", 2000, 4);
	case 67: GameTextForPlayer(playerid, "Pool Player", 2000, 4);
	case 68: GameTextForPlayer(playerid, "Priest/Preacher", 2000, 4);
	case 69: GameTextForPlayer(playerid, "Normal Ped", 2000, 4);
	case 70: GameTextForPlayer(playerid, "Scientist", 2000, 4);
	case 71: GameTextForPlayer(playerid, "Security Guard", 2000, 4);
	case 72: GameTextForPlayer(playerid, "Hippy", 2000, 4);
	case 73: GameTextForPlayer(playerid, "Hippy", 2000, 4);
	case 75: GameTextForPlayer(playerid, "Prostitute", 2000, 4);
	case 76: GameTextForPlayer(playerid, "Normal Ped", 2000, 4);
	case 77: GameTextForPlayer(playerid, "Homeless", 2000, 4);
	case 78: GameTextForPlayer(playerid, "Homeless", 2000, 4);
	case 79: GameTextForPlayer(playerid, "Homeless", 2000, 4);
	case 80: GameTextForPlayer(playerid, "Boxer", 2000, 4);
	case 81: GameTextForPlayer(playerid, "Boxer", 2000, 4);
	case 82: GameTextForPlayer(playerid, "Black Elvis", 2000, 4);
	case 83: GameTextForPlayer(playerid, "White Elvis", 2000, 4);
	case 84: GameTextForPlayer(playerid, "Blue Elvis", 2000, 4);
	case 85: GameTextForPlayer(playerid, "Prostitute", 2000, 4);
	case 86: GameTextForPlayer(playerid, "Ryder With Robbery Mask", 2000, 4);
	case 87: GameTextForPlayer(playerid, "Stripper", 2000, 4);
	case 88: GameTextForPlayer(playerid, "Normal Ped", 2000, 4);
	case 89: GameTextForPlayer(playerid, "Normal Ped", 2000, 4);
	case 90: GameTextForPlayer(playerid, "Jogger", 2000, 4);
	case 91: GameTextForPlayer(playerid, "Rich Woman", 2000, 4);
	case 92: GameTextForPlayer(playerid, "Rollerskater", 2000, 4);
	case 93: GameTextForPlayer(playerid, "Normal Ped", 2000, 4);
	case 94: GameTextForPlayer(playerid, "Normal Ped", 2000, 4);
	case 95: GameTextForPlayer(playerid, "Normal Ped", 2000, 4);
	case 96: GameTextForPlayer(playerid, "Jogger", 2000, 4);
	case 97: GameTextForPlayer(playerid, "Lifeguard", 2000, 4);
	case 98: GameTextForPlayer(playerid, "Normal Ped", 2000, 4);
	case 99: GameTextForPlayer(playerid, "Homeless", 2000, 4);
	case 100: GameTextForPlayer(playerid, "Biker", 2000, 4);
	case 101: GameTextForPlayer(playerid, "Normal Ped", 2000, 4);
	case 102: GameTextForPlayer(playerid, "Balla", 2000, 4);
	case 103: GameTextForPlayer(playerid, "Balla", 2000, 4);
	case 104: GameTextForPlayer(playerid, "Balla", 2000, 4);
	case 105: GameTextForPlayer(playerid, "Grove Street Families", 2000, 4);
	case 106: GameTextForPlayer(playerid, "Grove Street Families", 2000, 4);
	case 107: GameTextForPlayer(playerid, "Grove Street Families", 2000, 4);
	case 108: GameTextForPlayer(playerid, "Los Santos Vagos", 2000, 4);
	case 109: GameTextForPlayer(playerid, "Los Santos Vagos", 2000, 4);
	case 110: GameTextForPlayer(playerid, "Los Santos Vagos", 2000, 4);
	case 111: GameTextForPlayer(playerid, "The Russian Mafia", 2000, 4);
	case 112: GameTextForPlayer(playerid, "The Russian Mafia", 2000, 4);
	case 113: GameTextForPlayer(playerid, "The Russian Mafia", 2000, 4);
	case 114: GameTextForPlayer(playerid, "Varios Los Aztecas", 2000, 4);
	case 115: GameTextForPlayer(playerid, "Varios Los Aztecas", 2000, 4);
	case 116: GameTextForPlayer(playerid, "Varios Los Aztecas", 2000, 4);
	case 117: GameTextForPlayer(playerid, "Triad", 2000, 4);
	case 118: GameTextForPlayer(playerid, "Triad", 2000, 4);
	case 119: GameTextForPlayer(playerid, "Johhny Sindacco", 2000, 4);
	case 120: GameTextForPlayer(playerid, "Triad Boss", 2000, 4);
	case 121: GameTextForPlayer(playerid, "Da Nang Boy", 2000, 4);
	case 122: GameTextForPlayer(playerid, "Da Nang Boy", 2000, 4);
	case 123: GameTextForPlayer(playerid, "Da Nang Boy", 2000, 4);
	case 124: GameTextForPlayer(playerid, "Mafia", 2000, 4);
	case 125: GameTextForPlayer(playerid, "Mafia", 2000, 4);
	case 126: GameTextForPlayer(playerid, "Mafia", 2000, 4);
	case 127: GameTextForPlayer(playerid, "Mafia", 2000, 4);
	case 128: GameTextForPlayer(playerid, "Farm Inhabitant", 2000, 4);
	case 129: GameTextForPlayer(playerid, "Farm Inhabitant", 2000, 4);
	case 130: GameTextForPlayer(playerid, "Farm Inhabitant", 2000, 4);
	case 131: GameTextForPlayer(playerid, "Farm Inhabitant", 2000, 4);
	case 132: GameTextForPlayer(playerid, "Farm Inhabitant", 2000, 4);
	case 133: GameTextForPlayer(playerid, "Farm Inhabitant", 2000, 4);
	case 134: GameTextForPlayer(playerid, "Homeless", 2000, 4);
	case 135: GameTextForPlayer(playerid, "Homeless", 2000, 4);
	case 136: GameTextForPlayer(playerid, "Homeless", 2000, 4);
	case 137: GameTextForPlayer(playerid, "Homeless", 2000, 4);
	case 138: GameTextForPlayer(playerid, "Beach Visitor", 2000, 4);
	case 139: GameTextForPlayer(playerid, "Beach Visitor", 2000, 4);
	case 140: GameTextForPlayer(playerid, "Beach Visitor", 2000, 4);
	case 141: GameTextForPlayer(playerid, "Businesswoman", 2000, 4);
	case 142: GameTextForPlayer(playerid, "Taxi Driver", 2000, 4);
	case 143: GameTextForPlayer(playerid, "Crack Maker", 2000, 4);
	case 144: GameTextForPlayer(playerid, "Crack Maker", 2000, 4);
	case 145: GameTextForPlayer(playerid, "Crack Maker", 2000, 4);
	case 146: GameTextForPlayer(playerid, "Normal Ped", 2000, 4);
	case 147: GameTextForPlayer(playerid, "Businessman", 2000, 4);
	case 148: GameTextForPlayer(playerid, "Businesswoman", 2000, 4);
	case 149: GameTextForPlayer(playerid, "Big Smoke Armored", 2000, 4);
	case 150: GameTextForPlayer(playerid, "Businesswoman", 2000, 4);
	case 151: GameTextForPlayer(playerid, "Normal Ped", 2000, 4);
	case 152: GameTextForPlayer(playerid, "Prostitute", 2000, 4);
	case 153: GameTextForPlayer(playerid, "Construction Worker", 2000, 4);
	case 154: GameTextForPlayer(playerid, "Beach Visitor", 2000, 4);
	case 155: GameTextForPlayer(playerid, "Well Stacked Pizza Worker", 2000, 4);
	case 156: GameTextForPlayer(playerid, "Barber", 2000, 4);
	case 157: GameTextForPlayer(playerid, "Hillbilly", 2000, 4);
	case 158: GameTextForPlayer(playerid, "Farmer", 2000, 4);
	case 159: GameTextForPlayer(playerid, "Hillbilly", 2000, 4);
	case 160: GameTextForPlayer(playerid, "Hillbilly", 2000, 4);
	case 161: GameTextForPlayer(playerid, "Farmer", 2000, 4);
	case 162: GameTextForPlayer(playerid, "Hillbilly", 2000, 4);
	case 163: GameTextForPlayer(playerid, "Black Bouncer", 2000, 4);
	case 164: GameTextForPlayer(playerid, "White Bouncer", 2000, 4);
	case 165: GameTextForPlayer(playerid, "White MIB Agent", 2000, 4);
	case 166: GameTextForPlayer(playerid, "Black MIB Agent", 2000, 4);
	case 167: GameTextForPlayer(playerid, "Cluckin' Bell Worker", 2000, 4);
	case 168: GameTextForPlayer(playerid, "Hotdog/Chilli Dog Vendor", 2000, 4);
	case 169: GameTextForPlayer(playerid, "Normal Ped", 2000, 4);
	case 170: GameTextForPlayer(playerid, "Normal Ped", 2000, 4);
	case 171: GameTextForPlayer(playerid, "Blackjack Dealer", 2000, 4);
	case 172: GameTextForPlayer(playerid, "Casino Croupier", 2000, 4);
	case 173: GameTextForPlayer(playerid, "San Fierro Rifa", 2000, 4);
	case 174: GameTextForPlayer(playerid, "San Fierro Rifa", 2000, 4);
	case 175: GameTextForPlayer(playerid, "San Fierro Rifa", 2000, 4);
	case 176: GameTextForPlayer(playerid, "Barber", 2000, 4);
	case 177: GameTextForPlayer(playerid, "Barber", 2000, 4);
	case 178: GameTextForPlayer(playerid, "Whore", 2000, 4);
	case 179: GameTextForPlayer(playerid, "Ammunation Salesman", 2000, 4);
	case 180: GameTextForPlayer(playerid, "Tattoo Artist", 2000, 4);
	case 181: GameTextForPlayer(playerid, "Punk", 2000, 4);
	case 182: GameTextForPlayer(playerid, "Cab Driver", 2000, 4);
	case 183: GameTextForPlayer(playerid, "Normal Ped", 2000, 4);
	case 184: GameTextForPlayer(playerid, "Normal Ped", 2000, 4);
	case 185: GameTextForPlayer(playerid, "Normal Ped", 2000, 4);
	case 186: GameTextForPlayer(playerid, "Normal Ped", 2000, 4);
	case 187: GameTextForPlayer(playerid, "Businessman", 2000, 4);
	case 188: GameTextForPlayer(playerid, "Normal Ped", 2000, 4);
	case 189: GameTextForPlayer(playerid, "Valet", 2000, 4);
	case 190: GameTextForPlayer(playerid, "Barbara Schternvart", 2000, 4);
	case 191: GameTextForPlayer(playerid, "Helena Wankstein", 2000, 4);
	case 192: GameTextForPlayer(playerid, "Michelle Cannes", 2000, 4);
	case 193: GameTextForPlayer(playerid, "Katie Zhan", 2000, 4);
	case 194: GameTextForPlayer(playerid, "Millie Perkins", 2000, 4);
	case 195: GameTextForPlayer(playerid, "Denise Robinson", 2000, 4);
	case 196: GameTextForPlayer(playerid, "Farm Town Inhabitant", 2000, 4);
	case 197: GameTextForPlayer(playerid, "Hillbilly", 2000, 4);
	case 198: GameTextForPlayer(playerid, "Farm Town Inhabitant", 2000, 4);
	case 199: GameTextForPlayer(playerid, "Farm Town Inhabitant", 2000, 4);
	case 200: GameTextForPlayer(playerid, "Hillbilly", 2000, 4);
	case 201: GameTextForPlayer(playerid, "Farmer", 2000, 4);
	case 202: GameTextForPlayer(playerid, "Farmer", 2000, 4);
	case 203: GameTextForPlayer(playerid, "Karate Teacher", 2000, 4);
	case 204: GameTextForPlayer(playerid, "Karate Teacher", 2000, 4);
	case 205: GameTextForPlayer(playerid, "Burger Shot Cashier", 2000, 4);
	case 206: GameTextForPlayer(playerid, "Cab Driver", 2000, 4);
	case 207: GameTextForPlayer(playerid, "Prostitute", 2000, 4);
	case 208: GameTextForPlayer(playerid, "Su Xi Mu (Suzie)", 2000, 4);
	case 209: GameTextForPlayer(playerid, "Noodle Stand Vendor", 2000, 4);
	case 210: GameTextForPlayer(playerid, "Boater", 2000, 4);
	case 211: GameTextForPlayer(playerid, "Clothes Shop Staff", 2000, 4);
	case 212: GameTextForPlayer(playerid, "Homeless", 2000, 4);
	case 213: GameTextForPlayer(playerid, "Weird Old Man", 2000, 4);
	case 214: GameTextForPlayer(playerid, "Waitress (Maria Latore)", 2000, 4);
	case 215: GameTextForPlayer(playerid, "Normal Ped", 2000, 4);
	case 216: GameTextForPlayer(playerid, "Normal Ped", 2000, 4);
	case 217: GameTextForPlayer(playerid, "Clothes Shop Staff", 2000, 4);
	case 218: GameTextForPlayer(playerid, "Normal Ped", 2000, 4);
	case 219: GameTextForPlayer(playerid, "Rich Woman", 2000, 4);
	case 220: GameTextForPlayer(playerid, "Cab Driver", 2000, 4);
	case 221: GameTextForPlayer(playerid, "Normal Ped", 2000, 4);
	case 222: GameTextForPlayer(playerid, "Normal Ped", 2000, 4);
	case 223: GameTextForPlayer(playerid, "Normal Ped", 2000, 4);
	case 224: GameTextForPlayer(playerid, "Normal Ped", 2000, 4);
	case 225: GameTextForPlayer(playerid, "Hillbilly", 2000, 4);
	case 226: GameTextForPlayer(playerid, "Normal Ped", 2000, 4);
	case 227: GameTextForPlayer(playerid, "Businessman", 2000, 4);
	case 228: GameTextForPlayer(playerid, "Normal Ped", 2000, 4);
	case 229: GameTextForPlayer(playerid, "Normal Ped", 2000, 4);
	case 230: GameTextForPlayer(playerid, "Homeless", 2000, 4);
	case 231: GameTextForPlayer(playerid, "Normal Ped", 2000, 4);
	case 232: GameTextForPlayer(playerid, "Normal Ped", 2000, 4);
	case 233: GameTextForPlayer(playerid, "Normal Ped", 2000, 4);
	case 234: GameTextForPlayer(playerid, "Cab Driver", 2000, 4);
	case 235: GameTextForPlayer(playerid, "Normal Ped", 2000, 4);
	case 236: GameTextForPlayer(playerid, "Normal Ped", 2000, 4);
	case 237: GameTextForPlayer(playerid, "Prostitute", 2000, 4);
	case 238: GameTextForPlayer(playerid, "Prostitute", 2000, 4);
	case 239: GameTextForPlayer(playerid, "Homeless", 2000, 4);
	case 240: GameTextForPlayer(playerid, "The D.A", 2000, 4);
	case 241: GameTextForPlayer(playerid, "Afro American", 2000, 4);
	case 242: GameTextForPlayer(playerid, "Mexican", 2000, 4);
	case 243: GameTextForPlayer(playerid, "Prostitute", 2000, 4);
	case 244: GameTextForPlayer(playerid, "Stripper", 2000, 4);
	case 245: GameTextForPlayer(playerid, "Prostitute", 2000, 4);
	case 246: GameTextForPlayer(playerid, "Stripper", 2000, 4);
	case 247: GameTextForPlayer(playerid, "Biker", 2000, 4);
	case 248: GameTextForPlayer(playerid, "Biker", 2000, 4);
	case 249: GameTextForPlayer(playerid, "Pimp", 2000, 4);
	case 250: GameTextForPlayer(playerid, "Normal Ped", 2000, 4);
	case 251: GameTextForPlayer(playerid, "Lifeguard", 2000, 4);
	case 252: GameTextForPlayer(playerid, "Naked Valet", 2000, 4);
	case 253: GameTextForPlayer(playerid, "Bus Driver", 2000, 4);
	case 254: GameTextForPlayer(playerid, "Biker Drug Dealer", 2000, 4);
	case 255: GameTextForPlayer(playerid, "Chauffeur (Limo Driver)", 2000, 4);
	case 256: GameTextForPlayer(playerid, "Stripper", 2000, 4);
	case 257: GameTextForPlayer(playerid, "Stripper", 2000, 4);
	case 258: GameTextForPlayer(playerid, "Heckler", 2000, 4);
	case 259: GameTextForPlayer(playerid, "Heckler", 2000, 4);
	case 260: GameTextForPlayer(playerid, "Construction Worker", 2000, 4);
	case 261: GameTextForPlayer(playerid, "Cab Driver", 2000, 4);
	case 262: GameTextForPlayer(playerid, "Cab Driver", 2000, 4);
	case 263: GameTextForPlayer(playerid, "Normal Ped", 2000, 4);
	case 264: GameTextForPlayer(playerid, "Clown", 2000, 4);
	case 265: GameTextForPlayer(playerid, "Officer Frank Tenpenny (Corrupt Cop)", 2000, 4);
	case 266: GameTextForPlayer(playerid, "Officer Eddie Pulaski (Corrupt Cop)", 2000, 4);
	case 267: GameTextForPlayer(playerid, "Officer Jimmy Hernandez", 2000, 4);
	case 268: GameTextForPlayer(playerid, "Dwaine/Dwayne", 2000, 4);
	case 269: GameTextForPlayer(playerid, "Melvin 'Big Smoke' Harris", 2000, 4);
	case 270: GameTextForPlayer(playerid, "Sean 'Sweet' Johnson", 2000, 4);
	case 271: GameTextForPlayer(playerid, "Lance 'Ryder' Wilson", 2000, 4);
	case 272: GameTextForPlayer(playerid, "Mafia Boss", 2000, 4);
	case 273: GameTextForPlayer(playerid, "T-Bone Mendez", 2000, 4);
	case 274: GameTextForPlayer(playerid, "Paramedic (Emergency Medical Technician)", 2000, 4);
	case 275: GameTextForPlayer(playerid, "Paramedic (Emergency Medical Technician)", 2000, 4);
	case 276: GameTextForPlayer(playerid, "Paramedic (Emergency Medical Technician)", 2000, 4);
	case 277: GameTextForPlayer(playerid, "Firefighter", 2000, 4);
	case 278: GameTextForPlayer(playerid, "Firefighter", 2000, 4);
	case 279: GameTextForPlayer(playerid, "Firefighter", 2000, 4);
	case 280: GameTextForPlayer(playerid, "Los Santos Police Officer", 2000, 4);
	case 281: GameTextForPlayer(playerid, "San Fierro Police Officer", 2000, 4);
	case 282: GameTextForPlayer(playerid, "Las Venturas Police Officer", 2000, 4);
	case 283: GameTextForPlayer(playerid, "Country Sheriff", 2000, 4);
	case 284: GameTextForPlayer(playerid, "LSPD Motorbike Cop", 2000, 4);
	case 285: GameTextForPlayer(playerid, "S.W.A.T. Special Forces", 2000, 4);
	case 286: GameTextForPlayer(playerid, "Federal Agent", 2000, 4);
	case 287: GameTextForPlayer(playerid, "San Andreas Army", 2000, 4);
	case 288: GameTextForPlayer(playerid, "Desert Sheriff", 2000, 4);
	case 289: GameTextForPlayer(playerid, "Zero", 2000, 4);
	case 290: GameTextForPlayer(playerid, "Ken Rosenberg", 2000, 4);
	case 291: GameTextForPlayer(playerid, "Kent Paul", 2000, 4);
	case 292: GameTextForPlayer(playerid, "Cesar Vialpando", 2000, 4);
	case 293: GameTextForPlayer(playerid, "Jeffery 'OG Loc' Martin/Cross", 2000, 4);
	case 294: GameTextForPlayer(playerid, "Wu Zi Mu (Woozie)", 2000, 4);
	case 295: GameTextForPlayer(playerid, "Michael Toreno", 2000, 4);
	case 296: GameTextForPlayer(playerid, "Jizzy B", 2000, 4);
	case 297: GameTextForPlayer(playerid, "Madd Dogg", 2000, 4);
	case 298: GameTextForPlayer(playerid, "Catalina", 2000, 4);
	case 299: GameTextForPlayer(playerid, "Claude Speed", 2000, 4);
	}
	return 0;
}

public OnPlayerText(playerid, text[])
{
	new pText[144];
	format(pText, sizeof (pText), "(%d) %s", playerid, text);
	SendPlayerMessageToAll(playerid, pText);
	SetPlayerChatBubble(playerid, text, 0xAA3333AA, 80.0, 10000);
	return 0; // ignore the default text and send the custom one
}

public OnPlayerCommandText(playerid, cmdtext[])
{
	return true;
}

CMD:help(playerid)
{
	SendClientMessage(playerid,COLOR_DPT,"===== Помощь =====");
	SendClientMessage(playerid,COLOR_WHITE,"Введите /commands чтобы посмотреть список комманд");
	//SendClientMessage(playerid,COLOR_WHITE,"Введите /rules чтобы прочитать правила сервера");
	//SendClientMessage(playerid,COLOR_WHITE,"Введите /credits чтобы прочитать про авторов");
	return true;
}
CMD:commands(playerid)
{
	SendClientMessage(playerid,COLOR_DPT,"===== Страница 1/3 =====");
	SendClientMessage(playerid,COLOR_WHITE,"Введите /kill чтобы убить себя");
	SendClientMessage(playerid,COLOR_WHITE,"Введите /fix чтобы починить тачку");
	SendClientMessage(playerid,COLOR_WHITE,"Введите /flip чтобы перевернуть тачку");
	SendClientMessage(playerid,COLOR_WHITE,"Введите /para чтобы получить парашют");
	SendClientMessage(playerid,COLOR_WHITE,"Введите /jetpack чтобы получить джет-пак");
	SendClientMessage(playerid,COLOR_WHITE,"Введите /weapons чтобы получить оружия");
	SendClientMessage(playerid,COLOR_DPT,"===== След. страница: /commands2 =====");
	return true;
}
CMD:commands2(playerid)
{
	SendClientMessage(playerid,COLOR_DPT,"===== Страница 2/3 =====");
	SendClientMessage(playerid,COLOR_WHITE,"Введите /teleports чтобы посмотреть список телепортов по карте");
	SendClientMessage(playerid,COLOR_WHITE,"Введите /cars чтобы получить машины");
	SendClientMessage(playerid,COLOR_WHITE,"Введите /tcars чтобы получить тюнингованные машины");
	SendClientMessage(playerid,COLOR_WHITE,"Введите /fstyle чтобы изменить стиль боя");
	SendClientMessage(playerid,COLOR_WHITE,"Введите /colors чтобы сменить цвет ника");
	SendClientMessage(playerid,COLOR_WHITE,"Введите /killall чтобы убить всех (Только для Администраторов)");
	SendClientMessage(playerid,COLOR_DPT,"===== След. страница: /commands3 =====");
	return true;
}
CMD:commands3(playerid)
{
	SendClientMessage(playerid,COLOR_DPT,"===== Страница 3/3 =====");
	SendClientMessage(playerid,COLOR_WHITE,"Введите /soulsphere чтобы получить 200% здоровья");
	SendClientMessage(playerid,COLOR_WHITE,"Введите /megasphere чтобы получить 200% здоровья и 200% брони");
	SendClientMessage(playerid,COLOR_WHITE,"Введите /heal чтобы вылечится");
	SendClientMessage(playerid,COLOR_WHITE,"Введите /iddqd чтобы включить/выключить неуязвимость");
	SendClientMessage(playerid,COLOR_WHITE,"Введите /vehplate чтобы сменить номер на машине");
	SendClientMessage(playerid,COLOR_DPT,"===== Пред. страница: /commands2 =====");
	return true;
}
CMD:killall(playerid)
{
	if(IsPlayerAdmin(playerid)) for(new i=0; i<MAX_PLAYERS; i++) SetPlayerHealth(i,0);
	else SendClientMessage(playerid,COLOR_RED,"GameMode.Error: Вы не Администратор! Требуется RCON доступ.");
	return true;
}
CMD:iddqd(playerid)
{
	switch(God[playerid])
	{
	case 0:
		{
			SendClientMessage(playerid, COLOR_GREEN, "Вы включили неуязвимость.");
			God[playerid] = 1;
			SetPlayerArmour(playerid, 65535);
			SetPlayerHealth(playerid, 65535);
			return true;
		}
	case 1:
		{
			SendClientMessage(playerid, COLOR_RED, "Вы отключили неуязвимость.");
			SetPlayerHealth(playerid, 100);
			SetPlayerArmour(playerid, 100);
			God[playerid] = 0;
			return true;
		}
	}
	return true;
}
CMD:vehplate(playerid)
{
	new Float:x,Float:y,Float:z,Float:ang;
	GetVehiclePos(GetPlayerVehicleID(playerid),x,y,z);
	GetVehicleZAngle(GetPlayerVehicleID(playerid),ang);
	if(!IsPlayerInAnyVehicle(playerid)) return SendClientMessage(playerid,0xFFFFFFFF,"Вы должны быть в машине!");
	ShowPlayerDialog(playerid,0,DIALOG_STYLE_INPUT,"{EE7777}Vehicle Numberplate","{00CC66}Введи новый номер ниже.","ОК","Отменить");
	return true;
}
//Возможности
CMD:soulsphere(playerid)
{
	SetPlayerHealth(playerid,200);
	return true;
}
CMD:megasphere(playerid)
{
	SetPlayerHealth(playerid,200);
	SetPlayerArmour(playerid,200);
	return true;
}
CMD:heal(playerid)
{
	SetPlayerHealth(playerid,100);
	return true;
}
CMD:kill(playerid)
{
	new pName[MAX_PLAYER_NAME], string[39 + MAX_PLAYER_NAME];
	GetPlayerName(playerid, pName, sizeof(pName));
	format(string, sizeof(string), "%s [ID:%d] совершил самоубийство.", pName, playerid);
	SendClientMessageToAll(COLOR_RED, string);
	SetPlayerHealth(playerid,0);
	return true;
}
CMD:fix(playerid)
{
	if(!IsPlayerInAnyVehicle(playerid)) return SendClientMessage(playerid, COLOR_RED, "GameMode.Error: Вы должны быть в машине!");
	RepairVehicle(GetPlayerVehicleID(playerid));
	SendClientMessage(playerid, COLOR_YELLOW, "Ваша машина успешно отремонтирована.");
	return true;
}
CMD:para(playerid)
{
	GivePlayerWeapon(playerid, 46, 1);
	return true;
}
CMD:jetpack(playerid)
{
	SetPlayerSpecialAction(playerid, SPECIAL_ACTION_USEJETPACK);
	return true;
}
CMD:flip(playerid)
{
	if(!IsPlayerInAnyVehicle(playerid))
	{
		SendClientMessage(playerid, COLOR_RED,"GameMode.Error: Вы должны быть в машине!");
		return true;
	}
	new Float:PX, Float:PY, Float:PZ, Float:PA;
	GetPlayerPos(playerid, PX, PY, PZ);
	GetVehicleZAngle(GetPlayerVehicleID(playerid), PA);
	SetVehiclePos(GetPlayerVehicleID(playerid), PX, PY, PZ+1);
	SetVehicleZAngle(GetPlayerVehicleID(playerid), PA);
	SendClientMessage(playerid, COLOR_YELLOW, "Ваша машина успешно перевернута.");
	PlayerPlaySound(playerid, 1085, 0.0, 0.0, 0.0);
	return true;
}
CMD:fstyle(playerid)
{
	SendClientMessage(playerid,COLOR_DPT,"===== Стили боя =====");
	SendClientMessage(playerid,COLOR_WHITE,"=== /boxing (Бокс)");
	SendClientMessage(playerid,COLOR_WHITE,"=== /kungfu (Кунг-Фу)");
	SendClientMessage(playerid,COLOR_WHITE,"=== /kneehead (Knee Head)");
	SendClientMessage(playerid,COLOR_WHITE,"=== /grabkick (Grab Kick)");
	SendClientMessage(playerid,COLOR_WHITE,"=== /elbow (Elbow)");
	SendClientMessage(playerid,COLOR_WHITE,"=== /fsnormal (Вернуть обычное состояние)");
	return true;
}
CMD:boxing(playerid)
{
	SetPlayerFightingStyle (playerid, FIGHT_STYLE_BOXING);
	return true;
}
CMD:kungfu(playerid)
{
	SetPlayerFightingStyle (playerid, FIGHT_STYLE_KUNGFU);
	return true;
}
CMD:kneehead(playerid)
{
	SetPlayerFightingStyle (playerid, FIGHT_STYLE_KNEEHEAD);
	return true;
}
CMD:grabkick(playerid)
{
	SetPlayerFightingStyle (playerid, FIGHT_STYLE_GRABKICK);
	return true;
}
CMD:elbow(playerid)
{
	SetPlayerFightingStyle (playerid, FIGHT_STYLE_ELBOW);
	return true;
}
CMD:fsnormal(playerid)
{
	SetPlayerFightingStyle (playerid, FIGHT_STYLE_NORMAL);
	return true;
}
CMD:colors(playerid)
{
	SendClientMessage(playerid,COLOR_DPT,"===== Цвета ника =====");
	SendClientMessage(playerid,COLOR_WHITE,"=== /cgrey {AFAFAF}(Серый)");
	SendClientMessage(playerid,COLOR_WHITE,"=== /cgreen {33AA33}(Зеленый)");
	SendClientMessage(playerid,COLOR_WHITE,"=== /cred {AA3333}(Красный)");
	SendClientMessage(playerid,COLOR_WHITE,"=== /cyellow {FFFF00}(Желтый)");
	SendClientMessage(playerid,COLOR_WHITE,"=== /cwhite {FFFFFF}(Белый)");
	SendClientMessage(playerid,COLOR_WHITE,"=== /cblue {3A47DE}(Синий)");
	SendClientMessage(playerid,COLOR_WHITE,"=== /corange {FF9900}(Ораньжевый)");
	return true;
}
CMD:weapons(playerid)
{
	SendClientMessage(playerid,COLOR_DPT,"===== Страница 1/2 =====");
	SendClientMessage(playerid,COLOR_WHITE,"=== /wuzi (Micro Uzi)");
	SendClientMessage(playerid,COLOR_WHITE,"=== /wtec9 (Tec 9)");
	SendClientMessage(playerid,COLOR_WHITE,"=== /wcombat (Combat)");
	SendClientMessage(playerid,COLOR_WHITE,"=== /wsawnoff (Sawn Off)");
	SendClientMessage(playerid,COLOR_WHITE,"=== /wminigun (Minigun)");
	SendClientMessage(playerid,COLOR_WHITE,"=== /wrocket (Rocket Launcher)");
	SendClientMessage(playerid,COLOR_DPT,"===== След. страница: /weapons2 =====");
	return true;
}
CMD:weapons2(playerid)
{
	SendClientMessage(playerid,COLOR_DPT,"===== Страница 2/2 =====");
	SendClientMessage(playerid,COLOR_WHITE,"=== /wm4 (M4)");
	SendClientMessage(playerid,COLOR_WHITE,"=== /wgrenade (Grenade)");
	SendClientMessage(playerid,COLOR_WHITE,"=== /wsniper (Sniper Rifle)");
	SendClientMessage(playerid,COLOR_WHITE,"=== /propack (Пак оружия Профи)");
	SendClientMessage(playerid,COLOR_WHITE,"=== /noobpack (Нубоганы)");
	SendClientMessage(playerid,COLOR_WHITE,"=== /idkfa (Пак оружия для думера)");
	SendClientMessage(playerid,COLOR_DPT,"===== Пред. страница: /weapons =====");
	return true;
}
CMD:propack(playerid)
{
	ResetPlayerMoney(playerid);
	GivePlayerMoney(playerid, 10000);
	GivePlayerWeapon(playerid, 4, 1);
	GivePlayerWeapon(playerid, 24, 120);
	GivePlayerWeapon(playerid, 30, 350);
	GivePlayerWeapon(playerid, 34, 50);
	return true;
}
CMD:noobpack(playerid)
{
	ResetPlayerMoney(playerid);
	GivePlayerMoney(playerid, 99999999);
	GivePlayerWeapon(playerid, 4, 1);
	GivePlayerWeapon(playerid, 14, 10000);
	GivePlayerWeapon(playerid, 18, 10000);
	GivePlayerWeapon(playerid, 24, 10000);
	GivePlayerWeapon(playerid, 26, 10000);
	GivePlayerWeapon(playerid, 28, 10000);
	GivePlayerWeapon(playerid, 30, 10000);
	GivePlayerWeapon(playerid, 32, 10000);
	GivePlayerWeapon(playerid, 34, 10000);
	GivePlayerWeapon(playerid, 38, 10000);
	GivePlayerWeapon(playerid, 40, 10000);
	GivePlayerWeapon(playerid, 42, 10000);
	GivePlayerWeapon(playerid, 44, 10000);
	return true;
}
CMD:idkfa(playerid)
{
	ResetPlayerMoney(playerid);
	GivePlayerWeapon(playerid, 1, 1);
	GivePlayerWeapon(playerid, 9, 1);
	GivePlayerWeapon(playerid, 22, 400);
	GivePlayerWeapon(playerid, 25, 100);
	GivePlayerWeapon(playerid, 41, 600);
	GivePlayerWeapon(playerid, 43, 10000);
	return true;
}
CMD:spawn(playerid)
{
	SendClientMessage(playerid,COLOR_BLUE,"Вы были телепортированы на спавн.");
	SpawnPlayer(playerid);
	return true;
}
CMD:cgrey(playerid)
{
	SetPlayerColor(playerid,COLOR_GREY);
	return true;
}
CMD:cgreen(playerid)
{
	SetPlayerColor(playerid,COLOR_GREEN);
	return true;
}
CMD:cred(playerid)
{
	SetPlayerColor(playerid,COLOR_RED);
	return true;
}
CMD:cyellow(playerid)
{
	SetPlayerColor(playerid,COLOR_YELLOW);
	return true;
}
CMD:cwhite(playerid)
{
	SetPlayerColor(playerid,COLOR_WHITE);
	return true;
}
CMD:cblue(playerid)
{
	SetPlayerColor(playerid,COLOR_BLUE);
	return true;
}
CMD:corange(playerid)
{
	SetPlayerColor(playerid,COLOR_ORANGE);
	return true;
}
CMD:wuzi(playerid)
{
	GivePlayerWeapon(playerid,28,100000);
	return true;
}
CMD:wtec9(playerid)
{
	GivePlayerWeapon(playerid,32,100000);
	return true;
}
CMD:wcombat(playerid)
{
	GivePlayerWeapon(playerid,27,100000);
	return true;
}
CMD:wsawnoff(playerid)
{
	GivePlayerWeapon(playerid,26,100000);
	return true;
}
CMD:wminigun(playerid)
{
	GivePlayerWeapon(playerid,38,100000);
	return true;
}
CMD:wrocket(playerid)
{
	GivePlayerWeapon(playerid,35,100000);
	return true;
}
CMD:wm4(playerid)
{
	GivePlayerWeapon(playerid,31,100000);
	return true;
}
CMD:wgrenade(playerid)
{
	GivePlayerWeapon(playerid,16,100000);
	return true;
}
CMD:wsniper(playerid)
{
	GivePlayerWeapon(playerid,34,100000);
	return true;
}
//Спавн Тачек
CMD:cars(playerid)
{
	SendClientMessage(playerid,COLOR_DPT,"===== Страница 1/2 =====");
	SendClientMessage(playerid,COLOR_WHITE,"=== /huntley /landstalker /perrenial /rancher /rancher2 /regina /banshee /bullet /zr350 /benson /dumper ");
	SendClientMessage(playerid,COLOR_WHITE,"=== /romero /solair /alpha /blista /bravura /buccaneer /cadrona /cheetah /comet /turismo /windsor /dozer ");
	SendClientMessage(playerid,COLOR_WHITE,"=== /club /esperanto /feltzer /fortune /hermes /hustler /majestic /hotknife /infernus /supergt /mesa ");
	SendClientMessage(playerid,COLOR_WHITE,"=== /manana /picador /previon /stafford /stallion /tampa /virgo /hotring /hotringa /hotringb /dft30 ");
	SendClientMessage(playerid,COLOR_WHITE,"=== /admiral /elegant /emperor /euros /glendale /glendale2 /greenwood /boxville /boxville2 /cementtruck ");
	SendClientMessage(playerid,COLOR_WHITE,"=== /intruder /merit /nebula /oceanic /premier /primo /sentinel /stretch /dune /flatbed /hotdog /linerunner ");
	SendClientMessage(playerid,COLOR_DPT,"===== След. страница: /cars2 =====");
	return true;
}
CMD:cars2(playerid)
{
	SendClientMessage(playerid,COLOR_DPT,"===== Страница 2/2 =====");
	SendClientMessage(playerid,COLOR_WHITE,"=== /sunrise /tahoma /vincent /washington /willard /buffalo /clover /mrwoopee /mule /packer /roadtrain ");
	SendClientMessage(playerid,COLOR_WHITE,"=== /phoenix /sabre /elegy /flash /jester /stratum /sultan /uranus /tanker /tractor /yankee /topfun ");
	SendClientMessage(playerid,COLOR_WHITE,"=== /bobcat /burrito /forklift /moonbeam /mower /newsvan /pony /rumpo /sadler /sadler2 /tug /walton ");
	SendClientMessage(playerid,COLOR_WHITE,"=== /blade /broadway /remington /savanna /slamvan /tornado /voodoo /yosemite /linerunner  /combine ");
	SendClientMessage(playerid,COLOR_WHITE,"=== /other /bikes /public /security /aircrafts /boats /rccars ");
	SendClientMessage(playerid,COLOR_DPT,"===== Пред. страница: /cars =====");
	return true;
}
CMD:other(playerid)
{
	SendClientMessage(playerid,COLOR_DPT,"===== Другие =====");
	SendClientMessage(playerid,COLOR_WHITE,"=== /bandito /bfinjection /bloodringbanger /caddy /camper /journey /kart /monster /monstera /monsterb ");
	SendClientMessage(playerid,COLOR_WHITE,"=== /quad /sandking /vortex ");
	return true;
}
CMD:bikes(playerid)
{
	SendClientMessage(playerid,COLOR_DPT,"===== Мотоциклы =====");
	SendClientMessage(playerid,COLOR_WHITE,"=== /bmx /bike /mountainbike /bf400 /faggio /fcr900 /freeway /nrg500 /pcj600 /pizzaboy /sanchez /wayfarer ");
	return true;
}
CMD:public(playerid)
{
	SendClientMessage(playerid,COLOR_DPT,"===== Публичные =====");
	SendClientMessage(playerid,COLOR_WHITE,"=== /baggage /bus /ambulance /cabbie /coach /sweeper /taxi /towtruck /trashmaster /utilityvan ");
	return true;
}
CMD:security(playerid)
{
	SendClientMessage(playerid,COLOR_DPT,"*===== Охрана =====");
	SendClientMessage(playerid,COLOR_WHITE,"=== /barracks /enforcer /fbirancher /fbitruck /firetruck /firetrucka /hpv1000 /patriot /rhino ");
	SendClientMessage(playerid,COLOR_WHITE,"=== /policels /policesf /policelv /policeranger /securicar /swattank ");
	return true;
}
CMD:aircrafts(playerid)
{
	SendClientMessage(playerid,COLOR_DPT,"*===== Авиа =====");
	SendClientMessage(playerid,COLOR_WHITE,"=== /andromada /at400 /beagle /cargobob /cropduster /dodo /hunter /leviathon /maverick /nevada /hydra ");
	SendClientMessage(playerid,COLOR_WHITE,"=== /newsmaverick /policemaverick /raindance /rustler /seasparrow /shamal /skimmer /sparrow /stuntplane ");
	return true;
}
CMD:boats(playerid)
{
	SendClientMessage(playerid,COLOR_DPT,"*===== Лодки =====");
	SendClientMessage(playerid,COLOR_WHITE,"=== /coastguard /dingy /jetmax /launch /marquis /predator /reefer /speeder /squallo /tropic ");
	return true;
}
CMD:rccars(playerid)
{
	SendClientMessage(playerid,COLOR_DPT,"*===== Радио-управляемые =====");
	SendClientMessage(playerid,COLOR_WHITE,"=== /rcbandit /rcbaron /rccam /rcgoblin /rcgoblin2 /rctiger ");
	return true;
}
CMD:huntley(playerid)
{
	new Float:X;
	new Float:Y;
	new Float:Z;
	GetPlayerPos(playerid,X,Y,Z);
	GameTextForPlayer(playerid,"~h~~w~HUNTLEY~n~~h~~w~ID:~h~~r~579",2500,1);
	CreateVehicle(579,X,Y+5,Z,1,1,1,90000);
	return true;
}
CMD:landstalker(playerid)
{
	new Float:X;
	new Float:Y;
	new Float:Z;
	GetPlayerPos(playerid,X,Y,Z);
	GameTextForPlayer(playerid,"~h~~w~LANDSTALKER~n~~h~~w~ID:~h~~r~400",2500,1);
	CreateVehicle(400,X,Y+5,Z,1,1,1,90000);
	return true;
}
CMD:perrenial(playerid)
{
	new Float:X;
	new Float:Y;
	new Float:Z;
	GetPlayerPos(playerid,X,Y,Z);
	GameTextForPlayer(playerid,"~h~~w~PERRENIAL~n~~h~~w~ID:~h~~r~404",2500,1);
	CreateVehicle(404,X,Y+5,Z,1,1,1,90000);
	return true;
}
CMD:rancher(playerid)
{
	new Float:X;
	new Float:Y;
	new Float:Z;
	GetPlayerPos(playerid,X,Y,Z);
	GameTextForPlayer(playerid,"~h~~w~RANCHER~n~~h~~w~ID:~h~~r~489",2500,1);
	CreateVehicle(489,X,Y+5,Z,1,1,1,90000);
	return true;
}
CMD:rancher2(playerid)
{
	new Float:X;
	new Float:Y;
	new Float:Z;
	GetPlayerPos(playerid,X,Y,Z);
	GameTextForPlayer(playerid,"~h~~w~ANOTHER RANCHER~n~~h~~w~ID:~h~~r~505",2500,1);
	CreateVehicle(505,X,Y+5,Z,1,1,1,90000);
	return true;
}
CMD:regina(playerid)
{
	new Float:X;
	new Float:Y;
	new Float:Z;
	GetPlayerPos(playerid,X,Y,Z);
	GameTextForPlayer(playerid,"~h~~w~REGINA~n~~h~~w~ID:~h~~r~479",2500,1);
	CreateVehicle(479,X,Y+5,Z,1,1,1,90000);
	return true;
}
CMD:romero(playerid)
{
	new Float:X;
	new Float:Y;
	new Float:Z;
	GetPlayerPos(playerid,X,Y,Z);
	GameTextForPlayer(playerid,"~h~~w~ROMERO~n~~h~~w~ID:~h~~r~442",2500,1);
	CreateVehicle(442,X,Y+5,Z,1,1,1,90000);
	return true;
}
CMD:solair(playerid)
{
	new Float:X;
	new Float:Y;
	new Float:Z;
	GetPlayerPos(playerid,X,Y,Z);
	GameTextForPlayer(playerid,"~h~~w~SOLAIR~n~~h~~w~ID:~h~~r~458",2500,1);
	CreateVehicle(458,X,Y+5,Z,1,1,1,90000);
	return true;
}
CMD:alpha(playerid)
{
	new Float:X;
	new Float:Y;
	new Float:Z;
	GetPlayerPos(playerid,X,Y,Z);
	GameTextForPlayer(playerid,"~h~~w~ALPHA~n~~h~~w~ID:~h~~r~602",2500,1);
	CreateVehicle(602,X,Y+5,Z,1,1,1,90000);
	return true;
}
CMD:blista(playerid)
{
	new Float:X;
	new Float:Y;
	new Float:Z;
	GetPlayerPos(playerid,X,Y,Z);
	GameTextForPlayer(playerid,"~h~~w~BLISTA COMPACT~n~~h~~w~ID:~h~~r~496",2500,1);
	CreateVehicle(496,X,Y+5,Z,1,1,1,90000);
	return true;
}
CMD:bravura(playerid)
{
	new Float:X;
	new Float:Y;
	new Float:Z;
	GetPlayerPos(playerid,X,Y,Z);
	GameTextForPlayer(playerid,"~h~~w~BRAVURA~n~~h~~w~ID:~h~~r~401",2500,1);
	CreateVehicle(401,X,Y+5,Z,1,1,1,90000);
	return true;
}
CMD:buccaneer(playerid)
{
	new Float:X;
	new Float:Y;
	new Float:Z;
	GetPlayerPos(playerid,X,Y,Z);
	GameTextForPlayer(playerid,"~h~~w~BUCCANEER~n~~h~~w~ID:~h~~r~518",2500,1);
	CreateVehicle(518,X,Y+5,Z,1,1,1,90000);
	return true;
}
CMD:cadrona(playerid)
{
	new Float:X;
	new Float:Y;
	new Float:Z;
	GetPlayerPos(playerid,X,Y,Z);
	GameTextForPlayer(playerid,"~h~~w~CADRONA~n~~h~~w~ID:~h~~r~527",2500,1);
	CreateVehicle(527,X,Y+5,Z,1,1,1,90000);
	return true;
}
CMD:club(playerid)
{
	new Float:X;
	new Float:Y;
	new Float:Z;
	GetPlayerPos(playerid,X,Y,Z);
	GameTextForPlayer(playerid,"~h~~w~CLUB~n~~h~~w~ID:~h~~r~589",2500,1);
	CreateVehicle(589,X,Y+5,Z,1,1,1,90000);
	return true;
}
CMD:esperanto(playerid)
{
	new Float:X;
	new Float:Y;
	new Float:Z;
	GetPlayerPos(playerid,X,Y,Z);
	GameTextForPlayer(playerid,"~h~~w~ESPERANTO~n~~h~~w~ID:~h~~r~419",2500,1);
	CreateVehicle(419,X,Y+5,Z,1,1,1,90000);
	return true;
}
CMD:feltzer(playerid)
{
	new Float:X;
	new Float:Y;
	new Float:Z;
	GetPlayerPos(playerid,X,Y,Z);
	GameTextForPlayer(playerid,"~h~~w~FELTZER~n~~h~~w~ID:~h~~r~533",2500,1);
	CreateVehicle(533,X,Y+5,Z,1,1,1,90000);
	return true;
}
CMD:fortune(playerid)
{
	new Float:X;
	new Float:Y;
	new Float:Z;
	GetPlayerPos(playerid,X,Y,Z);
	GameTextForPlayer(playerid,"~h~~w~FORTUNE~n~~h~~w~ID:~h~~r~526",2500,1);
	CreateVehicle(526,X,Y+5,Z,1,1,1,90000);
	return true;
}
CMD:hermes(playerid)
{
	new Float:X;
	new Float:Y;
	new Float:Z;
	GetPlayerPos(playerid,X,Y,Z);
	GameTextForPlayer(playerid,"~h~~w~HERMES~n~~h~~w~ID:~h~~r~474",2500,1);
	CreateVehicle(474,X,Y+5,Z,1,1,1,90000);
	return true;
}
CMD:hustler(playerid)
{
	new Float:X;
	new Float:Y;
	new Float:Z;
	GetPlayerPos(playerid,X,Y,Z);
	GameTextForPlayer(playerid,"~h~~w~HUSTLER~n~~h~~w~ID:~h~~r~545",2500,1);
	CreateVehicle(545,X,Y+5,Z,1,1,1,90000);
	return true;
}
CMD:majestic(playerid)
{
	new Float:X;
	new Float:Y;
	new Float:Z;
	GetPlayerPos(playerid,X,Y,Z);
	GameTextForPlayer(playerid,"~h~~w~MAJESTIC~n~~h~~w~ID:~h~~r~517",2500,1);
	CreateVehicle(517,X,Y+5,Z,1,1,1,90000);
	return true;
}
CMD:manana(playerid)
{
	new Float:X;
	new Float:Y;
	new Float:Z;
	GetPlayerPos(playerid,X,Y,Z);
	GameTextForPlayer(playerid,"~h~~w~MANANA~n~~h~~w~ID:~h~~r~410",2500,1);
	CreateVehicle(410,X,Y+5,Z,1,1,1,90000);
	return true;
}
CMD:picador(playerid)
{
	new Float:X;
	new Float:Y;
	new Float:Z;
	GetPlayerPos(playerid,X,Y,Z);
	GameTextForPlayer(playerid,"~h~~w~PICADOR~n~~h~~w~ID:~h~~r~600",2500,1);
	CreateVehicle(600,X,Y+5,Z,1,1,1,90000);
	return true;
}
CMD:previon(playerid)
{
	new Float:X;
	new Float:Y;
	new Float:Z;
	GetPlayerPos(playerid,X,Y,Z);
	GameTextForPlayer(playerid,"~h~~w~PREVION~n~~h~~w~ID:~h~~r~436",2500,1);
	CreateVehicle(436,X,Y+5,Z,1,1,1,90000);
	return true;
}
CMD:stafford(playerid)
{
	new Float:X;
	new Float:Y;
	new Float:Z;
	GetPlayerPos(playerid,X,Y,Z);
	GameTextForPlayer(playerid,"~h~~w~STAFFORD~n~~h~~w~ID:~h~~r~580",2500,1);
	CreateVehicle(580,X,Y+5,Z,1,1,1,90000);
	return true;
}
CMD:stallion(playerid)
{
	new Float:X;
	new Float:Y;
	new Float:Z;
	GetPlayerPos(playerid,X,Y,Z);
	GameTextForPlayer(playerid,"~h~~w~STALLION~n~~h~~w~ID:~h~~r~439",2500,1);
	CreateVehicle(439,X,Y+5,Z,1,1,1,90000);
	return true;
}
CMD:tampa(playerid)
{
	new Float:X;
	new Float:Y;
	new Float:Z;
	GetPlayerPos(playerid,X,Y,Z);
	GameTextForPlayer(playerid,"~h~~w~TAMPA~n~~h~~w~ID:~h~~r~549",2500,1);
	CreateVehicle(549,X,Y+5,Z,1,1,1,90000);
	return true;
}
CMD:virgo(playerid)
{
	new Float:X;
	new Float:Y;
	new Float:Z;
	GetPlayerPos(playerid,X,Y,Z);
	GameTextForPlayer(playerid,"~h~~w~VIRGO~n~~h~~w~ID:~h~~r~491",2500,1);
	CreateVehicle(491,X,Y+5,Z,1,1,1,90000);
	return true;
}
CMD:admiral(playerid)
{
	new Float:X;
	new Float:Y;
	new Float:Z;
	GetPlayerPos(playerid,X,Y,Z);
	GameTextForPlayer(playerid,"~h~~w~ADMIRAL~n~~h~~w~ID:~h~~r~445",2500,1);
	CreateVehicle(445,X,Y+5,Z,1,1,1,90000);
	return true;
}
CMD:elegant(playerid)
{
	new Float:X;
	new Float:Y;
	new Float:Z;
	GetPlayerPos(playerid,X,Y,Z);
	GameTextForPlayer(playerid,"~h~~w~ELEGANT~n~~h~~w~ID:~h~~r~507",2500,1);
	CreateVehicle(507,X,Y+5,Z,1,1,1,90000);
	return true;
}
CMD:emperor(playerid)
{
	new Float:X;
	new Float:Y;
	new Float:Z;
	GetPlayerPos(playerid,X,Y,Z);
	GameTextForPlayer(playerid,"~h~~w~EMPEROR~n~~h~~w~ID:~h~~r~585",2500,1);
	CreateVehicle(585,X,Y+5,Z,1,1,1,90000);
	return true;
}
CMD:euros(playerid)
{
	new Float:X;
	new Float:Y;
	new Float:Z;
	GetPlayerPos(playerid,X,Y,Z);
	GameTextForPlayer(playerid,"~h~~w~EUROS~n~~h~~w~ID:~h~~r~587",2500,1);
	CreateVehicle(587,X,Y+5,Z,1,1,1,90000);
	return true;
}
CMD:glendale(playerid)
{
	new Float:X;
	new Float:Y;
	new Float:Z;
	GetPlayerPos(playerid,X,Y,Z);
	GameTextForPlayer(playerid,"~h~~w~GLENDALE~n~~h~~w~ID:~h~~r~466",2500,1);
	CreateVehicle(466,X,Y+5,Z,1,1,1,90000);
	return true;
}
CMD:greenwood(playerid)
{
	new Float:X;
	new Float:Y;
	new Float:Z;
	GetPlayerPos(playerid,X,Y,Z);
	GameTextForPlayer(playerid,"~h~~w~GREENWOOD~n~~h~~w~ID:~h~~r~492",2500,1);
	CreateVehicle(492,X,Y+5,Z,1,1,1,90000);
	return true;
}
CMD:intruder(playerid)
{
	new Float:X;
	new Float:Y;
	new Float:Z;
	GetPlayerPos(playerid,X,Y,Z);
	GameTextForPlayer(playerid,"~h~~w~INTRUDER~n~~h~~w~ID:~h~~r~546",2500,1);
	CreateVehicle(546,X,Y+5,Z,1,1,1,90000);
	return true;
}
CMD:merit(playerid)
{
	new Float:X;
	new Float:Y;
	new Float:Z;
	GetPlayerPos(playerid,X,Y,Z);
	GameTextForPlayer(playerid,"~h~~w~MERIT~n~~h~~w~ID:~h~~r~551",2500,1);
	CreateVehicle(551,X,Y+5,Z,1,1,1,90000);
	return true;
}
CMD:nebula(playerid)
{
	new Float:X;
	new Float:Y;
	new Float:Z;
	GetPlayerPos(playerid,X,Y,Z);
	GameTextForPlayer(playerid,"~h~~w~NEBULA~n~~h~~w~ID:~h~~r~516",2500,1);
	CreateVehicle(516,X,Y+5,Z,1,1,1,90000);
	return true;
}
CMD:oceanic(playerid)
{
	new Float:X;
	new Float:Y;
	new Float:Z;
	GetPlayerPos(playerid,X,Y,Z);
	GameTextForPlayer(playerid,"~h~~w~OCEANIC~n~~h~~w~ID:~h~~r~467",2500,1);
	CreateVehicle(467,X,Y+5,Z,1,1,1,90000);
	return true;
}
CMD:premier(playerid)
{
	new Float:X;
	new Float:Y;
	new Float:Z;
	GetPlayerPos(playerid,X,Y,Z);
	GameTextForPlayer(playerid,"~h~~w~PREMIER~n~~h~~w~ID:~h~~r~426",2500,1);
	CreateVehicle(426,X,Y+5,Z,1,1,1,90000);
	return true;
}
CMD:primo(playerid)
{
	new Float:X;
	new Float:Y;
	new Float:Z;
	GetPlayerPos(playerid,X,Y,Z);
	GameTextForPlayer(playerid,"~h~~w~PRIMO~n~~h~~w~ID:~h~~r~547",2500,1);
	CreateVehicle(547,X,Y+5,Z,1,1,1,90000);
	return true;
}
CMD:sentinel(playerid)
{
	new Float:X;
	new Float:Y;
	new Float:Z;
	GetPlayerPos(playerid,X,Y,Z);
	GameTextForPlayer(playerid,"~h~~w~SENTINEL~n~~h~~w~ID:~h~~r~405",2500,1);
	CreateVehicle(405,X,Y+5,Z,1,1,1,90000);
	return true;
}
CMD:stretch(playerid)
{
	new Float:X;
	new Float:Y;
	new Float:Z;
	GetPlayerPos(playerid,X,Y,Z);
	GameTextForPlayer(playerid,"~h~~w~STRETCH~n~~h~~w~ID:~h~~r~409",2500,1);
	CreateVehicle(409,X,Y+5,Z,1,1,1,90000);
	return true;
}
CMD:sunrise(playerid)
{
	new Float:X;
	new Float:Y;
	new Float:Z;
	GetPlayerPos(playerid,X,Y,Z);
	GameTextForPlayer(playerid,"~h~~w~SUNRISE~n~~h~~w~ID:~h~~r~550",2500,1);
	CreateVehicle(550,X,Y+5,Z,1,1,1,90000);
	return true;
}
CMD:tahoma(playerid)
{
	new Float:X;
	new Float:Y;
	new Float:Z;
	GetPlayerPos(playerid,X,Y,Z);
	GameTextForPlayer(playerid,"~h~~w~TAHOMA~n~~h~~w~ID:~h~~r~566",2500,1);
	CreateVehicle(566,X,Y+5,Z,1,1,1,90000);
	return true;
}
CMD:vincent(playerid)
{
	new Float:X;
	new Float:Y;
	new Float:Z;
	GetPlayerPos(playerid,X,Y,Z);
	GameTextForPlayer(playerid,"~h~~w~VINCENT~n~~h~~w~ID:~h~~r~540",2500,1);
	CreateVehicle(540,X,Y+5,Z,1,1,1,90000);
	return true;
}
CMD:washington(playerid)
{
	new Float:X;
	new Float:Y;
	new Float:Z;
	GetPlayerPos(playerid,X,Y,Z);
	GameTextForPlayer(playerid,"~h~~w~WASHINGTON~n~~h~~w~ID:~h~~r~421",2500,1);
	CreateVehicle(421,X,Y+5,Z,1,1,1,90000);
	return true;
}
CMD:willard(playerid)
{
	new Float:X;
	new Float:Y;
	new Float:Z;
	GetPlayerPos(playerid,X,Y,Z);
	GameTextForPlayer(playerid,"~h~~w~WILLARD~n~~h~~w~ID:~h~~r~529",2500,1);
	CreateVehicle(529,X,Y+5,Z,1,1,1,90000);
	return true;
}
CMD:buffalo(playerid)
{
	new Float:X;
	new Float:Y;
	new Float:Z;
	GetPlayerPos(playerid,X,Y,Z);
	GameTextForPlayer(playerid,"~h~~w~BUFFALO~n~~h~~w~ID:~h~~r~402",2500,1);
	CreateVehicle(402,X,Y+5,Z,1,1,1,90000);
	return true;
}
CMD:clover(playerid)
{
	new Float:X;
	new Float:Y;
	new Float:Z;
	GetPlayerPos(playerid,X,Y,Z);
	GameTextForPlayer(playerid,"~h~~w~CLOVER~n~~h~~w~ID:~h~~r~542",2500,1);
	CreateVehicle(542,X,Y+5,Z,1,1,1,90000);
	return true;
}
CMD:phoenix(playerid)
{
	new Float:X;
	new Float:Y;
	new Float:Z;
	GetPlayerPos(playerid,X,Y,Z);
	GameTextForPlayer(playerid,"~h~~w~PHOENIX~n~~h~~w~ID:~h~~r~603",2500,1);
	CreateVehicle(603,X,Y+5,Z,1,1,1,90000);
	return true;
}
CMD:sabre(playerid)
{
	new Float:X;
	new Float:Y;
	new Float:Z;
	GetPlayerPos(playerid,X,Y,Z);
	GameTextForPlayer(playerid,"~h~~w~SABRE~n~~h~~w~ID:~h~~r~475",2500,1);
	CreateVehicle(475,X,Y+5,Z,1,1,1,90000);
	return true;
}
CMD:elegy(playerid)
{
	new Float:X;
	new Float:Y;
	new Float:Z;
	GetPlayerPos(playerid,X,Y,Z);
	GameTextForPlayer(playerid,"~h~~w~ELEGY~n~~h~~w~ID:~h~~r~562",2500,1);
	CreateVehicle(562,X,Y+5,Z,1,1,1,90000);
	return true;
}
CMD:flash(playerid)
{
	new Float:X;
	new Float:Y;
	new Float:Z;
	GetPlayerPos(playerid,X,Y,Z);
	GameTextForPlayer(playerid,"~h~~w~FLASH~n~~h~~w~ID:~h~~r~565",2500,1);
	CreateVehicle(565,X,Y+5,Z,1,1,1,90000);
	return true;
}
CMD:jester(playerid)
{
	new Float:X;
	new Float:Y;
	new Float:Z;
	GetPlayerPos(playerid,X,Y,Z);
	GameTextForPlayer(playerid,"~h~~w~JESTER~n~~h~~w~ID:~h~~r~559",2500,1);
	CreateVehicle(559,X,Y+5,Z,1,1,1,90000);
	return true;
}
CMD:stratum(playerid)
{
	new Float:X;
	new Float:Y;
	new Float:Z;
	GetPlayerPos(playerid,X,Y,Z);
	GameTextForPlayer(playerid,"~h~~w~STRATUM~n~~h~~w~ID:~h~~r~561",2500,1);
	CreateVehicle(561,X,Y+5,Z,1,1,1,90000);
	return true;
}
CMD:sultan(playerid)
{
	new Float:X;
	new Float:Y;
	new Float:Z;
	GetPlayerPos(playerid,X,Y,Z);
	GameTextForPlayer(playerid,"~h~~w~SULTAN~n~~h~~w~ID:~h~~r~560",2500,1);
	CreateVehicle(560,X,Y+5,Z,1,1,1,90000);
	return true;
}
CMD:uranus(playerid)
{
	new Float:X;
	new Float:Y;
	new Float:Z;
	GetPlayerPos(playerid,X,Y,Z);
	GameTextForPlayer(playerid,"~h~~w~URANUS~n~~h~~w~ID:~h~~r~558",2500,1);
	CreateVehicle(558,X,Y+5,Z,1,1,1,90000);
	return true;
}
CMD:banshee(playerid)
{
	new Float:X;
	new Float:Y;
	new Float:Z;
	GetPlayerPos(playerid,X,Y,Z);
	GameTextForPlayer(playerid,"~h~~w~BANSHEE~n~~h~~w~ID:~h~~r~429",2500,1);
	CreateVehicle(429,X,Y+5,Z,1,1,1,90000);
	return true;
}
CMD:bullet(playerid)
{
	new Float:X;
	new Float:Y;
	new Float:Z;
	GetPlayerPos(playerid,X,Y,Z);
	GameTextForPlayer(playerid,"~h~~w~BULLET~n~~h~~w~ID:~h~~r~541",2500,1);
	CreateVehicle(541,X,Y+5,Z,1,1,1,90000);
	return true;
}
CMD:cheetah(playerid)
{
	new Float:X;
	new Float:Y;
	new Float:Z;
	GetPlayerPos(playerid,X,Y,Z);
	GameTextForPlayer(playerid,"~h~~w~CHEETAH~n~~h~~w~ID:~h~~r~415",2500,1);
	CreateVehicle(415,X,Y+5,Z,1,1,1,90000);
	return true;
}
CMD:comet(playerid)
{
	new Float:X;
	new Float:Y;
	new Float:Z;
	GetPlayerPos(playerid,X,Y,Z);
	GameTextForPlayer(playerid,"~h~~w~COMET~n~~h~~w~ID:~h~~r~480",2500,1);
	CreateVehicle(480,X,Y+5,Z,1,1,1,90000);
	return true;
}
CMD:hotknife(playerid)
{
	new Float:X;
	new Float:Y;
	new Float:Z;
	GetPlayerPos(playerid,X,Y,Z);
	GameTextForPlayer(playerid,"~h~~w~HOTKNIFE~n~~h~~w~ID:~h~~r~434",2500,1);
	CreateVehicle(434,X,Y+5,Z,1,1,1,90000);
	return true;
}
CMD:hotring(playerid)
{
	new Float:X;
	new Float:Y;
	new Float:Z;
	GetPlayerPos(playerid,X,Y,Z);
	GameTextForPlayer(playerid,"~h~~w~HOTRING~n~~h~~w~ID:~h~~r~494",2500,1);
	CreateVehicle(494,X,Y+5,Z,1,1,1,90000);
	return true;
}
CMD:hotringa(playerid)
{
	new Float:X;
	new Float:Y;
	new Float:Z;
	GetPlayerPos(playerid,X,Y,Z);
	GameTextForPlayer(playerid,"~h~~w~HOTRING A~n~~h~~w~ID:~h~~r~502",2500,1);
	CreateVehicle(502,X,Y+5,Z,1,1,1,90000);
	return true;
}
CMD:hotringb(playerid)
{
	new Float:X;
	new Float:Y;
	new Float:Z;
	GetPlayerPos(playerid,X,Y,Z);
	GameTextForPlayer(playerid,"~h~~w~HOTRING B~n~~h~~w~ID:~h~~r~503",2500,1);
	CreateVehicle(503,X,Y+5,Z,1,1,1,90000);
	return true;
}
CMD:infernus(playerid)
{
	new Float:X;
	new Float:Y;
	new Float:Z;
	GetPlayerPos(playerid,X,Y,Z);
	GameTextForPlayer(playerid,"~h~~w~INFERNUS~n~~h~~w~ID:~h~~r~411",2500,1);
	CreateVehicle(411,X,Y+5,Z,1,1,1,90000);
	return true;
}
CMD:supergt(playerid)
{
	new Float:X;
	new Float:Y;
	new Float:Z;
	GetPlayerPos(playerid,X,Y,Z);
	GameTextForPlayer(playerid,"~h~~w~SUPER GT~n~~h~~w~ID:~h~~r~506",2500,1);
	CreateVehicle(506,X,Y+5,Z,1,1,1,90000);
	return true;
}
CMD:turismo(playerid)
{
	new Float:X;
	new Float:Y;
	new Float:Z;
	GetPlayerPos(playerid,X,Y,Z);
	GameTextForPlayer(playerid,"~h~~w~TURISMO~n~~h~~w~ID:~h~~r~451",2500,1);
	CreateVehicle(451,X,Y+5,Z,1,1,1,90000);
	return true;
}
CMD:windsor(playerid)
{
	new Float:X;
	new Float:Y;
	new Float:Z;
	GetPlayerPos(playerid,X,Y,Z);
	GameTextForPlayer(playerid,"~h~~w~WINDSOR~n~~h~~w~ID:~h~~r~555",2500,1);
	CreateVehicle(555,X,Y+5,Z,1,1,1,90000);
	return true;
}
CMD:zr350(playerid)
{
	new Float:X;
	new Float:Y;
	new Float:Z;
	GetPlayerPos(playerid,X,Y,Z);
	GameTextForPlayer(playerid,"~h~~w~ZR-350~n~~h~~w~ID:~h~~r~477",2500,1);
	CreateVehicle(477,X,Y+5,Z,1,1,1,90000);
	return true;
}
CMD:benson(playerid)
{
	new Float:X;
	new Float:Y;
	new Float:Z;
	GetPlayerPos(playerid,X,Y,Z);
	GameTextForPlayer(playerid,"~h~~w~BENSON~n~~h~~w~ID:~h~~r~499",2500,1);
	CreateVehicle(499,X,Y+5,Z,1,1,1,90000);
	return true;
}
CMD:boxville(playerid)
{
	new Float:X;
	new Float:Y;
	new Float:Z;
	GetPlayerPos(playerid,X,Y,Z);
	GameTextForPlayer(playerid,"~h~~w~BOXVILLE~n~~h~~w~ID:~h~~r~498",2500,1);
	CreateVehicle(498,X,Y+5,Z,1,1,1,90000);
	return true;
}
CMD:boxville2(playerid)
{
	new Float:X;
	new Float:Y;
	new Float:Z;
	GetPlayerPos(playerid,X,Y,Z);
	GameTextForPlayer(playerid,"~h~~w~BOXVILLE ( black )~n~~h~~w~ID:~h~~r~609",2500,1);
	CreateVehicle(609,X,Y+5,Z,1,1,1,90000);
	return true;
}
CMD:cementtruck(playerid)
{
	new Float:X;
	new Float:Y;
	new Float:Z;
	GetPlayerPos(playerid,X,Y,Z);
	GameTextForPlayer(playerid,"~h~~w~CEMENT TRUCK~n~~h~~w~ID:~h~~r~524",2500,1);
	CreateVehicle(524,X,Y+5,Z,1,1,1,90000);
	return true;
}
CMD:combine(playerid)
{
	new Float:X;
	new Float:Y;
	new Float:Z;
	GetPlayerPos(playerid,X,Y,Z);
	GameTextForPlayer(playerid,"~h~~w~COMBINE HARVESTOR~n~~h~~w~ID:~h~~r~532",2500,1);
	CreateVehicle(532,X,Y+5,Z,1,1,1,90000);
	return true;
}
CMD:dft30(playerid)
{
	new Float:X;
	new Float:Y;
	new Float:Z;
	GetPlayerPos(playerid,X,Y,Z);
	GameTextForPlayer(playerid,"~h~~w~DFT-30~n~~h~~w~ID:~h~~r~578",2500,1);
	CreateVehicle(578,X,Y+5,Z,1,1,1,90000);
	return true;
}
CMD:dozer(playerid)
{
	new Float:X;
	new Float:Y;
	new Float:Z;
	GetPlayerPos(playerid,X,Y,Z);
	GameTextForPlayer(playerid,"~h~~w~DOZER~n~~h~~w~ID:~h~~r~486",2500,1);
	CreateVehicle(486,X,Y+5,Z,1,1,1,90000);
	return true;
}
CMD:dumper(playerid)
{
	new Float:X;
	new Float:Y;
	new Float:Z;
	GetPlayerPos(playerid,X,Y,Z);
	GameTextForPlayer(playerid,"~h~~w~DUMPER~n~~h~~w~ID:~h~~r~406",2500,1);
	CreateVehicle(406,X,Y+5,Z,1,1,1,90000);
	return true;
}
CMD:dune(playerid)
{
	new Float:X;
	new Float:Y;
	new Float:Z;
	GetPlayerPos(playerid,X,Y,Z);
	GameTextForPlayer(playerid,"~h~~w~DUNE~n~~h~~w~ID:~h~~r~573",2500,1);
	CreateVehicle(573,X,Y+5,Z,1,1,1,90000);
	return true;
}
CMD:flatbed(playerid)
{
	new Float:X;
	new Float:Y;
	new Float:Z;
	GetPlayerPos(playerid,X,Y,Z);
	GameTextForPlayer(playerid,"~h~~w~FLATBED~n~~h~~w~ID:~h~~r~455",2500,1);
	CreateVehicle(455,X,Y+5,Z,1,1,1,90000);
	return true;
}
CMD:hotdog(playerid)
{
	new Float:X;
	new Float:Y;
	new Float:Z;
	GetPlayerPos(playerid,X,Y,Z);
	GameTextForPlayer(playerid,"~h~~w~HOTDOG~n~~h~~w~ID:~h~~r~588",2500,1);
	CreateVehicle(588,X,Y+5,Z,1,1,1,90000);
	return true;
}
CMD:linerunner(playerid)
{
	new Float:X;
	new Float:Y;
	new Float:Z;
	GetPlayerPos(playerid,X,Y,Z);
	GameTextForPlayer(playerid,"~h~~w~LINERUNNER~n~~h~~w~ID:~h~~r~403",2500,1);
	CreateVehicle(403,X,Y+5,Z,1,1,1,90000);
	return true;
}
CMD:mrwoopee(playerid)
{
	new Float:X;
	new Float:Y;
	new Float:Z;
	GetPlayerPos(playerid,X,Y,Z);
	GameTextForPlayer(playerid,"~h~~w~MR WOOPEE~n~~h~~w~ID:~h~~r~423",2500,1);
	CreateVehicle(423,X,Y+5,Z,1,1,1,90000);
	return true;
}
CMD:mule(playerid)
{
	new Float:X;
	new Float:Y;
	new Float:Z;
	GetPlayerPos(playerid,X,Y,Z);
	GameTextForPlayer(playerid,"~h~~w~MULE~n~~h~~w~ID:~h~~r~414",2500,1);
	CreateVehicle(414,X,Y+5,Z,1,1,1,90000);
	return true;
}
CMD:packer(playerid)
{
	new Float:X;
	new Float:Y;
	new Float:Z;
	GetPlayerPos(playerid,X,Y,Z);
	GameTextForPlayer(playerid,"~h~~w~PACKER~n~~h~~w~ID:~h~~r~443",2500,1);
	CreateVehicle(443,X,Y+5,Z,1,1,1,90000);
	return true;
}
CMD:roadtrain(playerid)
{
	new Float:X;
	new Float:Y;
	new Float:Z;
	GetPlayerPos(playerid,X,Y,Z);
	GameTextForPlayer(playerid,"~h~~w~ROADTRAIN~n~~h~~w~ID:~h~~r~515",2500,1);
	CreateVehicle(515,X,Y+5,Z,1,1,1,90000);
	return true;
}
CMD:tanker(playerid)
{
	new Float:X;
	new Float:Y;
	new Float:Z;
	GetPlayerPos(playerid,X,Y,Z);
	GameTextForPlayer(playerid,"~h~~w~TANKER~n~~h~~w~ID:~h~~r~514",2500,1);
	CreateVehicle(514,X,Y+5,Z,1,1,1,90000);
	return true;
}
CMD:tractor(playerid)
{
	new Float:X;
	new Float:Y;
	new Float:Z;
	GetPlayerPos(playerid,X,Y,Z);
	GameTextForPlayer(playerid,"~h~~w~TRACTOR~n~~h~~w~ID:~h~~r~531",2500,1);
	CreateVehicle(531,X,Y+5,Z,1,1,1,90000);
	return true;
}
CMD:yankee(playerid)
{
	new Float:X;
	new Float:Y;
	new Float:Z;
	GetPlayerPos(playerid,X,Y,Z);
	GameTextForPlayer(playerid,"~h~~w~YANKEE~n~~h~~w~ID:~h~~r~456",2500,1);
	CreateVehicle(456,X,Y+5,Z,1,1,1,90000);
	return true;
}
CMD:topfun(playerid)
{
	new Float:X;
	new Float:Y;
	new Float:Z;
	GetPlayerPos(playerid,X,Y,Z);
	GameTextForPlayer(playerid,"~h~~w~TOPFUN~n~~h~~w~ID:~h~~r~459",2500,1);
	CreateVehicle(459,X,Y+5,Z,1,1,1,90000);
	return true;
}
CMD:bobcat(playerid)
{
	new Float:X;
	new Float:Y;
	new Float:Z;
	GetPlayerPos(playerid,X,Y,Z);
	GameTextForPlayer(playerid,"~h~~w~BOBCAT~n~~h~~w~ID:~h~~r~422",2500,1);
	CreateVehicle(422,X,Y+5,Z,1,1,1,90000);
	return true;
}
CMD:burrito(playerid)
{
	new Float:X;
	new Float:Y;
	new Float:Z;
	GetPlayerPos(playerid,X,Y,Z);
	GameTextForPlayer(playerid,"~h~~w~BURRITO~n~~h~~w~ID:~h~~r~482",2500,1);
	CreateVehicle(482,X,Y+5,Z,1,1,1,90000);
	return true;
}
CMD:forklift(playerid)
{
	new Float:X;
	new Float:Y;
	new Float:Z;
	GetPlayerPos(playerid,X,Y,Z);
	GameTextForPlayer(playerid,"~h~~w~FORKLIFT~n~~h~~w~ID:~h~~r~530",2500,1);
	CreateVehicle(530,X,Y+5,Z,1,1,1,90000);
	return true;
}
CMD:moonbeam(playerid)
{
	new Float:X;
	new Float:Y;
	new Float:Z;
	GetPlayerPos(playerid,X,Y,Z);
	GameTextForPlayer(playerid,"~h~~w~MOONBEAM~n~~h~~w~ID:~h~~r~418",2500,1);
	CreateVehicle(418,X,Y+5,Z,1,1,1,90000);
	return true;
}
CMD:mower(playerid)
{
	new Float:X;
	new Float:Y;
	new Float:Z;
	GetPlayerPos(playerid,X,Y,Z);
	GameTextForPlayer(playerid,"~h~~w~MOWER~n~~h~~w~ID:~h~~r~572",2500,1);
	CreateVehicle(572,X,Y+5,Z,1,1,1,90000);
	return true;
}
CMD:newsvan(playerid)
{
	new Float:X;
	new Float:Y;
	new Float:Z;
	GetPlayerPos(playerid,X,Y,Z);
	GameTextForPlayer(playerid,"~h~~w~NEWSVAN~n~~h~~w~ID:~h~~r~582",2500,1);
	CreateVehicle(582,X,Y+5,Z,1,1,1,90000);
	return true;
}
CMD:pony(playerid)
{
	new Float:X;
	new Float:Y;
	new Float:Z;
	GetPlayerPos(playerid,X,Y,Z);
	GameTextForPlayer(playerid,"~h~~w~PONY~n~~h~~w~ID:~h~~r~413",2500,1);
	CreateVehicle(413,X,Y+5,Z,1,1,1,90000);
	return true;
}
CMD:rumpo(playerid)
{
	new Float:X;
	new Float:Y;
	new Float:Z;
	GetPlayerPos(playerid,X,Y,Z);
	GameTextForPlayer(playerid,"~h~~w~RUMPO~n~~h~~w~ID:~h~~r~440",2500,1);
	CreateVehicle(440,X,Y+5,Z,1,1,1,90000);
	return true;
}
CMD:sadler(playerid)
{
	new Float:X;
	new Float:Y;
	new Float:Z;
	GetPlayerPos(playerid,X,Y,Z);
	GameTextForPlayer(playerid,"~h~~w~SADLER~n~~h~~w~ID:~h~~r~543",2500,1);
	CreateVehicle(543,X,Y+5,Z,1,1,1,90000);
	return true;
}
CMD:tug(playerid)
{
	new Float:X;
	new Float:Y;
	new Float:Z;
	GetPlayerPos(playerid,X,Y,Z);
	GameTextForPlayer(playerid,"~h~~w~TUG~n~~h~~w~ID:~h~~r~583",2500,1);
	CreateVehicle(583,X,Y+5,Z,1,1,1,90000);
	return true;
}
CMD:walton(playerid)
{
	new Float:X;
	new Float:Y;
	new Float:Z;
	GetPlayerPos(playerid,X,Y,Z);
	GameTextForPlayer(playerid,"~h~~w~WALTON~n~~h~~w~ID:~h~~r~478",2500,1);
	CreateVehicle(478,X,Y+5,Z,1,1,1,90000);
	return true;
}
CMD:yosemite(playerid)
{
	new Float:X;
	new Float:Y;
	new Float:Z;
	GetPlayerPos(playerid,X,Y,Z);
	GameTextForPlayer(playerid,"~h~~w~YOSEMITE~n~~h~~w~ID:~h~~r~554",2500,1);
	CreateVehicle(554,X,Y+5,Z,1,1,1,90000);
	return true;
}
CMD:blade(playerid)
{
	new Float:X;
	new Float:Y;
	new Float:Z;
	GetPlayerPos(playerid,X,Y,Z);
	GameTextForPlayer(playerid,"~h~~w~BLADE~n~~h~~w~ID:~h~~r~536",2500,1);
	CreateVehicle(536,X,Y+5,Z,1,1,1,90000);
	return true;
}
CMD:broadway(playerid)
{
	new Float:X;
	new Float:Y;
	new Float:Z;
	GetPlayerPos(playerid,X,Y,Z);
	GameTextForPlayer(playerid,"~h~~w~BROADWAY~n~~h~~w~ID:~h~~r~575",2500,1);
	CreateVehicle(575,X,Y+5,Z,1,1,1,90000);
	return true;
}
CMD:remington(playerid)
{
	new Float:X;
	new Float:Y;
	new Float:Z;
	GetPlayerPos(playerid,X,Y,Z);
	GameTextForPlayer(playerid,"~h~~w~REMINGTON~n~~h~~w~ID:~h~~r~534",2500,1);
	CreateVehicle(534,X,Y+5,Z,1,1,1,90000);
	return true;
}
CMD:savanna(playerid)
{
	new Float:X;
	new Float:Y;
	new Float:Z;
	GetPlayerPos(playerid,X,Y,Z);
	GameTextForPlayer(playerid,"~h~~w~SAVANNA~n~~h~~w~ID:~h~~r~567",2500,1);
	CreateVehicle(567,X,Y+5,Z,1,1,1,90000);
	return true;
}
CMD:slamvan(playerid)
{
	new Float:X;
	new Float:Y;
	new Float:Z;
	GetPlayerPos(playerid,X,Y,Z);
	GameTextForPlayer(playerid,"~h~~w~SLAMVAN~n~~h~~w~ID:~h~~r~535",2500,1);
	CreateVehicle(535,X,Y+5,Z,1,1,1,90000);
	return true;
}
CMD:tornado(playerid)
{
	new Float:X;
	new Float:Y;
	new Float:Z;
	GetPlayerPos(playerid,X,Y,Z);
	GameTextForPlayer(playerid,"~h~~w~TORNADO~n~~h~~w~ID:~h~~r~576",2500,1);
	CreateVehicle(576,X,Y+5,Z,1,1,1,90000);
	return true;
}
CMD:voodoo(playerid)
{
	new Float:X;
	new Float:Y;
	new Float:Z;
	GetPlayerPos(playerid,X,Y,Z);
	GameTextForPlayer(playerid,"~h~~w~VOODOO~n~~h~~w~ID:~h~~r~412",2500,1);
	CreateVehicle(412,X,Y+5,Z,1,1,1,90000);
	return true;
}
CMD:bandito(playerid)
{
	new Float:X;
	new Float:Y;
	new Float:Z;
	GetPlayerPos(playerid,X,Y,Z);
	GameTextForPlayer(playerid,"~h~~w~BANDITO~n~~h~~w~ID:~h~~r~568",2500,1);
	CreateVehicle(568,X,Y+5,Z,1,1,1,90000);
	return true;
}
CMD:bfinjection(playerid)
{
	new Float:X;
	new Float:Y;
	new Float:Z;
	GetPlayerPos(playerid,X,Y,Z);
	GameTextForPlayer(playerid,"~h~~w~BF INJECTION~n~~h~~w~ID:~h~~r~424",2500,1);
	CreateVehicle(424,X,Y+5,Z,1,1,1,90000);
	return true;
}
CMD:bloodringbanger(playerid)
{
	new Float:X;
	new Float:Y;
	new Float:Z;
	GetPlayerPos(playerid,X,Y,Z);
	GameTextForPlayer(playerid,"~h~~w~BLOODRING BANGER~n~~h~~w~ID:~h~~r~504",2500,1);
	CreateVehicle(504,X,Y+5,Z,1,1,1,90000);
	return true;
}
CMD:caddy(playerid)
{
	new Float:X;
	new Float:Y;
	new Float:Z;
	GetPlayerPos(playerid,X,Y,Z);
	GameTextForPlayer(playerid,"~h~~w~CADDY~n~~h~~w~ID:~h~~r~457",2500,1);
	CreateVehicle(457,X,Y+5,Z,1,1,1,90000);
	return true;
}
CMD:camper(playerid)
{
	new Float:X;
	new Float:Y;
	new Float:Z;
	GetPlayerPos(playerid,X,Y,Z);
	GameTextForPlayer(playerid,"~h~~w~CAMPER~n~~h~~w~ID:~h~~r~483",2500,1);
	CreateVehicle(483,X,Y+5,Z,1,1,1,90000);
	return true;
}
CMD:journey(playerid)
{
	new Float:X;
	new Float:Y;
	new Float:Z;
	GetPlayerPos(playerid,X,Y,Z);
	GameTextForPlayer(playerid,"~h~~w~JOURNEY~n~~h~~w~ID:~h~~r~508",2500,1);
	CreateVehicle(508,X,Y+5,Z,1,1,1,90000);
	return true;
}
CMD:kart(playerid)
{
	new Float:X;
	new Float:Y;
	new Float:Z;
	GetPlayerPos(playerid,X,Y,Z);
	GameTextForPlayer(playerid,"~h~~w~KART~n~~h~~w~ID:~h~~r~571",2500,1);
	CreateVehicle(571,X,Y+5,Z,1,1,1,90000);
	return true;
}
CMD:mesa(playerid)
{
	new Float:X;
	new Float:Y;
	new Float:Z;
	GetPlayerPos(playerid,X,Y,Z);
	GameTextForPlayer(playerid,"~h~~w~MESA~n~~h~~w~ID:~h~~r~500",2500,1);
	CreateVehicle(500,X,Y+5,Z,1,1,1,90000);
	return true;
}
CMD:monster(playerid)
{
	new Float:X;
	new Float:Y;
	new Float:Z;
	GetPlayerPos(playerid,X,Y,Z);
	GameTextForPlayer(playerid,"~h~~w~MONSTER~n~~h~~w~ID:~h~~r~444",2500,1);
	CreateVehicle(444,X,Y+5,Z,1,1,1,90000);
	return true;
}
CMD:monstera(playerid)
{
	new Float:X;
	new Float:Y;
	new Float:Z;
	GetPlayerPos(playerid,X,Y,Z);
	GameTextForPlayer(playerid,"~h~~w~MONSTER A~n~~h~~w~ID:~h~~r~556",2500,1);
	CreateVehicle(556,X,Y+5,Z,1,1,1,90000);
	return true;
}
CMD:monsterb(playerid)
{
	new Float:X;
	new Float:Y;
	new Float:Z;
	GetPlayerPos(playerid,X,Y,Z);
	GameTextForPlayer(playerid,"~h~~w~MONSTER B~n~~h~~w~ID:~h~~r~557",2500,1);
	CreateVehicle(557,X,Y+5,Z,1,1,1,90000);
	return true;
}
CMD:quad(playerid)
{
	new Float:X;
	new Float:Y;
	new Float:Z;
	GetPlayerPos(playerid,X,Y,Z);
	GameTextForPlayer(playerid,"~h~~w~QUAD~n~~h~~w~ID:~h~~r~471",2500,1);
	CreateVehicle(471,X,Y+5,Z,1,1,1,90000);
	return true;
}
CMD:sandking(playerid)
{
	new Float:X;
	new Float:Y;
	new Float:Z;
	GetPlayerPos(playerid,X,Y,Z);
	GameTextForPlayer(playerid,"~h~~w~SANDKING~n~~h~~w~ID:~h~~r~495",2500,1);
	CreateVehicle(495,X,Y+5,Z,1,1,1,90000);
	return true;
}
CMD:vortex(playerid)
{
	new Float:X;
	new Float:Y;
	new Float:Z;
	GetPlayerPos(playerid,X,Y,Z);
	GameTextForPlayer(playerid,"~h~~w~VORTEX~n~~h~~w~ID:~h~~r~539",2500,1);
	CreateVehicle(539,X,Y+5,Z,1,1,1,90000);
	return true;
}
CMD:bmx(playerid)
{
	new Float:X;
	new Float:Y;
	new Float:Z;
	GetPlayerPos(playerid,X,Y,Z);
	GameTextForPlayer(playerid,"~h~~w~BMX~n~~h~~w~ID:~h~~r~481",2500,1);
	CreateVehicle(481,X,Y+5,Z,1,1,1,90000);
	return true;
}
CMD:bike(playerid)
{
	new Float:X;
	new Float:Y;
	new Float:Z;
	GetPlayerPos(playerid,X,Y,Z);
	GameTextForPlayer(playerid,"~h~~w~BIKE~n~~h~~w~ID:~h~~r~509",2500,1);
	CreateVehicle(509,X,Y+5,Z,1,1,1,90000);
	return true;
}
CMD:mountainbike(playerid)
{
	new Float:X;
	new Float:Y;
	new Float:Z;
	GetPlayerPos(playerid,X,Y,Z);
	GameTextForPlayer(playerid,"~h~~w~MOUNTAIN BIKE~n~~h~~w~ID:~h~~r~510",2500,1);
	CreateVehicle(510,X,Y+5,Z,1,1,1,90000);
	return true;
}
CMD:bf400(playerid)
{
	new Float:X;
	new Float:Y;
	new Float:Z;
	GetPlayerPos(playerid,X,Y,Z);
	GameTextForPlayer(playerid,"~h~~w~BF-400~n~~h~~w~ID:~h~~r~581",2500,1);
	CreateVehicle(581,X,Y+5,Z,1,1,1,90000);
	return true;
}
CMD:faggio(playerid)
{
	new Float:X;
	new Float:Y;
	new Float:Z;
	GetPlayerPos(playerid,X,Y,Z);
	GameTextForPlayer(playerid,"~h~~w~FAGGIO~n~~h~~w~ID:~h~~r~462",2500,1);
	CreateVehicle(462,X,Y+5,Z,1,1,1,90000);
	return true;
}
CMD:fcr900(playerid)
{
	new Float:X;
	new Float:Y;
	new Float:Z;
	GetPlayerPos(playerid,X,Y,Z);
	GameTextForPlayer(playerid,"~h~~w~FCR-900~n~~h~~w~ID:~h~~r~521",2500,1);
	CreateVehicle(521,X,Y+5,Z,1,1,1,90000);
	return true;
}
CMD:freeway(playerid)
{
	new Float:X;
	new Float:Y;
	new Float:Z;
	GetPlayerPos(playerid,X,Y,Z);
	GameTextForPlayer(playerid,"~h~~w~FREEWAY~n~~h~~w~ID:~h~~r~463",2500,1);
	CreateVehicle(463,X,Y+5,Z,1,1,1,90000);
	return true;
}
CMD:nrg500(playerid)
{
	new Float:X;
	new Float:Y;
	new Float:Z;
	GetPlayerPos(playerid,X,Y,Z);
	GameTextForPlayer(playerid,"~h~~w~NRG-500~n~~h~~w~ID:~h~~r~522",2500,1);
	CreateVehicle(522,X,Y+5,Z,1,1,1,90000);
	return true;
}
CMD:pcj600(playerid)
{
	new Float:X;
	new Float:Y;
	new Float:Z;
	GetPlayerPos(playerid,X,Y,Z);
	GameTextForPlayer(playerid,"~h~~w~PCJ-600~n~~h~~w~ID:~h~~r~461",2500,1);
	CreateVehicle(461,X,Y+5,Z,1,1,1,90000);
	return true;
}
CMD:pizzaboy(playerid)
{
	new Float:X;
	new Float:Y;
	new Float:Z;
	GetPlayerPos(playerid,X,Y,Z);
	GameTextForPlayer(playerid,"~h~~w~PIZZABOY~n~~h~~w~ID:~h~~r~448",2500,1);
	CreateVehicle(448,X,Y+5,Z,1,1,1,90000);
	return true;
}
CMD:sanchez(playerid)
{
	new Float:X;
	new Float:Y;
	new Float:Z;
	GetPlayerPos(playerid,X,Y,Z);
	GameTextForPlayer(playerid,"~h~~w~SANCHEZ~n~~h~~w~ID:~h~~r~468",2500,1);
	CreateVehicle(468,X,Y+5,Z,1,1,1,90000);
	return true;
}
CMD:wayfarer(playerid)
{
	new Float:X;
	new Float:Y;
	new Float:Z;
	GetPlayerPos(playerid,X,Y,Z);
	GameTextForPlayer(playerid,"~h~~w~WAYFARER~n~~h~~w~ID:~h~~r~586",2500,1);
	CreateVehicle(586,X,Y+5,Z,1,1,1,90000);
	return true;
}
CMD:baggage(playerid)
{
	new Float:X;
	new Float:Y;
	new Float:Z;
	GetPlayerPos(playerid,X,Y,Z);
	GameTextForPlayer(playerid,"~h~~w~BAGGAGE~n~~h~~w~ID:~h~~r~485",2500,1);
	CreateVehicle(485,X,Y+5,Z,1,1,1,90000);
	return true;
}
CMD:bus(playerid)
{
	new Float:X;
	new Float:Y;
	new Float:Z;
	GetPlayerPos(playerid,X,Y,Z);
	GameTextForPlayer(playerid,"~h~~w~BUS~n~~h~~w~ID:~h~~r~431",2500,1);
	CreateVehicle(431,X,Y+5,Z,1,1,1,90000);
	return true;
}
CMD:cabbie(playerid)
{
	new Float:X;
	new Float:Y;
	new Float:Z;
	GetPlayerPos(playerid,X,Y,Z);
	GameTextForPlayer(playerid,"~h~~w~CABBIE~n~~h~~w~ID:~h~~r~438",2500,1);
	CreateVehicle(438,X,Y+5,Z,1,1,1,90000);
	return true;
}
CMD:coach(playerid)
{
	new Float:X;
	new Float:Y;
	new Float:Z;
	GetPlayerPos(playerid,X,Y,Z);
	GameTextForPlayer(playerid,"~h~~w~COACH~n~~h~~w~ID:~h~~r~437",2500,1);
	CreateVehicle(437,X,Y+5,Z,1,1,1,90000);
	return true;
}
CMD:sweeper(playerid)
{
	new Float:X;
	new Float:Y;
	new Float:Z;
	GetPlayerPos(playerid,X,Y,Z);
	GameTextForPlayer(playerid,"~h~~w~SWEEPER~n~~h~~w~ID:~h~~r~574",2500,1);
	CreateVehicle(574,X,Y+5,Z,1,1,1,90000);
	return true;
}
CMD:taxi(playerid)
{
	new Float:X;
	new Float:Y;
	new Float:Z;
	GetPlayerPos(playerid,X,Y,Z);
	GameTextForPlayer(playerid,"~h~~w~TAXI~n~~h~~w~ID:~h~~r~420",2500,1);
	CreateVehicle(420,X,Y+5,Z,1,1,1,90000);
	return true;
}
CMD:towtruck(playerid)
{
	new Float:X;
	new Float:Y;
	new Float:Z;
	GetPlayerPos(playerid,X,Y,Z);
	GameTextForPlayer(playerid,"~h~~w~TOWTRUCK~n~~h~~w~ID:~h~~r~525",2500,1);
	CreateVehicle(525,X,Y+5,Z,1,1,1,90000);
	return true;
}
CMD:trashmaster(playerid)
{
	new Float:X;
	new Float:Y;
	new Float:Z;
	GetPlayerPos(playerid,X,Y,Z);
	GameTextForPlayer(playerid,"~h~~w~TRASHMASTER~n~~h~~w~ID:~h~~r~408",2500,1);
	CreateVehicle(408,X,Y+5,Z,1,1,1,90000);
	return true;
}
CMD:utilityvan(playerid)
{
	new Float:X;
	new Float:Y;
	new Float:Z;
	GetPlayerPos(playerid,X,Y,Z);
	GameTextForPlayer(playerid,"~h~~w~UTILITY VAN~n~~h~~w~ID:~h~~r~552",2500,1);
	CreateVehicle(552,X,Y+5,Z,1,1,1,90000);
	return true;
}
CMD:ambulance(playerid)
{
	new Float:X;
	new Float:Y;
	new Float:Z;
	GetPlayerPos(playerid,X,Y,Z);
	GameTextForPlayer(playerid,"~h~~w~AMBULANCE~n~~h~~w~ID:~h~~r~416",2500,1);
	CreateVehicle(416,X,Y+5,Z,1,1,1,90000);
	return true;
}
CMD:barracks(playerid)
{
	new Float:X;
	new Float:Y;
	new Float:Z;
	GetPlayerPos(playerid,X,Y,Z);
	GameTextForPlayer(playerid,"~h~~w~BARRACKS~n~~h~~w~ID:~h~~r~433",2500,1);
	CreateVehicle(433,X,Y+5,Z,1,1,1,90000);
	return true;
}
CMD:enforcer(playerid)
{
	new Float:X;
	new Float:Y;
	new Float:Z;
	GetPlayerPos(playerid,X,Y,Z);
	GameTextForPlayer(playerid,"~h~~w~ENFORCER~n~~h~~w~ID:~h~~r~427",2500,1);
	CreateVehicle(427,X,Y+5,Z,1,1,1,90000);
	return true;
}
CMD:fbirancher(playerid)
{
	new Float:X;
	new Float:Y;
	new Float:Z;
	GetPlayerPos(playerid,X,Y,Z);
	GameTextForPlayer(playerid,"~h~~w~FBI RANCHER~n~~h~~w~ID:~h~~r~490",2500,1);
	CreateVehicle(490,X,Y+5,Z,1,1,1,90000);
	return true;
}
CMD:fbitruck(playerid)
{
	new Float:X;
	new Float:Y;
	new Float:Z;
	GetPlayerPos(playerid,X,Y,Z);
	GameTextForPlayer(playerid,"~h~~w~FBI TRUCK~n~~h~~w~ID:~h~~r~528",2500,1);
	CreateVehicle(528,X,Y+5,Z,1,1,1,90000);
	return true;
}
CMD:firetruck(playerid)
{
	new Float:X;
	new Float:Y;
	new Float:Z;
	GetPlayerPos(playerid,X,Y,Z);
	GameTextForPlayer(playerid,"~h~~w~FIRETRUCK~n~~h~~w~ID:~h~~r~407",2500,1);
	CreateVehicle(407,X,Y+5,Z,1,1,1,90000);
	return true;
}
CMD:firetrucka(playerid)
{
	new Float:X;
	new Float:Y;
	new Float:Z;
	GetPlayerPos(playerid,X,Y,Z);
	GameTextForPlayer(playerid,"~h~~w~FIRETRUCK A~n~~h~~w~ID:~h~~r~544",2500,1);
	CreateVehicle(544,X,Y+5,Z,1,1,1,90000);
	return true;
}
CMD:hpv1000(playerid)
{
	new Float:X;
	new Float:Y;
	new Float:Z;
	GetPlayerPos(playerid,X,Y,Z);
	GameTextForPlayer(playerid,"~h~~w~HPV-1000~n~~h~~w~ID:~h~~r~523",2500,1);
	CreateVehicle(523,X,Y+5,Z,1,1,1,90000);
	return true;
}
CMD:patriot(playerid)
{
	new Float:X;
	new Float:Y;
	new Float:Z;
	GetPlayerPos(playerid,X,Y,Z);
	GameTextForPlayer(playerid,"~h~~w~PATRIOT~n~~h~~w~ID:~h~~r~470",2500,1);
	CreateVehicle(470,X,Y+5,Z,1,1,1,90000);
	return true;
}
CMD:policels(playerid)
{
	new Float:X;
	new Float:Y;
	new Float:Z;
	GetPlayerPos(playerid,X,Y,Z);
	GameTextForPlayer(playerid,"~h~~w~POLICE LOS SANTOS~n~~h~~w~ID:~h~~r~596",2500,1);
	CreateVehicle(596,X,Y+5,Z,1,1,0,90000);
	return true;
}
CMD:policesf(playerid)
{
	new Float:X;
	new Float:Y;
	new Float:Z;
	GetPlayerPos(playerid,X,Y,Z);
	GameTextForPlayer(playerid,"~h~~w~POLICE SAN FIERRO~n~~h~~w~ID:~h~~r~597",2500,1);
	CreateVehicle(597,X,Y+5,Z,1,1,0,90000);
	return true;
}
CMD:policelv(playerid)
{
	new Float:X;
	new Float:Y;
	new Float:Z;
	GetPlayerPos(playerid,X,Y,Z);
	GameTextForPlayer(playerid,"~h~~w~POLICE LAS VENTURAS~n~~h~~w~ID:~h~~r~598",2500,1);
	CreateVehicle(598,X,Y+5,Z,1,1,0,90000);
	return true;
}
CMD:policeranger(playerid)
{
	new Float:X;
	new Float:Y;
	new Float:Z;
	GetPlayerPos(playerid,X,Y,Z);
	GameTextForPlayer(playerid,"~h~~w~POLICE RANGER~n~~h~~w~ID:~h~~r~599",2500,1);
	CreateVehicle(599,X,Y+5,Z,1,1,0,90000);
	return true;
}
CMD:rhino(playerid)
{
	new Float:X;
	new Float:Y;
	new Float:Z;
	GetPlayerPos(playerid,X,Y,Z);
	GameTextForPlayer(playerid,"~h~~w~RHINO~n~~h~~w~ID:~h~~r~432",2500,1);
	CreateVehicle(432,X,Y+5,Z,1,1,1,90000);
	return true;
}
CMD:securicar(playerid)
{
	new Float:X;
	new Float:Y;
	new Float:Z;
	GetPlayerPos(playerid,X,Y,Z);
	GameTextForPlayer(playerid,"~h~~w~SECURICAR~n~~h~~w~ID:~h~~r~428",2500,1);
	CreateVehicle(428,X,Y+5,Z,1,1,1,90000);
	return true;
}
CMD:swattank(playerid)
{
	new Float:X;
	new Float:Y;
	new Float:Z;
	GetPlayerPos(playerid,X,Y,Z);
	GameTextForPlayer(playerid,"~h~~w~SWAT TANK~n~~h~~w~ID:~h~~r~601",2500,1);
	CreateVehicle(601,X,Y+5,Z,1,1,1,90000);
	return true;
}
CMD:andromada(playerid)
{
	new Float:X;
	new Float:Y;
	new Float:Z;
	GetPlayerPos(playerid,X,Y,Z);
	GameTextForPlayer(playerid,"~h~~w~ANDROMADA~n~~h~~w~ID:~h~~r~592",2500,1);
	CreateVehicle(592,X,Y+20,Z,1,1,1,90000);
	return true;
}
CMD:at400(playerid)
{
	new Float:X;
	new Float:Y;
	new Float:Z;
	GetPlayerPos(playerid,X,Y,Z);
	GameTextForPlayer(playerid,"~h~~w~AT-400~n~~h~~w~ID:~h~~r~577",2500,1);
	CreateVehicle(577,X,Y+20,Z,1,1,1,90000);
	return true;
}
CMD:beagle(playerid)
{
	new Float:X;
	new Float:Y;
	new Float:Z;
	GetPlayerPos(playerid,X,Y,Z);
	GameTextForPlayer(playerid,"~h~~w~BEAGLE~n~~h~~w~ID:~h~~r~511",2500,1);
	CreateVehicle(511,X,Y+20,Z,1,1,1,90000);
	return true;
}
CMD:cargobob(playerid)
{
	new Float:X;
	new Float:Y;
	new Float:Z;
	GetPlayerPos(playerid,X,Y,Z);
	GameTextForPlayer(playerid,"~h~~w~CARGOBOB~n~~h~~w~ID:~h~~r~548",2500,1);
	CreateVehicle(548,X,Y+10,Z,1,1,1,90000);
	return true;
}
CMD:cropduster(playerid)
{
	new Float:X;
	new Float:Y;
	new Float:Z;
	GetPlayerPos(playerid,X,Y,Z);
	GameTextForPlayer(playerid,"~h~~w~CROPDUSTER~n~~h~~w~ID:~h~~r~512",2500,1);
	CreateVehicle(512,X,Y+10,Z,1,1,1,90000);
	return true;
}
CMD:dodo(playerid)
{
	new Float:X;
	new Float:Y;
	new Float:Z;
	GetPlayerPos(playerid,X,Y,Z);
	GameTextForPlayer(playerid,"~h~~w~DODO~n~~h~~w~ID:~h~~r~593",2500,1);
	CreateVehicle(593,X,Y+10,Z,1,1,1,90000);
	return true;
}
CMD:hunter(playerid)
{
	new Float:X;
	new Float:Y;
	new Float:Z;
	GetPlayerPos(playerid,X,Y,Z);
	GameTextForPlayer(playerid,"~h~~w~HUNTER~n~~h~~w~ID:~h~~r~425",2500,1);
	CreateVehicle(425,X,Y+10,Z,1,1,1,90000);
	return true;
}
CMD:leviathon(playerid)
{
	new Float:X;
	new Float:Y;
	new Float:Z;
	GetPlayerPos(playerid,X,Y,Z);
	GameTextForPlayer(playerid,"~h~~w~LEVIATHON~n~~h~~w~ID:~h~~r~417",2500,1);
	CreateVehicle(417,X,Y+10,Z,1,1,1,90000);
	return true;
}
CMD:maverick(playerid)
{
	new Float:X;
	new Float:Y;
	new Float:Z;
	GetPlayerPos(playerid,X,Y,Z);
	GameTextForPlayer(playerid,"~h~~w~MAVERICK~n~~h~~w~ID:~h~~r~487",2500,1);
	CreateVehicle(487,X,Y+10,Z,1,1,1,90000);
	return true;
}
CMD:nevada(playerid)
{
	new Float:X;
	new Float:Y;
	new Float:Z;
	GetPlayerPos(playerid,X,Y,Z);
	GameTextForPlayer(playerid,"~h~~w~NEVADA~n~~h~~w~ID:~h~~r~553",2500,1);
	CreateVehicle(553,X,Y+10,Z,1,1,1,90000);
	return true;
}
CMD:newsmaverick(playerid)
{
	new Float:X;
	new Float:Y;
	new Float:Z;
	GetPlayerPos(playerid,X,Y,Z);
	GameTextForPlayer(playerid,"~h~~w~NEWS MAVERICK~n~~h~~w~ID:~h~~r~488",2500,1);
	CreateVehicle(488,X,Y+10,Z,1,1,1,90000);
	return true;
}
CMD:policemaverick(playerid)
{
	new Float:X;
	new Float:Y;
	new Float:Z;
	GetPlayerPos(playerid,X,Y,Z);
	GameTextForPlayer(playerid,"~h~~w~POLICE MAVERICK~n~~h~~w~ID:~h~~r~497",2500,1);
	CreateVehicle(497,X,Y+10,Z,1,1,0,90000);
	return true;
}
CMD:raindance(playerid)
{
	new Float:X;
	new Float:Y;
	new Float:Z;
	GetPlayerPos(playerid,X,Y,Z);
	GameTextForPlayer(playerid,"~h~~w~RAINDANCE~n~~h~~w~ID:~h~~r~563",2500,1);
	CreateVehicle(563,X,Y+10,Z,1,1,1,90000);
	return true;
}
CMD:rustler(playerid)
{
	new Float:X;
	new Float:Y;
	new Float:Z;
	GetPlayerPos(playerid,X,Y,Z);
	GameTextForPlayer(playerid,"~h~~w~RUSTLER~n~~h~~w~ID:~h~~r~476",2500,1);
	CreateVehicle(476,X,Y+10,Z,1,1,1,90000);
	return true;
}
CMD:seasparrow(playerid)
{
	new Float:X;
	new Float:Y;
	new Float:Z;
	GetPlayerPos(playerid,X,Y,Z);
	GameTextForPlayer(playerid,"~h~~w~SEA SPARROW~n~~h~~w~ID:~h~~r~447",2500,1);
	CreateVehicle(447,X,Y+10,Z,1,1,1,90000);
	return true;
}
CMD:shamal(playerid)
{
	new Float:X;
	new Float:Y;
	new Float:Z;
	GetPlayerPos(playerid,X,Y,Z);
	GameTextForPlayer(playerid,"~h~~w~SHAMAL~n~~h~~w~ID:~h~~r~519",2500,1);
	CreateVehicle(519,X,Y+10,Z,1,1,1,90000);
	return true;
}
CMD:skimmer(playerid)
{
	new Float:X;
	new Float:Y;
	new Float:Z;
	GetPlayerPos(playerid,X,Y,Z);
	GameTextForPlayer(playerid,"~h~~w~SKIMMER~n~~h~~w~ID:~h~~r~460",2500,1);
	CreateVehicle(460,X,Y+10,Z,1,1,1,90000);
	return true;
}
CMD:sparrow(playerid)
{
	new Float:X;
	new Float:Y;
	new Float:Z;
	GetPlayerPos(playerid,X,Y,Z);
	GameTextForPlayer(playerid,"~h~~w~SPARROW~n~~h~~w~ID:~h~~r~469",2500,1);
	CreateVehicle(469,X,Y+10,Z,1,1,1,90000);
	return true;
}
CMD:stuntplane(playerid)
{
	new Float:X;
	new Float:Y;
	new Float:Z;
	GetPlayerPos(playerid,X,Y,Z);
	GameTextForPlayer(playerid,"~h~~w~STUNT PLANE~n~~h~~w~ID:~h~~r~513",2500,1);
	CreateVehicle(513,X,Y+10,Z,1,1,1,90000);
	return true;
}
CMD:hydra(playerid)
{
	new Float:X;
	new Float:Y;
	new Float:Z;
	GetPlayerPos(playerid,X,Y,Z);
	GameTextForPlayer(playerid,"~h~~w~HYDRA~n~~h~~w~ID:~h~~r~520",2500,1);
	CreateVehicle(520,X,Y+10,Z,1,1,1,90000);
	return true;
}
CMD:coastguar(playerid)
{
	new Float:X;
	new Float:Y;
	new Float:Z;
	GetPlayerPos(playerid,X,Y,Z);
	GameTextForPlayer(playerid,"~h~~w~COASTGUARD~n~~h~~w~ID:~h~~r~472",2500,1);
	CreateVehicle(472,X,Y+5,Z,1,1,1,90000);
	return true;
}
CMD:dingy(playerid)
{
	new Float:X;
	new Float:Y;
	new Float:Z;
	GetPlayerPos(playerid,X,Y,Z);
	GameTextForPlayer(playerid,"~h~~w~DINGY~n~~h~~w~ID:~h~~r~473",2500,1);
	CreateVehicle(473,X,Y+5,Z,1,1,1,90000);
	return true;
}
CMD:jetmax(playerid)
{
	new Float:X;
	new Float:Y;
	new Float:Z;
	GetPlayerPos(playerid,X,Y,Z);
	GameTextForPlayer(playerid,"~h~~w~JETMAX~n~~h~~w~ID:~h~~r~493",2500,1);
	CreateVehicle(493,X,Y+5,Z,1,1,1,90000);
	return true;
}
CMD:launch(playerid)
{
	new Float:X;
	new Float:Y;
	new Float:Z;
	GetPlayerPos(playerid,X,Y,Z);
	GameTextForPlayer(playerid,"~h~~w~LAUNCH~n~~h~~w~ID:~h~~r~595",2500,1);
	CreateVehicle(595,X,Y+5,Z,1,1,1,90000);
	return true;
}
CMD:marquis(playerid)
{
	new Float:X;
	new Float:Y;
	new Float:Z;
	GetPlayerPos(playerid,X,Y,Z);
	GameTextForPlayer(playerid,"~h~~w~MARQUIS~n~~h~~w~ID:~h~~r~484",2500,1);
	CreateVehicle(484,X,Y+5,Z,1,1,1,90000);
	return true;
}
CMD:predator(playerid)
{
	new Float:X;
	new Float:Y;
	new Float:Z;
	GetPlayerPos(playerid,X,Y,Z);
	GameTextForPlayer(playerid,"~h~~w~PREDATOR~n~~h~~w~ID:~h~~r~430",2500,1);
	CreateVehicle(430,X,Y+5,Z,1,1,1,90000);
	return true;
}
CMD:reefer(playerid)
{
	new Float:X;
	new Float:Y;
	new Float:Z;
	GetPlayerPos(playerid,X,Y,Z);
	GameTextForPlayer(playerid,"~h~~w~REEFER~n~~h~~w~ID:~h~~r~453",2500,1);
	CreateVehicle(453,X,Y+5,Z,1,1,1,90000);
	return true;
}
CMD:speeder(playerid)
{
	new Float:X;
	new Float:Y;
	new Float:Z;
	GetPlayerPos(playerid,X,Y,Z);
	GameTextForPlayer(playerid,"~h~~w~SPEEDER~n~~h~~w~ID:~h~~r~452",2500,1);
	CreateVehicle(452,X,Y+5,Z,1,1,1,90000);
	return true;
}
CMD:squallo(playerid)
{
	new Float:X;
	new Float:Y;
	new Float:Z;
	GetPlayerPos(playerid,X,Y,Z);
	GameTextForPlayer(playerid,"~h~~w~SQUALLO~n~~h~~w~ID:~h~~r~446",2500,1);
	CreateVehicle(446,X,Y+5,Z,1,1,1,90000);
	return true;
}
CMD:tropic(playerid)
{
	new Float:X;
	new Float:Y;
	new Float:Z;
	GetPlayerPos(playerid,X,Y,Z);
	GameTextForPlayer(playerid,"~h~~w~TROPIC~n~~h~~w~ID:~h~~r~454",2500,1);
	CreateVehicle(454,X,Y+5,Z,1,1,1,90000);
	return true;
}
CMD:rcbandit(playerid)
{
	new Float:X;
	new Float:Y;
	new Float:Z;
	GetPlayerPos(playerid,X,Y,Z);
	GameTextForPlayer(playerid,"~h~~w~RC BANDIT~n~~h~~w~ID:~h~~r~441",2500,1);
	CreateVehicle(441,X,Y+5,Z,1,1,1,90000);
	return true;
}
CMD:rcbaron(playerid)
{
	new Float:X;
	new Float:Y;
	new Float:Z;
	GetPlayerPos(playerid,X,Y,Z);
	GameTextForPlayer(playerid,"~h~~w~RC BARON~n~~h~~w~ID:~h~~r~464",2500,1);
	CreateVehicle(464,X,Y+5,Z,1,1,1,90000);
	return true;
}
CMD:rccam(playerid)
{
	new Float:X;
	new Float:Y;
	new Float:Z;
	GetPlayerPos(playerid,X,Y,Z);
	GameTextForPlayer(playerid,"~h~~w~RC CAM~n~~h~~w~ID:~h~~r~594",2500,1);
	CreateVehicle(594,X,Y+5,Z,1,1,1,90000);
	return true;
}
CMD:rcgoblin(playerid)
{
	new Float:X;
	new Float:Y;
	new Float:Z;
	GetPlayerPos(playerid,X,Y,Z);
	GameTextForPlayer(playerid,"~h~~w~RC GOBLIN~n~~h~~w~ID:~h~~r~465",2500,1);
	CreateVehicle(465,X,Y+5,Z,1,1,1,90000);
	return true;
}
CMD:rcgoblin2(playerid)
{
	new Float:X;
	new Float:Y;
	new Float:Z;
	GetPlayerPos(playerid,X,Y,Z);
	GameTextForPlayer(playerid,"~h~~w~ANOTHER RC GOBLIN~n~~h~~w~ID:~h~~r~501",2500,1);
	CreateVehicle(501,X,Y+5,Z,1,1,1,90000);
	return true;
}
CMD:rctiger(playerid)
{
	new Float:X;
	new Float:Y;
	new Float:Z;
	GetPlayerPos(playerid,X,Y,Z);
	GameTextForPlayer(playerid,"~h~~w~RC TIGER~n~~h~~w~ID:~h~~r~564",2500,1);
	CreateVehicle(564,X,Y+5,Z,1,1,1,90000);
	return true;
}
CMD:glendale2(playerid)
{
	new Float:X;
	new Float:Y;
	new Float:Z;
	GetPlayerPos(playerid,X,Y,Z);
	GameTextForPlayer(playerid,"~h~~w~BEAT UP GLENDALE~n~~h~~w~ID:~h~~r~604",2500,1);
	CreateVehicle(604,X,Y+5,Z,1,1,1,90000);
	return true;
}
CMD:sadler2(playerid)
{
	new Float:X;
	new Float:Y;
	new Float:Z;
	GetPlayerPos(playerid,X,Y,Z);
	GameTextForPlayer(playerid,"~h~~w~BEAT UP SADLER~n~~h~~w~ID:~h~~r~605",2500,1);
	CreateVehicle(605,X,Y+5,Z,1,1,1,90000);
	return true;
}
//Тюнингованные Тачки
CMD:tcars(playerid)
{
	SendClientMessage(playerid,COLOR_DPT,"===== Тюнингованные Машины =====");
	SendClientMessage(playerid,COLOR_WHITE,"=== Введите /telegy чтобы получить Elegy!");
	SendClientMessage(playerid,COLOR_WHITE,"=== Введите /turanus чтобы получить Uranus!");
	SendClientMessage(playerid,COLOR_WHITE,"=== Введите /tstrat чтобы получить Stratus!");
	SendClientMessage(playerid,COLOR_WHITE,"=== Введите /tflash чтобы получить Flash!");
	SendClientMessage(playerid,COLOR_WHITE,"=== Введите /tjester чтобы получить Jester!");
	SendClientMessage(playerid,COLOR_WHITE,"=== Введите /tsultan чтобы получить Sultan!");
	return true;
}
CMD:telegy(playerid)
{
	new Float:X;
	new Float:Y;
	new Float:Z;
	new carid;
	GetPlayerPos(playerid,X,Y,Z);
	GameTextForPlayer(playerid,"~h~~w~TUNED ELEGY~n~~h~~w~ID:~h~~r~605",2500,1);
	carid = CreateVehicle(562,X,Y+5,Z,1,1,1,90000);
	AddVehicleComponent(carid,1034);
	AddVehicleComponent(carid,1038);
	AddVehicleComponent(carid,1147);
	AddVehicleComponent(carid,1010);
	AddVehicleComponent(carid,1073);
	ChangeVehiclePaintjob(carid,1);
	return true;
}
CMD:turanus(playerid)
{
	new Float:X;
	new Float:Y;
	new Float:Z;
	new carid;
	GetPlayerPos(playerid,X,Y,Z);
	GameTextForPlayer(playerid,"~h~~w~TUNED URANUS~n~~h~~w~ID:~h~~r~605",2500,1);
	carid = CreateVehicle(558,X,Y+5,Z,1,1,1,90000);
	AddVehicleComponent(carid,1088);
	AddVehicleComponent(carid,1092);
	AddVehicleComponent(carid,1139);
	AddVehicleComponent(carid,1010);
	AddVehicleComponent(carid,1073);
	ChangeVehiclePaintjob(carid,1);
	return true;
}
CMD:tstrat(playerid)
{
	new Float:X;
	new Float:Y;
	new Float:Z;
	new carid;
	GetPlayerPos(playerid,X,Y,Z);
	GameTextForPlayer(playerid,"~h~~w~TUNED STRATUS~n~~h~~w~ID:~h~~r~605",2500,1);
	carid = CreateVehicle(561,X,Y+5,Z,1,1,1,90000);
	AddVehicleComponent(carid,1055);
	AddVehicleComponent(carid,1058);
	AddVehicleComponent(carid,1064);
	AddVehicleComponent(carid,1010);
	AddVehicleComponent(carid,1073);
	ChangeVehiclePaintjob(carid,1);
	return true;
}
CMD:tflash(playerid)
{
	new Float:X;
	new Float:Y;
	new Float:Z;
	new carid;
	GetPlayerPos(playerid,X,Y,Z);
	GameTextForPlayer(playerid,"~h~~w~TUNED FLASH~n~~h~~w~ID:~h~~r~605",2500,1);
	carid = CreateVehicle(565,X,Y+5,Z,1,1,1,90000);
	AddVehicleComponent(carid,1046);
	AddVehicleComponent(carid,1049);
	AddVehicleComponent(carid,1053);
	AddVehicleComponent(carid,1010);
	AddVehicleComponent(carid,1073);
	ChangeVehiclePaintjob(carid,1);
	return true;
}
CMD:tjester(playerid)
{
	new Float:X;
	new Float:Y;
	new Float:Z;
	new carid;
	GetPlayerPos(playerid,X,Y,Z);
	GameTextForPlayer(playerid,"~h~~w~TUNED JESTER~n~~h~~w~ID:~h~~r~605",2500,1);
	carid = CreateVehicle(559,X,Y+5,Z,1,1,1,90000);
	AddVehicleComponent(carid,1065);
	AddVehicleComponent(carid,1067);
	AddVehicleComponent(carid,1162);
	AddVehicleComponent(carid,1010);
	AddVehicleComponent(carid,1073);
	ChangeVehiclePaintjob(carid,1);
	return true;
}
CMD:tsultan(playerid)
{
	new Float:X;
	new Float:Y;
	new Float:Z;
	new carid;
	GetPlayerPos(playerid,X,Y,Z);
	GameTextForPlayer(playerid,"~h~~w~TUNED SULTAN~n~~h~~w~ID:~h~~r~605",2500,1);
	carid = CreateVehicle(560,X,Y+5,Z,1,1,1,90000);
	AddVehicleComponent(carid,1029);
	AddVehicleComponent(carid,1033);
	AddVehicleComponent(carid,1139);
	AddVehicleComponent(carid,1010);
	AddVehicleComponent(carid,1073);
	ChangeVehiclePaintjob(carid,1);
	return true;
}
//Телепорты
CMD:teleports(playerid)
{
	SendClientMessage(playerid,COLOR_DPT,"===== Страница 1/3 =====");
	SendClientMessage(playerid,COLOR_WHITE,"=== /ls /sf /lv (Города)");
	SendClientMessage(playerid,COLOR_WHITE,"=== /lsair /sfair /lvair /aa (Аэропорты)");
	SendClientMessage(playerid,COLOR_WHITE,"=== /lspd /sfpd /lvpd (Полиция)");
	SendClientMessage(playerid,COLOR_WHITE,"=== /ammuls /ammusf /ammulv (Амуниция)");
	SendClientMessage(playerid,COLOR_WHITE,"=== /arch /trans /loco (Тюнинг)");
	SendClientMessage(playerid,COLOR_WHITE,"=== /sdrift1 /sdrift2 /sdrift3 (Дрифт)");
	SendClientMessage(playerid,COLOR_DPT,"===== След. страница: /teleports2 =====");
	return true;
}
CMD:teleports2(playerid)
{
	SendClientMessage(playerid,COLOR_DPT,"===== Страница 2/3 =====");
	SendClientMessage(playerid,COLOR_WHITE,"=== /drift[1-53] /driftcircle /driftschool /skydrift (Дрифт 2)");
	SendClientMessage(playerid,COLOR_WHITE,"=== /beach[1-3] (Пляж)");
	SendClientMessage(playerid,COLOR_WHITE,"=== /thebank (Банк)");
	SendClientMessage(playerid,COLOR_WHITE,"=== /area51 (Зона 69)");
	SendClientMessage(playerid,COLOR_WHITE,"=== /4dragons (Казино 4 Дракона)");
	SendClientMessage(playerid,COLOR_WHITE,"=== /farm (Ферма)");
	SendClientMessage(playerid,COLOR_DPT,"===== След. страница: /teleports3 =====");
	return true;
}
CMD:teleports3(playerid)
{
	SendClientMessage(playerid,COLOR_DPT,"===== Страница 3/3 =====");
	SendClientMessage(playerid,COLOR_WHITE,"=== /chilliad (Гора Чилиад)");
	SendClientMessage(playerid,COLOR_WHITE,"=== /gs (Грув Стрит)");
	SendClientMessage(playerid,COLOR_WHITE,"=== /spawn (Спавн)");
	SendClientMessage(playerid,COLOR_DPT,"===== Пред. страница: /teleports2 =====");
	return true;
}
CMD:racetrack(playerid)
{
	new string[256];
	new pName[24];
	if(IsPlayerInAnyVehicle(playerid))
	{
		if(GetPlayerState(playerid) == PLAYER_STATE_DRIVER)
		{
			SetVehiclePos(GetPlayerVehicleID(playerid),-521.0,-3643.0,7.0);
			SetVehicleZAngle(GetPlayerVehicleID(playerid), 0.0);
			SetCameraBehindPlayer(playerid);
			format(string, sizeof(string), "%s [ID:%d] телепортирован на Race Track (/racetrack)", pName, playerid);
			SendClientMessageToAll(COLOR_YELLOW, string);
			GameTextForPlayer(playerid, "~w~Добро пожаловать на Race Track! ~G~", 5000, 5);
		}
		else
		{
			SendClientMessage(playerid, COLOR_RED, "GameMode.Error: Вы должны быть в машине!");
		}
	}
	else
	{
		SetPlayerPos(playerid,-521.0,-3643.0,7.0);
		SetPlayerFacingAngle(playerid, 0.0);
		SetCameraBehindPlayer(playerid);
		format(string, sizeof(string), "%s [ID:%d] телепортирован на Race Track (/racetrack)", pName, playerid);
		SendClientMessageToAll(COLOR_YELLOW, string);
		GameTextForPlayer(playerid, "~w~Добро пожаловать на Race Track! ~G~", 5000, 5);
	}
	return true;
}
CMD:beach1(playerid)
{
	new string[256];
	new pName[24];
	if(IsPlayerInAnyVehicle(playerid))
	{
		if(GetPlayerState(playerid) == PLAYER_STATE_DRIVER)
		{
			SetVehiclePos(GetPlayerVehicleID(playerid),183.5687,-1940.4738,-4.3239);
			SetVehicleZAngle(GetPlayerVehicleID(playerid), 0.0);
			SetCameraBehindPlayer(playerid);
			format(string, sizeof(string), "%s [ID:%d] телепортирован на Beach 1 (/beach1)", pName, playerid);
			SendClientMessageToAll(COLOR_YELLOW, string);
			GameTextForPlayer(playerid, "~w~Добро пожаловать на Beach 1! ~G~", 5000, 5);
		}
		else
		{
			SendClientMessage(playerid, COLOR_RED, "GameMode.Error: Вы должны быть в машине!");
		}
	}
	else
	{
		SetPlayerPos(playerid,183.5687,-1940.4738,-4.3239);
		SetPlayerFacingAngle(playerid, 0.0);
		SetCameraBehindPlayer(playerid);
		format(string, sizeof(string), "%s [ID:%d] телепортирован на Beach 1 (/beach1)", pName, playerid);
		SendClientMessageToAll(COLOR_YELLOW, string);
		GameTextForPlayer(playerid, "~w~Добро пожаловать на Beach 1! ~G~", 5000, 5);
	}
	return true;
}
CMD:beach2(playerid)
{
	new string[256];
	new pName[24];
	if(IsPlayerInAnyVehicle(playerid))
	{
		if(GetPlayerState(playerid) == PLAYER_STATE_DRIVER)
		{
			SetVehiclePos(GetPlayerVehicleID(playerid),195.6263,-1943.2715,-3.9503);
			SetVehicleZAngle(GetPlayerVehicleID(playerid), 0.0);
			SetCameraBehindPlayer(playerid);
			format(string, sizeof(string), "%s [ID:%d] телепортирован на Beach 2 (/beach2)", pName, playerid);
			SendClientMessageToAll(COLOR_YELLOW, string);
			GameTextForPlayer(playerid, "~w~Добро пожаловать на Beach 2! ~G~", 5000, 5);
		}
		else
		{
			SendClientMessage(playerid, COLOR_RED, "GameMode.Error: Вы должны быть в машине!");
		}
	}
	else
	{
		SetPlayerPos(playerid,195.6263,-1943.2715,-3.9503);
		SetPlayerFacingAngle(playerid, 0.0);
		SetCameraBehindPlayer(playerid);
		format(string, sizeof(string), "%s [ID:%d] телепортирован на Beach 2 (/beach2)", pName, playerid);
		SendClientMessageToAll(COLOR_YELLOW, string);
		GameTextForPlayer(playerid, "~w~Добро пожаловать на Beach 2! ~G~", 5000, 5);
	}
	return true;
}
CMD:beach3(playerid)
{
	new string[256];
	new pName[24];
	if(IsPlayerInAnyVehicle(playerid))
	{
		if(GetPlayerState(playerid) == PLAYER_STATE_DRIVER)
		{
			SetVehiclePos(GetPlayerVehicleID(playerid),205.5823,-1943.0797,-4.0632);
			SetVehicleZAngle(GetPlayerVehicleID(playerid), 0.0);
			SetCameraBehindPlayer(playerid);
			format(string, sizeof(string), "%s [ID:%d] телепортирован на Beach 3 (/beach3)", pName, playerid);
			SendClientMessageToAll(COLOR_YELLOW, string);
			GameTextForPlayer(playerid, "~w~Добро пожаловать на Beach 3! ~G~", 5000, 5);
		}
		else
		{
			SendClientMessage(playerid, COLOR_RED, "GameMode.Error: Вы должны быть в машине!");
		}
	}
	else
	{
		SetPlayerPos(playerid,205.5823,-1943.0797,-4.0632);
		SetPlayerFacingAngle(playerid, 0.0);
		SetCameraBehindPlayer(playerid);
		format(string, sizeof(string), "%s [ID:%d] телепортирован на Beach 3 (/beach3)", pName, playerid);
		SendClientMessageToAll(COLOR_YELLOW, string);
		GameTextForPlayer(playerid, "~w~Добро пожаловать на Beach 3! ~G~", 5000, 5);
	}
	return true;
}
CMD:gs(playerid)
{	
	new string[256];
	new pName[24];
	if(IsPlayerInAnyVehicle(playerid))
	{
		if(GetPlayerState(playerid) == PLAYER_STATE_DRIVER)
		{
			SetVehiclePos(GetPlayerVehicleID(playerid),2512.0932617188,-1671.1571044922,13.907941818237);
			SetVehicleZAngle(GetPlayerVehicleID(playerid), 0.0);
			SetCameraBehindPlayer(playerid);
			format(string, sizeof(string), "%s [ID:%d] телепортирован на Groove Street (/gs)", pName, playerid);
			SendClientMessageToAll(COLOR_YELLOW, string);
			GameTextForPlayer(playerid, "~w~Добро пожаловать на Groove Street! ~G~", 5000, 5);
		}
		else
		{
			SendClientMessage(playerid, COLOR_RED, "GameMode.Error: Вы должны быть в машине!");
		}
	}
	else
	{
		SetPlayerPos(playerid, 2512.0932617188,-1671.1571044922,13.907941818237);
		SetPlayerFacingAngle(playerid, 0.0);
		SetCameraBehindPlayer(playerid);
		format(string, sizeof(string), "%s [ID:%d] телепортирован на Groove Street (/gs)", pName, playerid);
		SendClientMessageToAll(COLOR_YELLOW, string);
		GameTextForPlayer(playerid, "~w~Добро пожаловать на Groove Street! ~G~", 5000, 5);
	}
	return true;
}
CMD:ls(playerid)
{	
	new string[256];
	new pName[24];
	if(IsPlayerInAnyVehicle(playerid))
	{
		if(GetPlayerState(playerid) == PLAYER_STATE_DRIVER)
		{
			SetVehiclePos(GetPlayerVehicleID(playerid),1280.9606933594,-1338.0102539063,13.654249191284);
			SetVehicleZAngle(GetPlayerVehicleID(playerid), 0.0);
			SetCameraBehindPlayer(playerid);
			format(string, sizeof(string), "%s [ID:%d] телепортирован на Los Santos (/ls)", pName, playerid);
			SendClientMessageToAll(COLOR_YELLOW, string);
			GameTextForPlayer(playerid, "~w~Добро пожаловать на Los Santos! ~G~", 5000, 5);
		}
		else
		{
			SendClientMessage(playerid, COLOR_RED, "GameMode.Error: Вы должны быть в машине!");
		}
	}
	else
	{
		SetPlayerPos(playerid, 1280.9606933594,-1338.0102539063,13.654249191284);
		SetPlayerFacingAngle(playerid, 0.0);
		SetCameraBehindPlayer(playerid);
		format(string, sizeof(string), "%s [ID:%d] телепортирован на Los Santos (/ls)", pName, playerid);
		SendClientMessageToAll(COLOR_YELLOW, string);
		GameTextForPlayer(playerid, "~w~Добро пожаловать на Los Santos! ~G~", 5000, 5);
	}
	return true;
}
CMD:sf(playerid)
{	
	new string[256];
	new pName[24];
	if(IsPlayerInAnyVehicle(playerid))
	{
		if(GetPlayerState(playerid) == PLAYER_STATE_DRIVER)
		{
			SetVehiclePos(GetPlayerVehicleID(playerid),-1985.9775390625,138.49540710449,28.008354187012);
			SetVehicleZAngle(GetPlayerVehicleID(playerid), 0.0);
			SetCameraBehindPlayer(playerid);
			format(string, sizeof(string), "%s [ID:%d] телепортирован на San Fierro (/sf)", pName, playerid);
			SendClientMessageToAll(COLOR_YELLOW, string);
			GameTextForPlayer(playerid, "~w~Добро пожаловать на San Fierro! ~G~", 5000, 5);
		}
		else
		{
			SendClientMessage(playerid, COLOR_RED, "GameMode.Error: Вы должны быть в машине!");
		}
	}
	else
	{
		SetPlayerPos(playerid, -1985.9775390625,138.49540710449,28.008354187012);
		SetPlayerFacingAngle(playerid, 0.0);
		SetCameraBehindPlayer(playerid);
		format(string, sizeof(string), "%s [ID:%d] телепортирован на San Fierro (/sf)", pName, playerid);
		SendClientMessageToAll(COLOR_YELLOW, string);
		GameTextForPlayer(playerid, "~w~Добро пожаловать на San Fierro! ~G~", 5000, 5);
	}
	return true;
}
CMD:lv(playerid)
{	
	new string[256];
	new pName[24];
	if(IsPlayerInAnyVehicle(playerid))
	{
		if(GetPlayerState(playerid) == PLAYER_STATE_DRIVER)
		{
			SetVehiclePos(GetPlayerVehicleID(playerid),2003.9881591797,1544.4967041016,13.785161018372);
			SetVehicleZAngle(GetPlayerVehicleID(playerid), 0.0);
			SetCameraBehindPlayer(playerid);
			format(string, sizeof(string), "%s [ID:%d] телепортирован на Las Venturas (/lv)", pName, playerid);
			SendClientMessageToAll(COLOR_YELLOW, string);
			GameTextForPlayer(playerid, "~w~Добро пожаловать на Las Venturas! ~G~", 5000, 5);
		}
		else
		{
			SendClientMessage(playerid, COLOR_RED, "GameMode.Error: Вы должны быть в машине!");
		}
	}
	else
	{
		SetPlayerPos(playerid, 2003.9881591797,1544.4967041016,13.785161018372);
		SetPlayerFacingAngle(playerid, 0.0);
		SetCameraBehindPlayer(playerid);
		format(string, sizeof(string), "%s [ID:%d] телепортирован на Las Venturas (/lv)", pName, playerid);
		SendClientMessageToAll(COLOR_YELLOW, string);
		GameTextForPlayer(playerid, "~w~Добро пожаловать на Las Venturas! ~G~", 5000, 5);
	}
	return true;
}
CMD:chilliad(playerid)
{	
	new string[256];
	new pName[24];
	if(IsPlayerInAnyVehicle(playerid))
	{
		if(GetPlayerState(playerid) == PLAYER_STATE_DRIVER)
		{
			SetVehiclePos(GetPlayerVehicleID(playerid),-2234.4709472656,-1736.5864257813,481.37677001953);
			SetVehicleZAngle(GetPlayerVehicleID(playerid), 0.0);
			SetCameraBehindPlayer(playerid);
			format(string, sizeof(string), "%s [ID:%d] телепортирован на Chilliad (/chilliad)", pName, playerid);
			SendClientMessageToAll(COLOR_YELLOW, string);
			GameTextForPlayer(playerid, "~w~Добро пожаловать на Chilliad! ~G~", 5000, 5);
		}
		else
		{
			SendClientMessage(playerid, COLOR_RED, "GameMode.Error: Вы должны быть в машине!");
		}
	}
	else
	{
		SetPlayerPos(playerid, -2234.4709472656,-1736.5864257813,481.37677001953);
		SetPlayerFacingAngle(playerid, 0.0);
		SetCameraBehindPlayer(playerid);
		format(string, sizeof(string), "%s [ID:%d] телепортирован на Chilliad (/chilliad)", pName, playerid);
		SendClientMessageToAll(COLOR_YELLOW, string);
		GameTextForPlayer(playerid, "~w~Добро пожаловать на Chilliad! ~G~", 5000, 5);
	}
	return true;
}
CMD:lsair(playerid)
{	
	new string[256];
	new pName[24];
	if(IsPlayerInAnyVehicle(playerid))
	{
		if(GetPlayerState(playerid) == PLAYER_STATE_DRIVER)
		{
			SetVehiclePos(GetPlayerVehicleID(playerid),1962.0178222656,-2183.4311523438,13.916575431824);
			SetVehicleZAngle(GetPlayerVehicleID(playerid), 0.0);
			SetCameraBehindPlayer(playerid);
			format(string, sizeof(string), "%s [ID:%d] телепортирован на Los Santos Airport (/lsair)", pName, playerid);
			SendClientMessageToAll(COLOR_YELLOW, string);
			GameTextForPlayer(playerid, "~w~Добро пожаловать на Los Santos Airport! ~G~", 5000, 5);
		}
		else
		{
			SendClientMessage(playerid, COLOR_RED, "GameMode.Error: Вы должны быть в машине!");
		}
	}
	else
	{
		SetPlayerPos(playerid,1962.0178222656,-2183.4311523438,13.916575431824);
		SetPlayerFacingAngle(playerid, 0.0);
		SetCameraBehindPlayer(playerid);
		format(string, sizeof(string), "%s [ID:%d] телепортирован на Los Santos Airport (/lsair)", pName, playerid);
		SendClientMessageToAll(COLOR_YELLOW, string);
		GameTextForPlayer(playerid, "~w~Добро пожаловать на Los Santos Airport! ~G~", 5000, 5);
	}
	return true;
}
CMD:sfair(playerid)
{	
	new string[256];
	new pName[24];
	if(IsPlayerInAnyVehicle(playerid))
	{
		if(GetPlayerState(playerid) == PLAYER_STATE_DRIVER)
		{
			SetVehiclePos(GetPlayerVehicleID(playerid),-1258.97265625,29.321908950806,15.348086357117);
			SetVehicleZAngle(GetPlayerVehicleID(playerid), 0.0);
			SetCameraBehindPlayer(playerid);
			format(string, sizeof(string), "%s [ID:%d] телепортирован на San Fierro Airport (/sfair)", pName, playerid);
			SendClientMessageToAll(COLOR_YELLOW, string);
			GameTextForPlayer(playerid, "~w~Добро пожаловать на San Fierro Airport! ~G~", 5000, 5);
		}
		else
		{
			SendClientMessage(playerid, COLOR_RED, "GameMode.Error: Вы должны быть в машине!");
		}
	}
	else
	{
		SetPlayerPos(playerid,-1258.97265625,29.321908950806,15.348086357117);
		SetPlayerFacingAngle(playerid, 0.0);
		SetCameraBehindPlayer(playerid);
		format(string, sizeof(string), "%s [ID:%d] телепортирован на San Fierro Airport (/sfair)", pName, playerid);
		SendClientMessageToAll(COLOR_YELLOW, string);
		GameTextForPlayer(playerid, "~w~Добро пожаловать на San Fierro Airport! ~G~", 5000, 5);
	}
	return true;
}
CMD:lvair(playerid)
{	
	new string[256];
	new pName[24];
	if(IsPlayerInAnyVehicle(playerid))
	{
		if(GetPlayerState(playerid) == PLAYER_STATE_DRIVER)
		{
			SetVehiclePos(GetPlayerVehicleID(playerid),1318.8817138672,1252.8098144531,11.167939186096);
			SetVehicleZAngle(GetPlayerVehicleID(playerid), 0.0);
			SetCameraBehindPlayer(playerid);
			format(string, sizeof(string), "%s [ID:%d] телепортирован на Las Venturas Airport (/lvair)", pName, playerid);
			SendClientMessageToAll(COLOR_YELLOW, string);
			GameTextForPlayer(playerid, "~w~Добро пожаловать на Las Venturas Airport! ~G~", 5000, 5);
		}
		else
		{
			SendClientMessage(playerid, COLOR_RED, "GameMode.Error: Вы должны быть в машине!");
		}
	}
	else
	{
		SetPlayerPos(playerid,1318.8817138672,1252.8098144531,11.167939186096);
		SetPlayerFacingAngle(playerid, 0.0);
		SetCameraBehindPlayer(playerid);
		format(string, sizeof(string), "%s [ID:%d] телепортирован на Las Venturas Airport (/lvair)", pName, playerid);
		SendClientMessageToAll(COLOR_YELLOW, string);
		GameTextForPlayer(playerid, "~w~Добро пожаловать на Las Venturas Airport! ~G~", 5000, 5);
	}
	return true;
}
CMD:lspd(playerid)
{	
	new string[256];
	new pName[24];
	if(IsPlayerInAnyVehicle(playerid))
	{
		if(GetPlayerState(playerid) == PLAYER_STATE_DRIVER)
		{
			SetVehiclePos(GetPlayerVehicleID(playerid),1541.4703369141,-1683.0941162109,14.26225566864);
			SetVehicleZAngle(GetPlayerVehicleID(playerid), 0.0);
			SetCameraBehindPlayer(playerid);
			format(string, sizeof(string), "%s [ID:%d] телепортирован на Los Santos Police Department (/lspd)", pName, playerid);
			SendClientMessageToAll(COLOR_YELLOW, string);
			GameTextForPlayer(playerid, "~w~Добро пожаловать на Los Santos Police Department! ~G~", 5000, 5);
		}
		else
		{
			SendClientMessage(playerid, COLOR_RED, "GameMode.Error: Вы должны быть в машине!");
		}
	}
	else
	{
		SetPlayerPos(playerid,1541.4703369141,-1683.0941162109,14.26225566864);
		SetPlayerFacingAngle(playerid, 0.0);
		SetCameraBehindPlayer(playerid);
		format(string, sizeof(string), "%s [ID:%d] телепортирован на Los Santos Police Department (/lspd)", pName, playerid);
		SendClientMessageToAll(COLOR_YELLOW, string);
		GameTextForPlayer(playerid, "~w~Добро пожаловать на Los Santos Police Department! ~G~", 5000, 5);
	}
	return true;
}
CMD:sfpd(playerid)
{	
	new string[256];
	new pName[24];
	if(IsPlayerInAnyVehicle(playerid))
	{
		if(GetPlayerState(playerid) == PLAYER_STATE_DRIVER)
		{
			SetVehiclePos(GetPlayerVehicleID(playerid),-1616.4086914063,681.66888427734,7.465208530426);
			SetVehicleZAngle(GetPlayerVehicleID(playerid), 0.0);
			SetCameraBehindPlayer(playerid);
			format(string, sizeof(string), "%s [ID:%d] телепортирован на San Fierro Police Department (/sfpd)", pName, playerid);
			SendClientMessageToAll(COLOR_YELLOW, string);
			GameTextForPlayer(playerid, "~w~Добро пожаловать на San Fierro Police Department! ~G~", 5000, 5);
		}
		else
		{
			SendClientMessage(playerid, COLOR_RED, "GameMode.Error: Вы должны быть в машине!");
		}
	}
	else
	{
		SetPlayerPos(playerid,-1616.4086914063,681.66888427734,7.465208530426);
		SetPlayerFacingAngle(playerid, 0.0);
		SetCameraBehindPlayer(playerid);
		format(string, sizeof(string), "%s [ID:%d] телепортирован на San Fierro Police Department (/sfpd)", pName, playerid);
		SendClientMessageToAll(COLOR_YELLOW, string);
		GameTextForPlayer(playerid, "~w~Добро пожаловать на San Fierro Police Department! ~G~", 5000, 5);
	}
	return true;
}
CMD:lvpd(playerid)
{	
	new string[256];
	new pName[24];
	if(IsPlayerInAnyVehicle(playerid))
	{
		if(GetPlayerState(playerid) == PLAYER_STATE_DRIVER)
		{
			SetVehiclePos(GetPlayerVehicleID(playerid),2240.849609375,2449.4326171875,11.949013710022);
			SetVehicleZAngle(GetPlayerVehicleID(playerid), 0.0);
			SetCameraBehindPlayer(playerid);
			format(string, sizeof(string), "%s [ID:%d] телепортирован на Las Venturas Police Department (/lvpd)", pName, playerid);
			SendClientMessageToAll(COLOR_YELLOW, string);
			GameTextForPlayer(playerid, "~w~Добро пожаловать на Las Venturas Police Department! ~G~", 5000, 5);
		}
		else
		{
			SendClientMessage(playerid, COLOR_RED, "GameMode.Error: Вы должны быть в машине!");
		}
	}
	else
	{
		SetPlayerPos(playerid,2240.849609375,2449.4326171875,11.949013710022);
		SetPlayerFacingAngle(playerid, 0.0);
		SetCameraBehindPlayer(playerid);
		format(string, sizeof(string), "%s [ID:%d] телепортирован на Las Venturas Police Department (/lvpd)", pName, playerid);
		SendClientMessageToAll(COLOR_YELLOW, string);
		GameTextForPlayer(playerid, "~w~Добро пожаловать на Las Venturas Police Department! ~G~", 5000, 5);
	}
	return true;
}
CMD:aa(playerid)
{	
	new string[256];
	new pName[24];
	if(IsPlayerInAnyVehicle(playerid))
	{
		if(GetPlayerState(playerid) == PLAYER_STATE_DRIVER)
		{
			SetVehiclePos(GetPlayerVehicleID(playerid),404.32720947266,2452.1518554688,16.990623474121);
			SetVehicleZAngle(GetPlayerVehicleID(playerid), 0.0);
			SetCameraBehindPlayer(playerid);
			format(string, sizeof(string), "%s [ID:%d] телепортирован на Abandoned Airport (/aa)", pName, playerid);
			SendClientMessageToAll(COLOR_YELLOW, string);
			GameTextForPlayer(playerid, "~w~Добро пожаловать на Abandoned Airport! ~G~", 5000, 5);
		}
		else
		{
			SendClientMessage(playerid, COLOR_RED, "GameMode.Error: Вы должны быть в машине!");
		}
	}
	else
	{
		SetPlayerPos(playerid,404.32720947266,2452.1518554688,16.990623474121);
		SetPlayerFacingAngle(playerid, 0.0);
		SetCameraBehindPlayer(playerid);
		format(string, sizeof(string), "%s [ID:%d] телепортирован на Abandoned Airport (/aa)", pName, playerid);
		SendClientMessageToAll(COLOR_YELLOW, string);
		GameTextForPlayer(playerid, "~w~Добро пожаловать на Abandoned Airport! ~G~", 5000, 5);
	}
	return true;
}
CMD:sdrift1(playerid)
{	
	new string[256];
	new pName[24];
	if(IsPlayerInAnyVehicle(playerid))
	{
		if(GetPlayerState(playerid) == PLAYER_STATE_DRIVER)
		{
			SetVehiclePos(GetPlayerVehicleID(playerid),-308.98721313477,1536.6369628906,75.495559692383);
			SetVehicleZAngle(GetPlayerVehicleID(playerid), 0.0);
			SetCameraBehindPlayer(playerid);
			format(string, sizeof(string), "%s [ID:%d] телепортирован на SDrift 1 (/sdrift1)", pName, playerid);
			SendClientMessageToAll(COLOR_YELLOW, string);
			GameTextForPlayer(playerid, "~w~Добро пожаловать на SDrift 1! ~G~", 5000, 5);
		}
		else
		{
			SendClientMessage(playerid, COLOR_RED, "GameMode.Error: Вы должны быть в машине!");
		}
	}
	else
	{
		SetPlayerPos(playerid,-308.98721313477,1536.6369628906,75.495559692383);
		SetPlayerFacingAngle(playerid, 0.0);
		SetCameraBehindPlayer(playerid);
		format(string, sizeof(string), "%s [ID:%d] телепортирован на SDrift 1 (/sdrift1)", pName, playerid);
		SendClientMessageToAll(COLOR_YELLOW, string);
		GameTextForPlayer(playerid, "~w~Добро пожаловать на SDrift 1! ~G~", 5000, 5);
	}
	return true;
}
CMD:sdrift2(playerid)
{	
	new string[256];
	new pName[24];
	if(IsPlayerInAnyVehicle(playerid))
	{
		if(GetPlayerState(playerid) == PLAYER_STATE_DRIVER)
		{
			SetVehiclePos(GetPlayerVehicleID(playerid),2342.1010742188,1398.7923583984,43.355499267578);
			SetVehicleZAngle(GetPlayerVehicleID(playerid), 0.0);
			SetCameraBehindPlayer(playerid);
			format(string, sizeof(string), "%s [ID:%d] телепортирован на SDrift 2 (/sdrift2)", pName, playerid);
			SendClientMessageToAll(COLOR_YELLOW, string);
			GameTextForPlayer(playerid, "~w~Добро пожаловать на SDrift 2! ~G~", 5000, 5);
		}
		else
		{
			SendClientMessage(playerid, COLOR_RED, "GameMode.Error: Вы должны быть в машине!");
		}
	}
	else
	{
		SetPlayerPos(playerid,2342.1010742188,1398.7923583984,43.355499267578);
		SetPlayerFacingAngle(playerid, 0.0);
		SetCameraBehindPlayer(playerid);
		format(string, sizeof(string), "%s [ID:%d] телепортирован на SDrift 2 (/sdrift2)", pName, playerid);
		SendClientMessageToAll(COLOR_YELLOW, string);
		GameTextForPlayer(playerid, "~w~Добро пожаловать на SDrift 2! ~G~", 5000, 5);
	}
	return true;
}
CMD:sdrift3(playerid)
{	
	new string[256];
	new pName[24];
	SetPlayerPos(playerid,2285.5529785156,1964.0476074219,31.797733306885);
	if(IsPlayerInAnyVehicle(playerid))
	{
		if(GetPlayerState(playerid) == PLAYER_STATE_DRIVER)
		{
			SetVehiclePos(GetPlayerVehicleID(playerid),2285.5529785156,1964.0476074219,31.797733306885);
			SetVehicleZAngle(GetPlayerVehicleID(playerid), 0.0);
			SetCameraBehindPlayer(playerid);
			format(string, sizeof(string), "%s [ID:%d] телепортирован на SDrift 3 (/sdrift3)", pName, playerid);
			SendClientMessageToAll(COLOR_YELLOW, string);
			GameTextForPlayer(playerid, "~w~Добро пожаловать на SDrift 3! ~G~", 5000, 5);
		}
		else
		{
			SendClientMessage(playerid, COLOR_RED, "GameMode.Error: Вы должны быть в машине!");
		}
	}
	else
	{
		SetPlayerPos(playerid,2285.5529785156,1964.0476074219,31.797733306885);
		SetPlayerFacingAngle(playerid, 0.0);
		SetCameraBehindPlayer(playerid);
		format(string, sizeof(string), "%s [ID:%d] телепортирован на SDrift 3 (/sdrift3)", pName, playerid);
		SendClientMessageToAll(COLOR_YELLOW, string);
		GameTextForPlayer(playerid, "~w~Добро пожаловать на SDrift 3! ~G~", 5000, 5);
	}
	return true;
}
CMD:trans(playerid)
{	
	new string[256];
	new pName[24];
	if(IsPlayerInAnyVehicle(playerid))
	{
		if(GetPlayerState(playerid) == PLAYER_STATE_DRIVER)
		{
			SetVehiclePos(GetPlayerVehicleID(playerid),1041.0904541016,-1033.6147460938,32.341972351074);
			SetVehicleZAngle(GetPlayerVehicleID(playerid), 0.0);
			SetCameraBehindPlayer(playerid);
			format(string, sizeof(string), "%s [ID:%d] телепортирован на Transport (/trans)", pName, playerid);
			SendClientMessageToAll(COLOR_YELLOW, string);
			GameTextForPlayer(playerid, "~w~Добро пожаловать на Transport! ~G~", 5000, 5);
		}
		else
		{
			SendClientMessage(playerid, COLOR_RED, "GameMode.Error: Вы должны быть в машине!");
		}
	}
	else
	{
		SetPlayerPos(playerid,1041.0904541016,-1033.6147460938,32.341972351074);
		SetPlayerFacingAngle(playerid, 0.0);
		SetCameraBehindPlayer(playerid);
		format(string, sizeof(string), "%s [ID:%d] телепортирован на Transport (/trans)", pName, playerid);
		SendClientMessageToAll(COLOR_YELLOW, string);
		GameTextForPlayer(playerid, "~w~Добро пожаловать на Transport! ~G~", 5000, 5);
	}
	return true;
}
CMD:loco(playerid)
{	
	new string[256];
	new pName[24];
	if(IsPlayerInAnyVehicle(playerid))
	{
		if(GetPlayerState(playerid) == PLAYER_STATE_DRIVER)
		{
			SetVehiclePos(GetPlayerVehicleID(playerid),2645.1872558594,-2017.2416992188,13.325689315796);
			SetVehicleZAngle(GetPlayerVehicleID(playerid), 0.0);
			SetCameraBehindPlayer(playerid);
			format(string, sizeof(string), "%s [ID:%d] телепортирован на Loco Low Co. (/loco)", pName, playerid);
			SendClientMessageToAll(COLOR_YELLOW, string);
			GameTextForPlayer(playerid, "~w~Добро пожаловать на Loco Low Co.! ~G~", 5000, 5);
		}
		else
		{
			SendClientMessage(playerid, COLOR_RED, "GameMode.Error: Вы должны быть в машине!");
		}
	}
	else
	{
		SetPlayerPos(playerid,2645.1872558594,-2017.2416992188,13.325689315796);
		SetPlayerFacingAngle(playerid, 0.0);
		SetCameraBehindPlayer(playerid);
		format(string, sizeof(string), "%s [ID:%d] телепортирован на Loco Low Co. (/loco)", pName, playerid);
		SendClientMessageToAll(COLOR_YELLOW, string);
		GameTextForPlayer(playerid, "~w~Добро пожаловать на Loco Low Co.! ~G~", 5000, 5);
	}
	return true;
}
CMD:arch(playerid)
{	
	new string[256];
	new pName[24];
	if(IsPlayerInAnyVehicle(playerid))
	{
		if(GetPlayerState(playerid) == PLAYER_STATE_DRIVER)
		{
			SetVehiclePos(GetPlayerVehicleID(playerid),-2705.3400878906,217.48022460938,3.8556115627289);
			SetVehicleZAngle(GetPlayerVehicleID(playerid), 0.0);
			SetCameraBehindPlayer(playerid);
			format(string, sizeof(string), "%s [ID:%d] телепортирован на Architectural Espionage (/arch)", pName, playerid);
			SendClientMessageToAll(COLOR_YELLOW, string);
			GameTextForPlayer(playerid, "~w~Добро пожаловать на Architectural Espionage! ~G~", 5000, 5);
		}
		else
		{
			SendClientMessage(playerid, COLOR_RED, "GameMode.Error: Вы должны быть в машине!");
		}
	}
	else
	{
		SetPlayerPos(playerid,-2705.3400878906,217.48022460938,3.8556115627289);
		SetPlayerFacingAngle(playerid, 0.0);
		SetCameraBehindPlayer(playerid);
		format(string, sizeof(string), "%s [ID:%d] телепортирован на Architectural Espionage (/arch)", pName, playerid);
		SendClientMessageToAll(COLOR_YELLOW, string);
		GameTextForPlayer(playerid, "~w~Добро пожаловать на Architectural Espionage! ~G~", 5000, 5);
	}
	return true;
}
CMD:area51(playerid)
{	
	new string[256];
	new pName[24];
	if(IsPlayerInAnyVehicle(playerid))
	{
		if(GetPlayerState(playerid) == PLAYER_STATE_DRIVER)
		{
			SetVehiclePos(GetPlayerVehicleID(playerid),213.86730957031,1869.2495117188,12.811868667603);
			SetVehicleZAngle(GetPlayerVehicleID(playerid), 0.0);
			SetCameraBehindPlayer(playerid);
			format(string, sizeof(string), "%s [ID:%d] телепортирован на Area 51 (/area51)", pName, playerid);
			SendClientMessageToAll(COLOR_YELLOW, string);
			GameTextForPlayer(playerid, "~w~Добро пожаловать на Area 51! ~G~", 5000, 5);
		}
		else
		{
			SendClientMessage(playerid, COLOR_RED, "GameMode.Error: Вы должны быть в машине!");
		}
	}
	else
	{
		SetPlayerPos(playerid, 213.86730957031,1869.2495117188,12.811868667603);
		SetPlayerFacingAngle(playerid, 0.0);
		SetCameraBehindPlayer(playerid);
		format(string, sizeof(string), "%s [ID:%d] телепортирован на Area 51 (/area51)", pName, playerid);
		SendClientMessageToAll(COLOR_YELLOW, string);
		GameTextForPlayer(playerid, "~w~Добро пожаловать на Area 51! ~G~", 5000, 5);
	}
	return true;
}
CMD:farm(playerid)
{	
	new string[256];
	new pName[24];
	if(IsPlayerInAnyVehicle(playerid))
	{
		if(GetPlayerState(playerid) == PLAYER_STATE_DRIVER)
		{
			SetVehiclePos(GetPlayerVehicleID(playerid),-1059.3493652344,-1195.5015869141,130.05325317383);
			SetVehicleZAngle(GetPlayerVehicleID(playerid), 0.0);
			SetCameraBehindPlayer(playerid);
			format(string, sizeof(string), "%s [ID:%d] телепортирован на Farm (/farm)", pName, playerid);
			SendClientMessageToAll(COLOR_YELLOW, string);
			GameTextForPlayer(playerid, "~w~Добро пожаловать на Farm! ~G~", 5000, 5);
		}
		else
		{
			SendClientMessage(playerid, COLOR_RED, "GameMode.Error: Вы должны быть в машине!");
		}
	}
	else
	{
		SetPlayerPos(playerid, -1059.3493652344,-1195.5015869141,130.05325317383);
		SetPlayerFacingAngle(playerid, 0.0);
		SetCameraBehindPlayer(playerid);
		format(string, sizeof(string), "%s [ID:%d] телепортирован на Farm (/farm)", pName, playerid);
		SendClientMessageToAll(COLOR_YELLOW, string);
		GameTextForPlayer(playerid, "~w~Добро пожаловать на Farm! ~G~", 5000, 5);
	}
	return true;
}
CMD:4dragons(playerid)
{	
	new string[256];
	new pName[24];
	if(IsPlayerInAnyVehicle(playerid))
	{
		if(GetPlayerState(playerid) == PLAYER_STATE_DRIVER)
		{
			SetVehiclePos(GetPlayerVehicleID(playerid),2028.6000976563,1008.0216064453,10.786623001099);
			SetVehicleZAngle(GetPlayerVehicleID(playerid), 0.0);
			SetCameraBehindPlayer(playerid);
			format(string, sizeof(string), "%s [ID:%d] телепортирован на The Four Dragons Casino (/4dragons)", pName, playerid);
			SendClientMessageToAll(COLOR_YELLOW, string);
			GameTextForPlayer(playerid, "~w~Добро пожаловать на The Four Dragons Casino! ~G~", 5000, 5);
		}
		else
		{
			SendClientMessage(playerid, COLOR_RED, "GameMode.Error: Вы должны быть в машине!");
		}
	}
	else
	{
		SetPlayerPos(playerid, 2028.6000976563,1008.0216064453,10.786623001099);
		SetPlayerFacingAngle(playerid, 0.0);
		SetCameraBehindPlayer(playerid);
		format(string, sizeof(string), "%s [ID:%d] телепортирован на The Four Dragons Casino (/4dragons)", pName, playerid);
		SendClientMessageToAll(COLOR_YELLOW, string);
		GameTextForPlayer(playerid, "~w~Добро пожаловать на The Four Dragons Casino! ~G~", 5000, 5);
	}
	return true;
}
CMD:ammulv(playerid)
{	
	new string[256];
	new pName[24];
	if(IsPlayerInAnyVehicle(playerid))
	{
		if(GetPlayerState(playerid) == PLAYER_STATE_DRIVER)
		{
			SetVehiclePos(GetPlayerVehicleID(playerid),2153.634765625,942.84271240234,11.116275787354);
			SetVehicleZAngle(GetPlayerVehicleID(playerid), 0.0);
			SetCameraBehindPlayer(playerid);
			format(string, sizeof(string), "%s [ID:%d] телепортирован на Ammu-Nation Las Venturas (/ammulv)", pName, playerid);
			SendClientMessageToAll(COLOR_YELLOW, string);
			GameTextForPlayer(playerid, "~w~Добро пожаловать на Ammu-Nation Las Venturas! ~G~", 5000, 5);
		}
		else
		{
			SendClientMessage(playerid, COLOR_RED, "GameMode.Error: Вы должны быть в машине!");
		}
	}
	else
	{
		SetPlayerPos(playerid, 2153.634765625,942.84271240234,11.116275787354);
		SetPlayerFacingAngle(playerid, 0.0);
		SetCameraBehindPlayer(playerid);
		format(string, sizeof(string), "%s [ID:%d] телепортирован на Ammu-Nation Las Venturas (/ammulv)", pName, playerid);
		SendClientMessageToAll(COLOR_YELLOW, string);
		GameTextForPlayer(playerid, "~w~Добро пожаловать на Ammu-Nation Las Venturas! ~G~", 5000, 5);
	}
	return true;
}
CMD:ammusf(playerid)
{	
	new string[256];
	new pName[24];
	if(IsPlayerInAnyVehicle(playerid))
	{
		if(GetPlayerState(playerid) == PLAYER_STATE_DRIVER)
		{
			SetVehiclePos(GetPlayerVehicleID(playerid),-2626.9919433594,213.13157653809,4.4227476119995);
			SetVehicleZAngle(GetPlayerVehicleID(playerid), 0.0);
			SetCameraBehindPlayer(playerid);
			format(string, sizeof(string), "%s [ID:%d] телепортирован на Ammu-Nation San Fierro (/ammusf)", pName, playerid);
			SendClientMessageToAll(COLOR_YELLOW, string);
			GameTextForPlayer(playerid, "~w~Добро пожаловать на Ammu-Nation San Fierro! ~G~", 5000, 5);
		}
		else
		{
			SendClientMessage(playerid, COLOR_RED, "GameMode.Error: Вы должны быть в машине!");
		}
	}
	else
	{
		SetPlayerPos(playerid, -2626.9919433594,213.13157653809,4.4227476119995);
		SetPlayerFacingAngle(playerid, 0.0);
		SetCameraBehindPlayer(playerid);
		format(string, sizeof(string), "%s [ID:%d] телепортирован на Ammu-Nation San Fierro (/ammusf)", pName, playerid);
		SendClientMessageToAll(COLOR_YELLOW, string);
		GameTextForPlayer(playerid, "~w~Добро пожаловать на Ammu-Nation San Fierro! ~G~", 5000, 5);
	}
	return true;
}
CMD:ammuls(playerid)
{	
	new string[256];
	new pName[24];
	if(IsPlayerInAnyVehicle(playerid))
	{
		if(GetPlayerState(playerid) == PLAYER_STATE_DRIVER)
		{
			SetVehiclePos(GetPlayerVehicleID(playerid),1364.6674804688,-1280.0222167969,13.651518821716);
			SetVehicleZAngle(GetPlayerVehicleID(playerid), 0.0);
			SetCameraBehindPlayer(playerid);
			format(string, sizeof(string), "%s [ID:%d] телепортирован на Ammu-Nation Los Santos (/ammuls)", pName, playerid);
			SendClientMessageToAll(COLOR_YELLOW, string);
			GameTextForPlayer(playerid, "~w~Добро пожаловать на Ammu-Nation Los Santos! ~G~", 5000, 5);
		}
		else
		{
			SendClientMessage(playerid, COLOR_RED, "GameMode.Error: Вы должны быть в машине!");
		}
	}
	else
	{
		SetPlayerPos(playerid, 1364.6674804688,-1280.0222167969,13.651518821716);
		SetPlayerFacingAngle(playerid, 0.0);
		SetCameraBehindPlayer(playerid);
		format(string, sizeof(string), "%s [ID:%d] телепортирован на Ammu-Nation Los Santos (/ammuls)", pName, playerid);
		SendClientMessageToAll(COLOR_YELLOW, string);
		GameTextForPlayer(playerid, "~w~Добро пожаловать на Ammu-Nation Los Santos! ~G~", 5000, 5);
	}
	return true;
}
CMD:thebank(playerid)
{	
	new string[256];
	new pName[24];
	if(IsPlayerInAnyVehicle(playerid))
	{
		if(GetPlayerState(playerid) == PLAYER_STATE_DRIVER)
		{
			SetVehiclePos(GetPlayerVehicleID(playerid),1460.8756103516,-1026.2967529297,23.937147140503);
			SetVehicleZAngle(GetPlayerVehicleID(playerid), 0.0);
			SetCameraBehindPlayer(playerid);
			format(string, sizeof(string), "%s [ID:%d] телепортирован на The Bank (/thebank)", pName, playerid);
			SendClientMessageToAll(COLOR_YELLOW, string);
			GameTextForPlayer(playerid, "~w~Добро пожаловать на The Bank! ~G~", 5000, 5);
		}
		else
		{
			SendClientMessage(playerid, COLOR_RED, "GameMode.Error: Вы должны быть в машине!");
		}
	}
	else
	{
		SetPlayerPos(playerid, 1460.8756103516,-1026.2967529297,23.937147140503);
		SetPlayerFacingAngle(playerid, 0.0);
		SetCameraBehindPlayer(playerid);
		format(string, sizeof(string), "%s [ID:%d] телепортирован на The Bank (/thebank)", pName, playerid);
		SendClientMessageToAll(COLOR_YELLOW, string);
		GameTextForPlayer(playerid, "~w~Добро пожаловать на The Bank! ~G~", 5000, 5);
	}
	return true;
}
CMD:driftcircle(playerid)
{	
	new string[256];
	new pName[24];
	if(!IsPlayerInAnyVehicle(playerid))
	{
		GetPlayerName(playerid, pName, sizeof(pName));
		format(string, sizeof(string), "%s [ID:%d] телепортирован на Drift Circle (/driftcircle)", pName, playerid);
		SendClientMessageToAll(COLOR_YELLOW, string);
		SetPlayerPos(playerid,-2693.8916,335.3300,4.1872);
		SetPlayerFacingAngle(playerid,88.6440);
		SetPlayerInterior(playerid,0);
		GameTextForPlayer(playerid, "~r~Добро пожаловать на Drift Circle", 5000, 5);
	}
	else
	{
		GetPlayerName(playerid, pName, sizeof(pName));
		format(string, sizeof(string), "%s [ID:%d] телепортирован на Drift Circle (/driftcircle)", pName, playerid);
		SendClientMessageToAll(COLOR_YELLOW, string);
		SetVehiclePos(GetPlayerVehicleID(playerid),-2693.8916,335.3300,4.1872);
		SetVehicleZAngle(GetPlayerVehicleID(playerid),88.6440);
		SetPlayerInterior(playerid,0);
		LinkVehicleToInterior(GetPlayerVehicleID(playerid),0);
		GameTextForPlayer(playerid, "~r~Добро пожаловать на Drift Circle", 5000, 5);
	}
	return true;
}
CMD:driftschool(playerid)
{	
	new string[256];
	new pName[24];
	if(!IsPlayerInAnyVehicle(playerid))
	{
		GetPlayerName(playerid, pName, sizeof(pName));
		format(string, sizeof(string), "%s [ID:%d] телепортирован на Drift School (/driftschool)", pName, playerid);
		SendClientMessageToAll(COLOR_YELLOW, string);
		SetPlayerPos(playerid,1138.2185,1357.6690,10.4783);
		SetPlayerFacingAngle(playerid,179.2724);
		SetPlayerInterior(playerid,0);
		GameTextForPlayer(playerid, "~r~Добро пожаловать на Drift School", 5000, 5);
	}
	else
	{
		GetPlayerName(playerid, pName, sizeof(pName));
		format(string, sizeof(string), "%s [ID:%d] телепортирован на Drift School (/driftschool)", pName, playerid);
		SendClientMessageToAll(COLOR_YELLOW, string);
		SetVehiclePos(GetPlayerVehicleID(playerid),1138.2185,1357.6690,10.4783);
		SetVehicleZAngle(GetPlayerVehicleID(playerid),179.2724);
		SetPlayerInterior(playerid,0);
		LinkVehicleToInterior(GetPlayerVehicleID(playerid),0);
		GameTextForPlayer(playerid, "~r~Добро пожаловать на Drift School", 5000, 5);
	}
	return true;
}
CMD:skydrift(playerid)
{	
	new string[256];
	new pName[24];
	if(!IsPlayerInAnyVehicle(playerid))
	{
		GetPlayerName(playerid, pName, sizeof(pName));
		format(string, sizeof(string), "%s [ID:%d] телепортирован на Sky Drift (/skydrift)", pName, playerid);
		SendClientMessageToAll(COLOR_YELLOW, string);
		SetPlayerPos(playerid,1114.8033,1504.1325,50.7243);
		SetPlayerFacingAngle(playerid,2.5815);
		SetPlayerInterior(playerid,0);
		GameTextForPlayer(playerid, "~r~Добро пожаловать на Sky Drift", 5000, 5);
	}
	else
	{
		GetPlayerName(playerid, pName, sizeof(pName));
		format(string, sizeof(string), "%s [ID:%d] телепортирован на Sky Drift (/skydrift)", pName, playerid);
		SetVehiclePos(GetPlayerVehicleID(playerid),1114.8033,1504.1325,50.7243);
		SetVehicleZAngle(GetPlayerVehicleID(playerid),2.5815);
		SetPlayerInterior(playerid,0);
		LinkVehicleToInterior(GetPlayerVehicleID(playerid),0);
		GameTextForPlayer(playerid, "~r~Добро пожаловать на Sky Drift", 5000, 5);
	}
	return true;
}
CMD:drift1(playerid)
{	
	new string[256];
	new pName[24];
	if(IsPlayerInAnyVehicle(playerid))
	{
		if(GetPlayerState(playerid) == PLAYER_STATE_DRIVER)
		{
			SetVehiclePos(GetPlayerVehicleID(playerid), -358.1943,1531.2909,75.1698 );
			SetVehicleZAngle(GetPlayerVehicleID(playerid), 264.7289);
			SetCameraBehindPlayer(playerid);
			format(string, sizeof(string), "%s [ID:%d] телепортирован на Drift 1 (/drift1)", pName, playerid);
			SendClientMessageToAll(COLOR_YELLOW, string);
			GameTextForPlayer(playerid, "~w~Добро пожаловать на Drift 1! ~G~", 5000, 5);
		}
		else SendClientMessage(playerid, COLOR_RED, "GameMode.Error: Вы должны быть в машине!");
	}
	else
	{
		SetPlayerPos(playerid, -329.3348,1536.3771,76.6117 );
		SetPlayerFacingAngle(playerid, 276.8851);
		SetCameraBehindPlayer(playerid);
		format(string, sizeof(string), "%s [ID:%d] телепортирован на Drift 1 (/drift1)", pName, playerid);
		SendClientMessageToAll(COLOR_YELLOW, string);
		GameTextForPlayer(playerid, "~w~Добро пожаловать на Drift 1! ~G~", 5000, 5);
	}
	return true;
}
CMD:drift2(playerid)
{	
	new string[256];
	new pName[24];
	if(IsPlayerInAnyVehicle(playerid))
	{
		if(GetPlayerState(playerid) == PLAYER_STATE_DRIVER)
		{
			SetVehiclePos(GetPlayerVehicleID(playerid), 2265.3010,1399.5085,42.8203);
			SetVehicleZAngle(GetPlayerVehicleID(playerid), 269.7637);
			SetCameraBehindPlayer(playerid);
			format(string, sizeof(string), "%s [ID:%d] телепортирован на Drift 2 (/drift2)", pName, playerid);
			SendClientMessageToAll(COLOR_YELLOW, string);
			GameTextForPlayer(playerid, "~w~Добро пожаловать на Drift 2! ~G~", 5000, 5);
		}
		else
		{
			SendClientMessage(playerid, COLOR_RED, "GameMode.Error: Вы должны быть в машине!");
		}
	}
	else
	{
		SetPlayerPos(playerid, 2265.3010,1399.5085,42.8203);
		SetPlayerFacingAngle(playerid, 110.5445);
		SetCameraBehindPlayer(playerid);
		format(string, sizeof(string), "%s [ID:%d] телепортирован на Drift 2 (/drift2)", pName, playerid);
		SendClientMessageToAll(COLOR_YELLOW, string);
		GameTextForPlayer(playerid, "~w~Добро пожаловать на Drift 2! ~G~", 5000, 5);
	}
	return true;
}
CMD:drift3(playerid)
{	
	new string[256];
	new pName[24];
	if(IsPlayerInAnyVehicle(playerid))
	{
		if(GetPlayerState(playerid) == PLAYER_STATE_DRIVER)
		{
			SetVehiclePos(GetPlayerVehicleID(playerid), -2489.8352,-616.3492,132.5658);
			SetVehicleZAngle(GetPlayerVehicleID(playerid), 178.7448);
			SetCameraBehindPlayer(playerid);
			format(string, sizeof(string), "%s [ID:%d] телепортирован на Drift 3 (/drift3)", pName, playerid);
			SendClientMessageToAll(COLOR_YELLOW, string);
			GameTextForPlayer(playerid, "~w~Добро пожаловать на Drift 3! ~G~", 5000, 5);
		}
		else
		{
			SendClientMessage(playerid, COLOR_RED, "GameMode.Error: Вы должны быть в машине!");
		}
	}
	else
	{
		SetPlayerPos(playerid, -2489.8352,-616.3492,132.5658);
		SetPlayerFacingAngle(playerid, 110.5445);
		SetCameraBehindPlayer(playerid);
		format(string, sizeof(string), "%s [ID:%d] телепортирован на Drift 3 (/drift3)", pName, playerid);
		SendClientMessageToAll(COLOR_YELLOW, string);
		GameTextForPlayer(playerid, "~w~Добро пожаловать на Drift 3! ~G~", 5000, 5);
	}
	return true;
}
CMD:drift4(playerid)
{	
	new string[256];
	new pName[24];
	if(IsPlayerInAnyVehicle(playerid))
	{
		if(GetPlayerState(playerid) == PLAYER_STATE_DRIVER)
		{
			SetVehiclePos(GetPlayerVehicleID(playerid), 2243.2185,1963.3853,31.7797);
			SetVehicleZAngle(GetPlayerVehicleID(playerid), 178.7448);
			SetCameraBehindPlayer(playerid);
			format(string, sizeof(string), "%s [ID:%d] телепортирован на Drift 4 (/drift4)", pName, playerid);
			SendClientMessageToAll(COLOR_YELLOW, string);
			GameTextForPlayer(playerid, "~w~Добро пожаловать на Drift 4! ~G~", 5000, 5);
		}
		else
		{
			SendClientMessage(playerid, COLOR_RED, "GameMode.Error: Вы должны быть в машине!");
		}
	}
	else
	{
		SetPlayerPos(playerid, 2243.2185,1963.3853,31.7797);
		SetPlayerFacingAngle(playerid, 110.5445);
		SetCameraBehindPlayer(playerid);
		format(string, sizeof(string), "%s [ID:%d] телепортирован на Drift 4 (/drift4)", pName, playerid);
		SendClientMessageToAll(COLOR_YELLOW, string);
		GameTextForPlayer(playerid, "~w~Добро пожаловать на Drift 4! ~G~", 5000, 5);
	}
	return true;
}
CMD:drift5(playerid)
{	
	new string[256];
	new pName[24];
	if(IsPlayerInAnyVehicle(playerid))
	{
		if(GetPlayerState(playerid) == PLAYER_STATE_DRIVER)
		{
			SetVehiclePos(GetPlayerVehicleID(playerid), 1146.2200,2178.7068,10.8203);
			SetVehicleZAngle(GetPlayerVehicleID(playerid), 178.7448);
			SetCameraBehindPlayer(playerid);
			format(string, sizeof(string), "%s [ID:%d] телепортирован на Drift 5 (/drift5)", pName, playerid);
			SendClientMessageToAll(COLOR_YELLOW, string);
			GameTextForPlayer(playerid, "~w~Добро пожаловать на Drift 5! ~G~", 5000, 5);
		}
		else
		{
			SendClientMessage(playerid, COLOR_RED, "GameMode.Error: Вы должны быть в машине!");
		}
	}
	else
	{
		SetPlayerPos(playerid, 1146.2200,2178.7068,10.8203);
		SetPlayerFacingAngle(playerid, 110.5445);
		SetCameraBehindPlayer(playerid);
		format(string, sizeof(string), "%s [ID:%d] телепортирован на Drift 5 (/drift5)", pName, playerid);
		SendClientMessageToAll(COLOR_YELLOW, string);
		GameTextForPlayer(playerid, "~w~Добро пожаловать на Drift 5! ~G~", 5000, 5);
	}
	return true;
}
CMD:drift6(playerid)
{	
	new string[256];
	new pName[24];
	if(IsPlayerInAnyVehicle(playerid))
	{
		if(GetPlayerState(playerid) == PLAYER_STATE_DRIVER)
		{
			SetVehiclePos(GetPlayerVehicleID(playerid), 1886.9543,1813.2212,18.9339);
			SetVehicleZAngle(GetPlayerVehicleID(playerid), 178.7448);
			SetCameraBehindPlayer(playerid);
			format(string, sizeof(string), "%s [ID:%d] телепортирован на Drift 6 (/drift6)", pName, playerid);
			SendClientMessageToAll(COLOR_YELLOW, string);
			GameTextForPlayer(playerid, "~w~Добро пожаловать на Drift 6! ~G~", 5000, 5);
		}
		else
		{
			SendClientMessage(playerid, COLOR_RED, "GameMode.Error: Вы должны быть в машине!");
		}
	}
	else
	{
		SetPlayerPos(playerid, 1886.9543,1813.2212,18.9339);
		SetPlayerFacingAngle(playerid, 110.5445);
		SetCameraBehindPlayer(playerid);
		format(string, sizeof(string), "%s [ID:%d] телепортирован на Drift 6 (/drift6)", pName, playerid);
		SendClientMessageToAll(COLOR_YELLOW, string);
		GameTextForPlayer(playerid, "~w~Добро пожаловать на Drift 6! ~G~", 5000, 5);
	}
	return true;
}
CMD:drift7(playerid)
{	
	new string[256];
	new pName[24];
	if(IsPlayerInAnyVehicle(playerid))
	{
		if(GetPlayerState(playerid) == PLAYER_STATE_DRIVER)
		{
			SetVehiclePos(GetPlayerVehicleID(playerid), -766.7427,-1730.1228,95.9759);
			SetVehicleZAngle(GetPlayerVehicleID(playerid), 355.3116);
			SetCameraBehindPlayer(playerid);
			format(string, sizeof(string), "%s [ID:%d] телепортирован на Drift 7 (/drift7)", pName, playerid);
			SendClientMessageToAll(COLOR_YELLOW, string);
			GameTextForPlayer(playerid, "~w~Добро пожаловать на Drift 7! ~G~", 5000, 5);
		}
		else
		{
			SendClientMessage(playerid, COLOR_RED, "GameMode.Error: Вы должны быть в машине!");
		}
	}
	else
	{
		SetPlayerPos(playerid, -766.7427,-1730.1228,95.9759);
		SetPlayerFacingAngle(playerid, 110.5445);
		SetCameraBehindPlayer(playerid);
		format(string, sizeof(string), "%s [ID:%d] телепортирован на Drift 7 (/drift7)", pName, playerid);
		SendClientMessageToAll(COLOR_YELLOW, string);
		GameTextForPlayer(playerid, "~w~Добро пожаловать на Drift 7! ~G~", 5000, 5);
	}
	return true;
}
CMD:drift8(playerid)
{	
	new string[256];
	new pName[24];
	if(IsPlayerInAnyVehicle(playerid))
	{
		if(GetPlayerState(playerid) == PLAYER_STATE_DRIVER)
		{
			SetVehiclePos(GetPlayerVehicleID(playerid), 711.8475,2581.5981,25.2460);
			SetVehicleZAngle(GetPlayerVehicleID(playerid), 178.7448);
			SetCameraBehindPlayer(playerid);
			format(string, sizeof(string), "%s [ID:%d] телепортирован на Drift 8 (/drift8)", pName, playerid);
			SendClientMessageToAll(COLOR_YELLOW, string);
			GameTextForPlayer(playerid, "~w~Добро пожаловать на Drift 8! ~G~", 5000, 5);
		}
		else
		{
			SendClientMessage(playerid, COLOR_RED, "GameMode.Error: Вы должны быть в машине!");
		}
	}
	else
	{
		SetPlayerPos(playerid, 711.8475,2581.5981,25.2460);
		SetPlayerFacingAngle(playerid, 110.5445);
		SetCameraBehindPlayer(playerid);
		format(string, sizeof(string), "%s [ID:%d] телепортирован на Drift 8 (/drift8)", pName, playerid);
		SendClientMessageToAll(COLOR_YELLOW, string);
		GameTextForPlayer(playerid, "~w~Добро пожаловать на Drift 8! ~G~", 5000, 5);
	}
	return true;
}
CMD:drift9(playerid)
{	
	new string[256];
	new pName[24];
	if(IsPlayerInAnyVehicle(playerid))
	{
		if(GetPlayerState(playerid) == PLAYER_STATE_DRIVER)
		{
			SetVehiclePos(GetPlayerVehicleID(playerid), -2418.8452,81.8775,34.6797);
			SetVehicleZAngle(GetPlayerVehicleID(playerid), 89.7885);
			SetCameraBehindPlayer(playerid);
			format(string, sizeof(string), "%s [ID:%d] телепортирован на Drift 9 (/drift9)", pName, playerid);
			SendClientMessageToAll(COLOR_YELLOW, string);
			GameTextForPlayer(playerid, "~w~Добро пожаловать на Drift 9! ~G~", 5000, 5);
		}
		else
		{
			SendClientMessage(playerid, COLOR_RED, "GameMode.Error: Вы должны быть в машине!");
		}
	}
	else
	{
		SetPlayerPos(playerid, -2418.8452,81.8775,34.6797);
		SetPlayerFacingAngle(playerid, 89.7885);
		SetCameraBehindPlayer(playerid);
		format(string, sizeof(string), "%s [ID:%d] телепортирован на Drift 9 (/drift9)", pName, playerid);
		SendClientMessageToAll(COLOR_YELLOW, string);
		GameTextForPlayer(playerid, "~w~Добро пожаловать на Drift 9! ~G~", 5000, 5);
	}
	return true;
}
CMD:drift10(playerid)
{	
	new string[256];
	new pName[24];
	if(IsPlayerInAnyVehicle(playerid))
	{
		if(GetPlayerState(playerid) == PLAYER_STATE_DRIVER)
		{
			SetVehiclePos(GetPlayerVehicleID(playerid), 915.9879,-685.1018,116.0321);
			SetVehicleZAngle(GetPlayerVehicleID(playerid), 148.8388);
			SetCameraBehindPlayer(playerid);
			format(string, sizeof(string), "%s [ID:%d] телепортирован на Drift 10 (/drift10)", pName, playerid);
			SendClientMessageToAll(COLOR_YELLOW, string);
			GameTextForPlayer(playerid, "~w~Добро пожаловать на Drift 10! ~G~", 5000, 5);
		}
		else
		{
			SendClientMessage(playerid, COLOR_RED, "GameMode.Error: Вы должны быть в машине!");
		}
	}
	else
	{
		SetPlayerPos(playerid, 915.9879,-685.1018,116.0321);
		SetPlayerFacingAngle(playerid, 148.8388);
		SetCameraBehindPlayer(playerid);
		format(string, sizeof(string), "%s [ID:%d] телепортирован на Drift 10 (/drift10)", pName, playerid);
		SendClientMessageToAll(COLOR_YELLOW, string);
		GameTextForPlayer(playerid, "~w~Добро пожаловать на Drift 10! ~G~", 5000, 5);
	}
	return true;
}
CMD:drift11(playerid)
{	
	new string[256];
	new pName[24];
	if(IsPlayerInAnyVehicle(playerid))
	{
		if(GetPlayerState(playerid) == PLAYER_STATE_DRIVER)
		{
			SetVehiclePos(GetPlayerVehicleID(playerid), -771.1682,-100.2281,64.8293);
			SetVehicleZAngle(GetPlayerVehicleID(playerid), 290.6883);
			SetCameraBehindPlayer(playerid);
			format(string, sizeof(string), "%s [ID:%d] телепортирован на Drift 11 (/drift11)", pName, playerid);
			SendClientMessageToAll(COLOR_YELLOW, string);
			GameTextForPlayer(playerid, "~w~Добро пожаловать на Drift 11! ~G~", 5000, 5);
		}
		else
		{
			SendClientMessage(playerid, COLOR_RED, "GameMode.Error: Вы должны быть в машине!");
		}
	}
	else
	{
		SetPlayerPos(playerid, -771.1682,-100.2281,64.8293);
		SetPlayerFacingAngle(playerid, 290.6883);
		SetCameraBehindPlayer(playerid);
		format(string, sizeof(string), "%s [ID:%d] телепортирован на Drift 11 (/drift11)", pName, playerid);
		SendClientMessageToAll(COLOR_YELLOW, string);
		GameTextForPlayer(playerid, "~w~Добро пожаловать на Drift 11! ~G~", 5000, 5);
	}
	return true;
}
CMD:drift12(playerid)
{	
	new string[256];
	new pName[24];
	if(IsPlayerInAnyVehicle(playerid))
	{
		if(GetPlayerState(playerid) == PLAYER_STATE_DRIVER)
		{
			SetVehiclePos(GetPlayerVehicleID(playerid), 2847.8616,-758.0251,10.4511);
			SetVehicleZAngle(GetPlayerVehicleID(playerid), 357.8184);
			SetCameraBehindPlayer(playerid);
			format(string, sizeof(string), "%s [ID:%d] телепортирован на Drift 12 (/drift12)", pName, playerid);
			SendClientMessageToAll(COLOR_YELLOW, string);
			GameTextForPlayer(playerid, "~w~Добро пожаловать на Drift 12! ~G~", 5000, 5);
		}
		else
		{
			SendClientMessage(playerid, COLOR_RED, "GameMode.Error: Вы должны быть в машине!");
		}
	}
	else
	{
		SetPlayerPos(playerid, 2847.8616,-758.0251,10.4511);
		SetPlayerFacingAngle(playerid, 357.8184);
		SetCameraBehindPlayer(playerid);
		format(string, sizeof(string), "%s [ID:%d] телепортирован на Drift 12 (/drift12)", pName, playerid);
		SendClientMessageToAll(COLOR_YELLOW, string);
		GameTextForPlayer(playerid, "~w~Добро пожаловать на Drift 12! ~G~", 5000, 5);
	}
	return true;
}
CMD:drift13(playerid)
{	
	new string[256];
	new pName[24];
	if(IsPlayerInAnyVehicle(playerid))
	{
		if(GetPlayerState(playerid) == PLAYER_STATE_DRIVER)
		{
			SetVehiclePos(GetPlayerVehicleID(playerid), 1246.2567,-2057.4617,59.5055);
			SetVehicleZAngle(GetPlayerVehicleID(playerid), 266.6362);
			SetCameraBehindPlayer(playerid);
			format(string, sizeof(string), "%s [ID:%d] телепортирован на Drift 13 (/drift13)", pName, playerid);
			SendClientMessageToAll(COLOR_YELLOW, string);
			GameTextForPlayer(playerid, "~w~Добро пожаловать на Drift 13! ~G~", 5000, 5);
		}
		else
		{
			SendClientMessage(playerid, COLOR_RED, "GameMode.Error: Вы должны быть в машине!");
		}
	}
	else
	{
		SetPlayerPos(playerid, 1239.8492,-2037.4199,59.9314);
		SetPlayerFacingAngle(playerid, 260.3887);
		SetCameraBehindPlayer(playerid);
		format(string, sizeof(string), "%s [ID:%d] телепортирован на Drift 13 (/drift13)", pName, playerid);
		SendClientMessageToAll(COLOR_YELLOW, string);
		GameTextForPlayer(playerid, "~w~Добро пожаловать на Drift 13! ~G~", 5000, 5);
	}
	return true;
}
CMD:drift14(playerid)
{	
	new string[256];
	new pName[24];
	if(IsPlayerInAnyVehicle(playerid))
	{
		if(GetPlayerState(playerid) == PLAYER_STATE_DRIVER)
		{
			SetVehiclePos(GetPlayerVehicleID(playerid), 1636.9423,-1154.2665,23.6056);
			SetVehicleZAngle(GetPlayerVehicleID(playerid), 357.5793);
			SetCameraBehindPlayer(playerid);
			format(string, sizeof(string), "%s [ID:%d] телепортирован на Drift 14 (/drift14)", pName, playerid);
			SendClientMessageToAll(COLOR_YELLOW, string);
			GameTextForPlayer(playerid, "~w~Добро пожаловать на Drift 14! ~G~", 5000, 5);
		}
		else
		{
			SendClientMessage(playerid, COLOR_RED, "GameMode.Error: Вы должны быть в машине!");
		}
	}
	else
	{
		SetPlayerPos(playerid, 1636.9423,-1154.2665,23.6056);
		SetPlayerFacingAngle(playerid, 357.5793);
		SetCameraBehindPlayer(playerid);
		format(string, sizeof(string), "%s [ID:%d] телепортирован на Drift 14 (/drift14)", pName, playerid);
		SendClientMessageToAll(COLOR_YELLOW, string);
		GameTextForPlayer(playerid, "~w~Добро пожаловать на Drift 14! ~G~", 5000, 5);
	}
	return true;
}
CMD:drift15(playerid)
{	
	new string[256];
	new pName[24];
	if(IsPlayerInAnyVehicle(playerid))
	{
		if(GetPlayerState(playerid) == PLAYER_STATE_DRIVER)
		{
			SetVehiclePos(GetPlayerVehicleID(playerid),1978.7637,2238.7798,26.8968);
			SetVehicleZAngle(GetPlayerVehicleID(playerid), 269.8691);
			SetCameraBehindPlayer(playerid);
			format(string, sizeof(string), "%s [ID:%d] телепортирован на Drift 15 (/drift15)", pName, playerid);
			SendClientMessageToAll(COLOR_YELLOW, string);
			GameTextForPlayer(playerid, "~w~Добро пожаловать на Drift 15! ~G~", 5000, 5);
		}
		else
		{
			SendClientMessage(playerid, COLOR_RED, "GameMode.Error: Вы должны быть в машине!");
		}
	}
	else
	{
		SetPlayerPos(playerid, 1978.7637,2238.7798,26.8968);
		SetPlayerFacingAngle(playerid,  269.8691);
		SetCameraBehindPlayer(playerid);
		format(string, sizeof(string), "%s [ID:%d] телепортирован на Drift 15 (/drift15)", pName, playerid);
		SendClientMessageToAll(COLOR_YELLOW, string);
		GameTextForPlayer(playerid, "~w~Добро пожаловать на Drift 15! ~G~", 5000, 5);
	}
	return true;
}
CMD:drift16(playerid)
{	
	new string[256];
	new pName[24];
	if(IsPlayerInAnyVehicle(playerid))
	{
		if(GetPlayerState(playerid) == PLAYER_STATE_DRIVER)
		{
			SetVehiclePos(GetPlayerVehicleID(playerid),-116.2590,819.2222,20.0582);
			SetVehicleZAngle(GetPlayerVehicleID(playerid), 199.9199);
			SetCameraBehindPlayer(playerid);
			format(string, sizeof(string), "%s [ID:%d] телепортирован на Drift 16 (/drift16)", pName, playerid);
			SendClientMessageToAll(COLOR_YELLOW, string);
			GameTextForPlayer(playerid, "~w~Добро пожаловать на Drift 16! ~G~", 5000, 5);
		}
		else
		{
			SendClientMessage(playerid, COLOR_RED, "GameMode.Error: Вы должны быть в машине!");
		}
	}
	else
	{
		SetPlayerPos(playerid, -116.2590,819.2222,20.0582);
		SetPlayerFacingAngle(playerid,  199.9199);
		SetCameraBehindPlayer(playerid);
		format(string, sizeof(string), "%s [ID:%d] телепортирован на Drift 16 (/drfit16)", pName, playerid);
		SendClientMessageToAll(COLOR_YELLOW, string);
		GameTextForPlayer(playerid, "~w~Добро пожаловать на Drift 16! ~G~", 5000, 5);
	}
	return true;
}
CMD:drift17(playerid)
{	
	new string[256];
	new pName[24];
	if(IsPlayerInAnyVehicle(playerid))
	{
		if(GetPlayerState(playerid) == PLAYER_STATE_DRIVER)
		{
			SetVehiclePos(GetPlayerVehicleID(playerid),2620.0789,-2406.7498,13.1992);
			SetVehicleZAngle(GetPlayerVehicleID(playerid), 269.8561);
			SetCameraBehindPlayer(playerid);
			format(string, sizeof(string), "%s [ID:%d] телепортирован на Drift 17 (/drift17)", pName, playerid);
			SendClientMessageToAll(COLOR_YELLOW, string);
			GameTextForPlayer(playerid, "~w~Добро пожаловать на Drift 17! ~G~", 5000, 5);
		}
		else
		{
			SendClientMessage(playerid, COLOR_RED, "GameMode.Error: Вы должны быть в машине!");
		}
	}
	else
	{
		SetPlayerPos(playerid, 2620.0789,-2406.7498,13.1992);
		SetPlayerFacingAngle(playerid,  269.8561);
		SetCameraBehindPlayer(playerid);
		format(string, sizeof(string), "%s [ID:%d] телепортирован на Drift 17 (/drift17)", pName, playerid);
		SendClientMessageToAll(COLOR_YELLOW, string);
		GameTextForPlayer(playerid, "~w~Добро пожаловать на Drift 18! ~G~", 5000, 5);
	}
	return true;
}
CMD:drift18(playerid)
{	
	new string[256];
	new pName[24];
	if(IsPlayerInAnyVehicle(playerid))
	{
		if(GetPlayerState(playerid) == PLAYER_STATE_DRIVER)
		{
			SetVehiclePos(GetPlayerVehicleID(playerid),-318.4155,2518.4719,34.4178);
			SetVehicleZAngle(GetPlayerVehicleID(playerid), 276.3857);
			SetCameraBehindPlayer(playerid);
			format(string, sizeof(string), "%s [ID:%d] телепортирован на Drift 18 (/drift18)", pName, playerid);
			SendClientMessageToAll(COLOR_YELLOW, string);
			GameTextForPlayer(playerid, "~w~Добро пожаловать на Drift 18! ~G~", 5000, 5);
		}
		else
		{
			SendClientMessage(playerid, COLOR_RED, "GameMode.Error: Вы должны быть в машине!");
		}
	}
	else
	{
		SetPlayerPos(playerid, -318.4155,2518.4719,34.4178);
		SetPlayerFacingAngle(playerid,  276.3857);
		SetCameraBehindPlayer(playerid);
		format(string, sizeof(string), "%s [ID:%d] телепортирован на Drift 18 (/drift18)", pName, playerid);
		SendClientMessageToAll(COLOR_YELLOW, string);
		GameTextForPlayer(playerid, "~w~Добро пожаловать на Drift 18! ~G~", 5000, 5);
	}
	return true;
}
CMD:drift19(playerid)
{	
	new string[256];
	new pName[24];
	if(IsPlayerInAnyVehicle(playerid))
	{
		if(GetPlayerState(playerid) == PLAYER_STATE_DRIVER)
		{
			SetVehiclePos(GetPlayerVehicleID(playerid),-1994.6610,343.1967,34.7129);
			SetVehicleZAngle(GetPlayerVehicleID(playerid), 266.1237);
			SetCameraBehindPlayer(playerid);
			format(string, sizeof(string), "%s [ID:%d] телепортирован на Drift 19 (/drift19)", pName, playerid);
			SendClientMessageToAll(COLOR_YELLOW, string);
			GameTextForPlayer(playerid, "~w~Добро пожаловать на Drift 19! ~G~", 5000, 5);
		}
		else
		{
			SendClientMessage(playerid, COLOR_RED, "GameMode.Error: Вы должны быть в машине!");
		}
	}
	else
	{
		SetPlayerPos(playerid, -1994.6610,343.1967,34.7129);
		SetPlayerFacingAngle(playerid,  266.1237);
		SetCameraBehindPlayer(playerid);
		format(string, sizeof(string), "%s [ID:%d] телепортирован на Drift 19 (/drift19)", pName, playerid);
		SendClientMessageToAll(COLOR_YELLOW, string);
		GameTextForPlayer(playerid, "~w~Добро пожаловать на Drift 19! ~G~", 5000, 5);
	}
	return true;
}
CMD:drift20(playerid)
{	
	new string[256];
	new pName[24];
	if(IsPlayerInAnyVehicle(playerid))
	{
		if(GetPlayerState(playerid) == PLAYER_STATE_DRIVER)
		{
			SetVehiclePos(GetPlayerVehicleID(playerid),-536.4901,1985.9124,59.8858);
			SetVehicleZAngle(GetPlayerVehicleID(playerid), 54.5365);
			SetCameraBehindPlayer(playerid);
			format(string, sizeof(string), "%s [ID:%d] телепортирован на Drift 20 (/drift20)", pName, playerid);
			SendClientMessageToAll(COLOR_YELLOW, string);
			GameTextForPlayer(playerid, "~w~Добро пожаловать на Drift 20! ~G~", 5000, 5);
		}
		else
		{
			SendClientMessage(playerid, COLOR_RED, "GameMode.Error: Вы должны быть в машине!");
		}
	}
	else
	{
		SetPlayerPos(playerid, -536.4901,1985.9124,59.8858);
		SetPlayerFacingAngle(playerid,  54.5365);
		SetCameraBehindPlayer(playerid);
		format(string, sizeof(string), "%s [ID:%d] телепортирован на Drift 20 (/drift20)", pName, playerid);
		SendClientMessageToAll(COLOR_YELLOW, string);
		GameTextForPlayer(playerid, "~w~Добро пожаловать на Drift 20! ~G~", 5000, 5);
	}
	return true;
}
CMD:drift21(playerid)
{	
	new string[256];
	new pName[24];
	if(IsPlayerInAnyVehicle(playerid))
	{
		if(GetPlayerState(playerid) == PLAYER_STATE_DRIVER)
		{
			SetVehiclePos(GetPlayerVehicleID(playerid),2560.1799,-1054.5699,69.1088);
			SetVehicleZAngle(GetPlayerVehicleID(playerid), 174.5037);
			SetCameraBehindPlayer(playerid);
			format(string, sizeof(string), "%s [ID:%d] телепортирован на Drift 21 (/drift21)", pName, playerid);
			SendClientMessageToAll(COLOR_YELLOW, string);
			GameTextForPlayer(playerid, "~w~Добро пожаловать на Drift 21! ~G~", 5000, 5);
		}
		else
		{
			SendClientMessage(playerid, COLOR_RED, "GameMode.Error: Вы должны быть в машине!");
		}
	}
	else
	{
		SetPlayerPos(playerid, 2560.1799,-1054.5699,69.1088);
		SetPlayerFacingAngle(playerid,  174.5037);
		SetCameraBehindPlayer(playerid);
		format(string, sizeof(string), "%s [ID:%d] телепортирован на Drift 21 (/drift21)", pName, playerid);
		SendClientMessageToAll(COLOR_YELLOW, string);
		GameTextForPlayer(playerid, "~w~Добро пожаловать на Drift 21! ~G~", 5000, 5);
	}
	return true;
}
CMD:drift22(playerid)
{	
	new string[256];
	new pName[24];
	if(IsPlayerInAnyVehicle(playerid))
	{
		if(GetPlayerState(playerid) == PLAYER_STATE_DRIVER)
		{
			SetVehiclePos(GetPlayerVehicleID(playerid),2744.8188,-1259.8951,59.2429);
			SetVehicleZAngle(GetPlayerVehicleID(playerid), 268.8653);
			SetCameraBehindPlayer(playerid);
			format(string, sizeof(string), "%s [ID:%d] телепортирован на Drift 22 (/drift22)", pName, playerid);
			SendClientMessageToAll(COLOR_YELLOW, string);
			GameTextForPlayer(playerid, "~w~Добро пожаловать на Drift 22! ~G~", 5000, 5);
		}
		else
		{
			SendClientMessage(playerid, COLOR_RED, "GameMode.Error: Вы должны быть в машине!");
		}
	}
	else
	{
		SetPlayerPos(playerid, 2744.8188,-1259.8951,59.2429);
		SetPlayerFacingAngle(playerid,  268.8653);
		SetCameraBehindPlayer(playerid);
		format(string, sizeof(string), "%s [ID:%d] телепортирован на Drift 22 (/drift22)", pName, playerid);
		SendClientMessageToAll(COLOR_YELLOW, string);
		GameTextForPlayer(playerid, "~w~Добро пожаловать на Drift 22! ~G~", 5000, 5);
	}
	return true;
}
CMD:drift23(playerid)
{	
	new string[256];
	new pName[24];
	if(IsPlayerInAnyVehicle(playerid))
	{
		if(GetPlayerState(playerid) == PLAYER_STATE_DRIVER)
		{
			SetVehiclePos(GetPlayerVehicleID(playerid),664.9158,-1317.3036,13.1367);
			SetVehicleZAngle(GetPlayerVehicleID(playerid), 1.9902);
			SetCameraBehindPlayer(playerid);
			format(string, sizeof(string), "%s [ID:%d] телепортирован на Drift 23 (/drift23)", pName, playerid);
			SendClientMessageToAll(COLOR_YELLOW, string);
			GameTextForPlayer(playerid, "~w~Добро пожаловать на Drift 23! ~G~", 5000, 5);
		}
		else
		{
			SendClientMessage(playerid, COLOR_RED, "GameMode.Error: Вы должны быть в машине!");
		}
	}
	else
	{
		SetPlayerPos(playerid, 664.9158,-1317.3036,13.1367);
		SetPlayerFacingAngle(playerid,  1.9902);
		SetCameraBehindPlayer(playerid);
		format(string, sizeof(string), "%s [ID:%d] телепортирован на Drift 23 (/drift23)", pName, playerid);
		SendClientMessageToAll(COLOR_YELLOW, string);
		GameTextForPlayer(playerid, "~w~Добро пожаловать на Drift 23! ~G~", 5000, 5);
	}
	return true;
}
CMD:drift24(playerid)
{	
	new string[256];
	new pName[24];
	if(IsPlayerInAnyVehicle(playerid))
	{
		if(GetPlayerState(playerid) == PLAYER_STATE_DRIVER)
		{
			SetVehiclePos(GetPlayerVehicleID(playerid),293.9851,-561.8304,40.3055);
			SetVehicleZAngle(GetPlayerVehicleID(playerid), 89.1122);
			SetCameraBehindPlayer(playerid);
			format(string, sizeof(string), "%s [ID:%d] телепортирован на Drift 24 (/drift24)", pName, playerid);
			SendClientMessageToAll(COLOR_YELLOW, string);
			GameTextForPlayer(playerid, "~w~Добро пожаловать на Drift 24! ~G~", 5000, 5);
		}
		else
		{
			SendClientMessage(playerid, COLOR_RED, "GameMode.Error: Вы должны быть в машине!");
		}
	}
	else
	{
		SetPlayerPos(playerid, 293.9851,-561.8304,40.3055);
		SetPlayerFacingAngle(playerid,  89.1122);
		SetCameraBehindPlayer(playerid);
		format(string, sizeof(string), "%s [ID:%d] телепортирован на Drift 24 (/drift24)", pName, playerid);
		SendClientMessageToAll(COLOR_YELLOW, string);
		GameTextForPlayer(playerid, "~w~Добро пожаловать на Drift 24! ~G~", 5000, 5);
	}
	return true;
}
CMD:drift25(playerid)
{	
	new string[256];
	new pName[24];
	if(IsPlayerInAnyVehicle(playerid))
	{
		if(GetPlayerState(playerid) == PLAYER_STATE_DRIVER)
		{
			SetVehiclePos(GetPlayerVehicleID(playerid),-1257.1068,-1355.8252,119.8318);
			SetVehicleZAngle(GetPlayerVehicleID(playerid), 110.5793);
			SetCameraBehindPlayer(playerid);
			format(string, sizeof(string), "%s [ID:%d] телепортирован на Drift 25 (/drift25)", pName, playerid);
			SendClientMessageToAll(COLOR_YELLOW, string);
			GameTextForPlayer(playerid, "~w~Добро пожаловать на Drift 25! ~G~", 5000, 5);
		}
		else
		{
			SendClientMessage(playerid, COLOR_RED, "GameMode.Error: Вы должны быть в машине!");
		}
	}
	else
	{
		SetPlayerPos(playerid, -1257.1068,-1355.8252,119.8318);
		SetPlayerFacingAngle(playerid,  110.5793);
		SetCameraBehindPlayer(playerid);
		format(string, sizeof(string), "%s [ID:%d] телепортирован на Drift 25 (/drift25)", pName, playerid);
		SendClientMessageToAll(COLOR_YELLOW, string);
		GameTextForPlayer(playerid, "~w~Добро пожаловать на Drift 25! ~G~", 5000, 5);
	}
	return true;
}
CMD:drift26(playerid)
{	
	new string[256];
	new pName[24];
	if(IsPlayerInAnyVehicle(playerid))
	{
		if(GetPlayerState(playerid) == PLAYER_STATE_DRIVER)
		{
			SetVehiclePos(GetPlayerVehicleID(playerid),1277.5319,-601.2232,100.9038);
			SetVehicleZAngle(GetPlayerVehicleID(playerid), 353.0812);
			SetCameraBehindPlayer(playerid);
			format(string, sizeof(string), "%s [ID:%d] телепортирован на Drift 26 (/drift26)", pName, playerid);
			SendClientMessageToAll(COLOR_YELLOW, string);
			GameTextForPlayer(playerid, "~w~Добро пожаловать на Drift 26! ~G~", 5000, 5);
		}
		else
		{
			SendClientMessage(playerid, COLOR_RED, "GameMode.Error: Вы должны быть в машине!");
		}
	}
	else
	{
		SetPlayerPos(playerid, 1277.5319,-601.2232,100.9038);
		SetPlayerFacingAngle(playerid,  353.0812);
		SetCameraBehindPlayer(playerid);
		format(string, sizeof(string), "%s [ID:%d] телепортирован на Drift 26 (/drift26)", pName, playerid);
		SendClientMessageToAll(COLOR_YELLOW, string);
		GameTextForPlayer(playerid, "~w~Добро пожаловать на Drift 26! ~G~", 5000, 5);
	}
	return true;
}
CMD:drift27(playerid)
{	
	new string[256];
	new pName[24];
	if(IsPlayerInAnyVehicle(playerid))
	{
		if(GetPlayerState(playerid) == PLAYER_STATE_DRIVER)
		{
			SetVehiclePos(GetPlayerVehicleID(playerid),-1810.9692,2685.8086,55.8367);
			SetVehicleZAngle(GetPlayerVehicleID(playerid), 76.9332);
			SetCameraBehindPlayer(playerid);
			format(string, sizeof(string), "%s [ID:%d] телепортирован на Drift 27 (/drift27)", pName, playerid);
			SendClientMessageToAll(COLOR_YELLOW, string);
			GameTextForPlayer(playerid, "~w~Добро пожаловать на Drift 27! ~G~", 5000, 5);
		}
		else
		{
			SendClientMessage(playerid, COLOR_RED, "GameMode.Error: Вы должны быть в машине!");
		}
	}
	else
	{
		SetPlayerPos(playerid, -1810.9692,2685.8086,55.8367);
		SetPlayerFacingAngle(playerid,  76.9332);
		SetCameraBehindPlayer(playerid);
		format(string, sizeof(string), "%s [ID:%d] телепортирован на Drift 27 (/drift27)", pName, playerid);
		SendClientMessageToAll(COLOR_YELLOW, string);
		GameTextForPlayer(playerid, "~w~Добро пожаловать на Drift 27! ~G~", 5000, 5);
	}
	return true;
}
CMD:drift28(playerid)
{	
	new string[256];
	new pName[24];
	if(IsPlayerInAnyVehicle(playerid))
	{
		if(GetPlayerState(playerid) == PLAYER_STATE_DRIVER)
		{
			SetVehiclePos(GetPlayerVehicleID(playerid),-1822.0422,2670.2593,54.7437);
			SetVehicleZAngle(GetPlayerVehicleID(playerid), 144.0571);
			SetCameraBehindPlayer(playerid);
			format(string, sizeof(string), "%s [ID:%d] телепортирован на Drift 28 (/drift28)", pName, playerid);
			SendClientMessageToAll(COLOR_YELLOW, string);
			GameTextForPlayer(playerid, "~w~Добро пожаловать на Drift 28! ~G~", 5000, 5);
		}
		else
		{
			SendClientMessage(playerid, COLOR_RED, "GameMode.Error: Вы должны быть в машине!");
		}
	}
	else
	{
		SetPlayerPos(playerid, -1822.0422,2670.2593,54.7437);
		SetPlayerFacingAngle(playerid,  144.0571);
		SetCameraBehindPlayer(playerid);
		format(string, sizeof(string), "%s [ID:%d] телепортирован на Drift 28 (/drift28)", pName, playerid);
		SendClientMessageToAll(COLOR_YELLOW, string);
		GameTextForPlayer(playerid, "~w~Добро пожаловать на Drift 28! ~G~", 5000, 5);
	}
	return true;
}
CMD:drift29(playerid)
{	
	new string[256];
	new pName[24];
	if(IsPlayerInAnyVehicle(playerid))
	{
		if(GetPlayerState(playerid) == PLAYER_STATE_DRIVER)
		{
			SetVehiclePos(GetPlayerVehicleID(playerid),1104.5126,815.3459,10.4263);
			SetVehicleZAngle(GetPlayerVehicleID(playerid), 305.2941);
			SetCameraBehindPlayer(playerid);
			format(string, sizeof(string), "%s [ID:%d] телепортирован на Drift 29 (/drift29)", pName, playerid);
			SendClientMessageToAll(COLOR_YELLOW, string);
			GameTextForPlayer(playerid, "~w~Добро пожаловать на Drift 29! ~G~", 5000, 5);
		}
		else
		{
			SendClientMessage(playerid, COLOR_RED, "GameMode.Error: Вы должны быть в машине!");
		}
	}
	else
	{
		SetPlayerPos(playerid, 1104.5126,815.3459,10.4263);
		SetPlayerFacingAngle(playerid,  305.2941);
		SetCameraBehindPlayer(playerid);
		format(string, sizeof(string), "%s [ID:%d] телепортирован на Drift 29 (/drift29)", pName, playerid);
		SendClientMessageToAll(COLOR_YELLOW, string);
		GameTextForPlayer(playerid, "~w~Добро пожаловать на Drift 29! ~G~", 5000, 5);
	}
	return true;
}
CMD:drift30(playerid)
{	
	new string[256];
	new pName[24];
	if(IsPlayerInAnyVehicle(playerid))
	{
		if(GetPlayerState(playerid) == PLAYER_STATE_DRIVER)
		{
			SetVehiclePos(GetPlayerVehicleID(playerid),2509.8716,1606.4781,10.4566);
			SetVehicleZAngle(GetPlayerVehicleID(playerid), 158.8041);
			SetCameraBehindPlayer(playerid);
			format(string, sizeof(string), "%s [ID:%d] телепортирован на Drift 30 (/drift30)", pName, playerid);
			SendClientMessageToAll(COLOR_YELLOW, string);
			GameTextForPlayer(playerid, "~w~Добро пожаловать на Drift 30! ~G~", 5000, 5);
		}
		else
		{
			SendClientMessage(playerid, COLOR_RED, "GameMode.Error: Вы должны быть в машине!");
		}
	}
	else
	{
		SetPlayerPos(playerid, 2509.8716,1606.4781,10.4566);
		SetPlayerFacingAngle(playerid,  158.8041);
		SetCameraBehindPlayer(playerid);
		format(string, sizeof(string), "%s [ID:%d] телепортирован на Drift 30 (/drift30)", pName, playerid);
		SendClientMessageToAll(COLOR_YELLOW, string);
		GameTextForPlayer(playerid, "~w~Добро пожаловать на Drift 30! ~G~", 5000, 5);
	}
	return true;
}
CMD:drift31(playerid)
{	
	new string[256];
	new pName[24];
	if(IsPlayerInAnyVehicle(playerid))
	{
		if(GetPlayerState(playerid) == PLAYER_STATE_DRIVER)
		{
			SetVehiclePos(GetPlayerVehicleID(playerid),-1421.2139,-816.0684,80.1159);
			SetVehicleZAngle(GetPlayerVehicleID(playerid), 93.0473);
			SetCameraBehindPlayer(playerid);
			format(string, sizeof(string), "%s [ID:%d] телепортирован на Drift 31 (/drift31)", pName, playerid);
			SendClientMessageToAll(COLOR_YELLOW, string);
			GameTextForPlayer(playerid, "~w~Добро пожаловать на Drift 31! ~G~", 5000, 5);
		}
		else
		{
			SendClientMessage(playerid, COLOR_RED, "GameMode.Error: Вы должны быть в машине!");
		}
	}
	else
	{
		SetPlayerPos(playerid, -1421.2139,-816.0684,80.1159);
		SetPlayerFacingAngle(playerid,  93.0473);
		SetCameraBehindPlayer(playerid);
		format(string, sizeof(string), "%s [ID:%d] телепортирован на Drift 31 (/drift31)", pName, playerid);
		SendClientMessageToAll(COLOR_YELLOW, string);
		GameTextForPlayer(playerid, "~w~Добро пожаловать на Drift 31! ~G~", 5000, 5);
	}
	return true;
}
CMD:drift32(playerid)
{	
	new string[256];
	new pName[24];
	if(IsPlayerInAnyVehicle(playerid))
	{
		if(GetPlayerState(playerid) == PLAYER_STATE_DRIVER)
		{
			SetVehiclePos(GetPlayerVehicleID(playerid),-1697.0072,991.5380,17.2838);
			SetVehicleZAngle(GetPlayerVehicleID(playerid), 357.3751);
			SetCameraBehindPlayer(playerid);
			format(string, sizeof(string), "%s [ID:%d] телепортирован на Drift 32 (/drift32)", pName, playerid);
			SendClientMessageToAll(COLOR_YELLOW, string);
			GameTextForPlayer(playerid, "~w~Добро пожаловать на Drift 32! ~G~", 5000, 5);
		}
		else
		{
			SendClientMessage(playerid, COLOR_RED, "GameMode.Error: Вы должны быть в машине!");
		}
	}
	else
	{
		SetPlayerPos(playerid, -1697.0072,991.5380,17.2838);
		SetPlayerFacingAngle(playerid,  357.3751);
		SetCameraBehindPlayer(playerid);
		format(string, sizeof(string), "%s [ID:%d] телепортирован на Drift 32 (/drift32)", pName, playerid);
		SendClientMessageToAll(COLOR_YELLOW, string);
		GameTextForPlayer(playerid, "~w~Добро пожаловать на Drift 32! ~G~", 5000, 5);
	}
	return true;
}
CMD:drift33(playerid)
{	
	new string[256];
	new pName[24];
	if(IsPlayerInAnyVehicle(playerid))
	{
		if(GetPlayerState(playerid) == PLAYER_STATE_DRIVER)
		{
			SetVehiclePos(GetPlayerVehicleID(playerid),-2136.3975,919.4185,79.5486);
			SetVehicleZAngle(GetPlayerVehicleID(playerid), 268.2998);
			SetCameraBehindPlayer(playerid);
			format(string, sizeof(string), "%s [ID:%d] телепортирован на Drift 33 (/drift33)", pName, playerid);
			SendClientMessageToAll(COLOR_YELLOW, string);
			GameTextForPlayer(playerid, "~w~Добро пожаловать на Drift 33! ~G~", 5000, 5);
		}
		else
		{
			SendClientMessage(playerid, COLOR_RED, "GameMode.Error: Вы должны быть в машине!");
		}
	}
	else
	{
		SetPlayerPos(playerid, -2136.3975,919.4185,79.5486);
		SetPlayerFacingAngle(playerid,  268.2998);
		SetCameraBehindPlayer(playerid);
		format(string, sizeof(string), "%s [ID:%d] телепортирован на Drift 33 (/drift33)", pName, playerid);
		SendClientMessageToAll(COLOR_YELLOW, string);
		GameTextForPlayer(playerid, "~w~Добро пожаловать на Drift 33! ~G~", 5000, 5);
	}
	return true;
}
CMD:drift34(playerid)
{	
	new string[256];
	new pName[24];
	if(IsPlayerInAnyVehicle(playerid))
	{
		if(GetPlayerState(playerid) == PLAYER_STATE_DRIVER)
		{
			SetVehiclePos(GetPlayerVehicleID(playerid),-1400.5747,-291.2898,5.7002);
			SetVehicleZAngle(GetPlayerVehicleID(playerid), 353.6805);
			SetCameraBehindPlayer(playerid);
			format(string, sizeof(string), "%s [ID:%d] телепортирован на Drift 34 (/drift34)", pName, playerid);
			SendClientMessageToAll(COLOR_YELLOW, string);
			GameTextForPlayer(playerid, "~w~Добро пожаловать на Drift 34! ~G~", 5000, 5);
		}
		else
		{
			SendClientMessage(playerid, COLOR_RED, "GameMode.Error: Вы должны быть в машине!");
		}
	}
	else
	{
		SetPlayerPos(playerid, -1400.5747,-291.2898,5.7002);
		SetPlayerFacingAngle(playerid,  353.6805);
		SetCameraBehindPlayer(playerid);
		format(string, sizeof(string), "%s [ID:%d] телепортирован на Drift 34 (/drift34)", pName, playerid);
		SendClientMessageToAll(COLOR_YELLOW, string);
		GameTextForPlayer(playerid, "~w~Добро пожаловать на Drift 34! ~G~", 5000, 5);
	}
	return true;
}
CMD:drift35(playerid)
{	
	new string[256];
	new pName[24];
	if(IsPlayerInAnyVehicle(playerid))
	{
		if(GetPlayerState(playerid) == PLAYER_STATE_DRIVER)
		{
			SetVehiclePos(GetPlayerVehicleID(playerid),1615.3378,-1659.0410,13.2405);
			SetVehicleZAngle(GetPlayerVehicleID(playerid), 184.4336);
			SetCameraBehindPlayer(playerid);
			format(string, sizeof(string), "%s [ID:%d] телепортирован на Drift 35 (/drift35)", pName, playerid);
			SendClientMessageToAll(COLOR_YELLOW, string);
			GameTextForPlayer(playerid, "~w~Добро пожаловать на Drift 35! ~G~", 5000, 5);
		}
		else
		{
			SendClientMessage(playerid, COLOR_RED, "GameMode.Error: Вы должны быть в машине!");
		}
	}
	else
	{
		SetPlayerPos(playerid, 1615.3378,-1659.0410,13.2405);
		SetPlayerFacingAngle(playerid,  184.4336);
		SetCameraBehindPlayer(playerid);
		format(string, sizeof(string), "%s [ID:%d] телепортирован на Drift 35 (/drift35)", pName, playerid);
		SendClientMessageToAll(COLOR_YELLOW, string);
		GameTextForPlayer(playerid, "~w~Добро пожаловать на Drift 35! ~G~", 5000, 5);
	}
	return true;
}
CMD:drift36(playerid)
{	
	new string[256];
	new pName[24];
	if(IsPlayerInAnyVehicle(playerid))
	{
		if(GetPlayerState(playerid) == PLAYER_STATE_DRIVER)
		{
			SetVehiclePos(GetPlayerVehicleID(playerid),1651.2620,-2599.9829,13.2465);
			SetVehicleZAngle(GetPlayerVehicleID(playerid), 269.8469);
			SetCameraBehindPlayer(playerid);
			format(string, sizeof(string), "%s [ID:%d] телепортирован на Drift 36 (/drift36)", pName, playerid);
			SendClientMessageToAll(COLOR_YELLOW, string);
			GameTextForPlayer(playerid, "~w~Добро пожаловать на Drift 36! ~G~", 5000, 5);
		}
		else
		{
			SendClientMessage(playerid, COLOR_RED, "GameMode.Error: Вы должны быть в машине!");
		}
	}
	else
	{
		SetPlayerPos(playerid, 1651.2620,-2599.9829,13.2465);
		SetPlayerFacingAngle(playerid,  269.8469);
		SetCameraBehindPlayer(playerid);
		format(string, sizeof(string), "%s [ID:%d] телепортирован на Drift 36 (/drift36)", pName, playerid);
		SendClientMessageToAll(COLOR_YELLOW, string);
		GameTextForPlayer(playerid, "~w~Добро пожаловать на Drift 36! ~G~", 5000, 5);
	}
	return true;
}
CMD:drift37(playerid)
{	
	new string[256];
	new pName[24];
	if(IsPlayerInAnyVehicle(playerid))
	{
		if(GetPlayerState(playerid) == PLAYER_STATE_DRIVER)
		{
			SetVehiclePos(GetPlayerVehicleID(playerid),291.6453,-1489.1570,32.3365);
			SetVehicleZAngle(GetPlayerVehicleID(playerid), 50.8979);
			SetCameraBehindPlayer(playerid);
			format(string, sizeof(string), "%s [ID:%d] телепортирован на Drift 37 (/drift37)", pName, playerid);
			SendClientMessageToAll(COLOR_YELLOW, string);
			GameTextForPlayer(playerid, "~w~Добро пожаловать на Drift 37! ~G~", 5000, 5);
		}
		else
		{
			SendClientMessage(playerid, COLOR_RED, "GameMode.Error: Вы должны быть в машине!");
		}
	}
	else
	{
		SetPlayerPos(playerid, 291.6453,-1489.1570,32.3365);
		SetPlayerFacingAngle(playerid,  50.8979);
		SetCameraBehindPlayer(playerid);
		format(string, sizeof(string), "%s [ID:%d] телепортирован на Drift 37 (/drift37)", pName, playerid);
		SendClientMessageToAll(COLOR_YELLOW, string);
		GameTextForPlayer(playerid, "~w~Добро пожаловать на Drift 37! ~G~", 5000, 5);
	}
	return true;
}
CMD:drift38(playerid)
{	
	new string[256];
	new pName[24];
	if(IsPlayerInAnyVehicle(playerid))
	{
		if(GetPlayerState(playerid) == PLAYER_STATE_DRIVER)
		{
			SetVehiclePos(GetPlayerVehicleID(playerid),1591.4022,-2192.9214,13.0724);
			SetVehicleZAngle(GetPlayerVehicleID(playerid), 88.7810);
			SetCameraBehindPlayer(playerid);
			format(string, sizeof(string), "%s [ID:%d] телепортирован на Drift 38 (/drift38)", pName, playerid);
			SendClientMessageToAll(COLOR_YELLOW, string);
			GameTextForPlayer(playerid, "~w~Добро пожаловать на Drift 38! ~G~", 5000, 5);
		}
		else
		{
			SendClientMessage(playerid, COLOR_RED, "GameMode.Error: Вы должны быть в машине!");
		}
	}
	else
	{
		SetPlayerPos(playerid, 1591.4022,-2192.9214,13.0724);
		SetPlayerFacingAngle(playerid,  88.7810);
		SetCameraBehindPlayer(playerid);
		format(string, sizeof(string), "%s [ID:%d] телепортирован на Drift 38 (/drift38)", pName, playerid);
		SendClientMessageToAll(COLOR_YELLOW, string);
		GameTextForPlayer(playerid, "~w~Добро пожаловать на Drift 38! ~G~", 5000, 5);
	}
	return true;
}
CMD:drift39(playerid)
{	
	new string[256];
	new pName[24];
	if(IsPlayerInAnyVehicle(playerid))
	{
		if(GetPlayerState(playerid) == PLAYER_STATE_DRIVER)
		{
			SetVehiclePos(GetPlayerVehicleID(playerid),1360.9453,-2465.1997,7.3572);
			SetVehicleZAngle(GetPlayerVehicleID(playerid), 269.3084);
			SetCameraBehindPlayer(playerid);
			format(string, sizeof(string), "%s [ID:%d] телепортирован на Drift 39 (/drift39)", pName, playerid);
			SendClientMessageToAll(COLOR_YELLOW, string);
			GameTextForPlayer(playerid, "~w~Добро пожаловать на Drift 39! ~G~", 5000, 5);
		}
		else
		{
			SendClientMessage(playerid, COLOR_RED, "GameMode.Error: Вы должны быть в машине!");
		}
	}
	else
	{
		SetPlayerPos(playerid, 1360.9453,-2465.1997,7.3572);
		SetPlayerFacingAngle(playerid,  269.3084);
		SetCameraBehindPlayer(playerid);
		format(string, sizeof(string), "%s [ID:%d] телепортирован на Drift 39 (/drift39)", pName, playerid);
		SendClientMessageToAll(COLOR_YELLOW, string);
		GameTextForPlayer(playerid, "~w~Добро пожаловать на Drift 39! ~G~", 5000, 5);
	}
	return true;
}
CMD:drift40(playerid)
{	
	new string[256];
	new pName[24];
	if(IsPlayerInAnyVehicle(playerid))
	{
		if(GetPlayerState(playerid) == PLAYER_STATE_DRIVER)
		{
			SetVehiclePos(GetPlayerVehicleID(playerid),-2265.7798,1158.4409,57.0986);
			SetVehicleZAngle(GetPlayerVehicleID(playerid), 0.1581);
			SetCameraBehindPlayer(playerid);
			format(string, sizeof(string), "%s [ID:%d] телепортирован на Drift 40 (/drift40)", pName, playerid);
			SendClientMessageToAll(COLOR_YELLOW, string);
			GameTextForPlayer(playerid, "~w~Добро пожаловать на Drift 40! ~G~", 5000, 5);
		}
		else
		{
			SendClientMessage(playerid, COLOR_RED, "GameMode.Error: Вы должны быть в машине!");
		}
	}
	else
	{
		SetPlayerPos(playerid, -2265.7798,1158.4409,57.0986);
		SetPlayerFacingAngle(playerid,  0.1581);
		SetCameraBehindPlayer(playerid);
		format(string, sizeof(string), "%s [ID:%d] телепортирован на Drift 40 (/drift40)", pName, playerid);
		SendClientMessageToAll(COLOR_YELLOW, string);
		GameTextForPlayer(playerid, "~w~Добро пожаловать на Drift 40! ~G~", 5000, 5);
	}
	return true;
}
CMD:drift41(playerid)
{	
	new string[256];
	new pName[24];
	if(IsPlayerInAnyVehicle(playerid))
	{
		if(GetPlayerState(playerid) == PLAYER_STATE_DRIVER)
		{
			SetVehiclePos(GetPlayerVehicleID(playerid),-2119.4114,-349.4402,34.8226);
			SetVehicleZAngle(GetPlayerVehicleID(playerid), 270.5172);
			SetCameraBehindPlayer(playerid);
			format(string, sizeof(string), "%s [ID:%d] телепортирован на Drift 41 (/drift41)", pName, playerid);
			SendClientMessageToAll(COLOR_YELLOW, string);
			GameTextForPlayer(playerid, "~w~Добро пожаловать на Drift 41! ~G~", 5000, 5);
		}
		else
		{
			SendClientMessage(playerid, COLOR_RED, "GameMode.Error: Вы должны быть в машине!");
		}
	}
	else
	{
		SetPlayerPos(playerid, -2119.4114,-349.4402,34.8226);
		SetPlayerFacingAngle(playerid,  270.5172);
		SetCameraBehindPlayer(playerid);
		format(string, sizeof(string), "%s [ID:%d] телепортирован на Drift 41 (/drift41)", pName, playerid);
		SendClientMessageToAll(COLOR_YELLOW, string);
		GameTextForPlayer(playerid, "~w~Добро пожаловать на Drift 41! ~G~", 5000, 5);
	}
	return true;
}
CMD:drift42(playerid)
{	
	new string[256];
	new pName[24];
	if(IsPlayerInAnyVehicle(playerid))
	{
		if(GetPlayerState(playerid) == PLAYER_STATE_DRIVER)
		{
			SetVehiclePos(GetPlayerVehicleID(playerid),1476.5244,1758.5297,10.5100);
			SetVehicleZAngle(GetPlayerVehicleID(playerid), 181.3618);
			SetCameraBehindPlayer(playerid);
			format(string, sizeof(string), "%s [ID:%d] телепортирован на Drift 42 (/drift42)", pName, playerid);
			SendClientMessageToAll(COLOR_YELLOW, string);
			GameTextForPlayer(playerid, "~w~Добро пожаловать на Drift 42! ~G~", 5000, 5);
		}
		else
		{
			SendClientMessage(playerid, COLOR_RED, "GameMode.Error: Вы должны быть в машине!");
		}
	}
	else
	{
		SetPlayerPos(playerid, 1476.5244,1758.5297,10.5100);
		SetPlayerFacingAngle(playerid,  181.3618);
		SetCameraBehindPlayer(playerid);
		format(string, sizeof(string), "%s [ID:%d] телепортирован на Drift 42 (/drift42)", pName, playerid);
		SendClientMessageToAll(COLOR_YELLOW, string);
		GameTextForPlayer(playerid, "~w~Добро пожаловать на Drift 42! ~G~", 5000, 5);
	}
	return true;
}
CMD:drift43(playerid)
{	
	new string[256];
	new pName[24];
	if(IsPlayerInAnyVehicle(playerid))
	{
		if(GetPlayerState(playerid) == PLAYER_STATE_DRIVER)
		{
			SetVehiclePos(GetPlayerVehicleID(playerid),137.5619,1946.4087,19.0599);
			SetVehicleZAngle(GetPlayerVehicleID(playerid), 181.3618);
			SetCameraBehindPlayer(playerid);
			format(string, sizeof(string), "%s [ID:%d] телепортирован на Drift 43 (/drift43)", pName, playerid);
			SendClientMessageToAll(COLOR_YELLOW, string);
			GameTextForPlayer(playerid, "~w~Добро пожаловать на Drift 43! ~G~", 5000, 5);
		}
		else
		{
			SendClientMessage(playerid, COLOR_RED, "GameMode.Error: Вы должны быть в машине!");
		}
	}
	else
	{
		SetPlayerPos(playerid, 137.5619,1946.4087,19.0599);
		SetPlayerFacingAngle(playerid,  181.3618);
		SetCameraBehindPlayer(playerid);
		format(string, sizeof(string), "%s [ID:%d] телепортирован на Drift 43 (/drift43)", pName, playerid);
		SendClientMessageToAll(COLOR_YELLOW, string);
		GameTextForPlayer(playerid, "~w~Добро пожаловать на Drift 43! ~G~", 5000, 5);
	}
	return true;
}
CMD:drift44(playerid)
{	
	new string[256];
	new pName[24];
	if(IsPlayerInAnyVehicle(playerid))
	{
		if(GetPlayerState(playerid) == PLAYER_STATE_DRIVER)
		{
			SetVehiclePos(GetPlayerVehicleID(playerid),2589.9761,2800.7749,10.3423);
			SetVehicleZAngle(GetPlayerVehicleID(playerid), 90.1578);
			SetCameraBehindPlayer(playerid);
			format(string, sizeof(string), "%s [ID:%d] телепортирован на Drift 44 (/drift44)", pName, playerid);
			SendClientMessageToAll(COLOR_YELLOW, string);
			GameTextForPlayer(playerid, "~w~Добро пожаловать на Drift 44! ~G~", 5000, 5);
		}
		else
		{
			SendClientMessage(playerid, COLOR_RED, "GameMode.Error: Вы должны быть в машине!");
		}
	}
	else
	{
		SetPlayerPos(playerid, 2589.9761,2800.7749,10.3423);
		SetPlayerFacingAngle(playerid,  90.1578);
		SetCameraBehindPlayer(playerid);
		format(string, sizeof(string), "%s [ID:%d] телепортирован на Drift 44 (/drift44)", pName, playerid);
		SendClientMessageToAll(COLOR_YELLOW, string);
		GameTextForPlayer(playerid, "~w~Добро пожаловать на Drift 44! ~G~", 5000, 5);
	}
	return true;
}
CMD:drift45(playerid)
{	
	new string[256];
	new pName[24];
	if(IsPlayerInAnyVehicle(playerid))
	{
		if(GetPlayerState(playerid) == PLAYER_STATE_DRIVER)
		{
			SetVehiclePos(GetPlayerVehicleID(playerid),1000.0231,2545.3728,10.3403);
			SetVehicleZAngle(GetPlayerVehicleID(playerid), 235.6451);
			SetCameraBehindPlayer(playerid);
			format(string, sizeof(string), "%s [ID:%d] телепортирован на Drift 45 (/drift45)", pName, playerid);
			SendClientMessageToAll(COLOR_YELLOW, string);
			GameTextForPlayer(playerid, "~w~Добро пожаловать на Drift 45! ~G~", 5000, 5);
		}
		else
		{
			SendClientMessage(playerid, COLOR_RED, "GameMode.Error: Вы должны быть в машине!");
		}
	}
	else
	{
		SetPlayerPos(playerid, 1000.0231,2545.3728,10.3403);
		SetPlayerFacingAngle(playerid,  235.6451);
		SetCameraBehindPlayer(playerid);
		format(string, sizeof(string), "%s [ID:%d] телепортирован на Drift 45 (/drift45)", pName, playerid);
		SendClientMessageToAll(COLOR_YELLOW, string);
		GameTextForPlayer(playerid, "~w~Добро пожаловать на Drift 45! ~G~", 5000, 5);
	}
	return true;
}
CMD:drift46(playerid)
{	
	new string[256];
	new pName[24];
	if(IsPlayerInAnyVehicle(playerid))
	{
		if(GetPlayerState(playerid) == PLAYER_STATE_DRIVER)
		{
			SetVehiclePos(GetPlayerVehicleID(playerid),1322.6106,2236.8350,10.4909);
			SetVehicleZAngle(GetPlayerVehicleID(playerid), 2.3974);
			SetCameraBehindPlayer(playerid);
			format(string, sizeof(string), "%s [ID:%d] телепортирован на Drift 46 (/drift46)", pName, playerid);
			SendClientMessageToAll(COLOR_YELLOW, string);
			GameTextForPlayer(playerid, "~w~Добро пожаловать на Drift 46! ~G~", 5000, 5);
		}
		else
		{
			SendClientMessage(playerid, COLOR_RED, "GameMode.Error: Вы должны быть в машине!");
		}
	}
	else
	{
		SetPlayerPos(playerid, 1322.6106,2236.8350,10.4909);
		SetPlayerFacingAngle(playerid,  2.3974);
		SetCameraBehindPlayer(playerid);
		format(string, sizeof(string), "%s [ID:%d] телепортирован на Drift 46 (/drift46)", pName, playerid);
		SendClientMessageToAll(COLOR_YELLOW, string);
		GameTextForPlayer(playerid, "~w~Добро пожаловать на Drift 46! ~G~", 5000, 5);
	}
	return true;
}
CMD:drift47(playerid)
{	
	new string[256];
	new pName[24];
	if(IsPlayerInAnyVehicle(playerid))
	{
		if(GetPlayerState(playerid) == PLAYER_STATE_DRIVER)
		{
			SetVehiclePos(GetPlayerVehicleID(playerid),1500.5153,994.9993,10.4639);
			SetVehicleZAngle(GetPlayerVehicleID(playerid), 90.1991);
			SetCameraBehindPlayer(playerid);
			format(string, sizeof(string), "%s [ID:%d] телепортирован на Drift 47 (/drift47)", pName, playerid);
			SendClientMessageToAll(COLOR_YELLOW, string);
			GameTextForPlayer(playerid, "~w~Добро пожаловать на Drift 47! ~G~", 5000, 5);
		}
		else
		{
			SendClientMessage(playerid, COLOR_RED, "GameMode.Error: Вы должны быть в машине!");
		}
	}
	else
	{
		SetPlayerPos(playerid, 1500.5153,994.9993,10.4639);
		SetPlayerFacingAngle(playerid,  90.1991);
		SetCameraBehindPlayer(playerid);
		format(string, sizeof(string), "%s [ID:%d] телепортирован на Drift 47 (/drift47)", pName, playerid);
		SendClientMessageToAll(COLOR_YELLOW, string);
		GameTextForPlayer(playerid, "~w~Добро пожаловать на Drift 47! ~G~", 5000, 5);
	}
	return true;
}
CMD:drift48(playerid)
{	
	new string[256];
	new pName[24];
	if(IsPlayerInAnyVehicle(playerid))
	{
		if(GetPlayerState(playerid) == PLAYER_STATE_DRIVER)
		{
			SetVehiclePos(GetPlayerVehicleID(playerid),2050.2854,864.9113,6.4736);
			SetVehicleZAngle(GetPlayerVehicleID(playerid), 182.3646);
			SetCameraBehindPlayer(playerid);
			format(string, sizeof(string), "%s [ID:%d] телепортирован на Drift 48 (/drift48)", pName, playerid);
			SendClientMessageToAll(COLOR_YELLOW, string);
			GameTextForPlayer(playerid, "~w~Добро пожаловать на Drift 48! ~G~", 5000, 5);
		}
		else
		{
			SendClientMessage(playerid, COLOR_RED, "GameMode.Error: Вы должны быть в машине!");
		}
	}
	else
	{
		SetPlayerPos(playerid, 2050.2854,864.9113,6.4736);
		SetPlayerFacingAngle(playerid,  182.3646);
		SetCameraBehindPlayer(playerid);
		format(string, sizeof(string), "%s [ID:%d] телепортирован на Drift 48 (/drift48)", pName, playerid);
		SendClientMessageToAll(COLOR_YELLOW, string);
		GameTextForPlayer(playerid, "~w~Добро пожаловать на Drift 48! ~G~", 5000, 5);
	}
	return true;
}
CMD:drift49(playerid)
{	
	new string[256];
	new pName[24];
	if(IsPlayerInAnyVehicle(playerid))
	{
		if(GetPlayerState(playerid) == PLAYER_STATE_DRIVER)
		{
			SetVehiclePos(GetPlayerVehicleID(playerid),2634.6064,1312.7318,10.4710);
			SetVehicleZAngle(GetPlayerVehicleID(playerid), 270.8752);
			SetCameraBehindPlayer(playerid);
			format(string, sizeof(string), "%s [ID:%d] телепортирован на Drift 49 (/drift49)", pName, playerid);
			SendClientMessageToAll(COLOR_YELLOW, string);
			GameTextForPlayer(playerid, "~w~Добро пожаловать на Drift 49! ~G~", 5000, 5);
		}
		else
		{
			SendClientMessage(playerid, COLOR_RED, "GameMode.Error: Вы должны быть в машине!");
		}
	}
	else
	{
		SetPlayerPos(playerid, 2634.6064,1312.7318,10.4710);
		SetPlayerFacingAngle(playerid,  270.8752);
		SetCameraBehindPlayer(playerid);
		format(string, sizeof(string), "%s [ID:%d] телепортирован на Drift 49 (/drift49)", pName, playerid);
		SendClientMessageToAll(COLOR_YELLOW, string);
		GameTextForPlayer(playerid, "~w~Добро пожаловать на Drift 49! ~G~", 5000, 5);
	}
	return true;
}
CMD:drift50(playerid)
{	
	new string[256];
	new pName[24];
	if(IsPlayerInAnyVehicle(playerid))
	{
		if(GetPlayerState(playerid) == PLAYER_STATE_DRIVER)
		{
			SetVehiclePos(GetPlayerVehicleID(playerid),1605.4539,2279.6563,10.4743);
			SetVehicleZAngle(GetPlayerVehicleID(playerid), 1.3359);
			SetCameraBehindPlayer(playerid);
			format(string, sizeof(string), "%s [ID:%d] телепортирован на Drift 50 (/drift50)", pName, playerid);
			SendClientMessageToAll(COLOR_YELLOW, string);
			GameTextForPlayer(playerid, "~w~Добро пожаловать на Drift 50! ~G~", 5000, 5);
		}
		else
		{
			SendClientMessage(playerid, COLOR_RED, "GameMode.Error: Вы должны быть в машине!");
		}
	}
	else
	{
		SetPlayerPos(playerid, 1605.4539,2279.6563,10.4743);
		SetPlayerFacingAngle(playerid,  1.3359);
		SetCameraBehindPlayer(playerid);
		format(string, sizeof(string), "%s [ID:%d] телепортирован на Drift 50 (/drift50)", pName, playerid);
		SendClientMessageToAll(COLOR_YELLOW, string);
		GameTextForPlayer(playerid, "~w~Добро пожаловать на Drift 50! ~G~", 5000, 5);
	}
	return true;
}
CMD:drift51(playerid)
{	
	new string[256];
	new pName[24];
	if(IsPlayerInAnyVehicle(playerid))
	{
		if(GetPlayerState(playerid) == PLAYER_STATE_DRIVER)
		{
			SetVehiclePos(GetPlayerVehicleID(playerid),2080.7761,-1865.9845,13.0337);
			SetVehicleZAngle(GetPlayerVehicleID(playerid), 179.1301);
			SetCameraBehindPlayer(playerid);
			format(string, sizeof(string), "%s [ID:%d] телепортирован на Drift 51 (/drift51)", pName, playerid);
			SendClientMessageToAll(COLOR_YELLOW, string);
			GameTextForPlayer(playerid, "~w~Добро пожаловать на Drift 51! ~G~", 5000, 5);
		}
		else
		{
			SendClientMessage(playerid, COLOR_RED, "GameMode.Error: Вы должны быть в машине!");
		}
	}
	else
	{
		SetPlayerPos(playerid, 2080.7761,-1865.9845,13.0337);
		SetPlayerFacingAngle(playerid,  179.1301);
		SetCameraBehindPlayer(playerid);
		format(string, sizeof(string), "%s [ID:%d] телепортирован на Drift 51 (/drift51)", pName, playerid);
		SendClientMessageToAll(COLOR_YELLOW, string);
		GameTextForPlayer(playerid, "~w~Добро пожаловать на Drift 51! ~G~", 5000, 5);
	}
	return true;
}
CMD:drift52(playerid)
{	
	new string[256];
	new pName[24];
	if(IsPlayerInAnyVehicle(playerid))
	{
		if(GetPlayerState(playerid) == PLAYER_STATE_DRIVER)
		{
			SetVehiclePos(GetPlayerVehicleID(playerid),1342.4817,-1576.3361,13.0962);
			SetVehicleZAngle(GetPlayerVehicleID(playerid), 179.1301);
			SetCameraBehindPlayer(playerid);
			format(string, sizeof(string), "%s [ID:%d] телепортирован на Drift 52 (/drift52)", pName, playerid);
			SendClientMessageToAll(COLOR_YELLOW, string);
			GameTextForPlayer(playerid, "~w~Добро пожаловать на Drift 52! ~G~", 5000, 5);
		}
		else
		{
			SendClientMessage(playerid, COLOR_RED, "GameMode.Error: Вы должны быть в машине!");
		}
	}
	else
	{
		SetPlayerPos(playerid, 1342.4817,-1576.3361,13.0962);
		SetPlayerFacingAngle(playerid,  179.1301);
		SetCameraBehindPlayer(playerid);
		format(string, sizeof(string), "%s [ID:%d] телепортирован на Drift 52 (/drift52)", pName, playerid);
		SendClientMessageToAll(COLOR_YELLOW, string);
		GameTextForPlayer(playerid, "~w~Добро пожаловать на Drift 52! ~G~", 5000, 5);
	}
	return true;
}
CMD:drift53(playerid)
{	
	new string[256];
	new pName[24];
	if(IsPlayerInAnyVehicle(playerid))
	{
		if(GetPlayerState(playerid) == PLAYER_STATE_DRIVER)
		{
			SetVehiclePos(GetPlayerVehicleID(playerid),835.6555,-878.2632,68.0216);
			SetVehicleZAngle(GetPlayerVehicleID(playerid), 238.8432);
			SetCameraBehindPlayer(playerid);
			format(string, sizeof(string), "%s [ID:%d] телепортирован на Drift 53 (/drift53)", pName, playerid);
			SendClientMessageToAll(COLOR_YELLOW, string);
			GameTextForPlayer(playerid, "~w~Добро пожаловать на Drift 53! ~G~", 5000, 5);
		}
		else
		{
			SendClientMessage(playerid, COLOR_RED, "GameMode.Error: Вы должны быть в машине!");
		}
	}
	else
	{
		SetPlayerPos(playerid, 835.6555,-878.2632,68.0216);
		SetPlayerFacingAngle(playerid,  238.8432);
		SetCameraBehindPlayer(playerid);
		format(string, sizeof(string), "%s [ID:%d] телепортирован на Drift 53 (/drift53)", pName, playerid);
		SendClientMessageToAll(COLOR_YELLOW, string);
		GameTextForPlayer(playerid, "~w~Добро пожаловать на Drift 53! ~G~", 5000, 5);
	}
	return true;
}
//TODO:
//return SendClientMessage(playerid,COLOR_RED,"GameMode.Error: Неизвестная команда, доступные команды ищите в /help");

public OnRconLoginAttempt(ip[], password[], success)
{
	if(!success) //Если пароль введёный игроком был неправильный.
	{
		printf("RCON Login: Неудачная попытка входа %s использованный пароль %s",ip, password);
		new pip[16];
		for(new i=0; i<MAX_PLAYERS; i++) //Цикл, для поиска игрока, который ввёл неверные данные.
		{
			GetPlayerIp(i, pip, sizeof(pip));
			if(!strcmp(ip, pip, true)) //Если, IP игрока, который ввёл неверный пароль нашёлся.
			{
				SendClientMessage(i, 0xFFFFFFFF, "Неверный пароль. Удачи"); //Отправить сообщение
				Ban(i); //Теперь ещё ему бан.
			}
		}
	}
	return true;
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

public OnPlayerUpdate(playerid)
{
	if(!IsPlayerConnected(playerid)) return 0;
	if(IsPlayerNPC(playerid)) return true;
	if( !gPlayerHasCitySelected[playerid] && GetPlayerState(playerid) == PLAYER_STATE_SPECTATING ) {
		ClassSel_HandleCitySelection(playerid);
		return true;
	}
	if(IsPlayerInAnyVehicle(playerid))
	{
		if(God[playerid] == 1)
		{
			new vid;
			vid = GetPlayerVehicleID(playerid);
			RepairVehicle(vid);
		}
	}
	if(God[playerid] == 1) ResetPlayerWeapons(playerid);
	return true;
}

public OnPlayerClickMap(playerid, Float:fX, Float:fY, Float:fZ)
{
	SetPlayerPosFindZ(playerid, fX, fY, fZ);
	return true;
}

public OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
	if(dialogid == 0)
	{
		if(response)
		{
			new Float:x,Float:y,Float:z,Float:ang;
			SetVehicleNumberPlate(GetPlayerVehicleID(playerid), inputtext);
			GetVehiclePos(GetPlayerVehicleID(playerid),x,y,z);
			GetVehicleZAngle(GetPlayerVehicleID(playerid),ang);
			SetVehicleToRespawn(GetPlayerVehicleID(playerid));
			SetVehiclePos(GetPlayerVehicleID(playerid),x,y,z);
			PutPlayerInVehicle(playerid,GetPlayerVehicleID(playerid),0);
			SetVehicleZAngle(GetPlayerVehicleID(playerid),ang);
		}
		else
		{
			SendClientMessage(playerid,0xFFFFFFFF,"Вы отменили действие!");
		}
	}
	return true;	
}

stock IsInvalidSkin(skinid)
{
	switch(skinid)
	{
	case 3..6, 8, 42, 65, 74, 86, 119, 149, 208, 273, 289: return true;
	}
	return false;
}

stock GetOnlinePlayersCount()
{
	new counter;
	for(new playerid = 0; playerid <= GetPlayerPoolSize(); playerid++)
	{
		if(!IsPlayerConnected(playerid)) continue;
		counter++;
	}
	return counter;
}
