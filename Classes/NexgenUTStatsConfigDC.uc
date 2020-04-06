/*##################################################################################################
##
##  Nexgen Advanced Ban Manager version 1.02
##  Copyright (C) 2013 Patrick "Sp0ngeb0b" Peltzer
##
##  This program is free software; you can redistribute and/or modify
##  it under the terms of the Open Unreal Mod License version 1.1.
##
##  Contact: spongebobut@yahoo.com | www.unrealriders.de
##
##################################################################################################*/
class NexgenUTStatsConfigDC extends NexgenSharedDataContainer;

var NexgenUTStatsConfig xConf;

var bool bEnableStatistics;               // Whether to UTStats client is enabled.
var string statsHost;                    // The hostname or IP of the UTStats server.
var int statsPort;                       // Port of the UTStats server.
var string statsPath;                    // Path of the UTStats script on the server.

/***************************************************************************************************
 *
 *  $DESCRIPTION  Loads the data that for this shared data container.
 *  $OVERRIDE
 *
 **************************************************************************************************/
function loadData() {
	local int index;

	xConf = NexgenUTStatsConfig(xControl.xConf);

	bEnableStatistics = xConf.bEnableStatistics;
	statsHost         = xConf.statsHost;
	statsPort         = xConf.statsPort;
	statsPath         = xConf.statsPath;
}


/***************************************************************************************************
 *
 *  $DESCRIPTION  Saves the data store in this shared data container.
 *  $OVERRIDE
 *
 **************************************************************************************************/
function saveData() {
	xConf.saveConfig();
}



/***************************************************************************************************
 *
 *  $DESCRIPTION Overwrites original function so that only admins receive the initial info.
 *               (optimizes network performance)
 *
 **************************************************************************************************/
function initRemoteClient(NexgenExtendedClientController xClient) {
  if(!xClient.client.hasRight(xClient.client.R_ServerAdmin)) return;
  super.initRemoteClient(xClient);
}

/***************************************************************************************************
 *
 *  $DESCRIPTION  Changes the value of the specified variable.
 *  $PARAM        varName  Name of the variable whose value is to be changed.
 *  $PARAM        value    New value for the variable.
 *  $PARAM        index    Array index in case the variable is an array.
 *  $REQUIRE      varName != "" && imply(isArray(varName), 0 <= index && index <= getArraySize(varName))
 *  $OVERRIDE
 *
 **************************************************************************************************/
function set(string varName, coerce string value, optional int index) {
	switch (varName) {
	  case "bEnableStatistics": bEnableStatistics = class'NexgenUtil'.static.str2bool(value); if (xConf != none) { xConf.bEnableStatistics = bEnableStatistics; } break;
    case "statsHost":         statsHost         = value;                                    if (xConf != none) { xConf.statsHost         = statsHost;         } break;
    case "statsPort":         statsPort         = clamp(int(value), 0, 65535);              if (xConf != none) { xConf.statsPort         = statsPort;         } break;
    case "statsPath":         statsPath         = value;                                    if (xConf != none) { xConf.statsPath         = statsPath;         } break;
  }
}


/***************************************************************************************************
 *
 *  $DESCRIPTION  Checks whether the specified client is allowed to read the variable value.
 *  $PARAM        xClient  The controller of the client that is to be checked.
 *  $PARAM        varName  Name of the variable whose access is to be checked.
 *  $REQUIRE      varName != ""
 *  $RETURN       True if the variable may be read by the specified client, false if not.
 *  $OVERRIDE
 *
 **************************************************************************************************/
function bool mayRead(NexgenExtendedClientController xClient, string varName) {

  return xClient.client.hasRight(xClient.client.R_ServerAdmin);
}


/***************************************************************************************************
 *
 *  $DESCRIPTION  Checks whether the specified client is allowed to change the variable value.
 *  $PARAM        xClient  The controller of the client that is to be checked.
 *  $PARAM        varName  Name of the variable whose access is to be checked.
 *  $REQUIRE      varName != ""
 *  $RETURN       True if the variable may be changed by the specified client, false if not.
 *  $OVERRIDE
 *
 **************************************************************************************************/
function bool mayWrite(NexgenExtendedClientController xClient, string varName) {
  return xClient.client.hasRight(xClient.client.R_ServerAdmin);
}


/***************************************************************************************************
 *
 *  $DESCRIPTION  Checks whether the specified client is allowed to save the data in this container.
 *  $PARAM        xClient  The controller of the client that is to be checked.
 *  $REQUIRE      xClient != none
 *  $RETURN       True if the data may be saved by the specified client, false if not.
 *  $OVERRIDE
 *
 **************************************************************************************************/
