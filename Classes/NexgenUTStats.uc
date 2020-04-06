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
class NexgenUTStats extends NexgenPlugin;

var NexgenUTStatsConfig conf;

var UTStats localLog;
var int logTries;

/***************************************************************************************************
 *
 *  $DESCRIPTION  Initializes the plugin. Note that if this function returns false the plugin will
 *                be destroyed and is not to be used anywhere.
 *  $RETURN       True if the initialization succeeded, false if it failed.
 *  $OVERRIDE
 *
 **************************************************************************************************/
function bool initialize() {

  // Load settings.
  if (control.bUseExternalConfig) {
    conf = spawn(class'NexgenUTStatsConfigExt', self);
  } else {
    conf = spawn(class'NexgenUTStatsConfigSys', self);
  }
  
  // Load HTTP client.
  if (conf.bEnableStatistics &&
      class'NexgenUtil'.static.trim(conf.statsHost) != "") {
    spawn(class'NexgenUTStatsHTTP');
  }
  return true;
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
    if(localLog != none) {
      localLog.LogEventString(localLog.GetTimeStamp()$Chr(9)$"player"$Chr(9)$"HWID"$Chr(9)$client.player.playerReplicationInfo.PlayerID$Chr(9)$class'NexgenUtil'.static.getProperty(arguments, "HWid"));
      localLog.LogEventString(localLog.GetTimeStamp()$Chr(9)$"player"$Chr(9)$"MAC"$Chr(9)$client.player.playerReplicationInfo.PlayerID$Chr(9)$class'NexgenUtil'.static.getProperty(arguments, "MAC"));
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
  if(localLog == none && logTries < 5) {
    foreach AllActors(class'UTStats', A) {
      localLog = A;
      break;
    }
    logTries++;
  }

  // Log client ID to UTStats log
  if(!client.bSpectator && localLog != none) {
    localLog.LogEventString(localLog.GetTimeStamp()$Chr(9)$"player"$Chr(9)$"NID"$Chr(9)$client.player.playerReplicationInfo.PlayerID$Chr(9)$client.playerID);
  }
}

/***************************************************************************************************
 *
 *  $DESCRIPTION  Default properties block.
 *
 **************************************************************************************************/
defaultproperties
{
     pluginName="Nexgen UTStats advanced statistic plugin"
     pluginAuthor="Sp0ngeb0b"
     pluginVersion="0.03"
}