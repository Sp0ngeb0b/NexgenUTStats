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
class NexgenUTStatsConfigPanel extends NexgenPanel;

var NexgenUTStatsClient xClient;
var NexgenSharedDataContainer configData;

var UWindowCheckbox bEnableStatisticsInp;
var UWindowEditControl statsHostInp;
var UWindowEditControl statsPortInp;
var UWindowEditControl statsPathInp;

var UWindowSmallButton resetButton;
var UWindowSmallButton saveButton;


/***************************************************************************************************
 *
 *  $DESCRIPTION  Creates the contents of the panel.
 *  $OVERRIDE
 *
 **************************************************************************************************/
function setContent() {
	local int region;

	xClient = NexgenUTStatsClient(client.getController(class'NexgenUTStatsClient'.default.ctrlID));

	// Create layout & add components.
	createPanelRootRegion();
	splitRegionH(12, defaultComponentDist);
	addLabel("Nexgen UTStats Configuration", true, TA_Center);

	splitRegionH(1, defaultComponentDist);
	addComponent(class'NexgenDummyComponent');

	divideRegionV(2, 2 * defaultComponentDist);
	divideRegionH(3);
	divideRegionH(3);
	splitRegionV(64);
	splitRegionV(64);
	splitRegionV(64);
	bEnableStatisticsInp = addCheckBox(TA_Left, "Enable Statistics", true);
	skipRegion();
	splitRegionV(196, , , true);
	addLabel("Stats host", true);
	statsHostInp = addEditBox();
	addLabel("Stats port", true);
	statsPortInp = addEditBox();
	addLabel("Stats path", true);
	statsPathInp = addEditBox();

	skipRegion();
	divideRegionV(2, defaultComponentDist);
	saveButton = addButton("Save");
	resetButton = addButton("Reset");

	// Configure components.
	statsHostInp.setMaxLength(50);
	statsPortInp.setMaxLength(5);
	statsPathInp.setMaxLength(250);
	statsPortInp.setNumericOnly(true);
	setValues();
}


/***************************************************************************************************
 *
 *  $DESCRIPTION  Called when the initial synchronization of the given shared data container is
 *                done. After this has happend the client may query its variables and receive valid
 *                results (assuming the client is allowed to read those variables).
 *  $PARAM        container  The shared data container that has become available for use.
 *  $REQUIRE      container != none
 *  $OVERRIDE
 *
 **************************************************************************************************/
function dataContainerAvailable(NexgenSharedDataContainer container) {
  if (container.containerID == class'NexgenUTStatsConfigDC'.default.containerID) {
		configData = container;
		setValues();
		resetButton.bDisabled = false;
		saveButton.bDisabled = false;
	}
}


/***************************************************************************************************
 *
 *  $DESCRIPTION  Sets the values of all input components to the current settings.
 *
 **************************************************************************************************/
function setValues() {
	bEnableStatisticsInp.bChecked = configData.getBool("bEnableStatistics");
	statsHostInp.setValue(configData.getString("statsHost"));
	statsPortInp.setValue(configData.getString("statsPort"));
	statsPathInp.setValue(configData.getString("statsPath"));
}


/***************************************************************************************************
 *
 *  $DESCRIPTION  Called when the value of a shared variable has been updated.
 *  $PARAM        container  Shared data container that contains the updated variable.
 *  $PARAM        varName    Name of the variable that was updated.
 *  $PARAM        index      Element index of the array variable that was changed.
 *  $REQUIRE      container != none && varName != "" && index >= 0
 *  $OVERRIDE
 *
 **************************************************************************************************/
function varChanged(NexgenSharedDataContainer container, string varName, optional int index) {
	if (container.containerID ~= class'NexgenUTStatsConfigDC'.default.containerID) {
		switch (varName) {
	 		case "bEnableStatistics":    bEnableStatisticsInp.bChecked = container.getBool(varName); break;
	 		case "statsHost":            statsHostInp.setValue(container.getString(varName));     break;
	 		case "statsPort":            statsPortInp.setValue(container.getString(varName));     break;
	 		case "statsPath":            statsPathInp.setValue(container.getString(varName));     break;
		}
	}
}


/***************************************************************************************************
 *
 *  $DESCRIPTION  Saves the current settings.
 *
 **************************************************************************************************/
function saveSettings() {
	local int index;

	xClient.setVar(class'NexgenUTStatsConfigDC'.default.containerID, "bEnableStatistics", bEnableStatisticsInp.bChecked);
	xClient.setVar(class'NexgenUTStatsConfigDC'.default.containerID, "statsHost",      statsHostInp.getValue());
	xClient.setVar(class'NexgenUTStatsConfigDC'.default.containerID, "statsPort",      statsPortInp.getValue());
	xClient.setVar(class'NexgenUTStatsConfigDC'.default.containerID, "statsPath",      statsPathInp.getValue());
	xClient.saveSharedData(class'NexgenUTStatsConfigDC'.default.containerID);
}


/***************************************************************************************************
 *
 *  $DESCRIPTION  Notifies the dialog of an event (caused by user interaction with the interface).
 *  $PARAM        control    The control object where the event was triggered.
 *  $PARAM        eventType  Identifier for the type of event that has occurred.
 *  $REQUIRE      control != none
 *  $OVERRIDE
 *
 **************************************************************************************************/
function notify(UWindowDialogControl control, byte eventType) {
	super.notify(control, eventType);

	// Button pressed?
	if (control != none && eventType == DE_Click && control.isA('UWindowSmallButton') &&
	    !UWindowSmallButton(control).bDisabled) {

		switch (control) {
			case resetButton: setValues(); break;
			case saveButton: saveSettings(); break;
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
     panelIdentifier="NexgenUTStatsConfigPanel"
     PanelHeight=96.000000
}
