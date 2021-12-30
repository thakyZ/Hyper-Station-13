//Chain link fences
//Sprites ported from /VG/


#define CUT_TIME 100
#define CLIMB_TIME 150

#define NO_HOLE 0 //section is intact
#define MEDIUM_HOLE 1 //medium hole in the section - can climb through
#define LARGE_HOLE 2 //large hole in the section - can walk through
#define MAX_HOLE_SIZE LARGE_HOLE

/obj/structure/fence
	name = "fence"
	desc = "A chain link fence. Not as effective as a wall, but generally it keeps people out."
	density = TRUE
	anchored = TRUE

	icon = 'icons/obj/fence.dmi'
	icon_state = "straight"

	var/cuttable = TRUE
	var/hole_size= NO_HOLE
	var/invulnerable = FALSE

/obj/structure/fence/Initialize()
	. = ..()

	update_cut_status()

/obj/structure/fence/examine(mob/user)
	. = ..()
	switch(hole_size)
		if(MEDIUM_HOLE)
			. += "There is a large hole in \the [src]."
		if(LARGE_HOLE)
			. += "\The [src] has been completely cut through."

/obj/structure/fence/end
	icon_state = "end"
	cuttable = FALSE

/obj/structure/fence/corner
	icon_state = "corner"
	cuttable = FALSE

/obj/structure/fence/post
	icon_state = "post"
	cuttable = FALSE

/obj/structure/fence/cut/medium
	icon_state = "straight_cut2"
	hole_size = MEDIUM_HOLE

/obj/structure/fence/cut/large
	icon_state = "straight_cut3"
	hole_size = LARGE_HOLE

/obj/structure/fence/attackby(obj/item/W, mob/user)
	if(istype(W, /obj/item/wirecutters))
		if(!cuttable)
			to_chat(user, "<span class='notice'>This section of the fence can't be cut.</span>")
			return
		if(invulnerable)
			to_chat(user, "<span class='notice'>This fence is too strong to cut through.</span>")
			return
		var/current_stage = hole_size
		if(current_stage >= MAX_HOLE_SIZE)
			to_chat(user, "<span class='notice'>This fence has too much cut out of it already.</span>")
			return

		user.visible_message("<span class='danger'>\The [user] starts cutting through \the [src] with \the [W].</span>",\
		"<span class='danger'>You start cutting through \the [src] with \the [W].</span>")

		if(do_after(user, CUT_TIME*W.toolspeed, target = src))
			if(current_stage == hole_size)
				switch(++hole_size)
					if(MEDIUM_HOLE)
						visible_message("<span class='notice'>\The [user] cuts into \the [src] some more.</span>")
						to_chat(user, "<span class='info'>You could probably fit yourself through that hole now. Although climbing through would be much faster if you made it even bigger.</span>")
						climbable = TRUE
					if(LARGE_HOLE)
						visible_message("<span class='notice'>\The [user] completely cuts through \the [src].</span>")
						to_chat(user, "<span class='info'>The hole in \the [src] is now big enough to walk through.</span>")
						climbable = FALSE

				update_cut_status()

	return TRUE

/obj/structure/fence/proc/update_cut_status()
	if(!cuttable)
		return
	density = TRUE
	switch(hole_size)
		if(NO_HOLE)
			icon_state = initial(icon_state)
		if(MEDIUM_HOLE)
			icon_state = "straight_cut2"
		if(LARGE_HOLE)
			icon_state = "straight_cut3"
			density = FALSE

//FENCE DOORS

/obj/structure/fence/door
	name = "fence door"
	desc = "Not very useful without a real lock."
	icon_state = "door_closed"
	cuttable = FALSE
	var/open = FALSE

/obj/structure/fence/door/Initialize()
	. = ..()

	update_door_status()

/obj/structure/fence/door/opened
	icon_state = "door_opened"
	open = TRUE
	density = TRUE

/obj/structure/fence/door/attack_hand(mob/user)
	if(can_open(user))
		toggle(user)

	return TRUE

/obj/structure/fence/door/proc/toggle(mob/user)
	switch(open)
		if(FALSE)
			visible_message("<span class='notice'>\The [user] opens \the [src].</span>")
			open = TRUE
		if(TRUE)
			visible_message("<span class='notice'>\The [user] closes \the [src].</span>")
			open = FALSE

	update_door_status()
	playsound(src, 'sound/machines/click.ogg', 100, 1)

/obj/structure/fence/door/proc/update_door_status()
	switch(open)
		if(FALSE)
			density = TRUE
			icon_state = "door_closed"
		if(TRUE)
			density = FALSE
			icon_state = "door_opened"

/obj/structure/fence/door/proc/can_open(mob/user)
	return TRUE

//HANDRAIL - Ported from Dymouth Gulch

/obj/structure/fence/handrail
	name = "handrail"
	desc = "A waist high handrail, perhaps you could climb over it."
	icon_state = "handrail"
	cuttable = FALSE
	climbable = TRUE
	max_integrity = 100
	var/health = 70
	var/maxhealth = 70
	resistance_flags = ACID_PROOF
	armor = list("melee" = 0, "bullet" = 0, "laser" = 0, "energy" = 0, "bomb" = 0, "bio" = 0, "rad" = 0, "fire" = 80, "acid" = 100)
	CanAtmosPass = ATMOS_PASS_PROC
	var/breaksound = "shatter"
	var/hitsound = 'sound/effects/Glasshit.ogg'
	icon_state = "handrail"

/obj/structure/fence/handrail/handrail_end
	icon_state = "handrail_end"
	cuttable = FALSE
	climbable = TRUE

/obj/structure/fence/handrail/handrail_corner
	icon_state = "handrail_corner"
	cuttable = FALSE
	climbable = TRUE

/obj/structure/fence/handrail/examine(mob/user)
	. = ..()
	if(health < maxhealth)
		switch(health / maxhealth)
			if(0.0 to 0.5)
				. += "<span class='warning'>It looks severely damaged!</span>"
			if(0.25 to 0.5)
				. += "<span class='warning'>It looks damaged!</span>"
			if(0.5 to 1.0)
				. += "<span class='notice'>It has a few scrapes and dents.</span>"

/obj/structure/fence/handrail/take_damage(amount)
	health -= amount
	if(health <= 0)
		visible_message("<span class='warning'>\The [src] breaks down!</span>")
		playsound(src, 'sound/effects/grillehit.ogg', 50, 1)
		new /obj/item/stack/rods(get_turf(src))
		qdel(src)

#undef CUT_TIME
#undef CLIMB_TIME

#undef NO_HOLE
#undef MEDIUM_HOLE
#undef LARGE_HOLE
#undef MAX_HOLE_SIZE