//============================================================================//
// **	  				Immortal Home Server	  						   ** //
// **         				  Created by Immortal						   ** //
// **                                                                      ** //
// **				 Copyright (2012 - 2014) [RIP old days]				   ** //
//============================================================================//
/*      a town beside the sea,
				    we can wander through the forrest,
									    and do so as we please,
									    		      living so merilly.      */
/*      for a old memories, my friends,some places,the sun,and my life.       */
//============================================================================//
/*
  Mod geliþtirme süreci notlarý:
  ---------------------------------------------------------------------------
  Mod samp sürümü: 0.3z                 	  Moda baþlama tarihi: 08/02/2014
  Mod geliþtiricileri: SkyChord			    Son güncelleme tarihi: 26/02/2014
  - Her ayýn 6, 16 ve 26'sýnda RC sürümü artacaktýr.
  ---------------------------------------------------------------------------

	-> Dialog idleri sýralamasý:
	    - Genel msgbox dialogu  	=   0
	    - Hesap sistemi dialoglarý  =   1-24
	    - Group sistemi dialoglarý  =   25-49
*/
// == (( Library Unit )) ==================================================== //
#include <a_samp>
#include <a_mysqlr6>
#include <streamer>
#include <supervivencia>

// Server settings:
#define server_name     "Supervivencia Survival Server [ALPHA][RC1.2]"
#define server_version  "v1.0.0RC1.2"
#define server_modname  "Supervivencia"
#define server_mapname  "San Andreas"

#define mysql_hostname  "localhost"
#define mysql_username  "root"
#define mysql_password  ""
#define mysql_database  "supervivencia"

#undef MAX_PLAYERS
#define MAX_PLAYERS     (50)

// Standart message formats:
#define showMessage(%0,%1) SendClientMessage(%0, -1, "{BBBBBB}** {00B3FF}" %1)
#define showDialog(%0,%1)  ShowPlayerDialog(playerid, 0, DIALOG_STYLE_MSGBOX, "{BBBBBB}** {00B3FF}" %0 " {BBBBBB}**","{BBBBBB}" %1, "Tamam", "")

// == (( Variable Unit )) =================================================== //
// Textdraws:
new Text:textdraw_server[MAX_PLAYERS];
new Text:textdraw_hungry[MAX_PLAYERS];
new Text:textdraw_radiation[MAX_PLAYERS];
new Text:textdraw_ping[MAX_PLAYERS];
new Text:textdraw_key1[MAX_PLAYERS];
new Text:textdraw_key2[MAX_PLAYERS];
new Text:textdraw_key3[MAX_PLAYERS];

// Player settings:
new playerTimer[MAX_PLAYERS];
new hungryTimer[MAX_PLAYERS];

// Account script:
#define dialog_register (1)
#define dialog_regapply (2)
#define dialog_login	(3)

enum pAccount
{
	pA_Pass[16],
	pA_AdminLevel,
	
	pA_Killed,
	pA_Death,
	pA_Score,
	pA_Money,
	
 	pA_Radiation,
	pA_Hungry,
	pA_Comfort,

	Float:pA_X,
	Float:pA_Y,
	Float:pA_Z,
	pA_Interior,

    pA_IP,
	pA_Online,
	pA_LastOnline,
	
	bool:pA_Spawned
};
new PlayerAccount[MAX_PLAYERS][pAccount];

// Campfire script:
new bool:campFire[MAX_PLAYERS] = false;
new fireObject[MAX_PLAYERS], fireWoods[MAX_PLAYERS];

// Guitar script:
new bool:guitarSong[MAX_PLAYERS] = false;

