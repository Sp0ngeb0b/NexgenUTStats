/***************************************************************************************************
 *
 *  NexgenUTStats
 *
 *  ChangeLog:
 * 
 *  *Version 02* [Fixed] Wrong IDs getting logged due to bots.
 *
 *  *Version 01*
 *
 **************************************************************************************************/
class NexgenUTStats extends NexgenExtendedPlugin;

var NexgenUTStatsDC StatsData;

var UTStats LocalLog;
var int LogTries;

/***************************************************************************************************
 *
 *  $DESCRIPTION  Initializes the plugin. Note that if this function returns false the plugin will
 *                be destroyed and is not to be used anywhere.
 *  $RETURN       True if the initialization succeeded, false if it failed.
 *  $OVERRIDE
 *
 **************************************************************************************************/
function bool initialize() {

  // Let super class initialize.
	if (!super.initialize()) {
		return false;
	}
	
	// Load HTTP client.
	if (NexgenUTStatsConfig(xConf).bEnableStatistics &&
      class'NexgenUtil'.static.trim(NexgenUTStatsConfig(xConf).statsHost) != "") {
    StatsData = spawn(class'NexgenUTStatsDC');
		spawn(class'NexgenUTStatsHTTP');
  }
	return true;
}

/***************************************************************************************************
 *
 *  $DESCRIPTION  Called when the plugin requires the to shared data containers to be created. These
 *                may only be created / added to the shared data synchronization manager inside this
 *                function. Once created they may not be destroyed until the current map unloads.
 *  $OVERRIDE
 *
 **************************************************************************************************/
function createSharedDataContainers() {
  dataSyncMgr.addDataContainer(class'NexgenUTStatsConfigDC');
}



function StatsDataReceived() {
  local int i;

  /*
  log("NexgenUTStats: StatsDataReceived.");
  for(i=0;i<10;i++) {
    log("TopPlayers["$i$"]:"@StatsData.TopPlayers[i]);
  }
  for(i=0;i<10;i++) {
    log("BestAttCTF["$i$"]:"@StatsData.BestAttCTF[i]);
  }
  for(i=0;i<10;i++) {
    log("BestDefCTF["$i$"]:"@StatsData.BestDefCTF[i]);
  }
  log("MostKills:"@StatsData.MostKills);
  log("MostTime:"@StatsData.MostTime);
  log("MostCovers:"@StatsData.MostCovers);
  */
}

/***************************************************************************************************
 *
 *  $DESCRIPTION  Called when a general event has occurred in the system.
 *  $PARAM        type      The type of event that has occurred.
 *  $PARAM        argument  Optional arguments providing details about the event.
 *
 **************************************************************************************************/
