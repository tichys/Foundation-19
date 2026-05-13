// A set of constants used to determine which type of mute an admin wishes to apply.
#define MUTE_IC         (1<<0)
#define MUTE_OOC        (1<<1)
#define MUTE_PRAY       (1<<2)
#define MUTE_ADMINHELP  (1<<3)
#define MUTE_DEADCHAT   (1<<4)
#define MUTE_AOOC       (1<<5)
#define MUTE_MENTOR     (1<<6)
#define MUTE_ALL        (~0)

// Some constants for DB_Ban
#define BANTYPE_PERMA       1
#define BANTYPE_TEMP        2
#define BANTYPE_JOB_PERMA   3
#define BANTYPE_JOB_TEMP    4
#define BANTYPE_ANY_FULLBAN 5 // Used to locate stuff to unban.

#define ROUNDSTART_LOGOUT_REPORT_TIME 6000 // Amount of time (in deciseconds) after the rounds starts, that the player disconnect report is issued.

// Admin permissions.
#define R_BUILDMODE     (1<<0)
#define R_ADMIN         (1<<1)
#define R_BAN           (1<<2)
#define R_FUN           (1<<3)
#define R_SERVER        (1<<4)
#define R_DEBUG         (1<<5)
#define R_POSSESS       (1<<6)
#define R_PERMISSIONS   (1<<7)
#define R_STEALTH       (1<<8)
#define R_REJUVINATE    (1<<9)
#define R_VAREDIT       (1<<10)
#define R_SOUNDS        (1<<11)
#define R_SPAWN         (1<<12)
#define R_MOD           (1<<13)
#define R_MENTOR        (1<<14)
#define R_HOST          (1<<15)
#define R_TIMELOCK		(1<<16)

#define R_MAXPERMISSION (1<<16) // This holds the maximum value for a permission. It is used in iteration, so keep it updated.

#define ADDANTAG_PLAYER 1	// Any player may call the add antagonist vote.
#define ADDANTAG_ADMIN  2	// Any player with admin privilegies may call the add antagonist vote.

#define TICKET_CLOSED   0   // Ticket has been resolved or declined
#define TICKET_OPEN     1 // Ticket has been created, but not responded to
#define TICKET_ASSIGNED 2 // An admin has assigned themself to the ticket and will respond

#define LAST_CKEY(M) (M.ckey || M.last_ckey)
#define LAST_KEY(M)  (M.key || M.last_ckey)

///Max length of a keypress command before it's considered to be a forged packet/bogus command
#define MAX_KEYPRESS_COMMANDLENGTH 16
///Maximum keys that can be bound to one button
#define MAX_COMMANDS_PER_KEY 5
///Maximum keys per keybind
#define MAX_KEYS_PER_KEYBIND 3
///Length of held key buffer
#define HELD_KEY_BUFFER_LENGTH 15