// Player colors:
new PlayerColors[200] = {
0xFF8C13FF, 0xC715FFFF, 0x20B2AAFF, 0xDC143CFF, 0x6495EDFF, 0xf0e68cFF, 0x778899FF, 0xFF1493FF, 0xF4A460FF,
0xEE82EEFF, 0xFFD720FF, 0x8b4513FF, 0x4949A0FF, 0x148b8bFF, 0x14ff7fFF, 0x556b2fFF, 0x0FD9FAFF, 0x10DC29FF,
0x534081FF, 0x0495CDFF, 0xEF6CE8FF, 0xBD34DAFF, 0x247C1BFF, 0x0C8E5DFF, 0x635B03FF, 0xCB7ED3FF, 0x65ADEBFF,
0x5C1ACCFF, 0xF2F853FF, 0x11F891FF, 0x7B39AAFF, 0x53EB10FF, 0x54137DFF, 0x275222FF, 0xF09F5BFF, 0x3D0A4FFF,
0x22F767FF, 0xD63034FF, 0x9A6980FF, 0xDFB935FF, 0x3793FAFF, 0x90239DFF, 0xE9AB2FFF, 0xAF2FF3FF, 0x057F94FF,
0xB98519FF, 0x388EEAFF, 0x028151FF, 0xA55043FF, 0x0DE018FF, 0x93AB1CFF, 0x95BAF0FF, 0x369976FF, 0x18F71FFF,
0x4B8987FF, 0x491B9EFF, 0x829DC7FF, 0xBCE635FF, 0xCEA6DFFF, 0x20D4ADFF, 0x2D74FDFF, 0x3C1C0DFF, 0x12D6D4FF,
0x48C000FF, 0x2A51E2FF, 0xE3AC12FF, 0xFC42A8FF, 0x2FC827FF, 0x1A30BFFF, 0xB740C2FF, 0x42ACF5FF, 0x2FD9DEFF,
0xFAFB71FF, 0x05D1CDFF, 0xC471BDFF, 0x94436EFF, 0xC1F7ECFF, 0xCE79EEFF, 0xBD1EF2FF, 0x93B7E4FF, 0x3214AAFF,
0x184D3BFF, 0xAE4B99FF, 0x7E49D7FF, 0x4C436EFF, 0xFA24CCFF, 0xCE76BEFF, 0xA04E0AFF, 0x9F945CFF, 0xDCDE3DFF,
0x10C9C5FF, 0x70524DFF, 0x0BE472FF, 0x8A2CD7FF, 0x6152C2FF, 0xCF72A9FF, 0xE59338FF, 0xEEDC2DFF, 0xD8C762FF,
0xD8C762FF, 0xFF8C13FF, 0xC715FFFF, 0x20B2AAFF, 0xDC143CFF, 0x6495EDFF, 0xf0e68cFF, 0x778899FF, 0xFF1493FF,
0xF4A460FF, 0xEE82EEFF, 0xFFD720FF, 0x8b4513FF, 0x4949A0FF, 0x148b8bFF, 0x14ff7fFF, 0x556b2fFF, 0x0FD9FAFF,
0x10DC29FF, 0x534081FF, 0x0495CDFF, 0xEF6CE8FF, 0xBD34DAFF, 0x247C1BFF, 0x0C8E5DFF, 0x635B03FF, 0xCB7ED3FF,
0x65ADEBFF, 0x5C1ACCFF, 0xF2F853FF, 0x11F891FF, 0x7B39AAFF, 0x53EB10FF, 0x54137DFF, 0x275222FF, 0xF09F5BFF,
0x3D0A4FFF, 0x22F767FF, 0xD63034FF, 0x9A6980FF, 0xDFB935FF, 0x3793FAFF, 0x90239DFF, 0xE9AB2FFF, 0xAF2FF3FF,
0x057F94FF, 0xB98519FF, 0x388EEAFF, 0x028151FF, 0xA55043FF, 0x0DE018FF, 0x93AB1CFF, 0x95BAF0FF, 0x369976FF,
0x18F71FFF, 0x4B8987FF, 0x491B9EFF, 0x829DC7FF, 0xBCE635FF, 0xCEA6DFFF, 0x20D4ADFF, 0x2D74FDFF, 0x3C1C0DFF,
0x12D6D4FF, 0x48C000FF, 0x2A51E2FF, 0xE3AC12FF, 0xFC42A8FF, 0x2FC827FF, 0x1A30BFFF, 0xB740C2FF, 0x42ACF5FF,
0x2FD9DEFF, 0xFAFB71FF, 0x05D1CDFF, 0xC471BDFF, 0x94436EFF, 0xC1F7ECFF, 0xCE79EEFF, 0xBD1EF2FF, 0x93B7E4FF,
0x3214AAFF, 0x184D3BFF, 0xAE4B99FF, 0x7E49D7FF, 0x4C436EFF, 0xFA24CCFF, 0xCE76BEFF, 0xA04E0AFF, 0x9F945CFF,
0xDCDE3DFF, 0x10C9C5FF, 0x70524DFF, 0x0BE472FF, 0x8A2CD7FF, 0x6152C2FF, 0xCF72A9FF, 0xE59338FF, 0xEEDC2DFF,
0xD8C762FF, 0xD8C762FF
};

// == (( Main Unit )) ======================================================= //
main()
{
 	new day, month, year;
	getdate(year, month, day);

	printf("\n---------------------------------------------------------------");
	printf("» Gamemode started! [%d/%d/%d]", day, month, year);
	printf("---------------------------------------------------------------");
	SkyAntiDeAMX();
}

