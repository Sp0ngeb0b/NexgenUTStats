class NexgenUTStatsHTTP extends UBrowserHTTPClient;

var NexgenUTStats xControl;             // controller.

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
	
	log("NexgenUTStatsHTTP: browsing ...");
	
	// Construct url to retrieve the stats.
	url = NexgenUTStatsConfig(xControl.xConf).statsPath;
	
	// Retrieve stats.
	browse(NexgenUTStatsConfig(xControl.xConf).statsHost, url, NexgenUTStatsConfig(xControl.xConf).statsPort);
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Called when the HTTP request failed.
 *  $OVERRIDE
 *
 **************************************************************************************************/
function HTTPError(int code) {
  log("NexgenUTStatsHTTP: Unable to connect to host. Error"@code);
	xControl.control.nscLog(class'NexgenUtil'.static.format("Unable to connect to host.", code));
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
	
	// Process data.
	remaining = data;
	do {
		currLine = class'NexgenUtil'.static.trim(class'NexgenUtil'.static.getNextLine(remaining));
		if (currLine != "") {
			processData(currLine);
		}
	} until (remaining == "");
	
	log("NexgenUTStatsHTTP: done.");
	xControl.StatsData.bStatsAvailable = True;
  xControl.StatsDataReceived();
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
			case "topplayers": // Add a new player list.
        while(cmdArgs[index] != "" && index<ArrayCount(cmdArgs)) {
           xControl.StatsData.TopPlayers[index] = cmdArgs[index];
           index++;
        }
			break;
		  case "bestattctf": // Add a new player list.
        while(cmdArgs[index] != "" && index<ArrayCount(cmdArgs)) {
           xControl.StatsData.BestAttCTF[index] = cmdArgs[index];
           index++;
        }
			break;
      case "bestdefctf": // Add a new player list.
        while(cmdArgs[index] != "" && index<ArrayCount(cmdArgs)) {
           xControl.StatsData.BestDefCTF[index] = cmdArgs[index];
           index++;
        }
			break;
     case "mostkills": // Add a new player list.
       if(cmdArgs[index] != "") xControl.StatsData.MostKills = cmdArgs[0];
			break;
     case "mosttime": // Add a new player list.
       if(cmdArgs[index] != "") xControl.StatsData.MostTime = cmdArgs[0];
			break;
			case "mostcovers": // Add a new player list.
       if(cmdArgs[index] != "") xControl.StatsData.MostCovers = cmdArgs[0];
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