function notifyEvent(string type, optional string arguments) {
  local NexgenClient client;
  local int JoinedPlayers;

  // ACE info available?
  if(type == "ace_login") {
    client = control.getClientByNum(int(class'NexgenUtil'.static.getProperty(arguments, "client")));

    // Log ACE info to UTStats log
    if(LocalLog != none) {
      LocalLog.LogEventString(LocalLog.GetTimeStamp()$Chr(9)$"player"$Chr(9)$"HWID"$Chr(9)$client.player.playerReplicationInfo.PlayerID$Chr(9)$class'NexgenUtil'.static.getProperty(arguments, "HWid"));
      LocalLog.LogEventString(LocalLog.GetTimeStamp()$Chr(9)$"player"$Chr(9)$"MAC"$Chr(9)$client.player.playerReplicationInfo.PlayerID$Chr(9)$class'NexgenUtil'.static.getProperty(arguments, "MAC"));
    }
  }
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Called whenever a player has joined the game (after its login has been accepted).
 *  $PARAM        client  The player that has joined the game.
 *  $REQUIRE      client != none
 *  $OVERRIDE
 *
 **************************************************************************************************/
function playerJoined(NexgenClient client) {
	local UTStats A;
	
	// Locate UTStats log file
  if(LocalLog == none && LogTries < 5) {
    foreach AllActors(class'UTStats', A) {
      LocalLog = A;
      break;
    }
    LogTries++;
  }


	// Log client ID to UTStats log
  if(!client.bSpectator && LocalLog != none) {
    LocalLog.LogEventString(LocalLog.GetTimeStamp()$Chr(9)$"player"$Chr(9)$"NID"$Chr(9)$client.player.playerReplicationInfo.PlayerID$Chr(9)$client.playerID);
  }
}


/***************************************************************************************************
 *
 *  $DESCRIPTION  Called when the value of a shared variable has been updated.
 *  $PARAM        container  Shared data container that contains the updated variable.
 *  $PARAM        varName    Name of the variable that was updated.
 *  $PARAM        index      Element index of the array variable that was changed.
 *  $REQUIRE      container != none && varName != "" && index >= 0
 *  $PARAM        author           Object that was responsible for the change.
 *  $OVERRIDE
 *
 **************************************************************************************************/
function varChanged(NexgenSharedDataContainer container, string varName, optional int index, optional Object author) {
	local NexgenClient client;

	// Log admin actions.
	if (author != none && (author.isA('NexgenClient') || author.isA('NexgenClientController')) &&
      container.containerID ~= class'NexgenUTStatsConfigDC'.default.containerID) {

		// Get client.
		if (author.isA('NexgenClientController')) {
			client = NexgenClientController(author).client;
		} else {
			client = NexgenClient(author);
		}
		// Log action.
		control.logAdminAction(client, "<C07>%1 has set %2.%3 to \"%4\".", client.playerName,
			                     string(xConf.class), varName, container.getString(varName),
			                     client.player.playerReplicationInfo, true, false);
	}
}

/***************************************************************************************************
 *
 *  Below are fixed functions for the Empty String TCP bug. Check out this article to read more
 *  about it: http://www.unrealadmin.org/forums/showthread.php?t=31280
 *
 **************************************************************************************************/
/***************************************************************************************************
 *
 *  $DESCRIPTION  Fixed serverside set() function of NexgenSharedDataSyncManager. Uses correct
 *                formatting.
 *
 **************************************************************************************************/
function setFixed(string dataContainerID, string varName, coerce string value, optional int index, optional Object author) {
	local NexgenSharedDataContainer dataContainer;
	local NexgenClient client;
	local NexgenExtendedClientController xClient;
	local string oldValue;
	local string newValue;

  // Get the data container.
	dataContainer = dataSyncMgr.getDataContainer(dataContainerID);
	if (dataContainer == none) return;

	oldValue = dataContainer.getString(varName, index);
	dataContainer.set(varName, value, index);
	newValue = dataContainer.getString(varName, index);

	// Notify clients if variable has changed.
	if (newValue != oldValue) {
		for (client = control.clientList; client != none; client = client.nextClient) {
			xClient = getXClient(client);
			if (xClient != none && xClient.bInitialSyncComplete && dataContainer.mayRead(xClient, varName)) {
				if (dataContainer.isArray(varName)) {
					xClient.sendStr(xClient.CMD_SYNC_PREFIX @ xClient.CMD_UPDATE_VAR
						              @ static.formatCmdArgFixed(dataContainerID)
						              @ static.formatCmdArgFixed(varName)
						              @ index
						              @ static.formatCmdArgFixed(newValue));
				} else {
					xClient.sendStr(xClient.CMD_SYNC_PREFIX @ xClient.CMD_UPDATE_VAR
						              @ static.formatCmdArgFixed(dataContainerID)
						              @ static.formatCmdArgFixed(varName)
						              @ static.formatCmdArgFixed(newValue));
				}
			}
		}
	}

	// Also notify the server side controller of this event.
	if (newValue != oldValue) {
		varChanged(dataContainer, varName, index, author);
	}
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Corrected version of the static formatCmdArg function in NexgenUtil. Empty strings
 *                are formated correctly now (original source of all trouble).
 *
 **************************************************************************************************/
static function string formatCmdArgFixed(coerce string arg) {
	local string result;

	result = arg;

	// Escape argument if necessary.
	if (result == "") {
		result = "\"\"";                      // Fix (originally, arg was assigned instead of result -_-)
	} else {
		result = class'NexgenUtil'.static.replace(result, "\\", "\\\\");
		result = class'NexgenUtil'.static.replace(result, "\"", "\\\"");
		result = class'NexgenUtil'.static.replace(result, chr(0x09), "\\t");
		result = class'NexgenUtil'.static.replace(result, chr(0x0A), "\\n");
		result = class'NexgenUtil'.static.replace(result, chr(0x0D), "\\r");

		if (instr(arg, " ") > 0) {
			result = "\"" $ result $ "\"";
		}
	}

	// Return result.
	return result;
}


/***************************************************************************************************
 *
 *  $DESCRIPTION  Default properties block.
 *
 **************************************************************************************************/

defaultproperties
{
     versionNum=001
     extConfigClass=Class'NexgenUTStatsConfigExt'
     sysConfigClass=Class'NexgenUTStatsConfigSys'
     clientControllerClass=Class'NexgenUTStatsClient'
     pluginName="Nexgen UTStats advanced statistic plugin"
     pluginAuthor="Sp0ngeb0b"
     pluginVersion="0.02"
}