// == (( Public Unit )) ===================================================== //
public OnGameModeInit()
{
	// General:
	printf("» %s gamemode initializing.", server_modname);
	SendRconCommand("rcon 0");

	SetGameModeText(server_modname " " server_version);
	new serverSettings[64];

	format(serverSettings, sizeof(serverSettings), "hostname %s", server_name);
	SendRconCommand(serverSettings);

	format(serverSettings, sizeof(serverSettings), "mapname %s", server_mapname);
	SendRconCommand(serverSettings);

	SetWeather(15);
	UsePlayerPedAnims();
	AllowInteriorWeapons(1);
	EnableStuntBonusForAll(0);
	ShowPlayerMarkers(2);
	ShowNameTags(1);
	SetNameTagDrawDistance(25.0);
	printf("  ** Server settings prepared.");

	// Class settings:
	new skinValue = 1;
	for(new i = 0; i <= 299; i++)
	{
		skinValue++;
 		AddPlayerClass(i, 1958.3783, 1343.1572, 15.3746, 269.1425, 0, 0, 0, 0, 0, 0);
	}

	printf("  ** %d player class loaded.", skinValue);

	// MySQL settings:
	mysql_connect(mysql_hostname, mysql_username, mysql_database, mysql_password);
	mysql_query("CREATE TABLE IF NOT EXISTS players(SQLID INT(11), Nickname VARCHAR(24), Password VARCHAR(16), AdminLevel INT(1), Killed INT(11), Death INT(11), Score INT(11), Money INT(11), Radiation INT(3), Hungry INT(3), Comfort INT(3), Last_X FLOAT, Last_Y FLOAT, Last_Z, FLOAT, Last_INT INT(3), LastIP VARCHAR(16), Online TINYINT(1), LastOnline DATE");
	mysql_query("CREATE TABLE IF NOT EXISTS iplog(playername VARCHAR(24), ip VARCHAR(16), connected TINYINT(1))");
	
 	if(mysql_ping() > 0)
	    printf("  ** MySQL connection successful! [Host: %s / Database: %s]", mysql_hostname, mysql_database);
	else
	    printf("  ** MySQL connection failed!");

    SkyAntiDeAMX();
    printf("  ** AntiDeAMX started!");

    LoadObjects();
    printf("  ** Objects loaded!");
	return 1;
}

public OnGameModeExit()
{
	mysql_close();
	printf("  ** MySQL connection closed!");

    printf("» %s gamemode closed.", server_modname);
	return 1;
}

public OnPlayerRequestClass(playerid, classid)
{
	CreateExplosion(1544.7887,-1675.4630,13.5591, 12, 20.0);
	SetPlayerPos(playerid, 1544.7887,-1675.4630,13.5591);
 	SetPlayerFacingAngle(playerid,90.0);
 	SetPlayerCameraPos(playerid, 1541.5293,-1675.4012,13.5527);
 	SetPlayerCameraLookAt(playerid, 1544.7887,-1675.4630,13.5591);
	return 1;
}

public OnPlayerConnect(playerid)
{
    new connectMessage[64 + MAX_PLAYER_NAME];
	format(connectMessage, sizeof(connectMessage), "{BBBBBB}** {00B3FF}%s {BBBBBB}connected server.", pName(playerid));
	SendClientMessageToAll(-1, connectMessage);
	SetPlayerColor(playerid, PlayerColors[playerid]);
	SendDeathMessage(INVALID_PLAYER_ID, playerid, 200);
	SetPlayerTime(playerid, 06, 00);
	DeleteObjects(playerid);

	LoadTextDraws(playerid);    // Textdraws loaded.
 	PlayerAccount[playerid][pA_Hungry] = 0; // Hungry level reseted.
	PlayerAccount[playerid][pA_Radiation] = 0;  // Radiation level reseted.
	TextDrawShowForPlayer(playerid, textdraw_server[playerid]); // Textdraw showed.
	playerTimer[playerid] = SetTimerEx("playerGameTimer", 2000, true, "i", playerid);   // Player General Timer started.

	// Account script:
	AccountReset(playerid);
	
	new query[256];
    format(query, sizeof(query), "SELECT FROM `players` WHERE user = '%s' LIMIT 1", pName(playerid)); //Formats the query, view above the code for a explanation
    mysql_query(query);
    mysql_store_result();
    new rows = mysql_num_rows();
    
    if(rows)
		ShowPlayerDialog(playerid, dialog_register, DIALOG_STYLE_INPUT, "{BBBBBB}** {00B3FF}Character Register:", "{BBBBBB}Welcome to the {00B3FF}"server_modname"!\n{333333}Enter your password and play the game.", "Register", "Cancel");
	else
		SendClientMessage(playerid, -1, "not rows");
	return 1;
}

