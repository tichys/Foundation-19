#define DEBUG
// Turf-only flags.
#define TURF_FLAG_NOJAUNT 1 // This is used in literally one place, turf.dm, to block ethereal jaunt.
#define TURF_FLAG_NORUINS 2

#define TRANSITIONEDGE 		7 // Distance from edge to move to another z-level.
#define RUIN_MAP_EDGE_PAD 	15

// Invisibility constants.
#define INVISIBILITY_HUNTER      	10 //SCP Edit: This is a special level for 966, so it can be seen by Night Vision and Infrared Goggles.
#define INVISIBILITY_LIGHTING    	20
#define INVISIBILITY_LEVEL_ONE   	35
#define INVISIBILITY_LEVEL_TWO   	45
#define INVISIBILITY_EYE_AI         59
#define INVISIBILITY_OBSERVER    	60
#define INVISIBILITY_EYE         	61
#define INVISIBILITY_SYSTEM      	99
#define INVISIBILITY_ABSTRACT  		101	// special: this can never be seen, regardless of see_invisible

#define SEE_INVISIBLE_LIVING     25
#define SEE_INVISIBLE_NOLIGHTING 15
#define SEE_INVISIBLE_LEVEL_ONE  INVISIBILITY_LEVEL_ONE
#define SEE_INVISIBLE_LEVEL_TWO  INVISIBILITY_LEVEL_TWO
#define SEE_INVISIBLE_AI         INVISIBILITY_EYE_AI
#define SEE_INVISIBLE_CULT       INVISIBILITY_OBSERVER
#define SEE_INVISIBLE_OBSERVER   INVISIBILITY_EYE
#define SEE_INVISIBLE_SYSTEM     INVISIBILITY_SYSTEM

#define SEE_IN_DARK_DEFAULT 2

#define SEE_INVISIBLE_MINIMUM 	5
#define INVISIBILITY_MAXIMUM 	100

// Some arbitrary defines to be used by self-pruning global lists. (see master_controller)
#define PROCESS_KILL 26 // Used to trigger removal from a processing list.

// For secHUDs and medHUDs and variants. The number is the location of the image on the list hud_list of humans.
#define	HEALTH_HUD 		1 // A simple line rounding the mob's number health.
#define	STATUS_HUD 		2 // Alive, dead, diseased, etc.
#define ID_HUD 			3 // The job asigned to your ID.
#define	WANTED_HUD 		4 // Wanted, released, paroled, security status.
#define	IMPLOYAL_HUD 	5 // Loyality implant.
#define IMPCHEM_HUD 	6 // Chemical implant.
#define	IMPTRACK_HUD 	7 // Tracking implant.
#define SPECIALROLE_HUD 8 // AntagHUD image.
#define STATUS_HUD_OOC 	9 // STATUS_HUD without virus DB check for someone being ill.
#define LIFE_HUD 		10 // STATUS_HUD that only reports dead or alive
#define BLINK_HUD       11 // A line representing the blink time remaining on a mob.
#define PESTILENCE_HUD  12 // A visual indicator of the pestilence for SCP-049.

// Shuttle moving status.
#define SHUTTLE_IDLE      0
#define SHUTTLE_WARMUP    1
#define SHUTTLE_INTRANSIT 2

// Autodock shuttle processing status.
#define IDLE_STATE   0
#define WAIT_LAUNCH  1
#define FORCE_LAUNCH 2
#define WAIT_ARRIVE  3
#define WAIT_FINISH  4

// Setting this much higher than 1024 could allow spammers to DOS the server easily.
#define MAX_MESSAGE_LEN       	1024
#define MAX_PAPER_MESSAGE_LEN 	6144
#define MAX_BOOK_MESSAGE_LEN  	18432
#define MAX_LNAME_LEN         	64
#define MAX_NAME_LEN          	26
#define MAX_DESC_LEN          	128
#define MAX_TEXTFILE_LENGTH 	128000		// 512GQ file

// Event defines.
#define EVENT_LEVEL_MUNDANE  1
#define EVENT_LEVEL_MODERATE 2
#define EVENT_LEVEL_MAJOR    3

//General-purpose life speed define for plants.
#define HYDRO_SPEED_MULTIPLIER 1

#define DEFAULT_JOB_TYPE /datum/job/classd

