/obj/item/reagent_containers/jetinjector
	name = "jet injector"
	desc = "A reloadable, cartridge-based chemical injector. Accepts pre-filled, proprietary cartridges."
	icon = 'icons/obj/chemical.dmi'
	item_state = "jetinjector"
	lefthand_file = 'icons/mob/inhands/equipment/medical_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/medical_righthand.dmi'
	icon_state = "jetinjector"
	var/obj/item/reagent_containers/jetcart = null
	var/cartcolor = null
	var/inj_amount = 10

/obj/item/reagent_containers/jetinjector/attack_self(mob/user)
	return

/obj/item/reagent_containers/jetinjector/attackby(obj/item/C, mob/user, params)
	if (!istype(C, /obj/item/reagent_containers/jetcart))
		return
	if (jetcart)
		to_chat(user, "<span class='notice'>\The [src] already has a cartridge loaded.</span>")
		return
	if (!user.transferItemToLoc(C, src))
		return

	jetcart = C
	cartcolor = C.icon_state
	to_chat(user, "<span class='notice'>\The [jetcart] clicks into place.</span>")
	playsound(loc ,"sound/weapons/gun_magazine_insert_full_1.ogg", 80, 0)
	update_icon()
	update_desc()

/obj/item/reagent_containers/jetinjector/attack_hand(mob/user)
	if(!user.is_holding(src))
		..()
		return
	if(jetcart)
		jetcart.forceMove(drop_location())
		user.put_in_hands(jetcart)
		jetcart = null
		cartcolor = null
		to_chat(user, "<span class='notice'>You eject the cartridge from \the [src].</span>")
		playsound(loc ,"sound/weapons/gun_magazine_remove_empty_1.ogg", 80, 0)
	update_icon()
	update_desc()

/obj/item/reagent_containers/jetinjector/attack(mob/M, mob/user, def_zone)
	var/contained = jetcart.reagents.log_list()
	if (!jetcart)
		to_chat(user, "<span class='notice'>There's no cartridge loaded in \the [src].</span>")
		return
	if (!jetcart.reagents.total_volume)
		to_chat(user, "<span class='notice'>\The [jetcart] is empty!</span>")
		return
	if (ismob(M))
		M.visible_message("<span class='notice'>[user] injects [M] with \the [src].</span>")
		add_logs(user, M, "injected", src, addition="which had [contained]")
		jetcart.reagents.trans_to(M, inj_amount)
		to_chat(user, "<span class='notice'>You inject [inj_amount] units of \the [jetcart]'s contents. It now contains [jetcart.reagents.total_volume] units.</span>")
		playsound(M.loc, 'sound/weapons/gun_slide_lock_1.ogg', 80, 0)
	else
		to_chat(user, "<span class='notice'>[src] can only be used on living organisms.</span>")
	update_icon()
	update_desc()

/obj/item/reagent_containers/jetinjector/update_icon()
	cut_overlays()	
	if (jetcart)
		var/c_volume = jetcart.reagents.total_volume
		add_overlay("over_[cartcolor]")
		add_overlay("jetinjector_[c_volume]")

/obj/item/reagent_containers/jetinjector/proc/update_desc()
	if (!jetcart)
		desc = "A reloadable, cartridge-based chemical injector. Accepts pre-filled, proprietary cartridges."
	if (jetcart)
		desc = "A reloadable, cartridge-based chemical injector. It is loaded with a [jetcart]. The volume light indicates that there are [jetcart.reagents.total_volume] units left."

// Cartridges

/obj/item/reagent_containers/jetcart
	name = "injector cartridge"
	desc = "A disposable chemical cartridge, used with jet injectors. Bane of janitors company-wide."
	icon = 'icons/obj/chemical.dmi'
	icon_state = "cartred"
	volume = 40
	container_type = TRANSPARENT

/obj/item/reagent_containers/jetcart/attack_self(mob/user)
	return

/obj/item/reagent_containers/jetcart/neuro
	name = "injector cartridge (epinephrine)"
	desc = "A disposable chemical cartridge, preloaded with epinephrine for stabilizing critical patients."
	list_reagents = list("epinephrine" = 40)

/obj/item/reagent_containers/jetcart/brute
	name = "injector cartridge (bicaridine)"
	desc = "A disposable chemical cartridge, preloaded with medicine to treat brute trauma."
	icon_state = "cartpink"
	list_reagents = list("bicaridine" = 40)

/obj/item/reagent_containers/jetcart/burn
	name = "injector cartridge (kelotane)"
	desc = "A disposable chemical cartridge, preloaded with medicine to treat burn damage."
	icon_state = "cartyellow"
	list_reagents = list("kelotane" = 40)

/obj/item/reagent_containers/jetcart/toxin
	name = "injector cartridge (antitoxin)"
	desc = "A disposable chemical cartridge, preloaded with medicine to counteract toxins."
	icon_state = "cartgreen"
	list_reagents = list("antitoxin" = 40)

/obj/item/reagent_containers/jetcart/genetic
	name = "injector cartridge (mutadone)"
	desc = "A disposable chemical cartridge, preloaded with medicine to correct genetic irregularities."
	icon_state = "cartpurple"
	list_reagents = list("mutadone" = 40)

/obj/item/reagent_containers/jetcart/oxy
	name = "injector cartridge (dexalin)"
	desc = "A disposable chemical cartridge, preloaded with medicine to treat oxygen deprivation."
	icon_state = "cartblue"
	list_reagents = list("dexalin" = 40)