public OnPlayerDisconnect(playerid, reason)
{
	new exitMessage[65 + MAX_PLAYER_NAME];
	switch(reason)
	{
	    case 0:format(exitMessage, sizeof(exitMessage), "{BBBBBB}** {00B3FF}%s {BBBBBB}is disconnected. [timeout]", pName(playerid));  // Error.
	    case 1:format(exitMessage, sizeof(exitMessage), "{BBBBBB}** {00B3FF}%s {BBBBBB}is leaved server.", pName(playerid));      // Player choice.
	    case 2:format(exitMessage, sizeof(exitMessage), "{BBBBBB}** {00B3FF}%s {BBBBBB}is kicked or banned.", pName(playerid));     // Kicked.
	}
	SendClientMessageToAll(-1, exitMessage);
	SendDeathMessage(INVALID_PLAYER_ID, playerid, 201);
	KillTimer(playerTimer[playerid]);   // Player General Timer stopped.
	KillTimer(hungryTimer[playerid]);   // Hunry Timer stopped.
	UnloadTextDraws(playerid);  // Textdraws unloaded.

	if(campFire[playerid] == true)
	{
		DestroyDynamicObject(fireWoods[playerid]);
		DestroyDynamicObject(fireObject[playerid]);
	}

	if(guitarSong[playerid] == true)
	{
	    StopAudioStreamForPlayer(playerid);
		RemovePlayerAttachedObject(playerid, 0);
		ClearAnimations(playerid);
	}
	return 1;
}

public OnPlayerSpawn(playerid)
{
	SetPlayerPos(playerid, -2020.6033,613.6348,36.6419);
    showMessage(playerid, "Spawned successful!");
    TextDrawShowForPlayer(playerid, textdraw_hungry[playerid]);
    TextDrawShowForPlayer(playerid, textdraw_radiation[playerid]);
	TextDrawShowForPlayer(playerid, textdraw_ping[playerid]);

	SetPlayerHealth(playerid, 100.0);
	hungryTimer[playerid] = SetTimerEx("addHungry", 15 * 1000, true, "i", playerid);

	TogglePlayerControllable(playerid, 1);
	TogglePlayerSpectating(playerid, 0);
	ClearAnimations(playerid);
	SetPlayerInterior(playerid, 0);
	SetPlayerVirtualWorld(playerid, 0);
	GivePlayerWeapon(playerid, 4, 1);
	SetPlayerDrunkLevel(playerid, 0);
	
	// Account script:
	PlayerAccount[playerid][pA_Spawned] = false;
	return 1;
}

public OnPlayerDeath(playerid, killerid, reason)
{
    if(!(GetPlayerScore(playerid) <= 0))
		SetPlayerScore(playerid, GetPlayerScore(playerid) - 1);

	SetPlayerScore(killerid, GetPlayerScore(killerid) + 1);
	SendDeathMessage(killerid, playerid, reason);

	PlayerAccount[playerid][pA_Hungry] = 0;
	PlayerAccount[playerid][pA_Radiation] = 0;

	TextDrawHideForPlayer(playerid, textdraw_hungry[playerid]);
    TextDrawHideForPlayer(playerid, textdraw_radiation[playerid]);
	TextDrawHideForPlayer(playerid, textdraw_ping[playerid]);

	if(campFire[playerid] == true)
	{
		DestroyDynamicObject(fireWoods[playerid]);
		DestroyDynamicObject(fireObject[playerid]);
	}

	if(guitarSong[playerid] == true)
	{
	    StopAudioStreamForPlayer(playerid);
		RemovePlayerAttachedObject(playerid, 0);
		ClearAnimations(playerid);
	}
	return 1;
}

public OnVehicleSpawn(vehicleid)
{
	return 1;
}

public OnVehicleDeath(vehicleid, killerid)
{
	return 1;
}

public OnPlayerText(playerid, text[])
{
	new pText[256 + MAX_PLAYER_NAME];
	format(pText, sizeof(pText), "%s {BBBBBB}[%d]: %s", pName(playerid), playerid, text);
	SendClientMessageToAll(GetPlayerColor(playerid), pText);
	return 0;
}