//Area flags, possibly more to come
#define AREA_FLAG_RAD_SHIELDED      	(1<<0)  // shielded from radiation, clearly
#define AREA_FLAG_EXTERNAL          	(1<<1)  // External as in exposed to space, not outside in a nice, green, forest
#define AREA_FLAG_ION_SHIELDED      	(1<<2)  // shielded from ionospheric anomalies as an FBP / IPC
#define AREA_FLAG_IS_NOT_PERSISTENT 	(1<<3)  // SSpersistence will not track values from this area.
#define AREA_FLAG_NO_MODIFY         	(1<<4) // turf in this area cannot be dismantled.
#define AREA_FLAG_HIDE_FROM_HOLOMAP 	(1<<5) // if we shouldn't be drawn on station holomaps

//Map template flags
#define TEMPLATE_FLAG_ALLOW_DUPLICATES 	(1<<0) // Lets multiple copies of the template to be spawned
#define TEMPLATE_FLAG_SPAWN_GUARANTEED 	(1<<1) // Makes it ignore away site budget and just spawn (only for away sites)
#define TEMPLATE_FLAG_CLEAR_CONTENTS   	(1<<2) // if it should destroy objects it spawns on top of
#define TEMPLATE_FLAG_NO_RUINS         	(1<<3) // if it should forbid ruins from spawning on top of it
#define TEMPLATE_FLAG_NO_RADS          	(1<<4)// Removes all radiation from the template after spawning.

//Ruin map template flags
#define TEMPLATE_FLAG_RUIN_STARTS_DISALLOWED 32 // Ruin is not available during spawning unless another ruin permits it.

#define WALL_CAN_OPEN 1
#define WALL_OPENING 2

#define BOMBCAP_DVSTN_RADIUS (config.max_explosion_range / 4)
#define BOMBCAP_HEAVY_RADIUS (config.max_explosion_range / 2)
#define BOMBCAP_LIGHT_RADIUS (config.max_explosion_range)
#define BOMBCAP_FLASH_RADIUS (config.max_explosion_range * 1.5)

// Special return values from bullet_act(). Positive return values are already used to indicate the blocked level of the projectile.
#define PROJECTILE_CONTINUE   -1 //if the projectile should continue flying after calling bullet_act()
#define PROJECTILE_FORCE_MISS -2 //if the projectile should treat the attack as a miss (suppresses attack and admin logs) - only applies to mobs.

//Camera capture modes
#define CAPTURE_MODE_REGULAR 	0 //Regular polaroid camera mode
#define CAPTURE_MODE_ALL 		1 //Admin camera mode
#define CAPTURE_MODE_PARTIAL 	3 //Simular to regular mode, but does not do dummy check

//objectives
#define CONFIG_OBJECTIVE_NONE 2
#define CONFIG_OBJECTIVE_VERB 1
#define CONFIG_OBJECTIVE_ALL  0

// How many times an AI tries to connect to APC before switching to low power mode.
#define AI_POWER_RESTORE_MAX_ATTEMPTS 3

// AI power restoration routine steps.
#define AI_RESTOREPOWER_FAILED 		-1
#define AI_RESTOREPOWER_IDLE 		0
#define AI_RESTOREPOWER_STARTING 	1
#define AI_RESTOREPOWER_DIAGNOSTICS 2
#define AI_RESTOREPOWER_CONNECTING 	3
#define AI_RESTOREPOWER_CONNECTED 	4
#define AI_RESTOREPOWER_COMPLETED 	5

// AI button defines
#define AI_BUTTON_PROC_BELONGS_TO_CALLER 	1
#define AI_BUTTON_INPUT_REQUIRES_SELECTION 2

// Values represented as Oxyloss. Can be tweaked, but make sure to use integers only.
#define AI_POWERUSAGE_LOWPOWER 		1
#define AI_POWERUSAGE_RESTORATION 	2
#define AI_POWERUSAGE_NORMAL 		5
#define AI_POWERUSAGE_RECHARGING 	7

// Above values get multiplied by this when converting AI oxyloss -> watts.
// For now, one oxyloss point equals 10kJ of energy, so normal AI uses 5 oxyloss per tick (50kW or 70kW if charging)
#define AI_POWERUSAGE_OXYLOSS_TO_WATTS_MULTIPLIER 10000

//Grid for Item Placement
#define CELLS 		8								//Amount of cells per row/column in grid
#define CELLSIZE 	(world.icon_size/CELLS)	//Size of a cell in pixels

#define PIXEL_MULTIPLIER WORLD_ICON_SIZE/32

#define DEFAULT_SPAWNPOINT_ID "Default"

//Error handler defines
#define ERROR_USEFUL_LEN 2

#define RAD_LEVEL_LOW 		1 // Around the level at which radiation starts to become harmful
#define RAD_LEVEL_MODERATE 	25
#define RAD_LEVEL_HIGH 		40
#define RAD_LEVEL_VERY_HIGH 100

#define RADIATION_THRESHOLD_CUTOFF 0.1	// Radiation will not affect a tile when below this value.

