//Made for HypeStation 13
//by QuoteFox

/obj/item/equipment/penis/
	name = "penis equipment"
	desc = "you shouldn't see this, contact coders immediately."
	icon = 'hyperstation/icons/obj/clothing/genitals.dmi'
	price = 3

/obj/item/equipment/penis/attack(mob/living/carbon/C, mob/living/user)
	var/mob/living/carbon/human/S = user
	var/mob/living/carbon/human/T = C
	var/obj/item/organ/genital/penis/P = C.getorganslot("penis")

	if(P&&P.is_exposed())
		if(P.equipment)
			to_chat(user, "<span class='notice'>There is already a [P.equipment.name] attached.</span>")
		else
			if(S!=T)//if you're not targeting yourself
				C.visible_message("<span class='warning'>[user] is trying to attach [src] to [T]!</span>",\
						"<span class='warning'>[user] is trying to put [src] on you!</span>")
				if(!do_mob(user, C, 4 SECONDS))//warn them and have a delay of 5 seconds to apply.
					return
			if(!user.transferItemToLoc(src, P)) //check if you can put it on
				return
			SEND_SIGNAL(src, "attach_genital_equipment",T)
			P.equipment = src
			to_chat(user, "<span class='love'>You attach [src] to [T]'s [P.name].</span>")


	else
		to_chat(user, "<span class='notice'>You don't see anywhere to attach this.</span>")
		return

//Cockrings

/obj/item/equipment/penis/ring
	name = "cock ring"
	desc = "Why don't you marry it already?"
	icon_state = "cockring"

/obj/item/equipment/penis/ring/metal
	name = "metal cock ring"
	icon_state = "cockring_metal"


/obj/item/equipment/penis/ring/fancy

	name = "fancy ribboned cock ring"
	desc = "A cock ring with a white bowtie, how cute."
	icon_state = "cockring_fancy"


//Cock ring limiter for fancy hide and grow

/obj/item/equipment/penis/ring/limiter
	name = "normalizer cock ring"
	desc = "An expensive technological cock ring cast in SynTech purples with shimmering Kinaris golds. It will limit the wearers penis size to a third."
	icon_state = "cockring_limit"
	price = 12

/obj/item/equipment/penis/ring/limiter/Initialize()
	.=..()
	RegisterSignal(src, "attach_genital_equipment", .proc/attach)
	RegisterSignal(src, "detach_genital_equipment", .proc/detach)

/obj/item/equipment/penis/ring/limiter/proc/attach(mob/living/carbon/human/U)
	playsound(usr, 'sound/effects/magic.ogg', 100, 1)
	var/obj/item/organ/genital/penis/P = loc
	if(P)
		P.limited = TRUE
		P.update_appearance()
		U.update_genitals()

/obj/item/equipment/penis/ring/limiter/proc/detach(mob/living/carbon/human/U)
	playsound(usr, 'sound/effects/magic.ogg', 100, 1)
	var/obj/item/organ/genital/penis/P = loc
	if(P)
		P.limited = FALSE
		P.update_appearance()
		U.update_genitals()