public OnPlayerCommandText(playerid, cmdtext[])
{
	printf("[command] %s entered \"%s\" command.", pName(playerid), cmdtext);

	// Roleplay commands:
	if(!strcmp(cmdtext, "/me", true, 3))
    {
        if(!cmdtext[3]) return showMessage(playerid, "USAGE: /me [action]");

        new text[128];
        format(text, sizeof(text), "* %s %s", pName(playerid), cmdtext[4]);
        SendClientMessageToAll(0xFFFF00AA, text);
        return 1;
    }

   	// Debug commands:
  	if(!strcmp(cmdtext, "/eat", true))
    {
        showMessage(playerid, "You're eated a {006699}burger.");
        PlayerAccount[playerid][pA_Hungry] = 0;
        ApplyAnimation(playerid, "FOOD", "EAT_Burger", 3.0, 0, 0, 0, 0, 0);
        return 1;
	}

	if(!strcmp(cmdtext, "/addrad", true))
    {
        showMessage(playerid, "Radiation coming!");
        PlayerAccount[playerid][pA_Radiation] += 15;
        return 1;
	}

	if(!strcmp(cmdtext, "/radpills", true))
    {
        showMessage(playerid, "You're used a {006699}radiation pill.");
        PlayerAccount[playerid][pA_Radiation] = 0;
        ApplyAnimation(playerid, "FOOD", "EAT_Burger", 3.0, 0, 0, 0, 0, 0);
        return 1;
	}

// ========================================================================== //

	// Campfire script:
	if(!strcmp(cmdtext, "/campfire", true))
	{
	    if(campFire[playerid] == true) return showMessage(playerid, "You need quench your last campfire. (/firedown)");
	    if(GetPlayerState(playerid) == PLAYER_STATE_DRIVER || GetPlayerState(playerid) == PLAYER_STATE_PASSENGER) return showMessage(playerid, "Arabadayken ateþ yakamazsýnýz!");
	    campFire[playerid] = true;

	    new Float:fireX, Float:fireY, Float:fireZ;
		GetPlayerPos(playerid, fireX, fireY, fireZ);
	    fireWoods[playerid]	 = CreateDynamicObject(1463, fireX, fireY - 3.5, fireZ - 0.8, 0.000000, 0.000000, 0.000000);
		fireObject[playerid] = CreateDynamicObject(18689, fireX, fireY - 3.5, fireZ - 2.5, 0.000000, 0.000000, 0.000000);
		showMessage(playerid, "You setted a campfire. (Quench: /firedown)");
		return 1;
	}

	if(!strcmp(cmdtext, "/firedown", true))
	{
	    if(campFire[playerid] == false) return showMessage(playerid, "Once you need setting a campfire. (/campfire)");
	    if(GetPlayerState(playerid) == PLAYER_STATE_DRIVER || GetPlayerState(playerid) == PLAYER_STATE_PASSENGER) return showMessage(playerid, "Arabadayken ateþi söndüremezsiniz!");

	    new Float:fireX, Float:fireY, Float:fireZ;
	    GetDynamicObjectPos(fireWoods[playerid], fireX, fireY, fireZ);
	    if(!IsPlayerInRangeOfPoint(playerid, 7.0, fireX, fireY, fireZ)) return showMessage(playerid, "Kamp ateþinin yakýnýnda deðilsiniz! [7 metre]");

		campFire[playerid] = false;
     	DestroyDynamicObject(fireWoods[playerid]);
      	DestroyDynamicObject(fireObject[playerid]);
		showMessage(playerid, "Kamp ateþini söndürdünüz!");
	    return 1;
	}

	// Guitar script:
	if(!strcmp(cmdtext, "/guitar", true))
	{
	    if(GetPlayerState(playerid) == PLAYER_STATE_DRIVER || GetPlayerState(playerid) == PLAYER_STATE_PASSENGER) return showMessage(playerid, "Arabadayken gitar çalamazsýnýz!");
	    guitarSong[playerid] = true;

	    new randomSongs[2][0] =
	    {
	        {"http://k007.kiwi6.com/hotlink/x3bp0yv6hg/Guitar1.mp3"},
	        {"http://k007.kiwi6.com/hotlink/okyiex9pxh/Guitar2.mp3"}
	    };
	    new music = random(sizeof(randomSongs));
	    new Float:pX, Float:pY, Float:pZ;
	    GetPlayerPos(playerid, pX, pY, pZ);

	    TogglePlayerControllable(playerid, 0);
	    PlayAudioStreamForPlayer(playerid, randomSongs[music][0], pX, pY, pZ, 20.0, 1);
	    SetPlayerAttachedObject(playerid, 0, 19317, 6, -0.434999, -0.387000, 0.180000, -58.100009, -96.599891, 24.100002, 1.000000, 1.000000, 1.000000);
	    ApplyAnimation(playerid,"BEACH", "ParkSit_M_loop", 4.0, 1, 0, 0, 0, 0);
	    showMessage(playerid, "Gitar çalmaya baþladýnýz, durmak için: /guitardown");
		return 1;
	}

	if(!strcmp(cmdtext, "/guitardown", true))
	{
	    if(guitarSong[playerid] == false) return showMessage(playerid, "Gitar çalmýyorsunuz! (/guitar)");
		guitarSong[playerid] = false;

		TogglePlayerControllable(playerid, 1);
		StopAudioStreamForPlayer(playerid);
		RemovePlayerAttachedObject(playerid, 0);
		ClearAnimations(playerid);
		showMessage(playerid, "Gitar çalmayý býraktýnýz!");
		return 1;
	}

	return showMessage(playerid, "Komut hatalý!");
}

