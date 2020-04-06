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
class NexgenUTStatsConfig extends NexgenPluginConfig;

// Config settings
var config bool bEnableStatistics;               // Whether to UTStats client is enabled.
var config string statsHost;                    // The hostname or IP of the UTStats server.
var config int statsPort;                       // Port of the UTStats server.
var config string statsPath;                    // Path of the UTStats script on the server.


/***************************************************************************************************
 *
 *  $DESCRIPTION  Automatically installs the plugin.
 *  $ENSURE       lastInstalledVersion >= xControl.versionNum
 *
 **************************************************************************************************/
function install() {

	lastInstalledVersion = xControl.versionNum;

	// Save updated config or create new one
	saveconfig();
}


defaultproperties
{
}