#define ADMIN_QUE(user) "(<a href='byond://?_src_=holder;[HrefToken(forceGlobal = TRUE)];adminmoreinfo=[REF(user)]'>?</a>)"
#define ADMIN_FLW(user) "(<a href='byond://?_src_=holder;[HrefToken(forceGlobal = TRUE)];adminplayerobservefollow=[REF(user)]'>FLW</a>)"
#define ADMIN_PP(user) "(<a href='byond://?_src_=holder;[HrefToken(forceGlobal = TRUE)];adminplayeropts=[REF(user)]'>PP</a>)"
#define ADMIN_PM(user) "(<a href='byond://?_src_=holder;[HrefToken(forceGlobal = TRUE)];priv_msg=[REF(user)]'>PM</a>)"
#define ADMIN_VV(atom) "(<a href='byond://?_src_=vars;[HrefToken(forceGlobal = TRUE)];Vars=[REF(atom)]'>VV</a>)"
#define ADMIN_TP(user) "(<a href='byond://?_src_=holder;[HrefToken(forceGlobal = TRUE)];traitor=[REF(user)]'>TP</a>)"
#define ADMIN_SP(user) "(<a href='byond://?_src_=holder;[HrefToken(forceGlobal = TRUE)];skillpanel=[REF(user)]'>SP</a>)"
#define ADMIN_KICK(user) "(<a href='byond://?_src_=holder;[HrefToken(forceGlobal = TRUE)];boot2=[REF(user)]'>KICK</a>)"
#define ADMIN_NRRT(user) "(<a href='byond://?_src_=holder;[HrefToken(forceGlobal = TRUE)];narrateto=[REF(user)]'>NRRT</a>)"
#define ADMIN_CENTCOM_REPLY(user) "(<a href='byond://?_src_=holder;[HrefToken(forceGlobal = TRUE)];CentcommReply=[REF(user)]'>RPLY</a>)"
#define ADMIN_SC(user) "(<a href='byond://?_src_=holder;[HrefToken(forceGlobal = TRUE)];adminspawncookie=[REF(user)]'>SC</a>)"
#define ADMIN_SMITE(user) "(<a href='byond://?_src_=holder;[HrefToken(forceGlobal = TRUE)];adminsmite=[REF(user)]'>SMITE</a>)"
#define ADMIN_LOOKUP(user) "[key_name_admin(user)][ADMIN_QUE(user)]"
#define ADMIN_LOOKUPFLW(user) "[key_name_admin(user)][ADMIN_QUE(user)] [ADMIN_FLW(user)]"
#define ADMIN_SET_SD_CODE "(<a href='byond://?_src_=holder;[HrefToken(forceGlobal = TRUE)];set_selfdestruct_code=1'>SETCODE</a>)"
#define ADMIN_FULLMONTY_NONAME(user) "[ADMIN_PM(user)] [ADMIN_QUE(user)] [ADMIN_PP(user)] [ADMIN_VV(user)] [ADMIN_FLW(user)] [ADMIN_TP(user)] [ADMIN_SP(user)] [ADMIN_INDIVIDUALLOG(user)] [ADMIN_SMITE(user)]"
#define ADMIN_FULLMONTY(user) "[key_name_admin(user)] [ADMIN_FULLMONTY_NONAME(user)]"
#define ADMIN_JMP(src) "(<a href='byond://?_src_=holder;[HrefToken(forceGlobal = TRUE)];adminplayerobservecoodjump=1;X=[src.x];Y=[src.y];Z=[src.z]'>JMP</a>)"
#define COORD(src) "[src ? src.Admin_Coordinates_Readable() : "nonexistent location"]"
#define AREACOORD(src) "[src ? src.Admin_Coordinates_Readable(TRUE) : "nonexistent location"]"
#define ADMIN_COORDJMP(src) "[src ? src.Admin_Coordinates_Readable(FALSE, TRUE) : "nonexistent location"]"
#define ADMIN_VERBOSEJMP(src) "[src ? src.Admin_Coordinates_Readable(TRUE, TRUE) : "nonexistent location"]"
#define ADMIN_INDIVIDUALLOG(user) "(<a href='byond://?_src_=holder;[HrefToken(forceGlobal = TRUE)];individuallog=[REF(user)]'>LOGS</a>)"
#define ADMIN_TAG(datum) "(<A href='byond://?src=[REF(src)];[HrefToken(forceGlobal = TRUE)];tag_datum=[REF(datum)]'>TAG</a>)"

/atom/proc/Admin_Coordinates_Readable(area_name, admin_jump_ref)
	var/turf/T = Safe_COORD_Location()
	return T ? "[area_name ? "[get_area_name(T)] " : " "]([T.x],[T.y],[T.z])[admin_jump_ref ? " [ADMIN_JMP(T)]" : ""]" : "nonexistent location"

/atom/proc/Safe_COORD_Location()
	var/atom/A = drop_location()
	if(!A)
		return //not a valid atom.
	var/turf/T = get_step(A, 0) //resolve where the thing is.
	if(!T) //incase it's inside a valid drop container, inside another container. ie if a mech picked up a closet and has it inside it's internal storage.
		var/atom/last_try = A.loc?.drop_location() //one last try, otherwise fuck it.
		if(last_try)
			T = get_step(last_try, 0)
	return T

/turf/Safe_COORD_Location()
	return src
