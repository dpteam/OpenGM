#include <a_samp>
#include <core>
#include <float>
#include "../include/gl_common.inc"
#include "../include/gl_spawns.inc"

new Text: Textdraw0;

main() {
	print("GameMode.Init > Open-Source gamemode <github.com/dpteam/OpenGM>");
	print("GameMode.Init > on LFI [License Free Information]");
	print("GameMode.Init > Gamemode Loaded");
}

#define MAX_BAD_SKINS 14
#define COLOR_GREY 0xAFAFAFFF
#define COLOR_GREEN 0x33AA33FF
#define COLOR_RED 0xAA3333FF
#define COLOR_YELLOW 0xFFFF00FF
#define COLOR_WHITE 0xFFFFFFFF
#define COLOR_BLUE 0x3A47DEFF
#define INACTIVE_PLAYER_ID 255
#define GIVECASH_DELAY 5000
#define NUMVALUES 4
#define COLOR_NORMAL_PLAYER 0xFFBB7777
#define CITY_LOS_SANTOS 	0
#define CITY_SAN_FIERRO 	1
#define CITY_LAS_VENTURAS 	2

forward MoneyGrubScoreUpdate();
forward Givecashdelaytimer(playerid);
forward SetPlayerRandomSpawn(playerid);
forward SetupPlayerForClassSelection(playerid);
forward GameModeExitFunc();
forward SendPlayerFormattedText(playerid, const str[], define);
forward public SendAllFormattedText(playerid, const str[], define);

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

public OnPlayerPickUpPickup(playerid, pickupid) {
	new s[256];
	format(s,256,"Picked up %d",pickupid);
	SendClientMessage(playerid,COLOR_WHITE,s);
}

public OnGameModeInit() {
	SetGameModeText("<github.com/dpteam/OpenGM>");
	ShowPlayerMarkers(PLAYER_MARKERS_MODE_GLOBAL);
	ShowNameTags(1);
	SetNameTagDrawDistance(40.0);
	EnableStuntBonusForAll(1);
	UsePlayerPedAnims();
	AllowInteriorWeapons(1);

	ClassSel_InitTextDraws();

	for(new s = 0; s < 300; s++) {
		if(IsInvalidSkin(s)) continue;
		AddPlayerClass(s, 1958.3783, 1343.1572, 15.3746, 269.1425, 0, 0, 0, 0, 0, 0);
	}

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

	return 1;
}

forward SetupPlayerForClassSelection(playerid);
public SetupPlayerForClassSelection(playerid) {
	SetPlayerInterior(playerid,14);
	SetPlayerPos(playerid,258.4893,-41.4008,1002.0234);
	SetPlayerFacingAngle(playerid, 90.0);
	SetPlayerCameraPos(playerid,256.0815,-43.0475,1003.0234);
	SetPlayerCameraLookAt(playerid,258.4893,-41.4008,1002.0234);
}