public OnPlayerEnterVehicle(playerid, vehicleid, ispassenger)
{
	return 1;
}

public OnPlayerExitVehicle(playerid, vehicleid)
{
	return 1;
}

public OnPlayerStateChange(playerid, newstate, oldstate)
{
	return 1;
}

public OnPlayerEnterCheckpoint(playerid)
{
	return 1;
}

public OnPlayerLeaveCheckpoint(playerid)
{
	return 1;
}

public OnPlayerEnterRaceCheckpoint(playerid)
{
	return 1;
}

public OnPlayerLeaveRaceCheckpoint(playerid)
{
	return 1;
}

public OnRconCommand(cmd[])
{
	return 1;
}

public OnPlayerRequestSpawn(playerid)
{
	return 1;
}

public OnObjectMoved(objectid)
{
	return 1;
}

public OnPlayerObjectMoved(playerid, objectid)
{
	return 1;
}

public OnPlayerPickUpPickup(playerid, pickupid)
{
	return 1;
}

public OnVehicleMod(playerid, vehicleid, componentid)
{
	return 1;
}

public OnVehiclePaintjob(playerid, vehicleid, paintjobid)
{
	return 1;
}

public OnVehicleRespray(playerid, vehicleid, color1, color2)
{
	return 1;
}

public OnPlayerSelectedMenuRow(playerid, row)
{
	return 1;
}

public OnPlayerExitedMenu(playerid)
{
	return 1;
}

public OnPlayerInteriorChange(playerid, newinteriorid, oldinteriorid)
{
	return 1;
}

public OnPlayerKeyStateChange(playerid, newkeys, oldkeys)
{
	return 1;
}

public OnRconLoginAttempt(ip[], password[], success)
{
	return 1;
}

public OnPlayerUpdate(playerid)
{
	return 1;
}

public OnPlayerStreamIn(playerid, forplayerid)
{
	return 1;
}

public OnPlayerStreamOut(playerid, forplayerid)
{
	return 1;
}

public OnVehicleStreamIn(vehicleid, forplayerid)
{
	return 1;
}

public OnVehicleStreamOut(vehicleid, forplayerid)
{
	return 1;
}

public OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
	// Account script:
	if(dialogid == dialog_register)
	{
		if(response)
		{
      		new query[256];
		    format(query, sizeof(query), "INSERT INTO players (Nickname, Password, LastIP) VALUES('%s', MD5('%s'), '%s')", pName(playerid), inputtext, pIP(playerid));
		    mysql_query(query);
		    format(query, sizeof(query), "INSERT INTO iplog (playername, ip, connected) VALUES('%s', '%s', 1)", pName(playerid), pIP(playerid));
		    mysql_query(query);
  		}
  		else
  		{
			new query[256];
			format(query, sizeof(query), "INSERT INTO iplog (playername, ip, connected) VALUES('%s', '%s', 0)", pName(playerid), pIP(playerid));
		    mysql_query(query);
			showMessage(playerid, "Good bye, we waiting you forever. :^)");
		    SetTimerEx("PlayerKick", 0100, 0, "i", playerid);
		}
	}
	return 1;
}

public OnPlayerClickPlayer(playerid, clickedplayerid, source)
{
	return 1;
}

