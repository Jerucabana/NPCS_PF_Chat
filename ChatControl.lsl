// ██████╗   ██████╗ ██╗     ██████╗ ███████╗███╗   ██╗    ██╗  ██╗███╗   ██╗██╗ ██████╗ ██╗  ██╗████████╗
// ██╔════╝ ██╔═══██╗██║     ██╔══██╗██╔════╝████╗  ██║    ██║ ██╔╝████╗  ██║██║██╔════╝ ██║  ██║╚══██╔══╝
// ██║  ███╗██║   ██║██║     ██║  ██║█████╗  ██╔██╗ ██║    █████╔╝ ██╔██╗ ██║██║██║  ███╗███████║   ██║   
// ██║   ██║██║   ██║██║     ██║  ██║██╔══╝  ██║╚██╗██║    ██╔═██╗ ██║╚██╗██║██║██║   ██║██╔══██║   ██║   
// ╚██████╔╝╚██████╔╝███████╗██████╔╝███████╗██║ ╚████║    ██║  ██╗██║ ╚████║██║╚██████╔╝██║  ██║   ██║   
//  ╚═════╝  ╚═════╝ ╚══════╝╚═════╝ ╚══════╝╚═╝  ╚═══╝    ╚═╝  ╚═╝╚═╝  ╚═══╝╚═╝ ╚═════╝ ╚═╝  ╚═╝   ╚═╝   
                                                                                                       
// ███████╗ ██████╗ ███████╗████████╗██╗    ██╗ █████╗ ██████╗ ███████╗                                   
// ██╔════╝██╔═══██╗██╔════╝╚══██╔══╝██║    ██║██╔══██╗██╔══██╗██╔════╝                                   
// ███████╗██║   ██║█████╗     ██║   ██║ █╗ ██║███████║██████╔╝█████╗                                     
// ╚════██║██║   ██║██╔══╝     ██║   ██║███╗██║██╔══██║██╔══██╗██╔══╝                                     
// ███████║╚██████╔╝██║        ██║   ╚███╔███╔╝██║  ██║██║  ██║███████╗                                   
// ╚══════╝ ╚═════╝ ╚═╝        ╚═╝    ╚══╝╚══╝ ╚═╝  ╚═╝╚═╝  ╚═╝╚══════╝      
//
// This script was created by Ferd Frederix.
// It had some issues and they were fixed and some points were finetuned by Pandora Bryer.
//
//key ownerKey = ""; //Add here your key if you need it for debug purposes.
// This chatbot is for OpenSim Only. It only works on NPC's.

// Rev 1.1 08-27-2015 made API use first name as the Hypergid names were too long
// Rev 2.0 - The greet mode was improved by Pandora Breyer.
//
// Chatbot for PersonalityForge. Get a free  account at http://www.personalityforge.com.
// 5,000 chats are free.
// :CODE:

// first, get a free  account at http://www.personalityforge.com.
// Get an API ID, and add it to the apiKey :

string apiKey = "gggg555y5y";    // your supplied apiKey from your Chat Bot API subscription

// Add the domain *.secondlife.com or your OpenSim server IP to the list of authorized domains at http://www.personalityforge.com/botland/myapi.php
// Add a checkmark to the "Enable Simple API" in tyour account.
// Click on the Simple API tab and pick a chatbot ID from the list of chatbots under the heading "Selecting A Chat Bot ID"
// for example, Countess Elvira is 99232.  Put that in chatBot ID below.
// Sex Bot Ciran is 100387.  Type menu for choices
// 754 is Liddora a sexy tart

// look at http://www.personalityforge.com/bookofapi.php for more public chat bots

string chatBotID = "00000";    // the ID of the chat bot you're talking to
integer greeting = TRUE;     // if TRUE, say hello when anyone comes up.
integer repeat = 30; //The seconds that the sensor will repeat its scan.

integer debug = FALSE;  // Set this TRUE to see the gory details

////////// REMOVE THESE IN WORLD ////////////////
///////// LSLEDIT DEBUG ONLY////////////////////
//osNpcSetRot(key npc, rotation rot) {llSay(0,"Roatating to " + (vector) llRot2Euler(rot));}
//osNpcStopAnimation(key npc, string animation) {llSay(0,"Stopped " + animation);}
//osNpcPlayAnimation(key npc, string animation) {llSay(0,"Playing " + animation);}
//osNpcSay(string speach) {llSay(0,speach);}
/////////////////////////////////////////////////////////////////////

// various  tuneable code bits
float range = 25; // haw far awy an avatar is before we greet them/. No point in making this more than 20, that cannot hear us after that
float  wpm = 50; // 33 wpm = 2.75 cps @ 5 chars per word for a typical avatar to type with.
//  Larger numbers make your NPC answer quicker.
float cps;
integer emotionchannel = 199; // a secret channel that the chatbot sends emotion strings on.
                              // You can listen for these with other scripts worn by your chatbot,  and animate something to show how your chat bot is feeling.
                              // this is also sent on Link Message Number 1 to all scripts in your chatbox prim

