# ExoRaidSetup
The mod basically allows a raid to share graphical representations of boss pulls and encounters using the 8 raid symbols in the Blizz raid UI, 2 additional icons, and up to 10 arrows for representing movement.

# Original creator
[BioQuark](https://wow.curseforge.com/addons/project-2885/)

# Showcase
![](http://imagehost.spark-media.ru/i4/FFAF321A-C5A1-C0B4-EE39-569F9CA4E0C4.png)

# Changelog
* Changed names for convenience			
* Changed additional icons and logo		
* Added High Quality Maps (by default) `13,1mb`			
* Added Low Quality Maps (if you RAM-pauper in 2k16) `3,7mb`		
* Added BWL, MC, ONY, AQ20, ZG, WorldBosses	
* Abolished Minimap integration when scrolling (very bugly with simpleMinimap and 0.64 scale), but you can still use for this: `/script ers_mmToggle()`		

Based on `ExoRaidSetup 1.34`

# Instalation
Put `ExoRaidSetup` folder to `World of Warcraft\Interface\AddOns`	
For lightweight maps version replace .tga files from `LowQualityMaps` to `World of Warcraft\Interface\AddOns\ExoRaidSetup\ERSart` folder

# Detailed description
`/ers` is the main command to bring up the mod; this will also bring up a help screen background which details the various methods of moving and naming symbols etc.		
`/ers nag` is an undocumented command which AFTER an 		
`/ers check` will send tells to all members of the raid with an outdated or missing version of ERS to upgrade to the current version.  
There are three "modes" for the mod:	

Single player: for players not in a raid to create, load, and edit setups and animations.	
Raid Leader: gives Raid officers/leaders full control over creation, sending, and editing setups and animations.	
Raid Member: a "locked" version of the mod intended for the raid members to recieve, load, and save setups and animations. There is also a "replay" feature of raid members to review recieved animation sequences.
		      
The setups can be "still shots"; or a series of frames which are viewed as a low FPS animation. The mod also has a Minimap mode that was still in development at the time of my leaving Exo, but which is still fully functional "as-is"; basically this sets the background image to the current minimap graphic for "on the fly" setups. Currently there are maps in the mod for all of AQ40 and Naxx, as these were the instances we were working on. The addition of boss rooms for other instances is possible; and I welcome anyone willing to do the work on the art for them because I am not. Controls are fairly self-explanatory; every button and feature has detailed tooltips to guide you in its use. 

I hope you find this mod useful it was both a joy and a pain to create :)