public OnPlayerConnect(playerid) {
	gPlayerCitySelection[playerid] = -1;
	gPlayerHasCitySelected[playerid] = 0;
	gPlayerLastCitySelectionTick[playerid] = GetTickCount();
	new pName[MAX_PLAYER_NAME], string[39 + MAX_PLAYER_NAME];
	GetPlayerName(playerid, pName, sizeof(pName));
	format(string, sizeof(string), "%s [ID:%d] connected to server.", pName, playerid);
	SendClientMessageToAll(COLOR_GREY, string);
	SendDeathMessage(INVALID_PLAYER_ID,playerid,200);
	SendClientMessage(playerid,COLOR_WHITE,"Welcome to Open-Source gamemode server");
	SendClientMessage(playerid,COLOR_WHITE,"=You may fork this project at=");
	SendClientMessage(playerid,COLOR_BLUE,"http://github.com/dpteam/OpenGM");
	SendClientMessage(playerid,COLOR_GREEN,"Use /help to see commands");
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

public OnPlayerDisconnect(playerid, reason) {
	new pName[MAX_PLAYER_NAME], string[39 + MAX_PLAYER_NAME];
	GetPlayerName(playerid, pName, sizeof(pName));
	new reasons[3][64] = {
		"crashed/low-energy",
		"disconnected",
		"kicked"
	};
	/*switch(reason) {
	case 0: format(string, sizeof(string), "%s [ID:%d] crashed/low-energy", pName, playerid);
	case 1: format(string, sizeof(string), "%s [ID:%d] out", pName, playerid);
	case 2: format(string, sizeof(string), "%s [ID:%d] kicked/banned", pName, playerid);
	}*/
	format(string, sizeof(string), "%s [ID:%d] %s", pName, playerid, reasons[reason]);
	SendClientMessageToAll(COLOR_GREY, string);
	SendDeathMessage(INVALID_PLAYER_ID,playerid,201);
	gActivePlayers[playerid]--;
	return 1;
}

public OnPlayerSpawn(playerid)
{
	if(IsPlayerNPC(playerid)) return 1;

	new randSpawn = 0;

	SetPlayerInterior(playerid,0);
	TogglePlayerClock(playerid,0);
	ResetPlayerMoney(playerid);
	GivePlayerMoney(playerid, 30000);

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

	GivePlayerMoney(playerid, 10000);
	GivePlayerWeapon(playerid, 30, 350);
	GivePlayerWeapon(playerid, 34, 50);
	GivePlayerWeapon(playerid, 4, 1);
	GivePlayerWeapon(playerid, 24, 120);
	SetPlayerInterior(playerid,0);
	TogglePlayerClock(playerid,1);

	return 1;
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
	GameTextForPlayer(playerid,"~w~WASTED",6000,3);
	return 1;
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
	txtClassSelHelper = TextDrawCreate(10.0, 415.0,
	" Press ~b~~k~~GO_LEFT~ ~w~or ~b~~k~~GO_RIGHT~ ~w~to switch cities.~n~ Press ~r~~k~~PED_FIREWEAPON~ ~w~to select.");
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
	if(IsPlayerNPC(playerid)) return 1;

	if(gPlayerHasCitySelected[playerid]) {
		ClassSel_SetupCharSelection(playerid);
		return 1;
	} else {
		if(GetPlayerState(playerid) != PLAYER_STATE_SPECTATING) {
			TogglePlayerSpectating(playerid,1);
			TextDrawShowForPlayer(playerid, txtClassSelHelper);
			gPlayerCitySelection[playerid] = -1;
		}
	}
	return 0;
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
	if(strcmp("/help", cmdtext, true, 10) == 0)
	{
		SendClientMessage(playerid,COLOR_RED,"WARNING: This GameMode for testing purposes only!");
		SendClientMessage(playerid,COLOR_WHITE,"Use /kill to suicide");
		SendClientMessage(playerid,COLOR_WHITE,"Use /fix to fix car");
		SendClientMessage(playerid,COLOR_WHITE,"Use /flip to flip car");
		SendClientMessage(playerid,COLOR_WHITE,"Use /card to spawn cars");
		return 1;
	}
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
		if(!IsPlayerInAnyVehicle(playerid))
		{
			SendClientMessage(playerid, COLOR_RED,"You need to be in a vehicle to use this command!");
			return 1;
		}

		new Float:PX, Float:PY, Float:PZ, Float:PA;
		GetPlayerPos(playerid, PX, PY, PZ);
		GetVehicleZAngle(GetPlayerVehicleID(playerid), PA);
		SetVehiclePos(GetPlayerVehicleID(playerid), PX, PY, PZ+1);
		SetVehicleZAngle(GetPlayerVehicleID(playerid), PA);
		SendClientMessage(playerid, COLOR_WHITE, "Your vehicle has been successfully flipped!");
		PlayerPlaySound(playerid, 1085, 0.0, 0.0, 0.0);
		return 1;
	}
	if(strcmp(cmdtext,"/cars",true)==0)
	{
		SendClientMessage(playerid,COLOR_YELLOW,"=========================== CARS ========================");
		SendClientMessage(playerid,COLOR_WHITE,"=== /huntley /landstalker /perrenial /rancher /rancher2 /regina /banshee /bullet /zr-350 /benson /dumper ===");
		SendClientMessage(playerid,COLOR_WHITE,"=== /romero /solair /alpha /blista /bravura /buccaneer /cadrona /cheetah /comet /turismo /windsor /dozer ===");
		SendClientMessage(playerid,COLOR_WHITE,"=== /club /esperanto /feltzer /fortune /hermes /hustler /majestic /hotknife /infernus /supergt /mesa ===");
		SendClientMessage(playerid,COLOR_WHITE,"=== /manana /picador /previon /stafford /stallion /tampa /virgo /hotring /hotringa /hotringb /dft-30 ===");
		SendClientMessage(playerid,COLOR_WHITE,"=== /admiral /elegant /emperor /euros /glendale /glendale2 /greenwood /boxville /boxville2 /cementtruck ===");
		SendClientMessage(playerid,COLOR_WHITE,"=== /intruder /merit /nebula /oceanic /premier /primo /sentinel /stretch /dune /flatbed /hotdog /linerunner ===");
		SendClientMessage(playerid,COLOR_WHITE,"=== /sunrise /tahoma /vincent /washington /willard /buffalo /clover /mrwoopee /mule /packer /roadtrain ===");
		SendClientMessage(playerid,COLOR_WHITE,"=== /phoenix /sabre /elegy /flash /jester /stratum /sultan /uranus /tanker /tractor /yankee /topfun ===");
		SendClientMessage(playerid,COLOR_WHITE,"=== /bobcat /burrito /forklift /moonbeam /mower /newsvan /pony /rumpo /sadler /sadler2 /tug /walton ===");
		SendClientMessage(playerid,COLOR_WHITE,"=== /blade /broadway /remington /savanna /slamvan /tornado /voodoo /yosemite /linerunner  /combine ===");
		SendClientMessage(playerid,COLOR_YELLOW,"=== /other /bikes /public /security /aircrafts /boats /rccars ===");
		return 1;
	}
	if(strcmp(cmdtext,"/other",true)==0)
	{
		SendClientMessage(playerid,COLOR_YELLOW,"=========================== OTHER ========================");
		SendClientMessage(playerid,COLOR_WHITE,"=== /bandito /bfinjection /bloodringbanger /caddy /camper /journey /kart /monster /monstera /monsterb ===");
		SendClientMessage(playerid,COLOR_WHITE,"=== /quad /sandking /vortex ===");
		return 1;
	}
	if(strcmp(cmdtext,"/bikes",true) == 0)
	{
		SendClientMessage(playerid,COLOR_YELLOW,"=========================== BIKES ========================");
		SendClientMessage(playerid,COLOR_WHITE,"=== /bmx /bike /mountainbike /bf-400 /faggio /fcr-900 /freeway /nrg-500 /pcj-600 /pizzaboy /sanchez /wayfarer ===");
		return 1;
	}
	if(strcmp(cmdtext,"/public",true)==0)
	{
		SendClientMessage(playerid,COLOR_YELLOW,"=========================== PUBLIC ========================");
		SendClientMessage(playerid,COLOR_WHITE,"=== /baggage /bus /ambulance /cabbie /coach /sweeper /taxi /towtruck /trashmaster /utilityvan ===");
		return 1;
	}
	if(strcmp(cmdtext,"/security",true)==0)
	{
		SendClientMessage(playerid,COLOR_YELLOW,"*=========================== SECURITY ========================");
		SendClientMessage(playerid,COLOR_WHITE,"=== /barracks /enforcer /fbirancher /fbitruck /firetruck /firetrucka /hpv-1000 /patriot /rhino ===");
		SendClientMessage(playerid,COLOR_WHITE,"=== /policels /policesf /policelv /policeranger /securicar /swattank ===");
		return 1;
	}
	if(strcmp(cmdtext,"/aircrafts",true)==0)
	{
		SendClientMessage(playerid,COLOR_YELLOW,"*=========================== AIRCRAFTS ========================");
		SendClientMessage(playerid,COLOR_WHITE,"=== /andromada /at-400 /beagle /cargobob /cropduster /dodo /hunter /leviathon /maverick /nevada /hydra ===");
		SendClientMessage(playerid,COLOR_WHITE,"=== /newsmaverick /policemaverick /raindance /rustler /seasparrow /shamal /skimmer /sparrow /stuntplane ===");
		return 1;
	}
	if(strcmp(cmdtext,"/boats",true)==0)
	{
		SendClientMessage(playerid,COLOR_YELLOW,"*=========================== BOATS ========================");
		SendClientMessage(playerid,COLOR_WHITE,"=== /coastguard /dingy /jetmax /launch /marquis /predator /reefer /speeder /squallo /tropic ===");
		return 1;
	}
	if(strcmp(cmdtext,"/rccars",true)==0)
	{
		SendClientMessage(playerid,COLOR_YELLOW,"*=========================== RC CARS ========================");
		SendClientMessage(playerid,COLOR_WHITE,"=== /rcbandit /rcbaron /rccam /rcgoblin /rcgoblin2 /rctiger ===");
		return 1;
	}
	if(strcmp(cmdtext,"/huntley",true) == 0)
	{
		new Float:X;
		new Float:Y;
		new Float:Z;
		GetPlayerPos(playerid,X,Y,Z);
		GameTextForPlayer(playerid,"~h~~w~HUNTLEY~n~~h~~w~ID:~h~~r~579",2500,1);
		CreateVehicle(579,X,Y+5,Z,1,1,1,90000);
		return 1;
	}
	if(strcmp(cmdtext,"/landstalker",true) == 0)
	{
		new Float:X;
		new Float:Y;
		new Float:Z;
		GetPlayerPos(playerid,X,Y,Z);
		GameTextForPlayer(playerid,"~h~~w~LANDSTALKER~n~~h~~w~ID:~h~~r~400",2500,1);
		CreateVehicle(400,X,Y+5,Z,1,1,1,90000);
		return 1;
	}
	if(strcmp(cmdtext,"/perrenial",true) == 0)
	{
		new Float:X;
		new Float:Y;
		new Float:Z;
		GetPlayerPos(playerid,X,Y,Z);
		GameTextForPlayer(playerid,"~h~~w~PERRENIAL~n~~h~~w~ID:~h~~r~404",2500,1);
		CreateVehicle(404,X,Y+5,Z,1,1,1,90000);
		return 1;
	}
	if(strcmp(cmdtext,"/rancher",true) == 0)
	{
		new Float:X;
		new Float:Y;
		new Float:Z;
		GetPlayerPos(playerid,X,Y,Z);
		GameTextForPlayer(playerid,"~h~~w~RANCHER~n~~h~~w~ID:~h~~r~489",2500,1);
		CreateVehicle(489,X,Y+5,Z,1,1,1,90000);
		return 1;
	}
	if(strcmp(cmdtext,"/rancher2",true) == 0)
	{
		new Float:X;
		new Float:Y;
		new Float:Z;
		GetPlayerPos(playerid,X,Y,Z);
		GameTextForPlayer(playerid,"~h~~w~ANOTHER RANCHER~n~~h~~w~ID:~h~~r~505",2500,1);
		CreateVehicle(505,X,Y+5,Z,1,1,1,90000);
		return 1;
	}
	if(strcmp(cmdtext,"/regina",true) == 0)
	{
		new Float:X;
		new Float:Y;
		new Float:Z;
		GetPlayerPos(playerid,X,Y,Z);
		GameTextForPlayer(playerid,"~h~~w~REGINA~n~~h~~w~ID:~h~~r~479",2500,1);
		CreateVehicle(479,X,Y+5,Z,1,1,1,90000);
		return 1;
	}
	if(strcmp(cmdtext,"/romero",true) == 0)
	{
		new Float:X;
		new Float:Y;
		new Float:Z;
		GetPlayerPos(playerid,X,Y,Z);
		GameTextForPlayer(playerid,"~h~~w~ROMERO~n~~h~~w~ID:~h~~r~442",2500,1);
		CreateVehicle(442,X,Y+5,Z,1,1,1,90000);
		return 1;
	}
	if(strcmp(cmdtext,"/solair",true) == 0)
	{
		new Float:X;
		new Float:Y;
		new Float:Z;
		GetPlayerPos(playerid,X,Y,Z);
		GameTextForPlayer(playerid,"~h~~w~SOLAIR~n~~h~~w~ID:~h~~r~458",2500,1);
		CreateVehicle(458,X,Y+5,Z,1,1,1,90000);
		return 1;
	}
	if(strcmp(cmdtext,"/alpha",true) == 0)
	{
		new Float:X;
		new Float:Y;
		new Float:Z;
		GetPlayerPos(playerid,X,Y,Z);
		GameTextForPlayer(playerid,"~h~~w~ALPHA~n~~h~~w~ID:~h~~r~602",2500,1);
		CreateVehicle(602,X,Y+5,Z,1,1,1,90000);
		return 1;
	}
	if(strcmp(cmdtext,"/blista",true) == 0)
	{
		new Float:X;
		new Float:Y;
		new Float:Z;
		GetPlayerPos(playerid,X,Y,Z);
		GameTextForPlayer(playerid,"~h~~w~BLISTA COMPACT~n~~h~~w~ID:~h~~r~496",2500,1);
		CreateVehicle(496,X,Y+5,Z,1,1,1,90000);
		return 1;
	}
	if(strcmp(cmdtext,"/bravura",true) == 0)
	{
		new Float:X;
		new Float:Y;
		new Float:Z;
		GetPlayerPos(playerid,X,Y,Z);
		GameTextForPlayer(playerid,"~h~~w~BRAVURA~n~~h~~w~ID:~h~~r~401",2500,1);
		CreateVehicle(401,X,Y+5,Z,1,1,1,90000);
		return 1;
	}
	if(strcmp(cmdtext,"/buccaneer",true) == 0)
	{
		new Float:X;
		new Float:Y;
		new Float:Z;
		GetPlayerPos(playerid,X,Y,Z);
		GameTextForPlayer(playerid,"~h~~w~BUCCANEER~n~~h~~w~ID:~h~~r~518",2500,1);
		CreateVehicle(518,X,Y+5,Z,1,1,1,90000);
		return 1;
	}
	if(strcmp(cmdtext,"/cadrona",true) == 0)
	{
		new Float:X;
		new Float:Y;
		new Float:Z;
		GetPlayerPos(playerid,X,Y,Z);
		GameTextForPlayer(playerid,"~h~~w~CADRONA~n~~h~~w~ID:~h~~r~527",2500,1);
		CreateVehicle(527,X,Y+5,Z,1,1,1,90000);
		return 1;
	}
	if(strcmp(cmdtext,"/club",true) == 0)
	{
		new Float:X;
		new Float:Y;
		new Float:Z;
		GetPlayerPos(playerid,X,Y,Z);
		GameTextForPlayer(playerid,"~h~~w~CLUB~n~~h~~w~ID:~h~~r~589",2500,1);
		CreateVehicle(589,X,Y+5,Z,1,1,1,90000);
		return 1;
	}
	if(strcmp(cmdtext,"/esperanto",true) == 0)
	{
		new Float:X;
		new Float:Y;
		new Float:Z;
		GetPlayerPos(playerid,X,Y,Z);
		GameTextForPlayer(playerid,"~h~~w~ESPERANTO~n~~h~~w~ID:~h~~r~419",2500,1);
		CreateVehicle(419,X,Y+5,Z,1,1,1,90000);
		return 1;
	}
	if(strcmp(cmdtext,"/feltzer",true) == 0)
	{
		new Float:X;
		new Float:Y;
		new Float:Z;
		GetPlayerPos(playerid,X,Y,Z);
		GameTextForPlayer(playerid,"~h~~w~FELTZER~n~~h~~w~ID:~h~~r~533",2500,1);
		CreateVehicle(533,X,Y+5,Z,1,1,1,90000);
		return 1;
	}
	if(strcmp(cmdtext,"/fortune",true) == 0)
	{
		new Float:X;
		new Float:Y;
		new Float:Z;
		GetPlayerPos(playerid,X,Y,Z);
		GameTextForPlayer(playerid,"~h~~w~FORTUNE~n~~h~~w~ID:~h~~r~526",2500,1);
		CreateVehicle(526,X,Y+5,Z,1,1,1,90000);
		return 1;
	}
	if(strcmp(cmdtext,"/hermes",true) == 0)
	{
		new Float:X;
		new Float:Y;
		new Float:Z;
		GetPlayerPos(playerid,X,Y,Z);
		GameTextForPlayer(playerid,"~h~~w~HERMES~n~~h~~w~ID:~h~~r~474",2500,1);
		CreateVehicle(474,X,Y+5,Z,1,1,1,90000);
		return 1;
	}
	if(strcmp(cmdtext,"/hustler",true) == 0)
	{
		new Float:X;
		new Float:Y;
		new Float:Z;
		GetPlayerPos(playerid,X,Y,Z);
		GameTextForPlayer(playerid,"~h~~w~HUSTLER~n~~h~~w~ID:~h~~r~545",2500,1);
		CreateVehicle(545,X,Y+5,Z,1,1,1,90000);
		return 1;
	}
	if(strcmp(cmdtext,"/majestic",true) == 0)
	{
		new Float:X;
		new Float:Y;
		new Float:Z;
		GetPlayerPos(playerid,X,Y,Z);
		GameTextForPlayer(playerid,"~h~~w~MAJESTIC~n~~h~~w~ID:~h~~r~517",2500,1);
		CreateVehicle(517,X,Y+5,Z,1,1,1,90000);
		return 1;
	}
	if(strcmp(cmdtext,"/manana",true) == 0)
	{
		new Float:X;
		new Float:Y;
		new Float:Z;
		GetPlayerPos(playerid,X,Y,Z);
		GameTextForPlayer(playerid,"~h~~w~MANANA~n~~h~~w~ID:~h~~r~410",2500,1);
		CreateVehicle(410,X,Y+5,Z,1,1,1,90000);
		return 1;
	}
	if(strcmp(cmdtext,"/picador",true) == 0)
	{
		new Float:X;
		new Float:Y;
		new Float:Z;
		GetPlayerPos(playerid,X,Y,Z);
		GameTextForPlayer(playerid,"~h~~w~PICADOR~n~~h~~w~ID:~h~~r~600",2500,1);
		CreateVehicle(600,X,Y+5,Z,1,1,1,90000);
		return 1;
	}
	if(strcmp(cmdtext,"/previon",true) == 0)
	{
		new Float:X;
		new Float:Y;
		new Float:Z;
		GetPlayerPos(playerid,X,Y,Z);
		GameTextForPlayer(playerid,"~h~~w~PREVION~n~~h~~w~ID:~h~~r~436",2500,1);
		CreateVehicle(436,X,Y+5,Z,1,1,1,90000);
		return 1;
	}
	if(strcmp(cmdtext,"/stafford",true) == 0)
	{
		new Float:X;
		new Float:Y;
		new Float:Z;
		GetPlayerPos(playerid,X,Y,Z);
		GameTextForPlayer(playerid,"~h~~w~STAFFORD~n~~h~~w~ID:~h~~r~580",2500,1);
		CreateVehicle(580,X,Y+5,Z,1,1,1,90000);
		return 1;
	}
	if(strcmp(cmdtext,"/stallion",true) == 0)
	{
		new Float:X;
		new Float:Y;
		new Float:Z;
		GetPlayerPos(playerid,X,Y,Z);
		GameTextForPlayer(playerid,"~h~~w~STALLION~n~~h~~w~ID:~h~~r~439",2500,1);
		CreateVehicle(439,X,Y+5,Z,1,1,1,90000);
		return 1;
	}
	if(strcmp(cmdtext,"/tampa",true) == 0)
	{
		new Float:X;
		new Float:Y;
		new Float:Z;
		GetPlayerPos(playerid,X,Y,Z);
		GameTextForPlayer(playerid,"~h~~w~TAMPA~n~~h~~w~ID:~h~~r~549",2500,1);
		CreateVehicle(549,X,Y+5,Z,1,1,1,90000);
		return 1;
	}
	if(strcmp(cmdtext,"/virgo",true) == 0)
	{
		new Float:X;
		new Float:Y;
		new Float:Z;
		GetPlayerPos(playerid,X,Y,Z);
		GameTextForPlayer(playerid,"~h~~w~VIRGO~n~~h~~w~ID:~h~~r~491",2500,1);
		CreateVehicle(491,X,Y+5,Z,1,1,1,90000);
		return 1;
	}
	if(strcmp(cmdtext,"/admiral",true) == 0)
	{
		new Float:X;
		new Float:Y;
		new Float:Z;
		GetPlayerPos(playerid,X,Y,Z);
		GameTextForPlayer(playerid,"~h~~w~ADMIRAL~n~~h~~w~ID:~h~~r~445",2500,1);
		CreateVehicle(445,X,Y+5,Z,1,1,1,90000);
		return 1;
	}
	if(strcmp(cmdtext,"/elegant",true) == 0)
	{
		new Float:X;
		new Float:Y;
		new Float:Z;
		GetPlayerPos(playerid,X,Y,Z);
		GameTextForPlayer(playerid,"~h~~w~ELEGANT~n~~h~~w~ID:~h~~r~507",2500,1);
		CreateVehicle(507,X,Y+5,Z,1,1,1,90000);
		return 1;
	}
	if(strcmp(cmdtext,"/emperor",true) == 0)
	{
		new Float:X;
		new Float:Y;
		new Float:Z;
		GetPlayerPos(playerid,X,Y,Z);
		GameTextForPlayer(playerid,"~h~~w~EMPEROR~n~~h~~w~ID:~h~~r~585",2500,1);
		CreateVehicle(585,X,Y+5,Z,1,1,1,90000);
		return 1;
	}
	if(strcmp(cmdtext,"/euros",true) == 0)
	{
		new Float:X;
		new Float:Y;
		new Float:Z;
		GetPlayerPos(playerid,X,Y,Z);
		GameTextForPlayer(playerid,"~h~~w~EUROS~n~~h~~w~ID:~h~~r~587",2500,1);
		CreateVehicle(587,X,Y+5,Z,1,1,1,90000);
		return 1;
	}
	if(strcmp(cmdtext,"/glendale",true) == 0)
	{
		new Float:X;
		new Float:Y;
		new Float:Z;
		GetPlayerPos(playerid,X,Y,Z);
		GameTextForPlayer(playerid,"~h~~w~GLENDALE~n~~h~~w~ID:~h~~r~466",2500,1);
		CreateVehicle(466,X,Y+5,Z,1,1,1,90000);
		return 1;
	}
	if(strcmp(cmdtext,"/greenwood",true) == 0)
	{
		new Float:X;
		new Float:Y;
		new Float:Z;
		GetPlayerPos(playerid,X,Y,Z);
		GameTextForPlayer(playerid,"~h~~w~GREENWOOD~n~~h~~w~ID:~h~~r~492",2500,1);
		CreateVehicle(492,X,Y+5,Z,1,1,1,90000);
		return 1;
	}
	if(strcmp(cmdtext,"/intruder",true) == 0)
	{
		new Float:X;
		new Float:Y;
		new Float:Z;
		GetPlayerPos(playerid,X,Y,Z);
		GameTextForPlayer(playerid,"~h~~w~INTRUDER~n~~h~~w~ID:~h~~r~546",2500,1);
		CreateVehicle(546,X,Y+5,Z,1,1,1,90000);
		return 1;
	}
	if(strcmp(cmdtext,"/merit",true) == 0)
	{
		new Float:X;
		new Float:Y;
		new Float:Z;
		GetPlayerPos(playerid,X,Y,Z);
		GameTextForPlayer(playerid,"~h~~w~MERIT~n~~h~~w~ID:~h~~r~551",2500,1);
		CreateVehicle(551,X,Y+5,Z,1,1,1,90000);
		return 1;
	}
	if(strcmp(cmdtext,"/nebula",true) == 0)
	{
		new Float:X;
		new Float:Y;
		new Float:Z;
		GetPlayerPos(playerid,X,Y,Z);
		GameTextForPlayer(playerid,"~h~~w~NEBULA~n~~h~~w~ID:~h~~r~516",2500,1);
		CreateVehicle(516,X,Y+5,Z,1,1,1,90000);
		return 1;
	}
	if(strcmp(cmdtext,"/oceanic",true) == 0)
	{
		new Float:X;
		new Float:Y;
		new Float:Z;
		GetPlayerPos(playerid,X,Y,Z);
		GameTextForPlayer(playerid,"~h~~w~OCEANIC~n~~h~~w~ID:~h~~r~467",2500,1);
		CreateVehicle(467,X,Y+5,Z,1,1,1,90000);
		return 1;
	}
	if(strcmp(cmdtext,"/premier",true) == 0)
	{
		new Float:X;
		new Float:Y;
		new Float:Z;
		GetPlayerPos(playerid,X,Y,Z);
		GameTextForPlayer(playerid,"~h~~w~PREMIER~n~~h~~w~ID:~h~~r~426",2500,1);
		CreateVehicle(426,X,Y+5,Z,1,1,1,90000);
		return 1;
	}
	if(strcmp(cmdtext,"/primo",true) == 0)
	{
		new Float:X;
		new Float:Y;
		new Float:Z;
		GetPlayerPos(playerid,X,Y,Z);
		GameTextForPlayer(playerid,"~h~~w~PRIMO~n~~h~~w~ID:~h~~r~547",2500,1);
		CreateVehicle(547,X,Y+5,Z,1,1,1,90000);
		return 1;
	}
	if(strcmp(cmdtext,"/sentinel",true) == 0)
	{
		new Float:X;
		new Float:Y;
		new Float:Z;
		GetPlayerPos(playerid,X,Y,Z);
		GameTextForPlayer(playerid,"~h~~w~SENTINEL~n~~h~~w~ID:~h~~r~405",2500,1);
		CreateVehicle(405,X,Y+5,Z,1,1,1,90000);
		return 1;
	}
	if(strcmp(cmdtext,"/stretch",true) == 0)
	{
		new Float:X;
		new Float:Y;
		new Float:Z;
		GetPlayerPos(playerid,X,Y,Z);
		GameTextForPlayer(playerid,"~h~~w~STRETCH~n~~h~~w~ID:~h~~r~409",2500,1);
		CreateVehicle(409,X,Y+5,Z,1,1,1,90000);
		return 1;
	}
	if(strcmp(cmdtext,"/sunrise",true) == 0)
	{
		new Float:X;
		new Float:Y;
		new Float:Z;
		GetPlayerPos(playerid,X,Y,Z);
		GameTextForPlayer(playerid,"~h~~w~SUNRISE~n~~h~~w~ID:~h~~r~550",2500,1);
		CreateVehicle(550,X,Y+5,Z,1,1,1,90000);
		return 1;
	}
	if(strcmp(cmdtext,"/tahoma",true) == 0)
	{
		new Float:X;
		new Float:Y;
		new Float:Z;
		GetPlayerPos(playerid,X,Y,Z);
		GameTextForPlayer(playerid,"~h~~w~TAHOMA~n~~h~~w~ID:~h~~r~566",2500,1);
		CreateVehicle(566,X,Y+5,Z,1,1,1,90000);
		return 1;
	}
	if(strcmp(cmdtext,"/vincent",true) == 0)
	{
		new Float:X;
		new Float:Y;
		new Float:Z;
		GetPlayerPos(playerid,X,Y,Z);
		GameTextForPlayer(playerid,"~h~~w~VINCENT~n~~h~~w~ID:~h~~r~540",2500,1);
		CreateVehicle(540,X,Y+5,Z,1,1,1,90000);
		return 1;
	}
	if(strcmp(cmdtext,"/washington",true) == 0)
	{
		new Float:X;
		new Float:Y;
		new Float:Z;
		GetPlayerPos(playerid,X,Y,Z);
		GameTextForPlayer(playerid,"~h~~w~WASHINGTON~n~~h~~w~ID:~h~~r~421",2500,1);
		CreateVehicle(421,X,Y+5,Z,1,1,1,90000);
		return 1;
	}
	if(strcmp(cmdtext,"/willard",true) == 0)
	{
		new Float:X;
		new Float:Y;
		new Float:Z;
		GetPlayerPos(playerid,X,Y,Z);
		GameTextForPlayer(playerid,"~h~~w~WILLARD~n~~h~~w~ID:~h~~r~529",2500,1);
		CreateVehicle(529,X,Y+5,Z,1,1,1,90000);
		return 1;
	}
	if(strcmp(cmdtext,"/majestic",true) == 0)
	{
		new Float:X;
		new Float:Y;
		new Float:Z;
		GetPlayerPos(playerid,X,Y,Z);
		GameTextForPlayer(playerid,"~h~~w~MAJESTIC~n~~h~~w~ID:~h~~r~517",2500,1);
		CreateVehicle(517,X,Y+5,Z,1,1,1,90000);
		return 1;
	}
	if(strcmp(cmdtext,"/buffalo",true) == 0)
	{
		new Float:X;
		new Float:Y;
		new Float:Z;
		GetPlayerPos(playerid,X,Y,Z);
		GameTextForPlayer(playerid,"~h~~w~BUFFALO~n~~h~~w~ID:~h~~r~402",2500,1);
		CreateVehicle(402,X,Y+5,Z,1,1,1,90000);
		return 1;
	}
	if(strcmp(cmdtext,"/clover",true) == 0)
	{
		new Float:X;
		new Float:Y;
		new Float:Z;
		GetPlayerPos(playerid,X,Y,Z);
		GameTextForPlayer(playerid,"~h~~w~CLOVER~n~~h~~w~ID:~h~~r~542",2500,1);
		CreateVehicle(542,X,Y+5,Z,1,1,1,90000);
		return 1;
	}
	if(strcmp(cmdtext,"/phoenix",true) == 0)
	{
		new Float:X;
		new Float:Y;
		new Float:Z;
		GetPlayerPos(playerid,X,Y,Z);
		GameTextForPlayer(playerid,"~h~~w~PHOENIX~n~~h~~w~ID:~h~~r~603",2500,1);
		CreateVehicle(603,X,Y+5,Z,1,1,1,90000);
		return 1;
	}
	if(strcmp(cmdtext,"/sabre",true) == 0)
	{
		new Float:X;
		new Float:Y;
		new Float:Z;
		GetPlayerPos(playerid,X,Y,Z);
		GameTextForPlayer(playerid,"~h~~w~SABRE~n~~h~~w~ID:~h~~r~475",2500,1);
		CreateVehicle(475,X,Y+5,Z,1,1,1,90000);
		return 1;
	}
	if(strcmp(cmdtext,"/elegy",true) == 0)
	{
		new Float:X;
		new Float:Y;
		new Float:Z;
		GetPlayerPos(playerid,X,Y,Z);
		GameTextForPlayer(playerid,"~h~~w~ELEGY~n~~h~~w~ID:~h~~r~562",2500,1);
		CreateVehicle(562,X,Y+5,Z,1,1,1,90000);
		return 1;
	}
	if(strcmp(cmdtext,"/flash",true) == 0)
	{
		new Float:X;
		new Float:Y;
		new Float:Z;
		GetPlayerPos(playerid,X,Y,Z);
		GameTextForPlayer(playerid,"~h~~w~FLASH~n~~h~~w~ID:~h~~r~565",2500,1);
		CreateVehicle(565,X,Y+5,Z,1,1,1,90000);
		return 1;
	}
	if(strcmp(cmdtext,"/jester",true) == 0)
	{
		new Float:X;
		new Float:Y;
		new Float:Z;
		GetPlayerPos(playerid,X,Y,Z);
		GameTextForPlayer(playerid,"~h~~w~JESTER~n~~h~~w~ID:~h~~r~559",2500,1);
		CreateVehicle(559,X,Y+5,Z,1,1,1,90000);
		return 1;
	}
	if(strcmp(cmdtext,"/stratum",true) == 0)
	{
		new Float:X;
		new Float:Y;
		new Float:Z;
		GetPlayerPos(playerid,X,Y,Z);
		GameTextForPlayer(playerid,"~h~~w~STRATUM~n~~h~~w~ID:~h~~r~561",2500,1);
		CreateVehicle(561,X,Y+5,Z,1,1,1,90000);
		return 1;
	}
	if(strcmp(cmdtext,"/sultan",true) == 0)
	{
		new Float:X;
		new Float:Y;
		new Float:Z;
		GetPlayerPos(playerid,X,Y,Z);
		GameTextForPlayer(playerid,"~h~~w~SULTAN~n~~h~~w~ID:~h~~r~560",2500,1);
		CreateVehicle(560,X,Y+5,Z,1,1,1,90000);
		return 1;
	}
	if(strcmp(cmdtext,"/uranus",true) == 0)
	{
		new Float:X;
		new Float:Y;
		new Float:Z;
		GetPlayerPos(playerid,X,Y,Z);
		GameTextForPlayer(playerid,"~h~~w~URANUS~n~~h~~w~ID:~h~~r~558",2500,1);
		CreateVehicle(558,X,Y+5,Z,1,1,1,90000);
		return 1;
	}
	if(strcmp(cmdtext,"/banshee",true) == 0)
	{
		new Float:X;
		new Float:Y;
		new Float:Z;
		GetPlayerPos(playerid,X,Y,Z);
		GameTextForPlayer(playerid,"~h~~w~BANSHEE~n~~h~~w~ID:~h~~r~429",2500,1);
		CreateVehicle(429,X,Y+5,Z,1,1,1,90000);
		return 1;
	}
	if(strcmp(cmdtext,"/bullet",true) == 0)
	{
		new Float:X;
		new Float:Y;
		new Float:Z;
		GetPlayerPos(playerid,X,Y,Z);
		GameTextForPlayer(playerid,"~h~~w~BULLET~n~~h~~w~ID:~h~~r~541",2500,1);
		CreateVehicle(541,X,Y+5,Z,1,1,1,90000);
		return 1;
	}
	if(strcmp(cmdtext,"/cheetah",true) == 0)
	{
		new Float:X;
		new Float:Y;
		new Float:Z;
		GetPlayerPos(playerid,X,Y,Z);
		GameTextForPlayer(playerid,"~h~~w~CHEETAH~n~~h~~w~ID:~h~~r~415",2500,1);
		CreateVehicle(415,X,Y+5,Z,1,1,1,90000);
		return 1;
	}
	if(strcmp(cmdtext,"/comet",true) == 0)
	{
		new Float:X;
		new Float:Y;
		new Float:Z;
		GetPlayerPos(playerid,X,Y,Z);
		GameTextForPlayer(playerid,"~h~~w~COMET~n~~h~~w~ID:~h~~r~480",2500,1);
		CreateVehicle(480,X,Y+5,Z,1,1,1,90000);
		return 1;
	}
	if(strcmp(cmdtext,"/hotknife",true) == 0)
	{
		new Float:X;
		new Float:Y;
		new Float:Z;
		GetPlayerPos(playerid,X,Y,Z);
		GameTextForPlayer(playerid,"~h~~w~HOTKNIFE~n~~h~~w~ID:~h~~r~434",2500,1);
		CreateVehicle(434,X,Y+5,Z,1,1,1,90000);
		return 1;
	}
	if(strcmp(cmdtext,"/hotring",true) == 0)
	{
		new Float:X;
		new Float:Y;
		new Float:Z;
		GetPlayerPos(playerid,X,Y,Z);
		GameTextForPlayer(playerid,"~h~~w~HOTRING~n~~h~~w~ID:~h~~r~494",2500,1);
		CreateVehicle(494,X,Y+5,Z,1,1,1,90000);
		return 1;
	}
	if(strcmp(cmdtext,"/hotringa",true) == 0)
	{
		new Float:X;
		new Float:Y;
		new Float:Z;
		GetPlayerPos(playerid,X,Y,Z);
		GameTextForPlayer(playerid,"~h~~w~HOTRING A~n~~h~~w~ID:~h~~r~502",2500,1);
		CreateVehicle(502,X,Y+5,Z,1,1,1,90000);
		return 1;
	}
	if(strcmp(cmdtext,"/hotringb",true) == 0)
	{
		new Float:X;
		new Float:Y;
		new Float:Z;
		GetPlayerPos(playerid,X,Y,Z);
		GameTextForPlayer(playerid,"~h~~w~HOTRING B~n~~h~~w~ID:~h~~r~503",2500,1);
		CreateVehicle(503,X,Y+5,Z,1,1,1,90000);
		return 1;
	}
	if(strcmp(cmdtext,"/infernus",true) == 0)
	{
		new Float:X;
		new Float:Y;
		new Float:Z;
		GetPlayerPos(playerid,X,Y,Z);
		GameTextForPlayer(playerid,"~h~~w~INFERNUS~n~~h~~w~ID:~h~~r~411",2500,1);
		CreateVehicle(411,X,Y+5,Z,1,1,1,90000);
		return 1;
	}
	if(strcmp(cmdtext,"/supergt",true) == 0)
	{
		new Float:X;
		new Float:Y;
		new Float:Z;
		GetPlayerPos(playerid,X,Y,Z);
		GameTextForPlayer(playerid,"~h~~w~SUPER GT~n~~h~~w~ID:~h~~r~506",2500,1);
		CreateVehicle(506,X,Y+5,Z,1,1,1,90000);
		return 1;
	}
	if(strcmp(cmdtext,"/turismo",true) == 0)
	{
		new Float:X;
		new Float:Y;
		new Float:Z;
		GetPlayerPos(playerid,X,Y,Z);
		GameTextForPlayer(playerid,"~h~~w~TURISMO~n~~h~~w~ID:~h~~r~451",2500,1);
		CreateVehicle(451,X,Y+5,Z,1,1,1,90000);
		return 1;
	}
	if(strcmp(cmdtext,"/windsor",true) == 0)
	{
		new Float:X;
		new Float:Y;
		new Float:Z;
		GetPlayerPos(playerid,X,Y,Z);
		GameTextForPlayer(playerid,"~h~~w~WINDSOR~n~~h~~w~ID:~h~~r~555",2500,1);
		CreateVehicle(555,X,Y+5,Z,1,1,1,90000);
		return 1;
	}
	if(strcmp(cmdtext,"/zr-350",true) == 0)
	{
		new Float:X;
		new Float:Y;
		new Float:Z;
		GetPlayerPos(playerid,X,Y,Z);
		GameTextForPlayer(playerid,"~h~~w~ZR-350~n~~h~~w~ID:~h~~r~477",2500,1);
		CreateVehicle(477,X,Y+5,Z,1,1,1,90000);
		return 1;
	}
	if(strcmp(cmdtext,"/benson",true) == 0)
	{
		new Float:X;
		new Float:Y;
		new Float:Z;
		GetPlayerPos(playerid,X,Y,Z);
		GameTextForPlayer(playerid,"~h~~w~BENSON~n~~h~~w~ID:~h~~r~499",2500,1);
		CreateVehicle(499,X,Y+5,Z,1,1,1,90000);
		return 1;
	}
	if(strcmp(cmdtext,"/boxville",true) == 0)
	{
		new Float:X;
		new Float:Y;
		new Float:Z;
		GetPlayerPos(playerid,X,Y,Z);
		GameTextForPlayer(playerid,"~h~~w~BOXVILLE~n~~h~~w~ID:~h~~r~498",2500,1);
		CreateVehicle(498,X,Y+5,Z,1,1,1,90000);
		return 1;
	}
	if(strcmp(cmdtext,"/boxville2",true) == 0)
	{
		new Float:X;
		new Float:Y;
		new Float:Z;
		GetPlayerPos(playerid,X,Y,Z);
		GameTextForPlayer(playerid,"~h~~w~BOXVILLE ( black )~n~~h~~w~ID:~h~~r~609",2500,1);
		CreateVehicle(609,X,Y+5,Z,1,1,1,90000);
		return 1;
	}
	if(strcmp(cmdtext,"/cementtruck",true) == 0)
	{
		new Float:X;
		new Float:Y;
		new Float:Z;
		GetPlayerPos(playerid,X,Y,Z);
		GameTextForPlayer(playerid,"~h~~w~CEMENT TRUCK~n~~h~~w~ID:~h~~r~524",2500,1);
		CreateVehicle(524,X,Y+5,Z,1,1,1,90000);
		return 1;
	}
	if(strcmp(cmdtext,"/combine",true) == 0)
	{
		new Float:X;
		new Float:Y;
		new Float:Z;
		GetPlayerPos(playerid,X,Y,Z);
		GameTextForPlayer(playerid,"~h~~w~COMBINE HARVESTOR~n~~h~~w~ID:~h~~r~532",2500,1);
		CreateVehicle(532,X,Y+5,Z,1,1,1,90000);
		return 1;
	}
	if(strcmp(cmdtext,"/dft-30",true) == 0)
	{
		new Float:X;
		new Float:Y;
		new Float:Z;
		GetPlayerPos(playerid,X,Y,Z);
		GameTextForPlayer(playerid,"~h~~w~DFT-30~n~~h~~w~ID:~h~~r~578",2500,1);
		CreateVehicle(578,X,Y+5,Z,1,1,1,90000);
		return 1;
	}
	if(strcmp(cmdtext,"/dozer",true) == 0)
	{
		new Float:X;
		new Float:Y;
		new Float:Z;
		GetPlayerPos(playerid,X,Y,Z);
		GameTextForPlayer(playerid,"~h~~w~DOZER~n~~h~~w~ID:~h~~r~486",2500,1);
		CreateVehicle(486,X,Y+5,Z,1,1,1,90000);
		return 1;
	}
	if(strcmp(cmdtext,"/dumper",true) == 0)
	{
		new Float:X;
		new Float:Y;
		new Float:Z;
		GetPlayerPos(playerid,X,Y,Z);
		GameTextForPlayer(playerid,"~h~~w~DUMPER~n~~h~~w~ID:~h~~r~406",2500,1);
		CreateVehicle(406,X,Y+5,Z,1,1,1,90000);
		return 1;
	}
	if(strcmp(cmdtext,"/dune",true) == 0)
	{
		new Float:X;
		new Float:Y;
		new Float:Z;
		GetPlayerPos(playerid,X,Y,Z);
		GameTextForPlayer(playerid,"~h~~w~DUNE~n~~h~~w~ID:~h~~r~573",2500,1);
		CreateVehicle(573,X,Y+5,Z,1,1,1,90000);
		return 1;
	}
	if(strcmp(cmdtext,"/flatbed",true) == 0)
	{
		new Float:X;
		new Float:Y;
		new Float:Z;
		GetPlayerPos(playerid,X,Y,Z);
		GameTextForPlayer(playerid,"~h~~w~FLATBED~n~~h~~w~ID:~h~~r~455",2500,1);
		CreateVehicle(455,X,Y+5,Z,1,1,1,90000);
		return 1;
	}
	if(strcmp(cmdtext,"/hotdog",true) == 0)
	{
		new Float:X;
		new Float:Y;
		new Float:Z;
		GetPlayerPos(playerid,X,Y,Z);
		GameTextForPlayer(playerid,"~h~~w~HOTDOG~n~~h~~w~ID:~h~~r~588",2500,1);
		CreateVehicle(588,X,Y+5,Z,1,1,1,90000);
		return 1;
	}
	if(strcmp(cmdtext,"/linerunner",true) == 0)
	{
		new Float:X;
		new Float:Y;
		new Float:Z;
		GetPlayerPos(playerid,X,Y,Z);
		GameTextForPlayer(playerid,"~h~~w~LINERUNNER~n~~h~~w~ID:~h~~r~403",2500,1);
		CreateVehicle(403,X,Y+5,Z,1,1,1,90000);
		return 1;
	}
	if(strcmp(cmdtext,"/mrwoopee",true) == 0)
	{
		new Float:X;
		new Float:Y;
		new Float:Z;
		GetPlayerPos(playerid,X,Y,Z);
		GameTextForPlayer(playerid,"~h~~w~MR WOOPEE~n~~h~~w~ID:~h~~r~423",2500,1);
		CreateVehicle(423,X,Y+5,Z,1,1,1,90000);
		return 1;
	}
	if(strcmp(cmdtext,"/mule",true) == 0)
	{
		new Float:X;
		new Float:Y;
		new Float:Z;
		GetPlayerPos(playerid,X,Y,Z);
		GameTextForPlayer(playerid,"~h~~w~MULE~n~~h~~w~ID:~h~~r~414",2500,1);
		CreateVehicle(414,X,Y+5,Z,1,1,1,90000);
		return 1;
	}
	if(strcmp(cmdtext,"/packer",true) == 0)
	{
		new Float:X;
		new Float:Y;
		new Float:Z;
		GetPlayerPos(playerid,X,Y,Z);
		GameTextForPlayer(playerid,"~h~~w~PACKER~n~~h~~w~ID:~h~~r~443",2500,1);
		CreateVehicle(443,X,Y+5,Z,1,1,1,90000);
		return 1;
	}
	if(strcmp(cmdtext,"/roadtrain",true) == 0)
	{
		new Float:X;
		new Float:Y;
		new Float:Z;
		GetPlayerPos(playerid,X,Y,Z);
		GameTextForPlayer(playerid,"~h~~w~ROADTRAIN~n~~h~~w~ID:~h~~r~515",2500,1);
		CreateVehicle(515,X,Y+5,Z,1,1,1,90000);
		return 1;
	}
	if(strcmp(cmdtext,"/tanker",true) == 0)
	{
		new Float:X;
		new Float:Y;
		new Float:Z;
		GetPlayerPos(playerid,X,Y,Z);
		GameTextForPlayer(playerid,"~h~~w~TANKER~n~~h~~w~ID:~h~~r~514",2500,1);
		CreateVehicle(514,X,Y+5,Z,1,1,1,90000);
		return 1;
	}
	if(strcmp(cmdtext,"/tractor",true) == 0)
	{
		new Float:X;
		new Float:Y;
		new Float:Z;
		GetPlayerPos(playerid,X,Y,Z);
		GameTextForPlayer(playerid,"~h~~w~TRACTOR~n~~h~~w~ID:~h~~r~531",2500,1);
		CreateVehicle(531,X,Y+5,Z,1,1,1,90000);
		return 1;
	}
	if(strcmp(cmdtext,"/yankee",true) == 0)
	{
		new Float:X;
		new Float:Y;
		new Float:Z;
		GetPlayerPos(playerid,X,Y,Z);
		GameTextForPlayer(playerid,"~h~~w~YANKEE~n~~h~~w~ID:~h~~r~456",2500,1);
		CreateVehicle(456,X,Y+5,Z,1,1,1,90000);
		return 1;
	}
	if(strcmp(cmdtext,"/topfun",true) == 0)
	{
		new Float:X;
		new Float:Y;
		new Float:Z;
		GetPlayerPos(playerid,X,Y,Z);
		GameTextForPlayer(playerid,"~h~~w~TOPFUN~n~~h~~w~ID:~h~~r~459",2500,1);
		CreateVehicle(459,X,Y+5,Z,1,1,1,90000);
		return 1;
	}
	if(strcmp(cmdtext,"/bobcat",true) == 0)
	{
		new Float:X;
		new Float:Y;
		new Float:Z;
		GetPlayerPos(playerid,X,Y,Z);
		GameTextForPlayer(playerid,"~h~~w~BOBCAT~n~~h~~w~ID:~h~~r~422",2500,1);
		CreateVehicle(422,X,Y+5,Z,1,1,1,90000);
		return 1;
	}
	if(strcmp(cmdtext,"/burrito",true) == 0)
	{
		new Float:X;
		new Float:Y;
		new Float:Z;
		GetPlayerPos(playerid,X,Y,Z);
		GameTextForPlayer(playerid,"~h~~w~BURRITO~n~~h~~w~ID:~h~~r~482",2500,1);
		CreateVehicle(482,X,Y+5,Z,1,1,1,90000);
		return 1;
	}
	if(strcmp(cmdtext,"/forklift",true) == 0)
	{
		new Float:X;
		new Float:Y;
		new Float:Z;
		GetPlayerPos(playerid,X,Y,Z);
		GameTextForPlayer(playerid,"~h~~w~FORKLIFT~n~~h~~w~ID:~h~~r~530",2500,1);
		CreateVehicle(530,X,Y+5,Z,1,1,1,90000);
		return 1;
	}
	if(strcmp(cmdtext,"/moonbeam",true) == 0)
	{
		new Float:X;
		new Float:Y;
		new Float:Z;
		GetPlayerPos(playerid,X,Y,Z);
		GameTextForPlayer(playerid,"~h~~w~MOONBEAM~n~~h~~w~ID:~h~~r~418",2500,1);
		CreateVehicle(418,X,Y+5,Z,1,1,1,90000);
		return 1;
	}
	if(strcmp(cmdtext,"/mower",true) == 0)
	{
		new Float:X;
		new Float:Y;
		new Float:Z;
		GetPlayerPos(playerid,X,Y,Z);
		GameTextForPlayer(playerid,"~h~~w~MOWER~n~~h~~w~ID:~h~~r~572",2500,1);
		CreateVehicle(572,X,Y+5,Z,1,1,1,90000);
		return 1;
	}
	if(strcmp(cmdtext,"/newsvan",true) == 0)
	{
		new Float:X;
		new Float:Y;
		new Float:Z;
		GetPlayerPos(playerid,X,Y,Z);
		GameTextForPlayer(playerid,"~h~~w~NEWSVAN~n~~h~~w~ID:~h~~r~582",2500,1);
		CreateVehicle(582,X,Y+5,Z,1,1,1,90000);
		return 1;
	}
	if(strcmp(cmdtext,"/pony",true) == 0)
	{
		new Float:X;
		new Float:Y;
		new Float:Z;
		GetPlayerPos(playerid,X,Y,Z);
		GameTextForPlayer(playerid,"~h~~w~PONY~n~~h~~w~ID:~h~~r~413",2500,1);
		CreateVehicle(413,X,Y+5,Z,1,1,1,90000);
		return 1;
	}
	if(strcmp(cmdtext,"/rumpo",true) == 0)
	{
		new Float:X;
		new Float:Y;
		new Float:Z;
		GetPlayerPos(playerid,X,Y,Z);
		GameTextForPlayer(playerid,"~h~~w~RUMPO~n~~h~~w~ID:~h~~r~440",2500,1);
		CreateVehicle(440,X,Y+5,Z,1,1,1,90000);
		return 1;
	}
	if(strcmp(cmdtext,"/sadler",true) == 0)
	{
		new Float:X;
		new Float:Y;
		new Float:Z;
		GetPlayerPos(playerid,X,Y,Z);
		GameTextForPlayer(playerid,"~h~~w~SADLER~n~~h~~w~ID:~h~~r~543",2500,1);
		CreateVehicle(543,X,Y+5,Z,1,1,1,90000);
		return 1;
	}
	if(strcmp(cmdtext,"/tug",true) == 0)
	{
		new Float:X;
		new Float:Y;
		new Float:Z;
		GetPlayerPos(playerid,X,Y,Z);
		GameTextForPlayer(playerid,"~h~~w~TUG~n~~h~~w~ID:~h~~r~583",2500,1);
		CreateVehicle(583,X,Y+5,Z,1,1,1,90000);
		return 1;
	}
	if(strcmp(cmdtext,"/walton",true) == 0)
	{
		new Float:X;
		new Float:Y;
		new Float:Z;
		GetPlayerPos(playerid,X,Y,Z);
		GameTextForPlayer(playerid,"~h~~w~WALTON~n~~h~~w~ID:~h~~r~478",2500,1);
		CreateVehicle(478,X,Y+5,Z,1,1,1,90000);
		return 1;
	}
	if(strcmp(cmdtext,"/yosemite",true) == 0)
	{
		new Float:X;
		new Float:Y;
		new Float:Z;
		GetPlayerPos(playerid,X,Y,Z);
		GameTextForPlayer(playerid,"~h~~w~YOSEMITE~n~~h~~w~ID:~h~~r~554",2500,1);
		CreateVehicle(554,X,Y+5,Z,1,1,1,90000);
		return 1;
	}
	if(strcmp(cmdtext,"/blade",true) == 0)
	{
		new Float:X;
		new Float:Y;
		new Float:Z;
		GetPlayerPos(playerid,X,Y,Z);
		GameTextForPlayer(playerid,"~h~~w~BLADE~n~~h~~w~ID:~h~~r~536",2500,1);
		CreateVehicle(536,X,Y+5,Z,1,1,1,90000);
		return 1;
	}
	if(strcmp(cmdtext,"/broadway",true) == 0)
	{
		new Float:X;
		new Float:Y;
		new Float:Z;
		GetPlayerPos(playerid,X,Y,Z);
		GameTextForPlayer(playerid,"~h~~w~BROADWAY~n~~h~~w~ID:~h~~r~575",2500,1);
		CreateVehicle(575,X,Y+5,Z,1,1,1,90000);
		return 1;
	}
	if(strcmp(cmdtext,"/remington",true) == 0)
	{
		new Float:X;
		new Float:Y;
		new Float:Z;
		GetPlayerPos(playerid,X,Y,Z);
		GameTextForPlayer(playerid,"~h~~w~REMINGTON~n~~h~~w~ID:~h~~r~534",2500,1);
		CreateVehicle(534,X,Y+5,Z,1,1,1,90000);
		return 1;
	}
	if(strcmp(cmdtext,"/savanna",true) == 0)
	{
		new Float:X;
		new Float:Y;
		new Float:Z;
		GetPlayerPos(playerid,X,Y,Z);
		GameTextForPlayer(playerid,"~h~~w~SAVANNA~n~~h~~w~ID:~h~~r~567",2500,1);
		CreateVehicle(567,X,Y+5,Z,1,1,1,90000);
		return 1;
	}
	if(strcmp(cmdtext,"/slamvan",true) == 0)
	{
		new Float:X;
		new Float:Y;
		new Float:Z;
		GetPlayerPos(playerid,X,Y,Z);
		GameTextForPlayer(playerid,"~h~~w~SLAMVAN~n~~h~~w~ID:~h~~r~535",2500,1);
		CreateVehicle(535,X,Y+5,Z,1,1,1,90000);
		return 1;
	}
	if(strcmp(cmdtext,"/tornado",true) == 0)
	{
		new Float:X;
		new Float:Y;
		new Float:Z;
		GetPlayerPos(playerid,X,Y,Z);
		GameTextForPlayer(playerid,"~h~~w~TORNADO~n~~h~~w~ID:~h~~r~576",2500,1);
		CreateVehicle(576,X,Y+5,Z,1,1,1,90000);
		return 1;
	}
	if(strcmp(cmdtext,"/voodoo",true) == 0)
	{
		new Float:X;
		new Float:Y;
		new Float:Z;
		GetPlayerPos(playerid,X,Y,Z);
		GameTextForPlayer(playerid,"~h~~w~VOODOO~n~~h~~w~ID:~h~~r~412",2500,1);
		CreateVehicle(412,X,Y+5,Z,1,1,1,90000);
		return 1;
	}
	if(strcmp(cmdtext,"/bandito",true) == 0)
	{
		new Float:X;
		new Float:Y;
		new Float:Z;
		GetPlayerPos(playerid,X,Y,Z);
		GameTextForPlayer(playerid,"~h~~w~BANDITO~n~~h~~w~ID:~h~~r~568",2500,1);
		CreateVehicle(568,X,Y+5,Z,1,1,1,90000);
		return 1;
	}
	if(strcmp(cmdtext,"/bfinjection",true) == 0)
	{
		new Float:X;
		new Float:Y;
		new Float:Z;
		GetPlayerPos(playerid,X,Y,Z);
		GameTextForPlayer(playerid,"~h~~w~BF INJECTION~n~~h~~w~ID:~h~~r~424",2500,1);
		CreateVehicle(424,X,Y+5,Z,1,1,1,90000);
		return 1;
	}
	if(strcmp(cmdtext,"/bloodringbanger",true) == 0)
	{
		new Float:X;
		new Float:Y;
		new Float:Z;
		GetPlayerPos(playerid,X,Y,Z);
		GameTextForPlayer(playerid,"~h~~w~BLOODRING BANGER~n~~h~~w~ID:~h~~r~504",2500,1);
		CreateVehicle(504,X,Y+5,Z,1,1,1,90000);
		return 1;
	}
	if(strcmp(cmdtext,"/caddy",true) == 0)
	{
		new Float:X;
		new Float:Y;
		new Float:Z;
		GetPlayerPos(playerid,X,Y,Z);
		GameTextForPlayer(playerid,"~h~~w~CADDY~n~~h~~w~ID:~h~~r~457",2500,1);
		CreateVehicle(457,X,Y+5,Z,1,1,1,90000);
		return 1;
	}
	if(strcmp(cmdtext,"/camper",true) == 0)
	{
		new Float:X;
		new Float:Y;
		new Float:Z;
		GetPlayerPos(playerid,X,Y,Z);
		GameTextForPlayer(playerid,"~h~~w~CAMPER~n~~h~~w~ID:~h~~r~483",2500,1);
		CreateVehicle(483,X,Y+5,Z,1,1,1,90000);
		return 1;
	}
	if(strcmp(cmdtext,"/journey",true) == 0)
	{
		new Float:X;
		new Float:Y;
		new Float:Z;
		GetPlayerPos(playerid,X,Y,Z);
		GameTextForPlayer(playerid,"~h~~w~JOURNEY~n~~h~~w~ID:~h~~r~508",2500,1);
		CreateVehicle(508,X,Y+5,Z,1,1,1,90000);
		return 1;
	}
	if(strcmp(cmdtext,"/kart",true) == 0)
	{
		new Float:X;
		new Float:Y;
		new Float:Z;
		GetPlayerPos(playerid,X,Y,Z);
		GameTextForPlayer(playerid,"~h~~w~KART~n~~h~~w~ID:~h~~r~571",2500,1);
		CreateVehicle(571,X,Y+5,Z,1,1,1,90000);
		return 1;
	}
	if(strcmp(cmdtext,"/mesa",true) == 0)
	{
		new Float:X;
		new Float:Y;
		new Float:Z;
		GetPlayerPos(playerid,X,Y,Z);
		GameTextForPlayer(playerid,"~h~~w~MESA~n~~h~~w~ID:~h~~r~500",2500,1);
		CreateVehicle(500,X,Y+5,Z,1,1,1,90000);
		return 1;
	}
	if(strcmp(cmdtext,"/monster",true) == 0)
	{
		new Float:X;
		new Float:Y;
		new Float:Z;
		GetPlayerPos(playerid,X,Y,Z);
		GameTextForPlayer(playerid,"~h~~w~MONSTER~n~~h~~w~ID:~h~~r~444",2500,1);
		CreateVehicle(444,X,Y+5,Z,1,1,1,90000);
		return 1;
	}
	if(strcmp(cmdtext,"/monstera",true) == 0)
	{
		new Float:X;
		new Float:Y;
		new Float:Z;
		GetPlayerPos(playerid,X,Y,Z);
		GameTextForPlayer(playerid,"~h~~w~MONSTER A~n~~h~~w~ID:~h~~r~556",2500,1);
		CreateVehicle(556,X,Y+5,Z,1,1,1,90000);
		return 1;
	}
	if(strcmp(cmdtext,"/monsterb",true) == 0)
	{
		new Float:X;
		new Float:Y;
		new Float:Z;
		GetPlayerPos(playerid,X,Y,Z);
		GameTextForPlayer(playerid,"~h~~w~MONSTER B~n~~h~~w~ID:~h~~r~557",2500,1);
		CreateVehicle(557,X,Y+5,Z,1,1,1,90000);
		return 1;
	}
	if(strcmp(cmdtext,"/quad",true) == 0)
	{
		new Float:X;
		new Float:Y;
		new Float:Z;
		GetPlayerPos(playerid,X,Y,Z);
		GameTextForPlayer(playerid,"~h~~w~QUAD~n~~h~~w~ID:~h~~r~471",2500,1);
		CreateVehicle(471,X,Y+5,Z,1,1,1,90000);
		return 1;
	}
	if(strcmp(cmdtext,"/sandking",true) == 0)
	{
		new Float:X;
		new Float:Y;
		new Float:Z;
		GetPlayerPos(playerid,X,Y,Z);
		GameTextForPlayer(playerid,"~h~~w~SANDKING~n~~h~~w~ID:~h~~r~495",2500,1);
		CreateVehicle(495,X,Y+5,Z,1,1,1,90000);
		return 1;
	}
	if(strcmp(cmdtext,"/vortex",true) == 0)
	{
		new Float:X;
		new Float:Y;
		new Float:Z;
		GetPlayerPos(playerid,X,Y,Z);
		GameTextForPlayer(playerid,"~h~~w~VORTEX~n~~h~~w~ID:~h~~r~539",2500,1);
		CreateVehicle(539,X,Y+5,Z,1,1,1,90000);
		return 1;
	}
	if(strcmp(cmdtext,"/bmx",true) == 0)
	{
		new Float:X;
		new Float:Y;
		new Float:Z;
		GetPlayerPos(playerid,X,Y,Z);
		GameTextForPlayer(playerid,"~h~~w~BMX~n~~h~~w~ID:~h~~r~481",2500,1);
		CreateVehicle(481,X,Y+5,Z,1,1,1,90000);
		return 1;
	}
	if(strcmp(cmdtext,"/bike",true) == 0)
	{
		new Float:X;
		new Float:Y;
		new Float:Z;
		GetPlayerPos(playerid,X,Y,Z);
		GameTextForPlayer(playerid,"~h~~w~BIKE~n~~h~~w~ID:~h~~r~509",2500,1);
		CreateVehicle(509,X,Y+5,Z,1,1,1,90000);
		return 1;
	}
	if(strcmp(cmdtext,"/mountainbike",true) == 0)
	{
		new Float:X;
		new Float:Y;
		new Float:Z;
		GetPlayerPos(playerid,X,Y,Z);
		GameTextForPlayer(playerid,"~h~~w~MOUNTAIN BIKE~n~~h~~w~ID:~h~~r~510",2500,1);
		CreateVehicle(510,X,Y+5,Z,1,1,1,90000);
		return 1;
	}
	if(strcmp(cmdtext,"/bf-400",true) == 0)
	{
		new Float:X;
		new Float:Y;
		new Float:Z;
		GetPlayerPos(playerid,X,Y,Z);
		GameTextForPlayer(playerid,"~h~~w~BF-400~n~~h~~w~ID:~h~~r~581",2500,1);
		CreateVehicle(581,X,Y+5,Z,1,1,1,90000);
		return 1;
	}
	if(strcmp(cmdtext,"/faggio",true) == 0)
	{
		new Float:X;
		new Float:Y;
		new Float:Z;
		GetPlayerPos(playerid,X,Y,Z);
		GameTextForPlayer(playerid,"~h~~w~FAGGIO~n~~h~~w~ID:~h~~r~462",2500,1);
		CreateVehicle(462,X,Y+5,Z,1,1,1,90000);
		return 1;
	}
	if(strcmp(cmdtext,"/fcr-900",true) == 0)
	{
		new Float:X;
		new Float:Y;
		new Float:Z;
		GetPlayerPos(playerid,X,Y,Z);
		GameTextForPlayer(playerid,"~h~~w~FCR-900~n~~h~~w~ID:~h~~r~521",2500,1);
		CreateVehicle(521,X,Y+5,Z,1,1,1,90000);
		return 1;
	}
	if(strcmp(cmdtext,"/freeway",true) == 0)
	{
		new Float:X;
		new Float:Y;
		new Float:Z;
		GetPlayerPos(playerid,X,Y,Z);
		GameTextForPlayer(playerid,"~h~~w~FREEWAY~n~~h~~w~ID:~h~~r~463",2500,1);
		CreateVehicle(463,X,Y+5,Z,1,1,1,90000);
		return 1;
	}
	if(strcmp(cmdtext,"/nrg-500",true) == 0)
	{
		new Float:X;
		new Float:Y;
		new Float:Z;
		GetPlayerPos(playerid,X,Y,Z);
		GameTextForPlayer(playerid,"~h~~w~NRG-500~n~~h~~w~ID:~h~~r~522",2500,1);
		CreateVehicle(522,X,Y+5,Z,1,1,1,90000);
		return 1;
	}
	if(strcmp(cmdtext,"/pcj-600",true) == 0)
	{
		new Float:X;
		new Float:Y;
		new Float:Z;
		GetPlayerPos(playerid,X,Y,Z);
		GameTextForPlayer(playerid,"~h~~w~PCJ-600~n~~h~~w~ID:~h~~r~461",2500,1);
		CreateVehicle(461,X,Y+5,Z,1,1,1,90000);
		return 1;
	}
	if(strcmp(cmdtext,"/pizzaboy",true) == 0)
	{
		new Float:X;
		new Float:Y;
		new Float:Z;
		GetPlayerPos(playerid,X,Y,Z);
		GameTextForPlayer(playerid,"~h~~w~PIZZABOY~n~~h~~w~ID:~h~~r~448",2500,1);
		CreateVehicle(448,X,Y+5,Z,1,1,1,90000);
		return 1;
	}
	if(strcmp(cmdtext,"/sanchez",true) == 0)
	{
		new Float:X;
		new Float:Y;
		new Float:Z;
		GetPlayerPos(playerid,X,Y,Z);
		GameTextForPlayer(playerid,"~h~~w~SANCHEZ~n~~h~~w~ID:~h~~r~468",2500,1);
		CreateVehicle(468,X,Y+5,Z,1,1,1,90000);
		return 1;
	}
	if(strcmp(cmdtext,"/wayfarer",true) == 0)
	{
		new Float:X;
		new Float:Y;
		new Float:Z;
		GetPlayerPos(playerid,X,Y,Z);
		GameTextForPlayer(playerid,"~h~~w~WAYFARER~n~~h~~w~ID:~h~~r~586",2500,1);
		CreateVehicle(586,X,Y+5,Z,1,1,1,90000);
		return 1;
	}
	if(strcmp(cmdtext,"/baggage",true) == 0)
	{
		new Float:X;
		new Float:Y;
		new Float:Z;
		GetPlayerPos(playerid,X,Y,Z);
		GameTextForPlayer(playerid,"~h~~w~BAGGAGE~n~~h~~w~ID:~h~~r~485",2500,1);
		CreateVehicle(485,X,Y+5,Z,1,1,1,90000);
		return 1;
	}
	if(strcmp(cmdtext,"/bus",true) == 0)
	{
		new Float:X;
		new Float:Y;
		new Float:Z;
		GetPlayerPos(playerid,X,Y,Z);
		GameTextForPlayer(playerid,"~h~~w~BUS~n~~h~~w~ID:~h~~r~431",2500,1);
		CreateVehicle(431,X,Y+5,Z,1,1,1,90000);
		return 1;
	}
	if(strcmp(cmdtext,"/cabbie",true) == 0)
	{
		new Float:X;
		new Float:Y;
		new Float:Z;
		GetPlayerPos(playerid,X,Y,Z);
		GameTextForPlayer(playerid,"~h~~w~CABBIE~n~~h~~w~ID:~h~~r~438",2500,1);
		CreateVehicle(438,X,Y+5,Z,1,1,1,90000);
		return 1;
	}
	if(strcmp(cmdtext,"/coach",true) == 0)
	{
		new Float:X;
		new Float:Y;
		new Float:Z;
		GetPlayerPos(playerid,X,Y,Z);
		GameTextForPlayer(playerid,"~h~~w~COACH~n~~h~~w~ID:~h~~r~437",2500,1);
		CreateVehicle(437,X,Y+5,Z,1,1,1,90000);
		return 1;
	}
	if(strcmp(cmdtext,"/sweeper",true) == 0)
	{
		new Float:X;
		new Float:Y;
		new Float:Z;
		GetPlayerPos(playerid,X,Y,Z);
		GameTextForPlayer(playerid,"~h~~w~SWEEPER~n~~h~~w~ID:~h~~r~574",2500,1);
		CreateVehicle(574,X,Y+5,Z,1,1,1,90000);
		return 1;
	}
	if(strcmp(cmdtext,"/taxi",true) == 0)
	{
		new Float:X;
		new Float:Y;
		new Float:Z;
		GetPlayerPos(playerid,X,Y,Z);
		GameTextForPlayer(playerid,"~h~~w~TAXI~n~~h~~w~ID:~h~~r~420",2500,1);
		CreateVehicle(420,X,Y+5,Z,1,1,1,90000);
		return 1;
	}
	if(strcmp(cmdtext,"/towtruck",true) == 0)
	{
		new Float:X;
		new Float:Y;
		new Float:Z;
		GetPlayerPos(playerid,X,Y,Z);
		GameTextForPlayer(playerid,"~h~~w~TOWTRUCK~n~~h~~w~ID:~h~~r~525",2500,1);
		CreateVehicle(525,X,Y+5,Z,1,1,1,90000);
		return 1;
	}
	if(strcmp(cmdtext,"/trashmaster",true) == 0)
	{
		new Float:X;
		new Float:Y;
		new Float:Z;
		GetPlayerPos(playerid,X,Y,Z);
		GameTextForPlayer(playerid,"~h~~w~TRASHMASTER~n~~h~~w~ID:~h~~r~408",2500,1);
		CreateVehicle(408,X,Y+5,Z,1,1,1,90000);
		return 1;
	}
	if(strcmp(cmdtext,"/utilityvan",true) == 0)
	{
		new Float:X;
		new Float:Y;
		new Float:Z;
		GetPlayerPos(playerid,X,Y,Z);
		GameTextForPlayer(playerid,"~h~~w~UTILITY VAN~n~~h~~w~ID:~h~~r~552",2500,1);
		CreateVehicle(552,X,Y+5,Z,1,1,1,90000);
		return 1;
	}
	if(strcmp(cmdtext,"/ambulance",true) == 0)
	{
		new Float:X;
		new Float:Y;
		new Float:Z;
		GetPlayerPos(playerid,X,Y,Z);
		GameTextForPlayer(playerid,"~h~~w~AMBULANCE~n~~h~~w~ID:~h~~r~416",2500,1);
		CreateVehicle(416,X,Y+5,Z,1,1,1,90000);
		return 1;
	}
	if(strcmp(cmdtext,"/barracks",true) == 0)
	{
		new Float:X;
		new Float:Y;
		new Float:Z;
		GetPlayerPos(playerid,X,Y,Z);
		GameTextForPlayer(playerid,"~h~~w~BARRACKS~n~~h~~w~ID:~h~~r~433",2500,1);
		CreateVehicle(433,X,Y+5,Z,1,1,1,90000);
		return 1;
	}
	if(strcmp(cmdtext,"/enforcer",true) == 0)
	{
		new Float:X;
		new Float:Y;
		new Float:Z;
		GetPlayerPos(playerid,X,Y,Z);
		GameTextForPlayer(playerid,"~h~~w~ENFORCER~n~~h~~w~ID:~h~~r~427",2500,1);
		CreateVehicle(427,X,Y+5,Z,1,1,1,90000);
		return 1;
	}
	if(strcmp(cmdtext,"/fbirancher",true) == 0)
	{
		new Float:X;
		new Float:Y;
		new Float:Z;
		GetPlayerPos(playerid,X,Y,Z);
		GameTextForPlayer(playerid,"~h~~w~FBI RANCHER~n~~h~~w~ID:~h~~r~490",2500,1);
		CreateVehicle(490,X,Y+5,Z,1,1,1,90000);
		return 1;
	}
	if(strcmp(cmdtext,"/fbitruck",true) == 0)
	{
		new Float:X;
		new Float:Y;
		new Float:Z;
		GetPlayerPos(playerid,X,Y,Z);
		GameTextForPlayer(playerid,"~h~~w~FBI TRUCK~n~~h~~w~ID:~h~~r~528",2500,1);
		CreateVehicle(528,X,Y+5,Z,1,1,1,90000);
		return 1;
	}
	if(strcmp(cmdtext,"/firetruck",true) == 0)
	{
		new Float:X;
		new Float:Y;
		new Float:Z;
		GetPlayerPos(playerid,X,Y,Z);
		GameTextForPlayer(playerid,"~h~~w~FIRETRUCK~n~~h~~w~ID:~h~~r~407",2500,1);
		CreateVehicle(407,X,Y+5,Z,1,1,1,90000);
		return 1;
	}
	if(strcmp(cmdtext,"/firetrucka",true) == 0)
	{
		new Float:X;
		new Float:Y;
		new Float:Z;
		GetPlayerPos(playerid,X,Y,Z);
		GameTextForPlayer(playerid,"~h~~w~FIRETRUCK A~n~~h~~w~ID:~h~~r~544",2500,1);
		CreateVehicle(544,X,Y+5,Z,1,1,1,90000);
		return 1;
	}
	if(strcmp(cmdtext,"/hpv-1000",true) == 0)
	{
		new Float:X;
		new Float:Y;
		new Float:Z;
		GetPlayerPos(playerid,X,Y,Z);
		GameTextForPlayer(playerid,"~h~~w~HPV-1000~n~~h~~w~ID:~h~~r~523",2500,1);
		CreateVehicle(523,X,Y+5,Z,1,1,1,90000);
		return 1;
	}
	if(strcmp(cmdtext,"/patriot",true) == 0)
	{
		new Float:X;
		new Float:Y;
		new Float:Z;
		GetPlayerPos(playerid,X,Y,Z);
		GameTextForPlayer(playerid,"~h~~w~PATRIOT~n~~h~~w~ID:~h~~r~470",2500,1);
		CreateVehicle(470,X,Y+5,Z,1,1,1,90000);
		return 1;
	}
	if(strcmp(cmdtext,"/policels",true) == 0)
	{
		new Float:X;
		new Float:Y;
		new Float:Z;
		GetPlayerPos(playerid,X,Y,Z);
		GameTextForPlayer(playerid,"~h~~w~POLICE LOS SANTOS~n~~h~~w~ID:~h~~r~596",2500,1);
		CreateVehicle(596,X,Y+5,Z,1,1,0,90000);
		return 1;
	}
	if(strcmp(cmdtext,"/policesf",true) == 0)
	{
		new Float:X;
		new Float:Y;
		new Float:Z;
		GetPlayerPos(playerid,X,Y,Z);
		GameTextForPlayer(playerid,"~h~~w~POLICE SAN FIERRO~n~~h~~w~ID:~h~~r~597",2500,1);
		CreateVehicle(597,X,Y+5,Z,1,1,0,90000);
		return 1;
	}
	if(strcmp(cmdtext,"/policelv",true) == 0)
	{
		new Float:X;
		new Float:Y;
		new Float:Z;
		GetPlayerPos(playerid,X,Y,Z);
		GameTextForPlayer(playerid,"~h~~w~POLICE LAS VENTURAS~n~~h~~w~ID:~h~~r~598",2500,1);
		CreateVehicle(598,X,Y+5,Z,1,1,0,90000);
		return 1;
	}
	if(strcmp(cmdtext,"/policeranger",true) == 0)
	{
		new Float:X;
		new Float:Y;
		new Float:Z;
		GetPlayerPos(playerid,X,Y,Z);
		GameTextForPlayer(playerid,"~h~~w~POLICE RANGER~n~~h~~w~ID:~h~~r~599",2500,1);
		CreateVehicle(599,X,Y+5,Z,1,1,0,90000);
		return 1;
	}
	if(strcmp(cmdtext,"/rhino",true) == 0)
	{
		new Float:X;
		new Float:Y;
		new Float:Z;
		GetPlayerPos(playerid,X,Y,Z);
		GameTextForPlayer(playerid,"~h~~w~RHINO~n~~h~~w~ID:~h~~r~432",2500,1);
		CreateVehicle(432,X,Y+5,Z,1,1,1,90000);
		return 1;
	}
	if(strcmp(cmdtext,"/securicar",true) == 0)
	{
		new Float:X;
		new Float:Y;
		new Float:Z;
		GetPlayerPos(playerid,X,Y,Z);
		GameTextForPlayer(playerid,"~h~~w~SECURICAR~n~~h~~w~ID:~h~~r~428",2500,1);
		CreateVehicle(428,X,Y+5,Z,1,1,1,90000);
		return 1;
	}
	if(strcmp(cmdtext,"/swattank",true) == 0)
	{
		new Float:X;
		new Float:Y;
		new Float:Z;
		GetPlayerPos(playerid,X,Y,Z);
		GameTextForPlayer(playerid,"~h~~w~SWAT TANK~n~~h~~w~ID:~h~~r~601",2500,1);
		CreateVehicle(601,X,Y+5,Z,1,1,1,90000);
		return 1;
	}
	if(strcmp(cmdtext,"/andromada",true) == 0)
	{
		new Float:X;
		new Float:Y;
		new Float:Z;
		GetPlayerPos(playerid,X,Y,Z);
		GameTextForPlayer(playerid,"~h~~w~ANDROMADA~n~~h~~w~ID:~h~~r~592",2500,1);
		CreateVehicle(592,X,Y+20,Z,1,1,1,90000);
		return 1;
	}
	if(strcmp(cmdtext,"/at-400",true) == 0)
	{
		new Float:X;
		new Float:Y;
		new Float:Z;
		GetPlayerPos(playerid,X,Y,Z);
		GameTextForPlayer(playerid,"~h~~w~AT-400~n~~h~~w~ID:~h~~r~577",2500,1);
		CreateVehicle(577,X,Y+20,Z,1,1,1,90000);
		return 1;
	}
	if(strcmp(cmdtext,"/beagle",true) == 0)
	{
		new Float:X;
		new Float:Y;
		new Float:Z;
		GetPlayerPos(playerid,X,Y,Z);
		GameTextForPlayer(playerid,"~h~~w~BEAGLE~n~~h~~w~ID:~h~~r~511",2500,1);
		CreateVehicle(511,X,Y+20,Z,1,1,1,90000);
		return 1;
	}
	if(strcmp(cmdtext,"/cargobob",true) == 0)
	{
		new Float:X;
		new Float:Y;
		new Float:Z;
		GetPlayerPos(playerid,X,Y,Z);
		GameTextForPlayer(playerid,"~h~~w~CARGOBOB~n~~h~~w~ID:~h~~r~548",2500,1);
		CreateVehicle(548,X,Y+10,Z,1,1,1,90000);
		return 1;
	}
	if(strcmp(cmdtext,"/cropduster",true) == 0)
	{
		new Float:X;
		new Float:Y;
		new Float:Z;
		GetPlayerPos(playerid,X,Y,Z);
		GameTextForPlayer(playerid,"~h~~w~CROPDUSTER~n~~h~~w~ID:~h~~r~512",2500,1);
		CreateVehicle(512,X,Y+10,Z,1,1,1,90000);
		return 1;
	}
	if(strcmp(cmdtext,"/dodo",true) == 0)
	{
		new Float:X;
		new Float:Y;
		new Float:Z;
		GetPlayerPos(playerid,X,Y,Z);
		GameTextForPlayer(playerid,"~h~~w~DODO~n~~h~~w~ID:~h~~r~593",2500,1);
		CreateVehicle(593,X,Y+10,Z,1,1,1,90000);
		return 1;
	}
	if(strcmp(cmdtext,"/hunter",true) == 0)
	{
		new Float:X;
		new Float:Y;
		new Float:Z;
		GetPlayerPos(playerid,X,Y,Z);
		GameTextForPlayer(playerid,"~h~~w~HUNTER~n~~h~~w~ID:~h~~r~425",2500,1);
		CreateVehicle(425,X,Y+10,Z,1,1,1,90000);
		return 1;
	}
	if(strcmp(cmdtext,"/leviathon",true) == 0)
	{
		new Float:X;
		new Float:Y;
		new Float:Z;
		GetPlayerPos(playerid,X,Y,Z);
		GameTextForPlayer(playerid,"~h~~w~LEVIATHON~n~~h~~w~ID:~h~~r~417",2500,1);
		CreateVehicle(417,X,Y+10,Z,1,1,1,90000);
		return 1;
	}
	if(strcmp(cmdtext,"/maverick",true) == 0)
	{
		new Float:X;
		new Float:Y;
		new Float:Z;
		GetPlayerPos(playerid,X,Y,Z);
		GameTextForPlayer(playerid,"~h~~w~MAVERICK~n~~h~~w~ID:~h~~r~487",2500,1);
		CreateVehicle(487,X,Y+10,Z,1,1,1,90000);
		return 1;
	}
	if(strcmp(cmdtext,"/nevada",true) == 0)
	{
		new Float:X;
		new Float:Y;
		new Float:Z;
		GetPlayerPos(playerid,X,Y,Z);
		GameTextForPlayer(playerid,"~h~~w~NEVADA~n~~h~~w~ID:~h~~r~553",2500,1);
		CreateVehicle(553,X,Y+10,Z,1,1,1,90000);
		return 1;
	}
	if(strcmp(cmdtext,"/newsmaverick",true) == 0)
	{
		new Float:X;
		new Float:Y;
		new Float:Z;
		GetPlayerPos(playerid,X,Y,Z);
		GameTextForPlayer(playerid,"~h~~w~NEWS MAVERICK~n~~h~~w~ID:~h~~r~488",2500,1);
		CreateVehicle(488,X,Y+10,Z,1,1,1,90000);
		return 1;
	}
	if(strcmp(cmdtext,"/policemaverick",true) == 0)
	{
		new Float:X;
		new Float:Y;
		new Float:Z;
		GetPlayerPos(playerid,X,Y,Z);
		GameTextForPlayer(playerid,"~h~~w~POLICE MAVERICK~n~~h~~w~ID:~h~~r~497",2500,1);
		CreateVehicle(497,X,Y+10,Z,1,1,0,90000);
		return 1;
	}
	if(strcmp(cmdtext,"/raindance",true) == 0)
	{
		new Float:X;
		new Float:Y;
		new Float:Z;
		GetPlayerPos(playerid,X,Y,Z);
		GameTextForPlayer(playerid,"~h~~w~RAINDANCE~n~~h~~w~ID:~h~~r~563",2500,1);
		CreateVehicle(563,X,Y+10,Z,1,1,1,90000);
		return 1;
	}
	if(strcmp(cmdtext,"/rustler",true) == 0)
	{
		new Float:X;
		new Float:Y;
		new Float:Z;
		GetPlayerPos(playerid,X,Y,Z);
		GameTextForPlayer(playerid,"~h~~w~RUSTLER~n~~h~~w~ID:~h~~r~476",2500,1);
		CreateVehicle(476,X,Y+10,Z,1,1,1,90000);
		return 1;
	}
	if(strcmp(cmdtext,"/seasparrow",true) == 0)
	{
		new Float:X;
		new Float:Y;
		new Float:Z;
		GetPlayerPos(playerid,X,Y,Z);
		GameTextForPlayer(playerid,"~h~~w~SEA SPARROW~n~~h~~w~ID:~h~~r~447",2500,1);
		CreateVehicle(447,X,Y+10,Z,1,1,1,90000);
		return 1;
	}
	if(strcmp(cmdtext,"/shamal",true) == 0)
	{
		new Float:X;
		new Float:Y;
		new Float:Z;
		GetPlayerPos(playerid,X,Y,Z);
		GameTextForPlayer(playerid,"~h~~w~SHAMAL~n~~h~~w~ID:~h~~r~519",2500,1);
		CreateVehicle(519,X,Y+10,Z,1,1,1,90000);
		return 1;
	}
	if(strcmp(cmdtext,"/skimmer",true) == 0)
	{
		new Float:X;
		new Float:Y;
		new Float:Z;
		GetPlayerPos(playerid,X,Y,Z);
		GameTextForPlayer(playerid,"~h~~w~SKIMMER~n~~h~~w~ID:~h~~r~460",2500,1);
		CreateVehicle(460,X,Y+10,Z,1,1,1,90000);
		return 1;
	}
	if(strcmp(cmdtext,"/sparrow",true) == 0)
	{
		new Float:X;
		new Float:Y;
		new Float:Z;
		GetPlayerPos(playerid,X,Y,Z);
		GameTextForPlayer(playerid,"~h~~w~SPARROW~n~~h~~w~ID:~h~~r~469",2500,1);
		CreateVehicle(469,X,Y+10,Z,1,1,1,90000);
		return 1;
	}
	if(strcmp(cmdtext,"/stuntplane",true) == 0)
	{
		new Float:X;
		new Float:Y;
		new Float:Z;
		GetPlayerPos(playerid,X,Y,Z);
		GameTextForPlayer(playerid,"~h~~w~STUNT PLANE~n~~h~~w~ID:~h~~r~513",2500,1);
		CreateVehicle(513,X,Y+10,Z,1,1,1,90000);
		return 1;
	}
	if(strcmp(cmdtext,"/hydra",true) == 0)
	{
		new Float:X;
		new Float:Y;
		new Float:Z;
		GetPlayerPos(playerid,X,Y,Z);
		GameTextForPlayer(playerid,"~h~~w~HYDRA~n~~h~~w~ID:~h~~r~520",2500,1);
		CreateVehicle(520,X,Y+10,Z,1,1,1,90000);
		return 1;
	}
	if(strcmp(cmdtext,"/coastguar",true) == 0)
	{
		new Float:X;
		new Float:Y;
		new Float:Z;
		GetPlayerPos(playerid,X,Y,Z);
		GameTextForPlayer(playerid,"~h~~w~COASTGUARD~n~~h~~w~ID:~h~~r~472",2500,1);
		CreateVehicle(472,X,Y+5,Z,1,1,1,90000);
		return 1;
	}
	if(strcmp(cmdtext,"/dingy",true) == 0)
	{
		new Float:X;
		new Float:Y;
		new Float:Z;
		GetPlayerPos(playerid,X,Y,Z);
		GameTextForPlayer(playerid,"~h~~w~DINGY~n~~h~~w~ID:~h~~r~473",2500,1);
		CreateVehicle(473,X,Y+5,Z,1,1,1,90000);
		return 1;
	}
	if(strcmp(cmdtext,"/jetmax",true) == 0)
	{
		new Float:X;
		new Float:Y;
		new Float:Z;
		GetPlayerPos(playerid,X,Y,Z);
		GameTextForPlayer(playerid,"~h~~w~JETMAX~n~~h~~w~ID:~h~~r~493",2500,1);
		CreateVehicle(493,X,Y+5,Z,1,1,1,90000);
		return 1;
	}
	if(strcmp(cmdtext,"/launch",true) == 0)
	{
		new Float:X;
		new Float:Y;
		new Float:Z;
		GetPlayerPos(playerid,X,Y,Z);
		GameTextForPlayer(playerid,"~h~~w~LAUNCH~n~~h~~w~ID:~h~~r~595",2500,1);
		CreateVehicle(595,X,Y+5,Z,1,1,1,90000);
		return 1;
	}
	if(strcmp(cmdtext,"/marquis",true) == 0)
	{
		new Float:X;
		new Float:Y;
		new Float:Z;
		GetPlayerPos(playerid,X,Y,Z);
		GameTextForPlayer(playerid,"~h~~w~MARQUIS~n~~h~~w~ID:~h~~r~484",2500,1);
		CreateVehicle(484,X,Y+5,Z,1,1,1,90000);
		return 1;
	}
	if(strcmp(cmdtext,"/predator",true) == 0)
	{
		new Float:X;
		new Float:Y;
		new Float:Z;
		GetPlayerPos(playerid,X,Y,Z);
		GameTextForPlayer(playerid,"~h~~w~PREDATOR~n~~h~~w~ID:~h~~r~430",2500,1);
		CreateVehicle(430,X,Y+5,Z,1,1,1,90000);
		return 1;
	}
	if(strcmp(cmdtext,"/reefer",true) == 0)
	{
		new Float:X;
		new Float:Y;
		new Float:Z;
		GetPlayerPos(playerid,X,Y,Z);
		GameTextForPlayer(playerid,"~h~~w~REEFER~n~~h~~w~ID:~h~~r~453",2500,1);
		CreateVehicle(453,X,Y+5,Z,1,1,1,90000);
		return 1;
	}
	if(strcmp(cmdtext,"/speeder",true) == 0)
	{
		new Float:X;
		new Float:Y;
		new Float:Z;
		GetPlayerPos(playerid,X,Y,Z);
		GameTextForPlayer(playerid,"~h~~w~SPEEDER~n~~h~~w~ID:~h~~r~452",2500,1);
		CreateVehicle(452,X,Y+5,Z,1,1,1,90000);
		return 1;
	}
	if(strcmp(cmdtext,"/squallo",true) == 0)
	{
		new Float:X;
		new Float:Y;
		new Float:Z;
		GetPlayerPos(playerid,X,Y,Z);
		GameTextForPlayer(playerid,"~h~~w~SQUALLO~n~~h~~w~ID:~h~~r~446",2500,1);
		CreateVehicle(446,X,Y+5,Z,1,1,1,90000);
		return 1;
	}
	if(strcmp(cmdtext,"/tropic",true) == 0)
	{
		new Float:X;
		new Float:Y;
		new Float:Z;
		GetPlayerPos(playerid,X,Y,Z);
		GameTextForPlayer(playerid,"~h~~w~TROPIC~n~~h~~w~ID:~h~~r~454",2500,1);
		CreateVehicle(454,X,Y+5,Z,1,1,1,90000);
		return 1;
	}
	if(strcmp(cmdtext,"/rcbandit",true) == 0)
	{
		new Float:X;
		new Float:Y;
		new Float:Z;
		GetPlayerPos(playerid,X,Y,Z);
		GameTextForPlayer(playerid,"~h~~w~RC BANDIT~n~~h~~w~ID:~h~~r~441",2500,1);
		CreateVehicle(441,X,Y+5,Z,1,1,1,90000);
		return 1;
	}
	if(strcmp(cmdtext,"/rcbaron",true) == 0)
	{
		new Float:X;
		new Float:Y;
		new Float:Z;
		GetPlayerPos(playerid,X,Y,Z);
		GameTextForPlayer(playerid,"~h~~w~RC BARON~n~~h~~w~ID:~h~~r~464",2500,1);
		CreateVehicle(464,X,Y+5,Z,1,1,1,90000);
		return 1;
	}
	if(strcmp(cmdtext,"/rccam",true) == 0)
	{
		new Float:X;
		new Float:Y;
		new Float:Z;
		GetPlayerPos(playerid,X,Y,Z);
		GameTextForPlayer(playerid,"~h~~w~RC CAM~n~~h~~w~ID:~h~~r~594",2500,1);
		CreateVehicle(594,X,Y+5,Z,1,1,1,90000);
		return 1;
	}
	if(strcmp(cmdtext,"/rcgoblin",true) == 0)
	{
		new Float:X;
		new Float:Y;
		new Float:Z;
		GetPlayerPos(playerid,X,Y,Z);
		GameTextForPlayer(playerid,"~h~~w~RC GOBLIN~n~~h~~w~ID:~h~~r~465",2500,1);
		CreateVehicle(465,X,Y+5,Z,1,1,1,90000);
		return 1;
	}
	if(strcmp(cmdtext,"/rcgoblin2",true) == 0)
	{
		new Float:X;
		new Float:Y;
		new Float:Z;
		GetPlayerPos(playerid,X,Y,Z);
		GameTextForPlayer(playerid,"~h~~w~ANOTHER RC GOBLIN~n~~h~~w~ID:~h~~r~501",2500,1);
		CreateVehicle(501,X,Y+5,Z,1,1,1,90000);
		return 1;
	}
	if(strcmp(cmdtext,"/rctiger",true) == 0)
	{
		new Float:X;
		new Float:Y;
		new Float:Z;
		GetPlayerPos(playerid,X,Y,Z);
		GameTextForPlayer(playerid,"~h~~w~RC TIGER~n~~h~~w~ID:~h~~r~564",2500,1);
		CreateVehicle(564,X,Y+5,Z,1,1,1,90000);
		return 1;
	}
	if(strcmp(cmdtext,"/glendale2",true) == 0)
	{
		new Float:X;
		new Float:Y;
		new Float:Z;
		GetPlayerPos(playerid,X,Y,Z);
		GameTextForPlayer(playerid,"~h~~w~BEAT UP GLENDALE~n~~h~~w~ID:~h~~r~604",2500,1);
		CreateVehicle(604,X,Y+5,Z,1,1,1,90000);
		return 1;
	}
	if(strcmp(cmdtext,"/sadler2",true) == 0)
	{
		new Float:X;
		new Float:Y;
		new Float:Z;
		GetPlayerPos(playerid,X,Y,Z);
		GameTextForPlayer(playerid,"~h~~w~BEAT UP SADLER~n~~h~~w~ID:~h~~r~605",2500,1);
		CreateVehicle(605,X,Y+5,Z,1,1,1,90000);
		return 1;
	}
	return SendClientMessage(playerid,COLOR_RED,"ERROR, Unknown Command - Use /help");
}