// global variables
key  npcKey ;         // the NPC wearing this
string npcName;       // ditto
integer starttime;    // the time we started typing
key requestid;        // check for out HTTP answer
integer AvatarPresent;// true is someone is here

// first of stride is the response from the bot, the second is the built-in animation
list gAnimations = ["normal", "hello",
                    "happy","express_smile",
                    "angry","express_anger",
                    "averse","express_embarrased",
                    "sad","express_sad",
                    "evil","express_repulsed",
                    "fuming","express_worry",
                    "hurt","express_cry",
                    "surprised","express_surprise",
                    "insulted","express_afraid",
                    "confused","express_shrug",
                    "amused","express_laugh",
                    "asking","express_shrug"];
                    

list lAvatars; // a list of visitors for the script know whom to greet and who was already greeted.
list lGreeted; // a list ot visitors already greeted that may return.

DEBUG(string msg)
{
    if (debug) (0,msg);
}

string strReplace(string str, string search, string replace) {
    return llDumpList2String(llParseStringKeepNulls(str, [search], []), replace);
}

default
{
    
    on_rez(integer param)
    {
        llResetScript();
    }

    state_entry()
    {
        
        npcKey = llGetOwner();
        npcName = llKey2Name(npcKey);
        DEBUG("npc is named " + npcName);

        llListen(0,"","","");
        cps = wpm * 5 / 60;    // change from words per minute to cps.
        DEBUG("CPS = " + (string) cps);
        if (greeting)
            llSensorRepeat("","",AGENT,range,PI,repeat);
    }

    sensor(integer N) 
    {
        // This sesor detects avatars on the entire region. It's recommended to
        // place the NPC near a landing point. 
        list avis = llGetAgentList(AGENT_LIST_REGION, []);
        integer avisLen = llGetListLength(avis);
        integer i;
        list avsDetected = [];
        //osNpcSayTo(npcKey, ownerKey, PUBLIC_CHANNEL, "AvsDetected: "+avsDetected);
        for (i = 0 ; i < avisLen; i ++)
        {
            key avatarKey = llList2Key(avis, i);
            avsDetected += avatarKey;
            //osNpcSayTo(npcKey, ownerKey, PUBLIC_CHANNEL, "lAvatars now: "+lAvatars);
            //osNpcSayTo(npcKey, ownerKey, PUBLIC_CHANNEL, "lGreeted now: "+lGreeted);
            if (llListFindList(lAvatars,[avatarKey]) == -1 & !osIsNpc(avatarKey)) 
            {
                // The next command will be the first greet message for all avatars that come.
                // Edit it to fit your needs or your preferences.
                osNpcSay(npcKey,"Hi there, " + llKey2Name(avatarKey));
                lAvatars += avatarKey;
                lGreeted += 1;
                if (llGetListLength(lAvatars) > 100) 
                {
                    lAvatars = llDeleteSubList(lAvatars, 0,0);
                    lGreeted = llDeleteSubList(lGreeted, 0,0);
                }
            } else 
            {
                integer j;
                integer num = llGetListLength(lAvatars);
                for (j = 0 ; j < num; j ++)
                {
                    if (llList2String(lAvatars, j) == avatarKey & (integer)llList2String(lGreeted, j) == 2)
                    {
                        // The next command will be the greet if an avatar that was already greeted and gone away return.
                        // Edit it to fit your needs or your preferences.
                        osNpcSay(npcKey,"Hello again, " + llKey2Name(avatarKey));
                        lGreeted = llListReplaceList(lGreeted, [1], j, j);
                    }
                }
            }
        }
        integer num = llGetListLength(lAvatars);
        integer k;
        for (k = 0 ; k < num; k ++)
        {
            key avatarKey2 = llList2String(lAvatars, k);
            if (llListFindList(avsDetected,[avatarKey2]) == -1 & (integer)llList2String(lGreeted, k) == 1)
            {
                lGreeted = llListReplaceList(lGreeted, [0], k, k);
            }
            if ((integer) llList2String(lGreeted, k) == 0)
            {
                lGreeted = llListReplaceList(lGreeted, [2], k, k);
                // The next command is to ba said if someone is gone.
                // Comment the line if you don't want the NPS to say nothing.
                // Or edit the command to fit your needs or your preference.
                osNpcSay(npcKey,"Oh... " + llKey2Name(avatarKey2) + " is gone...");
            }
        }
    }
        

    no_sensor()
    {
        // If no one is present, everyone on the list that controls who was already greeted turns to 2.
        // This way, the NPC stays on a waiting mode. If someone that was already greeted returns,
        // the NPS says the "hello again" phrase and if someone new appears, the NPC will greet
        // normally.
        AvatarPresent = FALSE;
        integer h = llGetListLength(lGreeted);
        integer i;
        for (i = 0 ; i < h; i ++)
        {
            lGreeted = llListReplaceList(lGreeted, [2], i, i);
        }
    }

    listen(integer channel, string name, key id, string message)
    {
        if (! osIsNpc(id))
        {
            // if the speaker is a prim, it will have a creator. Avatars do not have a creator
            list what = llGetObjectDetails(id,[OBJECT_CREATOR,  OBJECT_POS]);
            key spkrKey = llList2Key(what,0);

            if (spkrKey != NULL_KEY && !debug)
            {
                if (! debug)
                    return;    // we do not want to listen to objects
            }
        
            list names = llParseString2List(name,[" "],[]);
            string firstname = llList2String(names,0);
            string lastname = llList2String(names,1);

            requestid = llHTTPRequest("http://www.personalityforge.com/api/chat"+ "?apiKey="         
                + llEscapeURL(apiKey)
                + "&message="        + llEscapeURL(message)
                + "&chatBotID="      + llEscapeURL(chatBotID)
                + "&externalID="     + llEscapeURL(firstname)
                + "&firstName="      + llEscapeURL(firstname)
                + "&lastName="       + llEscapeURL(lastname)
                ,[HTTP_METHOD,"GET"],"");

            llSleep(llFrand(3)+2);  // think for two to five seconds before we type  - for realism

            starttime = llGetUnixTime();
            vector vspeaker = llList2Vector(what,1);
            rotation rdelta = llRotBetween( llGetPos(), vspeaker );
                
            rotation   newRot  = rdelta * llGetRot();
            //-- rotate the offset to be relative to npc  rotation - vector now points to speaker
        
            osNpcSetRot(npcKey,newRot); // * = add for quats
        
            osNpcPlayAnimation(npcKey,"type");
            llSetTimerEvent(10);    // for safety in case web site is down.
        }
    }

    timer()
    {
        osNpcStopAnimation(npcKey,"type");
        llSetTimerEvent(0);
    }

    http_response(key request_id, integer status, list metadata, string body)
    {
        DEBUG(body);
        // typical body:
        // Checking origin: '71.252.253.290' (regex: '71\.252\.253\.290')<br>Matched!<br>{"success":1,"errorMessage":"","message":{"chatBotName":"Liddora","chatBotID":"754","message":"Look up. It's Liddora. So how have you been lately, hello?","emotion":"asking"}}
        
        if (request_id == requestid)
        {
            llSetTimerEvent(0);    // shut off the error handler

               // get the name of the bot from the reponse
            integer botname = llSubStringIndex(body,"chatBotName");
            string namestr = llGetSubString(body,botname,-1);
            integer botnameend = llSubStringIndex(namestr,"\",\"");
            
            string botName =  llGetSubString(namestr,14, botnameend-1);
            DEBUG("Bot Name:" + (string) botName);
    
            integer  begin = llSubStringIndex(body, "message\":\"");
            string msg =  llGetSubString(body, begin +10, -1);
            integer  msgend = llSubStringIndex(msg, "emotion");
            string reply = llGetSubString(msg, 0, msgend-4);
            DEBUG("reponse:" + reply);

            // change the name in the reply to the bots real name.
            DEBUG("reply:" + reply);
            DEBUG("botName:" + botName);
            DEBUG("npcName:" + npcName);
            

            reply = strReplace(reply,botName,npcName);
        
            DEBUG("after nameswap:" + reply);
            DEBUG("Len:" + llStringLength(reply));
            // calculate how long it would take for a person to type the answer in cps or wpm
            float delay = (float) llStringLength(reply) / cps;    
            delay -= llGetUnixTime() - starttime ;                // subtract how long it has taken to look up the bots answer since we started typing.
            if (delay > 0) {
                DEBUG("delay:" + (string) delay);
                llSleep(delay)    ;  // fake out the delay that happens when an avatar is typing an answer
            }
            
            
            // Emotion Logic - speak on a chat channel what emotional stste the bot is in, for other scripts to use.
            string emotion =  llGetSubString(msg, msgend,-1);
            DEBUG((string) emotion);
            
            msgend = llSubStringIndex(emotion, "\"}");            
            emotion =  llGetSubString(emotion, 10,msgend-1);          
            DEBUG("Emotion:" + (string) emotion);

            // sends a link animate to prim animator, attempts to play an animation
            // normal, happy, angry, averse, sad, evil, fuming,
            // hurt, surprised, insulted, confused, amused, asking.
            
            llMessageLinked(LINK_SET,1,emotion,"");

            //  and also chats it on channel "emotionchannel" for external gadgetry to respond with.
            llSay(emotionchannel,emotion);  // for controlling external gadgets based on emotes

            osNpcStopAnimation(npcKey,"type");

            // emotional state output

            // you can override the built-in emotion by adding an animation
            // with any of the following names to the inventory
            // normal, happy, angry, averse, sad, evil, fuming,
            // hurt, surprised, insulted, confused, amused, asking.
            
            if (llGetInventoryType(emotion) == INVENTORY_ANIMATION) {
                DEBUG("Playing animation from inventory named " + emotion);
                osNpcPlayAnimation(npcKey,emotion);
            } else {
                integer index = llListFindList(gAnimations,[emotion]);
                if (index != -1) {
                    string toPlay = llList2String(gAnimations,index + 1);
                    DEBUG("Playing built-in animation named " + toPlay);
                    osNpcPlayAnimation(npcKey,toPlay);
                }
            }            
            osNpcSay(npcKey,reply);    // now speak it.

        }
    }
}