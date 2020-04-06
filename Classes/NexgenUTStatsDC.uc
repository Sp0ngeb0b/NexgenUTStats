/*##################################################################################################
##
##  Nexgen Player Lookup System version 2.01
##  Copyright (C) 2013 Patrick "Sp0ngeb0b" Peltzer
##
##  This program is free software; you can redistribute and/or modify
##  it under the terms of the Open Unreal Mod License version 1.1.
##
##  Contact: spongebobut@yahoo.com | www.unrealriders.de
##
##################################################################################################*/
class NexgenUTStatsDC extends NexgenSharedDataContainer;

var string topPlayers[3];
var string bestAttCTF[3];             
var string bestDefCTF[3];             
var string mostKills;        
var string mostTime;          
var string mostCovers;   

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

  return true;
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
    case "topPlayers": return topPlayers[index];
    case "bestAttCTF": return bestAttCTF[index];
    case "bestDefCTF": return bestDefCTF[index];
    case "mostKills":  return mostKills;
    case "mostTime":   return mostTime;
    case "mostCovers": return mostCovers;
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
  return 6;
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
    case 0:  return "topPlayers";
    case 1:  return "bestAttCTF";
    case 2:  return "bestDefCTF";
    case 3:  return "mostKills";
    case 4:  return "mostTime";
    case 5:  return "mostCovers";
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
    case "topPlayers": return DT_STRING;
    case "bestAttCTF": return DT_STRING;
    case "bestDefCTF": return DT_STRING;
    case "mostKills":  return DT_STRING;
    case "mostTime":   return DT_STRING;
    case "mostCovers": return DT_STRING;
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
    case "topPlayers": return arrayCount(topPlayers);
    case "bestAttCTF": return arrayCount(bestAttCTF);
    case "bestDefCTF": return arrayCount(bestDefCTF);
    default:           return 0;
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
    case "topPlayers": return true;
    case "bestAttCTF": return true;
    case "bestDefCTF": return true;
    default:           return false;
  }
}

/***************************************************************************************************
 *
 *  $DESCRIPTION  Default properties block.
 *
 **************************************************************************************************/
defaultproperties
{
     containerID="NexgenUTStatsDC"
}