public SendPlayerFormattedText(playerid, const str[], define) {
	new tmpbuf[256];
	format(tmpbuf, sizeof(tmpbuf), str, define);
	SendClientMessage(playerid, 0xFF004040, tmpbuf);
}

public SendAllFormattedText(playerid, const str[], define) {
	new tmpbuf[256];
	format(tmpbuf, sizeof(tmpbuf), str, define);
	SendClientMessageToAll(0xFFFF00AA, tmpbuf);
}

public OnPlayerUpdate(playerid)
{
	if(!IsPlayerConnected(playerid)) return 0;
	if(IsPlayerNPC(playerid)) return 1;
	if( !gPlayerHasCitySelected[playerid] &&
			GetPlayerState(playerid) == PLAYER_STATE_SPECTATING ) {
		ClassSel_HandleCitySelection(playerid);
		return 1;
	}
	if(GetPlayerInterior(playerid) != 0 && GetPlayerWeapon(playerid) != 0) {
		SetPlayerArmedWeapon(playerid,0);
		return 0;
	}
	if(GetPlayerWeapon(playerid) == WEAPON_MINIGUN) {
		Kick(playerid);
		return 0;
	}
	return 1;
}

stock IsInvalidSkin(skinid) {
	if(skinid > 310)
	return true;
	
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

stock GetOnlinePlayersCount() {
	new totalPlayers;
	for(new i, j = GetMaxPlayers(); i != j; ++i)
	if(IsPlayerConnected(i) && !IsPlayerNPC(i))
	++totalPlayers;
	
	return totalPlayers;
}