// == (( Extra Public Unit )) =============================================== //
// General player timer:
forward playerGameTimer(playerid);
public playerGameTimer(playerid)
{
 	if(PlayerAccount[playerid][pA_Hungry] >= 0 && PlayerAccount[playerid][pA_Hungry] < 50)
 	{
		new Float: playerHealth;
		GetPlayerHealth(playerid, playerHealth);
		TextDrawSetString(textdraw_hungry[playerid], "HUNGRY: ~g~~h~LOW");

		if(playerHealth < 100)
			SetPlayerHealth(playerid, playerHealth + 3.0);
	}
	else if(PlayerAccount[playerid][pA_Hungry] > 50 && PlayerAccount[playerid][pA_Hungry] < 100)
	    TextDrawSetString(textdraw_hungry[playerid], "HUNGRY: ~y~MEDIUM");
	else if(PlayerAccount[playerid][pA_Hungry] > 100)
	{
	    new Float: playerHealth;
	    GetPlayerHealth(playerid, playerHealth);
        TextDrawSetString(textdraw_hungry[playerid], "HUNGRY: ~r~~h~HIGH!");

		if(playerHealth < 25)
			SetPlayerHealth(playerid, playerHealth - 3.0);
	}

	if(PlayerAccount[playerid][pA_Radiation] == 0)
	{
	    TextDrawSetString(textdraw_radiation[playerid], "RADIATION: ~w~NONE");
	}
	else
	{
	    new radiationText[64];
 		if(PlayerAccount[playerid][pA_Radiation] > 0 && PlayerAccount[playerid][pA_Radiation] < 40)
	    	format(radiationText, sizeof(radiationText), "RADIATION: ~g~~h~%d", PlayerAccount[playerid][pA_Radiation]);
 		else if(PlayerAccount[playerid][pA_Radiation] >= 40 && PlayerAccount[playerid][pA_Radiation] < 90)
	    	format(radiationText, sizeof(radiationText), "RADIATION: ~y~%d", PlayerAccount[playerid][pA_Radiation]);
 		else if(PlayerAccount[playerid][pA_Radiation] >= 90)
	    	format(radiationText, sizeof(radiationText), "RADIATION: ~r~~h~%d", PlayerAccount[playerid][pA_Radiation]);
		TextDrawSetString(textdraw_radiation[playerid], radiationText);
	}

	new pingText[64];
	if(GetPlayerPing(playerid) >= 0 && GetPlayerPing(playerid) < 80)
		format(pingText, sizeof(pingText), "PING: ~g~~h~%d", GetPlayerPing(playerid));
    else if(GetPlayerPing(playerid) >= 80 && GetPlayerPing(playerid) < 200)
		format(pingText, sizeof(pingText), "PING: ~y~%d", GetPlayerPing(playerid));
    else if(GetPlayerPing(playerid) >= 200)
		format(pingText, sizeof(pingText), "PING: ~r~~h~%d", GetPlayerPing(playerid));

	TextDrawSetString(textdraw_ping[playerid], pingText);
}

// Player hungry timer:
forward addHungry(playerid);
public addHungry(playerid)
{
	PlayerAccount[playerid][pA_Hungry]++;
}

// Kick/Ban timer:
forward PlayerKick(playerid);
public PlayerKick(playerid)
{
	Kick(playerid);
}

forward PlayerBan(playerid, ex[]);
public PlayerBan(playerid, ex[])
{
	BanEx(playerid, ex);
}

// == (( Stock & Other Unit )) ============================================== //
stock pName(playerid)
{
	new p[MAX_PLAYER_NAME];
	GetPlayerName(playerid, p, sizeof(p));
	return p;
}

stock pIP(playerid)
{
	new ip[16];
	GetPlayerIp(playerid, ip, sizeof(ip));
	return ip;
}

// Account script:
stock AccountReset(playerid)
{
	PlayerAccount[playerid][pA_Pass] 		= -1;
	PlayerAccount[playerid][pA_AdminLevel]  = -1;
	PlayerAccount[playerid][pA_Killed]      = -1;
	PlayerAccount[playerid][pA_Death]       = -1;
	PlayerAccount[playerid][pA_Score]       = -1;
	PlayerAccount[playerid][pA_Money]       = -1;
 	PlayerAccount[playerid][pA_Radiation]   = -1;
	PlayerAccount[playerid][pA_Hungry]      = -1;
	PlayerAccount[playerid][pA_Comfort]     = -1;
	PlayerAccount[playerid][pA_X]           = -1;
	PlayerAccount[playerid][pA_Y]           = -1;
	PlayerAccount[playerid][pA_Z]           = -1;
	PlayerAccount[playerid][pA_Interior]    = -1;
    PlayerAccount[playerid][pA_IP]          = -1;
	PlayerAccount[playerid][pA_Online]      = -1;
	PlayerAccount[playerid][pA_LastOnline]  = -1;
}

// ========================================================================== //

