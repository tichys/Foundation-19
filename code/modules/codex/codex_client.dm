#define MAX_CODEX_SEARCH_ENTRIES 10

/client/verb/search_codex(searching as text)

	set name = "Search Codex"
	set category = "OOC"
	set src = usr

	if(!mob || !SScodex)
		return

	if(!searching)
		searching = input("Enter a search string.", "Codex Search") as text|null
		if(!searching)
			return

	var/list/all_entries = SScodex.retrieve_entries_for_string(searching)
	all_entries = all_entries.Copy() // So we aren't messing with the codex search cache.

	//Put entries with match in the name first
	for(var/datum/codex_entry/entry in all_entries)
		if(findtext(entry.display_name, searching))
			all_entries -= entry
			all_entries.Insert(1, entry)

	if(LAZYLEN(all_entries) == 1)
		SScodex.present_codex_entry(mob, all_entries[1])
	else
		if(LAZYLEN(all_entries) > 1)
			var/list/codex_data = list("<h3><b>[all_entries.len] matches</b> for '[searching]':</h3>")
			if(LAZYLEN(all_entries) > MAX_CODEX_SEARCH_ENTRIES)
				codex_data += "Showing first <b>[MAX_CODEX_SEARCH_ENTRIES]</b> entries. <b>[all_entries.len - MAX_CODEX_SEARCH_ENTRIES] result\s</b> omitted.</br>"
			codex_data += "<table width = 100%>"
			for(var/i = 1 to min(all_entries.len, MAX_CODEX_SEARCH_ENTRIES))
				var/datum/codex_entry/entry = all_entries[i]
				codex_data += "<tr><td>[entry.display_name]</td><td><a href='byond://?src=\ref[SScodex];show_examined_info=\ref[entry];show_to=\ref[mob]'>View</a></td></tr>"
			codex_data += "</table>"
			var/datum/browser/popup = new(mob, "codex-search", "Codex Search")
			popup.set_content(jointext(codex_data, null))
			popup.open()
		else
			to_chat(src, SPAN_NOTICE("The codex reports <b>no matches</b> for '[searching]'."))

/client/verb/codex()
	set name = "Codex"
	set category = "OOC"
	set src = usr

	if(!mob || !SScodex)
		return

	var/datum/codex_entry/entry = SScodex.get_codex_entry("codex")
	SScodex.present_codex_entry(mob, entry)

/client/proc/codex_topic(href, href_list)
	if(href_list["codex_search"]) //nano throwing errors
		search_codex()
		return TRUE

#undef MAX_CODEX_SEARCH_ENTRIES
