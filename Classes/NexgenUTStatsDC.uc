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
class NexgenUTStatsDC extends Info;

var bool bStatsAvailable;
var string TopPlayers[10];                   // The client's Nexgen ID
var string BestAttCTF[10];             // The client's Hardware ID
var string BestDefCTF[10];              // The client's MAC Hash
var string MostKills;        // Name1$Name2$Name3 and so on
var string MostTime;          // IP1$IP2$IP3 and so on
var string MostCovers;    // HN1$HN2$HN3 and so on

defaultproperties
{
}
