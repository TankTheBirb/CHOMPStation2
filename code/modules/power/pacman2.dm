//This file was auto-corrected by findeclaration.exe on 29/05/2012 15:03:05


//PACMAN variant that can run on the small plasma tanks.
/obj/machinery/power/port_gen/pacman2
	name = "Pacman II"
	desc = "P.A.C.M.A.N. type II portable generator. Uses liquid phoron as a fuel source."
	power_gen = 4500
	circuit = /obj/item/circuitboard/pacman2
	var/obj/item/tank/phoron/P = null
	var/emagged = 0
	var/heat = 0
/*
	process()
		if(P)
			if(P.air_contents.phoron <= 0)
				P.air_contents.phoron = 0
				eject()
			else
				P.air_contents.phoron -= 0.001
		return
*/

	HasFuel()
		if(P.air_contents.phoron >= 0.1)
			return 1
		return 0

	UseFuel()
		P.air_contents.phoron -= 0.01
		return

	Initialize()
		. = ..()
		default_apply_parts()

	RefreshParts()
		var/temp_rating = 0
		for(var/obj/item/stock_parts/SP in component_parts)
			if(istype(SP, /obj/item/stock_parts/matter_bin))
				//max_coins = SP.rating * SP.rating * 1000
			else if(istype(SP, /obj/item/stock_parts/micro_laser) || istype(SP, /obj/item/stock_parts/capacitor))
				temp_rating += SP.rating
		power_gen = round(initial(power_gen) * (max(2, temp_rating) / 2))

	examine(mob/user)
		. = ..()
		. += span_notice("The generator has [P.air_contents.phoron] units of fuel left, producing [power_gen] per cycle.")

	handleInactive()
		heat -= 2
		if (heat < 0)
			heat = 0
		else
			for(var/mob/M in viewers(1, src))
				if (M.client && M.machine == src)
					src.updateUsrDialog(M)

	proc
		overheat()
			explosion(get_turf(src), 2, 5, 2, -1)

	attackby(var/obj/item/O as obj, var/mob/user as mob)
		if(istype(O, /obj/item/tank/phoron))
			if(P)
				to_chat(user, span_red("The generator already has a phoron tank loaded!"))
				return
			P = O
			user.drop_item()
			O.loc = src
			to_chat(user, span_blue("You add the phoron tank to the generator."))
		else if(!active)
			if(O.has_tool_quality(TOOL_WRENCH))
				anchored = !anchored
				playsound(src, 'sound/items/Deconstruct.ogg', 50, 1)
				if(anchored)
					to_chat(user, span_blue("You secure the generator to the floor."))
				else
					to_chat(user, span_blue("You unsecure the generator from the floor."))
				SSmachines.makepowernets()
			else if(O.has_tool_quality(TOOL_SCREWDRIVER))
				open = !open
				playsound(src, O.usesound, 50, 1)
				if(open)
					to_chat(user, span_blue("You open the access panel."))
				else
					to_chat(user, span_blue("You close the access panel."))
			else if(O.has_tool_quality(TOOL_CROWBAR) && !open)
				playsound(src, O.usesound, 50, 1)
				var/obj/machinery/constructable_frame/machine_frame/new_frame = new /obj/machinery/constructable_frame/machine_frame(src.loc)
				for(var/obj/item/I in component_parts)
					I.loc = src.loc
				new_frame.state = 2
				new_frame.icon_state = "box_1"
				qdel(src)

	attack_hand(mob/user as mob)
		..()
		if (!anchored)
			return

		interact(user)

	attack_ai(mob/user as mob)
		interact(user)

	proc
		interact(mob/user)
			if (get_dist(src, user) > 1 )
				if (!isAI(user))
					user.machine = null
					user << browse(null, "window=port_gen")
					return

			user.machine = src

			var/dat = text(span_bold("[name]") + "<br>")
			if (active)
				dat += text("Generator: <A href='byond://?src=\ref[src];action=disable'>On</A><br>")
			else
				dat += text("Generator: <A href='byond://?src=\ref[src];action=enable'>Off</A><br>")
			if(P)
				dat += text("Currently loaded phoron tank: [P.air_contents.phoron]<br>")
			else
				dat += text("No phoron tank currently loaded.<br>")
			dat += text("Power output: <A href='byond://?src=\ref[src];action=lower_power'>-</A> [power_gen * power_output] <A href='byond://?src=\ref[src];action=higher_power'>+</A><br>")
			dat += text("Heat: [heat]<br>")
			dat += "<br><A href='byond://?src=\ref[src];action=close'>Close</A>"
			user << browse("<html>[dat]</html>", "window=port_gen")

	Topic(href, href_list)
		if(..())
			return

		src.add_fingerprint(usr)
		if(href_list["action"])
			if(href_list["action"] == "enable")
				if(!active && HasFuel())
					active = 1
					icon_state = "portgen1"
					src.updateUsrDialog(usr)
			if(href_list["action"] == "disable")
				if (active)
					active = 0
					icon_state = "portgen0"
					src.updateUsrDialog(usr)
			if(href_list["action"] == "lower_power")
				if (power_output > 1)
					power_output--
					src.updateUsrDialog(usr)
			if (href_list["action"] == "higher_power")
				if (power_output < 4 || emagged)
					power_output++
					src.updateUsrDialog(usr)
			if (href_list["action"] == "close")
				usr << browse(null, "window=port_gen")
				usr.machine = null

/obj/machinery/power/port_gen/pacman2/emag_act(var/remaining_uses, var/mob/user)
	emagged = 1
	emp_act(1)
	return 1
