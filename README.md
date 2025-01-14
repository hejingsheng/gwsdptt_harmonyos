# GWSD Open PTT Base HarmonyOS
Gwsd Open PTT support message,audio call, ptt call

## Login account description
1.invoke web api Create an account, select a package, and create a group. Bind an account to a group

## Package description
The package type corresponds to the fgrp parameter in the web api interface for creating an account

frgp|Set|Functions
----|---|--------
34|Set A|basic intercom + positioning
43|Set B|Basic intercom + location + message + full-duplex voice
33|Set C|Basic intercom + positioning + messaging + full-duplex voice + video call

## Matters needing attention
1. Full-duplex voice calls require an account with full-duplex rights. Select Package B or C when creating an account
2. Message chat requires an account to have message rights, please select package B or C when creating an account.
3. video call requires the account to have video call rights, select package C when creating an account

If you need to use the GWSD platform intercom server, message server, scheduling server, video server, upload file address do not need to change the demo
Contact O&M for private deployment
