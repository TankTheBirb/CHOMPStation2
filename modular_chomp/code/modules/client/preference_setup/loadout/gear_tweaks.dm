var/datum/gear_tweak/item_tf_spawn/gear_tweak_item_tf_spawn = new()

/datum/gear_tweak/item_tf_spawn

/datum/gear_tweak/item_tf_spawn/get_contents(var/metadata)
	if(!islist(metadata) || metadata["state"] == "Not Enabled")
		return "Item TF spawnpoint: Not Enabled"
	else if(metadata["state"] == "Anyone")
		return "Item TF spawnpoint: Enabled"
	else
		return "Item TF spawnpoint: Only ckeys [english_list(metadata["valid"], and_text = ", ")]"

/datum/gear_tweak/item_tf_spawn/get_default()
	. = list()
	.["state"] = "Not Enabled"
	.["valid"] = list()

/datum/gear_tweak/item_tf_spawn/get_metadata(var/user, var/list/metadata)
	. = get_default()
	metadata = islist(metadata) ? metadata : .
	var/entry = tgui_input_list(user, "Choose an entry.", "Character Preference", list("Not Enabled", "Anyone", "Only Specific Players"), metadata["state"])
	if(entry)
		.["state"] = entry
		if(entry == "Only Specific Players")
			var/ckey_input = tgui_input_text(user, "Input ckeys allowed to join on separate lines", "Allowed Players", jointext(metadata["valid"], "\n"), multiline = TRUE)
			.["valid"] = splittext(lowertext(ckey_input), "\n")
		else
			.["valid"] = metadata["valid"]
	else
		return metadata

/datum/gear_tweak/item_tf_spawn/tweak_item(var/obj/item/I, var/metadata)
	if(!islist(metadata))
		return
	if(metadata["state"] == "Not Enabled")
		return
	else if(metadata["state"] == "Anyone")
		I.item_tf_spawnpoint_set()
	else if(metadata["state"] == "Only Specific Players")
		I.item_tf_spawnpoint_set()
		I.ckeys_allowed_itemspawn = metadata["valid"]

/datum/gear_tweak/simplemob_picker
	var/list/simplemob_list

/datum/gear_tweak/simplemob_picker/New(var/list/valid_simplemobs)
	src.simplemob_list = valid_simplemobs
	..()

/datum/gear_tweak/simplemob_picker/get_contents(var/metadata)
	return "Type: [metadata]"

/datum/gear_tweak/simplemob_picker/get_default()
	return simplemob_list[1]

/datum/gear_tweak/simplemob_picker/get_metadata(var/user, var/metadata)
	return tgui_input_list(user, "Choose a type.", "Character Preference", simplemob_list, metadata)

/datum/gear_tweak/simplemob_picker/tweak_item(var/obj/item/capture_crystal/I, var/metadata)
	if(!(metadata in simplemob_list))
		return
	if(!istype(I))
		return
	I.spawn_mob_type = simplemob_list[metadata]
	I.spawn_mob_name = metadata

GLOBAL_DATUM_INIT(gear_tweak_free_matrix_recolor, /datum/gear_tweak/matrix_recolor, new)

/datum/gear_tweak/matrix_recolor

/datum/gear_tweak/matrix_recolor/get_contents(var/metadata)
	if(islist(metadata) && length(metadata))
		return "Matrix Recolor: [english_list(metadata)]"
	return "Matrix Recolor"

/datum/gear_tweak/matrix_recolor/get_default()
	return null

/datum/gear_tweak/matrix_recolor/get_metadata(user, metadata)
	var/list/returned = color_matrix_picker(user, "Pick a color matrix for this item", "Matrix Recolor", "Ok", "Erase", "Cancel", TRUE, 10 MINUTES, islist(metadata) && metadata)
	var/list/L = returned["matrix"]
	if(returned["button"] == 3)
		return metadata
	if((returned["button"] == 2) || !islist(L) || !ISINRANGE(L.len, 9, 20))
		return list()
	var/identity = TRUE
	var/static/list/ones = list(1, 5, 9)
	for(var/i in 1 to L.len)
		if(L[i] != ((i in ones)? 1 : 0))
			identity = FALSE
			break
	return identity? list() : L

/datum/gear_tweak/matrix_recolor/tweak_item(obj/item/I, metadata)
	. = ..()
	if(!islist(metadata) || (length(metadata) < 12))
		return
	if(istype(I))
		I.add_atom_colour(metadata, FIXED_COLOUR_PRIORITY)
	else
		I.color = metadata		// fuck off underwear