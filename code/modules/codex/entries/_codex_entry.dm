/datum/codex_entry
	var/display_name
	var/list/associated_strings
	var/list/associated_paths
	var/entry_text

/datum/codex_entry/dd_SortValue()
	return display_name

/datum/codex_entry/proc/update_links()
	return

/datum/codex_entry/New(_display_name, list/_associated_paths, list/_associated_strings, _entry_text)

	if(_display_name)       display_name =       _display_name
	if(_associated_paths)   associated_paths =   _associated_paths
	if(_associated_strings) associated_strings = _associated_strings
	if(_entry_text)     entry_text =     _entry_text

	if(associated_paths && associated_paths.len)
		for(var/tpath in associated_paths)
			var/atom/thing = tpath
			LAZYADD(associated_strings, sanitize(lowertext(initial(thing.name))))
	if(display_name)
		LAZYADD(associated_strings, display_name)
	else if(associated_strings && associated_strings.len)
		display_name = associated_strings[1]
	..()

/datum/codex_entry/proc/get_header(mob/presenting_to)
	var/list/dat = list()
	var/datum/codex_entry/linked_entry = SScodex.get_codex_entry("codex")
	dat += "<a href='byond://?src=\ref[SScodex];show_examined_info=\ref[linked_entry];show_to=\ref[presenting_to]'>Home</a>"
	dat += "<a href='byond://?src=\ref[presenting_to.client];codex_search=1'>Search Codex</a>"
	dat += "<hr><h2>[display_name]</h2>"
	return jointext(dat, null)

/datum/codex_entry/proc/get_text(mob/presenting_to)
	var/list/dat = list(get_header(presenting_to))
	if(entry_text)
		dat += entry_text
	return jointext(dat, null)
