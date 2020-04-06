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
class NexgenUTStatsClient extends NexgenExtendedClientController;


/***************************************************************************************************
 *
 *  $DESCRIPTION  Modifies the setup of the Nexgen remote control panel.
 *  $OVERRIDE
 *
 **************************************************************************************************/
simulated function setupControlPanel() {
  local NexgenPanelContainer container;
  local UWindowPageControlPage pageControl;
  local NexgenPanel newPanel;


  // Add config panel
  if (client.hasRight(client.R_ServerAdmin)) {
	  client.addPluginConfigPanel(class'NexgenUTStatsConfigPanel');
	}
}


/***************************************************************************************************
 *
 *  $DESCRIPTION  Wrapper function for NexgenController.logAdminAction() when called clientside.
 *  $PARAM        msg                Message that describes the action performed by the administrator.
 *  $PARAM        str1               Message specific content.
 *  $PARAM        str2               Message specific content.
 *  $PARAM        str3               Message specific content.
 *  $PARAM        bNoBroadcast       Whether not to broadcast this administrator action.
 *  $PARAM        bServerAdminsOnly  Broadcast message only to administrators with the server admin
 *                                   privilege.
 *
 **************************************************************************************************/
function SlogAdminAction(string msg, optional coerce string str1, optional coerce string str2,
                        optional coerce string str3, optional bool bNoBroadcast,
                        optional bool bServerAdminsOnly) {
	control.logAdminAction(client, msg, client.playerName, str1, str2, str3,
	                       client.player.playerReplicationInfo, bNoBroadcast, bServerAdminsOnly);
}


/***************************************************************************************************
 *
 *  $DESCRIPTION  Called when a string was received from the other machine.
 *  $PARAM        str  The string that was send by the other machine.
 *
 **************************************************************************************************
simulated function recvStr(string str) {
	local string cmd;
	local string args[10];
	local int argCount;

	super.recvStr(str);

	// Check controller role.
	if (role != ROLE_Authority) {
		// Commands accepted by client.
		if(class'NexgenUtil'.static.parseCmd(str, cmd, args, argCount, CMD_ABM_PREFIX)) {
      switch (cmd) {
        case CMD_ABM_CLR:    exec_ABM_CLR(); break;
        case CMD_ABM_DELBAN: exec_ABM_DELBAN(int(args[0])); break;
      }
    } else if (class'NexgenUtil'.static.parseCmd(str, cmd, args, argCount, CMD_ACEINFO_PREFIX)) {
			switch (cmd) {
				case CMD_ACEINFO_NEW:       exec_ACEINFO_NEW(args, argCount); break;
				case CMD_ACEINFO_VAR:       exec_ACEINFO_VAR(args, argCount); break;
				case CMD_ACEINFO_COMPLETE:  exec_ACEINFO_COMPLETE(args, argCount); break;
			}
		}
	} else {
    // Commands accepted by server.
    if(class'NexgenUtil'.static.parseCmd(str, cmd, args, argCount, CMD_ABM_PREFIX)) {
      switch (cmd) {
        case CMD_ABM_DELBAN: exec_ABM_DELBAN(int(args[0])); break;
      }
    }
  }
}
*/



/***************************************************************************************************
 *
 *  Below are fixed functions for the Empty String TCP bug. Check out this article to read more
 *  about it: http://www.unrealadmin.org/forums/showthread.php?t=31280
 *
 **************************************************************************************************/
/***************************************************************************************************
 *
 *  $DESCRIPTION  Fixed version of the setVar function in NexgenExtendedClientController.
 *                Empty strings are now formated correctly before beeing sent to the server.
 *
 **************************************************************************************************/
simulated function setVar(string dataContainerID, string varName, coerce string value, optional int index) {
	local NexgenSharedDataContainer dataContainer;
	local string oldValue;
	local string newValue;

	// Get data container.
	dataContainer = dataSyncMgr.getDataContainer(dataContainerID);

	// Check if variable can be updated.
	if (dataContainer == none || !dataContainer.mayWrite(self, varName)) return;

	// Update variable value.
	oldValue = dataContainer.getString(varName, index);
	dataContainer.set(varName, value, index);
	newValue = dataContainer.getString(varName, index);

	// Send new value to server.
	if (newValue != oldValue) {
		if (dataContainer.isArray(varName)) {
			sendStr(CMD_SYNC_PREFIX @ CMD_UPDATE_VAR
			        @ class'NexgenUTStats'.static.formatCmdArgFixed(dataContainerID)
			        @ class'NexgenUTStats'.static.formatCmdArgFixed(varName)
			        @ index
			        @ class'NexgenUTStats'.static.formatCmdArgFixed(newValue));
		} else {
			sendStr(CMD_SYNC_PREFIX @ CMD_UPDATE_VAR
			        @ class'NexgenUTStats'.static.formatCmdArgFixed(dataContainerID)
			        @ class'NexgenUTStats'.static.formatCmdArgFixed(varName)
			        @ class'NexgenUTStats'.static.formatCmdArgFixed(newValue));
		}
	}
}


/***************************************************************************************************
 *
 *  $DESCRIPTION  Corrected version of the exec_UPDATE_VAR function in NexgenExtendedClientController.
 *                Due to the invalid format function, empty strings weren't sent correctly and were
 *                therefore not identifiable for the other machine (server). This caused the var index
 *                being erroneously recognized as the new var value on the server.
 *                Since the serverside set() function in NexgenSharedDataSyncManager also uses the
 *                invalid format functions, I implemented a fixed function in NexgenUTStats. The
 *                client side set() function can still be called safely without problems.
 *
 **************************************************************************************************/
simulated function exec_UPDATE_VAR(string args[10], int argCount) {
	local int varIndex;
	local string varName;
	local string varValue;
	local NexgenSharedDataContainer container;
	local int index;

	// Get arguments.
	if (argCount == 3) {
		varName = args[1];
		varValue = args[2];
	} else if (argCount == 4) {
		varName = args[1];
		varIndex = int(args[2]);
		varValue = args[3];
	} else {
		return;
	}

	if (role == ROLE_Authority) {
  	// Server side, call fixed set() function
  	NexgenUTSTats(xControl).setFixed(args[0], varName, varValue, varIndex, self);
  } else {

    // Client Side
    dataSyncMgr.set(args[0], varName, varValue, varIndex, self);

    container = dataSyncMgr.getDataContainer(args[0]);

		// Signal event to client controllers.
		for (index = 0; index < client.clientCtrlCount; index++) {
			if (NexgenExtendedClientController(client.clientCtrl[index]) != none) {
				NexgenExtendedClientController(client.clientCtrl[index]).varChanged(container, varName, varIndex);
			}
		}

		// Signal event to GUI.
		client.mainWindow.mainPanel.varChanged(container, varName, varIndex);
  }
}


/***************************************************************************************************
 *
 *  $DESCRIPTION  Default properties block.
 *
 **************************************************************************************************/

defaultproperties
{
     ctrlID="NexgenUTStatsClient"
}