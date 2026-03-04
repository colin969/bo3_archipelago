# Black Ops 3 - Zombies Archipelago

## Setup Instructions
1. Make sure you've downgraded otherwise this mod will not work, see Downgrade Instructions below
2. Download `BO3APMod.zip` from Releases
3. Unpack it into the `/mods` folder inside your Black Ops 3 game folder. E.G `Call of Duty Black Ops III/mods/bo3_archipelago`. You may need to create the mods folder.
4. Install `cod-bo3.apworld` from Releases
5. Generate a yaml via the Options Builder in the Archipelago launcher
5. Generate and host a game with Archipelago per normal

## Downgrade Instructions
1. Open `steam://open/console` in your browser to open Steam's console
2. Run `download_depot 311210 311211 9084453472036406216` and wait for it to finish
3. Go to the folder it says it downloaded to, and copy the game executable into your main game folder
![Downgrade Instructions Visual](/assets/DowngradeInstructions.png)

## Usage Instructions
1. Load the mod in the mod menu
2. Use the Archipelago Menu to enter your server name and slot name
3. Validate your connection. If you see 'end of file' it may be taking too long to connect, but try starting a game anyway.
4. Start your game
![image1.png](/assets/image1.png)
![image2.png](/assets/image2.png)

# Features

**Supported Maps:**
- Shadows of Evil
- The Giant
- Der Eisendrache
- Zetsubou No Shima
- Gorod Krovi
- Revelations

**Fancy notifications in the top left when you send checks or receive items**

**Map QoL Changes:**
- Shadows of Evil EE supported with any number of players. Rails will remain electrified indefinitely if there are less than 4 players.
- Zetsubou No Shima will always have Anywhere but Here in the Host's 5th slot if they don't have it equipped already
- Revelations menu button to reset the summoning key when it gets stuck out of bounds

**Randomized Weapon Attachments:**
- Can be disabled
- Supported on most weapons
- Rolled attachments stay the same for the whole AP seed
- Configurable percentage chance of a gun having a 'large' scope (e.g Acog or Infra-Red)

**Gifts and Traps:**
- Weighted and evenly distributed replacement of filler items
- Gifts:
  - All powerups except for Nuke
  - Free perk powerup, this can exceed perk limit
  - 2 minutes of unlimited sprint
- Traps:
  - 30 seconds of third person mode
  - Nuke powerup
  - Spawn grenades at all players feet
  - Immediate and simultaneous knuckle cracking

**DeathLink:**
- Configurable to send:
  - Any Player Downed, Any Player Dies, Game Ends
- Configurable to receive:
  - Down Any Player, Kill Any Player, Game Ends

**Archipelago Items:**
- Map Unlocks:
  - Start with a number of maps unlocked and earn more from AP items. **Important if you want better AP logic**
  - To guarantee a map is in your starting maps selection, add the Map Unlock item to your Starting Inventory
  - All locked maps will be hinted for free when the AP starts
- Progressive Perk Limits:
  - Configurable modifier to default perk limit
  - Configurable number of Progressive perk limit items to increase number of perks you can have
  - Default: Start at 2 with 4 more in the itempool (6 max)
- Perk Machines (universal or map specific):
  - Cannot buy from the perk machine until item received
  - Wunderfizz will only give unlocked perks
  - Wunderfizz now costs 2000 points
- Progressive Pack-A-Punch Machine:
  - 2x in the itempool. First unlocks PaP, Second unlocks AATs / Repacking
