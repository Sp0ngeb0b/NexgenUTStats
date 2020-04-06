class NexgenUTStatsHTTP extends UBrowserHTTPClient;

var NexgenUTStats xControl;             // controller.

var string TopPlayers[3];
var string BestAttCTF[3];
var string BestDefCTF[3];
var string MostKills;      
var string MostTime;     
var string MostCovers;  

/***************************************************************************************************
 *
 *  $DESCRIPTION  Initializes the UTStats statistics retriever client.
 *  $OVERRIDE
 *
 **************************************************************************************************/
function preBeginPlay() {
  local string url;
  
  super.preBeginPlay();
  
  // Get controller.
  foreach allActors(class'NexgenUTStats', xControl) {
    break;
  }
  
  xControl.control.nscLog("NexgenUTStatsHTTP: browsing ...");
  
  // Construct url to retrieve the stats.
  url = xControl.conf.statsPath;
  
  // Retrieve stats.
  browse(xControl.conf.statsHost, url, xControl.conf.statsPort);
}

/***************************************************************************************************
 *
 *  $DESCRIPTION  Called when the HTTP request failed.
 *  $OVERRIDE
 *
 **************************************************************************************************/
function HTTPError(int code) {
  xControl.control.nscLog("NexgenUTStatsHTTP: Unable to connect to host. Error"@code);
}

/***************************************************************************************************
 *
 *  $DESCRIPTION  Called when the HTTP request has been replied and the data has been received.
 *  $PARAM        data  The data that has been received.
 *  $OVERRIDE
 *
 **************************************************************************************************/
function HTTPReceivedData(string data) {
  local string remaining;
  local string currLine;
  local NexgenUTStatsDC statsData;
  local int i;
  
  // Process data.
  remaining = data;
  do {
    currLine = class'NexgenUtil'.static.trim(class'NexgenUtil'.static.getNextLine(remaining));
    if (currLine != "") {
      processData(currLine);
    }
  } until (remaining == "");
  
  xControl.control.nscLog("NexgenUTStatsHTTP: done.");
  
  // Fill shared data container
  statsData = spawn(class'NexgenUTStatsDC');
  for(i=0; i<arrayCount(topPlayers); i++) statsData.topPlayers[i] = topPlayers[i];
  for(i=0; i<arrayCount(bestAttCTF); i++) statsData.bestAttCTF[i] = bestAttCTF[i];
  for(i=0; i<arrayCount(bestDefCTF); i++) statsData.topPlayers[i] = bestDefCTF[i];
  statsData.mostKills = mostKills;
  statsData.mostTime  = mostTime;
  statsData.mostCovers= mostCovers;
}

/***************************************************************************************************
 *
 *  $DESCRIPTION  Splits the given string in two parts: the first line and the rest.
 *  $PARAM        str  The string that should be splitted.
 *  $RETURN       The first line in the given string.
 *
 **************************************************************************************************/
function processData(string str) {
  local string cmdType;
  local string cmdArgs[10];
  local int index;
  
  // Parse command.
  if (class'NexgenUtil'.static.parseCmd(str, cmdType, cmdArgs)) {
    switch (cmdType) {
      case "topplayers":
        while(cmdArgs[index] != "" && index<ArrayCount(cmdArgs)) {
           topPlayers[index] = cmdArgs[index];
           index++;
        }
      break;
      case "bestattctf":
        while(cmdArgs[index] != "" && index<ArrayCount(cmdArgs)) {
           bestAttCTF[index] = cmdArgs[index];
           index++;
        }
      break;
      case "bestdefctf":
        while(cmdArgs[index] != "" && index<ArrayCount(cmdArgs)) {
           bestDefCTF[index] = cmdArgs[index];
           index++;
        }
      break;
     case "mostkills":
       if(cmdArgs[index] != "") mostKills = cmdArgs[0];
      break;
     case "mosttime":
       if(cmdArgs[index] != "") mostTime = cmdArgs[0];
      break;
      case "mostcovers":
       if(cmdArgs[index] != "") mostCovers = cmdArgs[0];
      break;
    }
  }
}

/***************************************************************************************************
 *
 *  $DESCRIPTION  Default properties block.
 *
 **************************************************************************************************/
defaultproperties
{
     RemoteRole=ROLE_None
}
