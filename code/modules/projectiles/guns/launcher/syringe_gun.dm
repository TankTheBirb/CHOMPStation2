/obj/item/syringe_cartridge
	name = "syringe gun cartridge"
	desc = "An impact-triggered compressed gas cartridge that can be fitted to a syringe for rapid injection."
	icon = 'icons/obj/ammo.dmi'
	icon_state = "syringe-cartridge"
	var/icon_flight = "syringe-cartridge-flight" //so it doesn't look so weird when shot
	matter = list(MAT_STEEL = 125, MAT_GLASS = 375)
	slot_flags = SLOT_BELT | SLOT_EARS
	throwforce = 3
	force = 3
	w_class = ITEMSIZE_TINY
	var/obj/item/reagent_containers/syringe/syringe

/obj/item/syringe_cartridge/update_icon()
	underlays.Cut()
	if(syringe)
		underlays += image(syringe.icon, src, syringe.icon_state)
		underlays += syringe.filling

/obj/item/syringe_cartridge/attackby(obj/item/I, mob/user)
	if(istype(I, /obj/item/reagent_containers/syringe))
		syringe = I
		to_chat(user, span_notice("You carefully insert [syringe] into [src]."))
		user.remove_from_mob(syringe)
		syringe.loc = src
		sharp = TRUE
		name = "syringe dart"
		update_icon()

/obj/item/syringe_cartridge/attack_self(mob/user)
	if(syringe)
		to_chat(user, span_notice("You remove [syringe] from [src]."))
		playsound(src, 'sound/weapons/empty.ogg', 50, 1)
		user.put_in_hands(syringe)
		syringe = null
		sharp = initial(sharp)
		name = initial(name)
		update_icon()

/obj/item/syringe_cartridge/proc/prime()
	//the icon state will revert back when update_icon() is called from throw_impact()
	icon_state = icon_flight
	underlays.Cut()

/obj/item/syringe_cartridge/throw_impact(atom/hit_atom, var/speed)
	..() //handles embedding for us. Should have a decent chance if thrown fast enough
	if(syringe)
		//check speed to see if we hit hard enough to trigger the rapid injection
		//incidentally, this means syringe_cartridges can be used with the pneumatic launcher
		if(speed >= 10 && isliving(hit_atom))
			var/mob/living/L = hit_atom
			//unfortuately we don't know where the dart will actually hit, since that's done by the parent.
			if(L.can_inject() && syringe.reagents)
				var/contained = syringe.reagents.get_reagents()
				var/trans = syringe.reagents.trans_to_mob(L, 15, CHEM_BLOOD)
				add_attack_logs(thrower,L,"Shot with [src.name] containing [contained], trasferred [trans] units")

		syringe.break_syringe(iscarbon(hit_atom)? hit_atom : null)
		syringe.update_icon()

	icon_state = initial(icon_state) //reset icon state
	update_icon()

/obj/item/gun/launcher/syringe
	name = "syringe gun"
	desc = "A spring loaded rifle designed to fit syringes, designed to incapacitate unruly patients from a distance."
	icon_state = "syringegun"
	item_state = "syringegun"
	w_class = ITEMSIZE_NORMAL
	force = 7
	matter = list(MAT_STEEL = 2000)
	slot_flags = SLOT_BELT | SLOT_HOLSTER

	fire_sound = 'sound/weapons/empty.ogg'
	fire_sound_text = "a metallic thunk"
	recoil = 0
	release_force = 10
	throw_distance = 10

	var/list/darts = list()
	var/max_darts = 1
	var/obj/item/syringe_cartridge/next

/obj/item/gun/launcher/syringe/consume_next_projectile()
	if(next)
		next.prime()
		return next
	return null

/obj/item/gun/launcher/syringe/handle_post_fire()
	..()
	darts -= next
	next = null

/obj/item/gun/launcher/syringe/attack_self(mob/living/user as mob)
	if(next)
		user.visible_message("[user] unlatches and carefully relaxes the bolt on [src].", span_warning("You unlatch and carefully relax the bolt on [src], unloading the spring."))
		next = null
	else if(darts.len)
		playsound(src, 'sound/weapons/flipblade.ogg', 50, 1)
		user.visible_message("[user] draws back the bolt on [src], clicking it into place.", span_warning("You draw back the bolt on the [src], loading the spring!"))
		next = darts[1]
	add_fingerprint(user)

/obj/item/gun/launcher/syringe/attack_hand(mob/living/user as mob)
	if(user.get_inactive_hand() == src)
		if(!darts.len)
			to_chat(user, span_warning("[src] is empty."))
			return
		if(next)
			to_chat(user, span_warning("[src]'s cover is locked shut."))
			return
		var/obj/item/syringe_cartridge/C = darts[1]
		darts -= C
		user.put_in_hands(C)
		user.visible_message("[user] removes \a [C] from [src].", span_notice("You remove \a [C] from [src]."))
		playsound(src, 'sound/weapons/empty.ogg', 50, 1)
	else
		..()

/obj/item/gun/launcher/syringe/attackby(var/obj/item/A as obj, mob/user as mob)
	if(istype(A, /obj/item/syringe_cartridge))
		var/obj/item/syringe_cartridge/C = A
		if(darts.len >= max_darts)
			to_chat(user, span_warning("[src] is full!"))
			return
		user.remove_from_mob(C)
		C.loc = src
		darts += C //add to the end
		user.visible_message("[user] inserts \a [C] into [src].", span_notice("You insert \a [C] into [src]."))
	else
		..()

/obj/item/gun/launcher/syringe/rapid
	name = "syringe gun revolver"
	desc = "A modification of the syringe gun design, using a rotating cylinder to store up to five syringes. The spring still needs to be drawn between shots."
	icon_state = "rapidsyringegun"
	item_state = "rapidsyringegun"
	max_darts = 5