- Special Box Weapons (map specific): **Important if you want better AP logic**
  - Wonder Weapons (Apothicon Servant, Raygun Mark 3 etc)
  - Specialist Weapons (Ragnarok DG-4s)
  - Special Grenades (Monkey Bombs and Li'l Arnies)
- Regular Box Weapons (universal): **Important if you want better AP logic**
  - Most weapons will not be available until found:
    - FFAR, Man-o-War, HVK-30, ICR-1
    - Drakon, Locus
    - Haymaker 12, 205 Brecci
    - RPK, Dingo, 48 Dredge
    - Vesper, VMP
- Wallbuys (universal or map specific)
- Shuffled shield parts seperately from other craftables
- Shuffled pieces of a craftable:
  - KT-4, Masamune, Keepers Protector are not craftables, support will come later
- 200 point filler items

**Archipelago Locations:**
- Configurable Round locations
  - Maximum round with a check and frequency of rounds, E.G Every 3 rounds until round 15 will give a check on rounds 3, 6, 9, 12 and 15
- Main Quest steps for all maps
- Configurable *(when not required for goal)* Main Easter Egg steps for all maps
- Partial Side Easter Egg steps for all maps
- Configurable Music Easter Eggs
- Configurable number of bows which have checks for Der Eisendrache
- Repair 5 Windows
- Universal Tracker support and basic in-game location viewer
  - In-game location viewer will only filter out disabled Der Eisendrache bows which do not have checks

**Archipelago Victory Conditions:**
- Easter Egg Hunt:
  - Complete X easter eggs across any of the enabled maps
- Weapon Quest:
  - Complete all weapon quests / upgrades across all enabled maps
- Goal Round:
  - Reach round X on all enabled maps

**Save and Restore:**
- Allows saving of map progress so you can leave and play another map whenever you want
- Data saved at the start of each round, and whenever the host exits via End Game
- Data cleared if the game ends without the host doing it via End Game
- Scoreboard stats (kills, headshots, revives and downs) are persistant across all maps in the seed
- Player support: **Make sure all players are in the game when you save**
  - Weapons with their stock and ammo counts
  - Perks
  - Specialist Weapons and their current charge meter
  - Points / Score
  - Player specific map challenges completed and collected
- General Map Support:
  - Each opened door or cleared debris
  - Power on
  - Current Round
  - Remaining zombies
  - Number of next special round
- Limited Map State Support:
  - Shadows of Evil 
    - Each completed main quest ritual excluding PaP
  - The Giant 
    - Number of linked teleporters / PaP opened
- Significant Map State Support:
  - Der Eisendrache
    - Each corruption engines finished, each easter egg step completed
  - Gorod Krovi
    - Each easter egg step completed, each dragon gauntlet step, each of the 3 unlocked side ee equips
  - Revelations
    - Each easter egg step completed

**Configurable Difficulty Adjustment - Checkpoints:**
- Saves a checkpoint after specific easter egg steps or every X rounds.
- If you end the game by dying, the next time you load the map you will resume at the last checkpointed save

**Configurable Difficulty Adjustment - Map Specifics:**
- Gorod Krovi - Dragon Egg instantly cools down after being bathed in flame or incubated
- Gorod Krovi - Dragon Wings immediately available

## Debug Commands (use tilde to open console in-game)
- `/ap_trigger_item <item>` - Force trigger an AP item
- `/ap_send_location <location>` - Force send an AP location
- `/ap_gum 1` - Give all players a random gobblegum
- `/ap_godmode <1/0>` - Enables or disables godmode on host player
- `/ap_testkit 1` - Awards 50000 points, all perks and unlimited sprint to host player
- `/ap_sv_cheats on` - Enables cheat commands like noclip
- `/ap_debug_craftables 1` - Print craftables with their names and piece stub names
- `/ap_debug_magicbox 1` - Prints a csv with the weapon data for the map into the mod folder
- `/ap_grand_tour 1` - Starts the grand tour (summoning key step) on Revelations early
- `/ap_set_flag <flag>` - Sets a level flag
- `/ap_get_flag <flag>` - Prints a level flag
- `/ap_set_player_flag <flag>` - Sets host player flag

## Other Useful Links

- AP World: https://github.com/colin969/Call-of-Duty-BO3-Zombies-Archipelago
- BO3 Mod: https://github.com/colin969/bo3_archipelago
- BO3 APClient DLL: https://github.com/colin969/Archi-T7Overcharged
  
## Development Setup
1. Clone to `Call of Duty Black Ops III\mods\bo3_archipelago`
2. Install L3akMod from https://wiki.modme.co/wiki/black_ops_3/lua_(lui)/Installation.html
3. Install T7MTEnhancements from https://github.com/Scobalula/T7MTEnhancements
3. Open Black Ops III - Mod Tools
4. Tick `core_mod` and `zm_mod` under `bo3_archipelago` on the left side, `Compile` and `Link` on the right side, and `Run` if you want to test
5. Press `Build`

## Special Thanks
T7 Overcharged https://github.com/JariKCoding/T7Overcharged, which I heavily mangled to run the AP Code
APClientPP - Used to implement the Archipelago Networking Protocol

The Black Ops 3 Modding Discord, especially Serious for answering all my beginner questions

The D3V Team (DTZxPorter, SE2Dev, Nukem) for mod tools, examples and more
Scobalula's Excellent re-creation of the Lobby Menu, as seen in the BO3Mutators project

## Notes
`dkjson` used for json parsing in lua, it has the global var stripped out

## Attribution
Archipelago Logo is © 2022 by Krista Corkos and Christopher Wilson is licensed under Attribution-NonCommercial 4.0 International. To view a copy of this license, visit http://creativecommons.org/licenses/by-nc/4.0/