#define LEGACY_RECORD_STRUCTURE(X, Y) GLOBAL_LIST_EMPTY(##X);/datum/computer_file/data/##Y/var/list/fields[0];/datum/computer_file/data/##Y/New(){..();GLOB.##X.Add(src);}/datum/computer_file/data/##Y/Destroy(){. = ..();GLOB.##X.Remove(src);}

#define SUPPLY_SECURITY_ELEVATED 	1
#define SUPPLY_SECURITY_HIGH 		2

// secure gun authorization settings
#define UNAUTHORIZED      0
#define AUTHORIZED        1
#define ALWAYS_AUTHORIZED 2

// wrinkle states for clothes
#define WRINKLES_DEFAULT	0
#define WRINKLES_WRINKLY	1
#define WRINKLES_NONE		2

//detergent states for clothes
#define SMELL_DEFAULT	0
#define SMELL_CLEAN		1
#define SMELL_STINKY	2

//Shuttle mission stages
#define SHUTTLE_MISSION_PLANNED  1
#define SHUTTLE_MISSION_STARTED  2
#define SHUTTLE_MISSION_FINISHED 3
#define SHUTTLE_MISSION_QUEUED   4

//Stats for department goals etc
#define STAT_XENOPLANTS_SCANNED  "xenoplants_scanned"
#define STAT_XENOFAUNA_SCANNED  "xenofauna_scanned"
#define STAT_FLAGS_PLANTED  "planet_flags"

//Number of slots a modular computer has which can be tweaked via gear tweaks.
#define TWEAKABLE_COMPUTER_PART_SLOTS 7

//Lying animation
#define ANIM_LYING_TIME 2

//Planet habitability class
#define HABITABILITY_IDEAL  1
#define HABITABILITY_OKAY  	2
#define HABITABILITY_BAD  	3

#ifndef WINDOWS_HTTP_POST_DLL_LOCATION
#define WINDOWS_HTTP_POST_DLL_LOCATION "lib/byhttp.dll"
#endif

#ifndef UNIX_HTTP_POST_DLL_LOCATION
#define UNIX_HTTP_POST_DLL_LOCATION "lib/libbyhttp.so"
#endif

#ifndef HTTP_POST_DLL_LOCATION
#define HTTP_POST_DLL_LOCATION (world.system_type == MS_WINDOWS ? WINDOWS_HTTP_POST_DLL_LOCATION : UNIX_HTTP_POST_DLL_LOCATION)
#endif

//Misc text define. Does 4 spaces. Used as a makeshift tabulator.
#define FOURSPACES "&nbsp;&nbsp;&nbsp;&nbsp;"
#define CLIENT_FROM_VAR(I) (ismob(I) ? I:client : (isclient(I) ? I : (istype(I, /datum/mind) ? I:current?:client : null)))

#define INCREMENT_WORLD_Z_SIZE world.maxz++; if (SSzcopy.zlev_maximums.len) { SSzcopy.calculate_zstack_limits() }

//Semantic; usage intent of variable
#define EMPTY_BITFIELD 0

//-- Masks for /atom/var/init_flags --
//- machinery
#define INIT_MACHINERY_PROCESS_SELF 		(1<<0)
#define INIT_MACHINERY_PROCESS_COMPONENTS 	(1<<1)
#define INIT_MACHINERY_PROCESS_ALL 			(INIT_MACHINERY_PROCESS_SELF | INIT_MACHINERY_PROCESS_COMPONENTS)
//--


// Helper procs for easy HTML browser button creation.
#define UIBUTTON(key, label, title) "[title ? title + ": " : ""]<a href='byond://?src=\ref[src];[key]=1'>[label]</a>"

#define UI_FONT_GOOD(X) FONT_COLORED("55cc55","[X]")
#define UI_FONT_BAD(X) FONT_COLORED("cc5555","[X]")

// Whereas ckey is in the global list or not
#define IS_TRUSTED_PLAYER(ckey) (ckey in GLOB.trusted_players)

//NOTE: INTENT_HOTKEY_* defines are not actual intents!
//they are here to support hotkeys
#define INTENT_HOTKEY_LEFT  "left"
#define INTENT_HOTKEY_RIGHT "right"

//for obj explosion block calculation
#define EXPLOSION_BLOCK_PROC -1

// Returned by emag_act if object didn't do anything
#define EMAG_NO_ACT -50

/* Ticker subsystem cross-comms news report */
// The higher numbers are basically more impactful and will override lower ones
#define FACILITY_EVACUATED 1
#define FACILITY_DESTROYED_NUKE 2
#define FACILITY_DESTROYED_SELF_DESTRUCT 3