function bool maySaveData(NexgenExtendedClientController xClient) {
	return xClient.client.hasRight(xClient.client.R_ServerAdmin);
}

/***************************************************************************************************
 *
 *  $DESCRIPTION  Reads the boolean value of the specified variable.
 *  $PARAM        varName  Name of the variable whose value is to be retrieved.
 *  $PARAM        index    Index of the element in the array that is to be retrieved.
 *  $REQUIRE      varName != "" && imply(isArray(varName), 0 <= index && index <= getArraySize(varName))
 *  $RETURN       The boolean value of the specified variable.
 *  $OVERRIDE
 *
 **************************************************************************************************/
function bool getBool(string varName, optional int index) {
	switch (varName) {
		case "bEnableStatistics": return bEnableStatistics;
	}
}

/***************************************************************************************************
 *
 *  $DESCRIPTION  Reads the integer value of the specified variable.
 *  $PARAM        varName  Name of the variable whose value is to be retrieved.
 *  $PARAM        index    Index of the element in the array that is to be retrieved.
 *  $REQUIRE      varName != "" && imply(isArray(varName), 0 <= index && index <= getArraySize(varName))
 *  $RETURN       The integer value of the specified variable.
 *  $OVERRIDE
 *
 **************************************************************************************************/
function int getInt(string varName, optional int index) {
	switch (varName) {
		case "statsPort":   return statsPort;
	}
}

/***************************************************************************************************
 *
 *  $DESCRIPTION  Reads the string value of the specified variable.
 *  $PARAM        varName  Name of the variable whose value is to be retrieved.
 *  $PARAM        index    Index of the element in the array that is to be retrieved.
 *  $REQUIRE      varName != "" && imply(isArray(varName), 0 <= index && index <= getArraySize(varName))
 *  $RETURN       The string value of the specified variable.
 *  $OVERRIDE
 *
 **************************************************************************************************/
function string getString(string varName, optional int index) {
	switch (varName) {
		case "bEnableStatistics": return string(bEnableStatistics);
		case "statsHost":         return statsHost;
		case "statsPort":         return string(statsPort);
		case "statsPath":         return statsPath;
	}
}


/***************************************************************************************************
 *
 *  $DESCRIPTION  Returns the number of variables that are stored in the container.
 *  $RETURN       The number of variables stored in the shared data container.
 *  $OVERRIDE
 *
 **************************************************************************************************/
function int getVarCount() {
	return 4;
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Retrieves the variable name of the variable at the specified index.
 *  $PARAM        varIndex  Index of the variable whose name is to be retrieved.
 *  $REQUIRE      0 <= varIndex && varIndex <= getVarCount()
 *  $RETURN       The name of the specified variable.
 *  $OVERRIDE
 *
 **************************************************************************************************/
function string getVarName(int varIndex) {
	switch (varIndex) {
		case 0:  return "bEnableStatistics";
		case 1:  return "statsHost";
		case 2:  return "statsPort";
		case 3:  return "statsPath";
	}
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Retrieves the data type of the specified variable.
 *  $PARAM        varName  Name of the variable whose data type is to be retrieved.
 *  $REQUIRE      varName != ""
 *  $RETURN       The data type of the specified variable.
 *  $OVERRIDE
 *
 **************************************************************************************************/
function byte getVarType(string varName) {
	switch (varName) {
		case "bEnableStatistics":       return DT_BOOL;
		case "statsHost":               return DT_STRING;
		case "statsPort":               return DT_INT;
		case "statsPath":               return DT_STRING;
	}
}


/***************************************************************************************************
 *
 *  $DESCRIPTION  Retrieves the array length of the specified variable.
 *  $PARAM        varName  Name of the variable which is to be checked.
 *  $REQUIRE      varName != "" && isArray(varName)
 *  $RETURN       The size of the array.
 *  $OVERRIDE
 *
 **************************************************************************************************/
function int getArraySize(string varName) {
	switch (varName) {
		default:				           return 0;
	}
}


/***************************************************************************************************
 *
 *  $DESCRIPTION  Checks whether the specified variable is an array.
 *  $PARAM        varName  Name of the variable which is to be checked.
 *  $REQUIRE      varName != ""
 *  $RETURN       True if the variable is an array, false if not.
 *  $OVERRIDE
 *
 **************************************************************************************************/
function bool isArray(string varName) {
	switch (varName) {
		default: return false;
	}
}


/***************************************************************************************************
 *
 *  $DESCRIPTION  Default properties block.
 *
 **************************************************************************************************/

defaultproperties
{
     containerID="NexgenUTStats_config"
}