stock LoadTextDraws(playerid)
{
    textdraw_server[playerid] = TextDrawCreate(5.000000, 435.000000, "Supervivencia Server ~b~~h~~h~v1.0.0");
	TextDrawBackgroundColor(textdraw_server[playerid], 255);
	TextDrawFont(textdraw_server[playerid], 2);
	TextDrawLetterSize(textdraw_server[playerid], 0.300000, 1.000000);
	TextDrawColor(textdraw_server[playerid], 1717987071);
	TextDrawSetOutline(textdraw_server[playerid], 1);
	TextDrawSetProportional(textdraw_server[playerid], 1);

	textdraw_hungry[playerid] = TextDrawCreate(635.000000, 425.000000, "HUNGRY: ~g~~h~LOW");
	TextDrawAlignment(textdraw_hungry[playerid], 3);
	TextDrawBackgroundColor(textdraw_hungry[playerid], 255);
	TextDrawFont(textdraw_hungry[playerid], 2);
	TextDrawLetterSize(textdraw_hungry[playerid], 0.300000, 1.000000);
	TextDrawColor(textdraw_hungry[playerid], 1717987071);
	TextDrawSetOutline(textdraw_hungry[playerid], 1);
	TextDrawSetProportional(textdraw_hungry[playerid], 1);

	textdraw_radiation[playerid] = TextDrawCreate(635.000000, 435.000000, "RADIATION: ~w~~h~NONE");
	TextDrawAlignment(textdraw_radiation[playerid], 3);
	TextDrawBackgroundColor(textdraw_radiation[playerid], 255);
	TextDrawFont(textdraw_radiation[playerid], 2);
	TextDrawLetterSize(textdraw_radiation[playerid], 0.300000, 1.000000);
	TextDrawColor(textdraw_radiation[playerid], 1717987071);
	TextDrawSetOutline(textdraw_radiation[playerid], 1);
	TextDrawSetProportional(textdraw_radiation[playerid], 1);

	textdraw_ping[playerid] = TextDrawCreate(635.000000, 415.000000, "PING: ~g~~h~0");
	TextDrawAlignment(textdraw_ping[playerid], 3);
	TextDrawBackgroundColor(textdraw_ping[playerid], 255);
	TextDrawFont(textdraw_ping[playerid], 2);
	TextDrawLetterSize(textdraw_ping[playerid], 0.300000, 1.000000);
	TextDrawColor(textdraw_ping[playerid], 1717987071);
	TextDrawSetOutline(textdraw_ping[playerid], 1);
	TextDrawSetProportional(textdraw_ping[playerid], 1);

	textdraw_key1[playerid] = TextDrawCreate(635.000000, 285.000000, "Y = ~p~PICK GUN");
	TextDrawAlignment(textdraw_key1[playerid], 3);
	TextDrawBackgroundColor(textdraw_key1[playerid], 255);
	TextDrawFont(textdraw_key1[playerid], 2);
	TextDrawLetterSize(textdraw_key1[playerid], 0.300000, 1.000000);
	TextDrawColor(textdraw_key1[playerid], 1717987071);
	TextDrawSetOutline(textdraw_key1[playerid], 1);
	TextDrawSetProportional(textdraw_key1[playerid], 1);

	textdraw_key2[playerid] = TextDrawCreate(635.000000, 295.000000, "N = ~p~DROP GUN");
	TextDrawAlignment(textdraw_key2[playerid], 3);
	TextDrawBackgroundColor(textdraw_key2[playerid], 255);
	TextDrawFont(textdraw_key2[playerid], 2);
	TextDrawLetterSize(textdraw_key2[playerid], 0.300000, 1.000000);
	TextDrawColor(textdraw_key2[playerid], 1717987071);
	TextDrawSetOutline(textdraw_key2[playerid], 1);
	TextDrawSetProportional(textdraw_key2[playerid], 1);

	textdraw_key3[playerid] = TextDrawCreate(635.000000, 305.000000, "H = ~p~OPEN INVENTORY");
	TextDrawAlignment(textdraw_key3[playerid], 3);
	TextDrawBackgroundColor(textdraw_key3[playerid], 255);
	TextDrawFont(textdraw_key3[playerid], 2);
	TextDrawLetterSize(textdraw_key3[playerid], 0.300000, 1.000000);
	TextDrawColor(textdraw_key3[playerid], 1717987071);
	TextDrawSetOutline(textdraw_key3[playerid], 1);
	TextDrawSetProportional(textdraw_key3[playerid], 1);
}

stock UnloadTextDraws(playerid)
{
    TextDrawDestroy(textdraw_server[playerid]);
	TextDrawDestroy(textdraw_hungry[playerid]);
	TextDrawDestroy(textdraw_radiation[playerid]);
	TextDrawDestroy(textdraw_ping[playerid]);
	TextDrawDestroy(textdraw_key1[playerid]);
	TextDrawDestroy(textdraw_key2[playerid]);
	TextDrawDestroy(textdraw_key3[playerid]);
}

// ========================================================================== //

SkyAntiDeAMX()
{
    new AMX;
    #emit load.pri AMX
    #emit stor.pri AMX

	new AMXX;
    #emit load.pri AMXX
    #emit stor.pri AMXX

    new AMXXX;
    #emit LOAD.S.alt AMXXX
    #emit STOR.S.alt AMXXX

    new AMXXXX[][] =
    {
        "Unarmed (Fist)",
        "Brass K"
    };
    #pragma unused AMXXXX

}
// EOL | End of Line {08/02/2014 - NA/NA/2014}
