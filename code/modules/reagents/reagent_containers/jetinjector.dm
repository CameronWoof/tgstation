/obj/item/reagent_containers/jetinjector
	name = "jet injector"
	desc = "A reloadable, cartridge-based chemical injector. Accepts pre-filled, proprietary cartridges." // We let the player know they can't just pour reagents in.
	icon = 'icons/obj/chemical.dmi'
	item_state = "jetinjector"
	lefthand_file = 'icons/mob/inhands/equipment/medical_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/medical_righthand.dmi'
	icon_state = "jetinjector"
	var/obj/item/reagent_containers/jetcart/cart = null
	var/cartcolor = null
	var/inj_amount = 10

/obj/item/reagent_containers/jetinjector/attack_self(mob/user) // This is to avoid changing the injection amount.
	return

/obj/item/reagent_containers/jetinjector/attackby(obj/item/C, mob/user, params)
	if (!istype(C, /obj/item/reagent_containers/jetcart))
		return
	if (cart)
		to_chat(user, "<span class='notice'>\The [src] already has a cartridge loaded.</span>")
		return
	if (!user.transferItemToLoc(C, src)) // The cartridge attempts to go inside the jet injector; if it fails, the proc ends.
		return

	cart = C
	cartcolor = C.icon_state
	to_chat(user, "<span class='notice'>\The [cart] clicks into place.</span>")
	playsound(loc ,"sound/weapons/gun_magazine_insert_full_1.ogg", 80, 0)
	update_icon() // These procs are used because the icon and description both change with cart events.
	update_desc()
	update_name()

/obj/item/reagent_containers/jetinjector/attack_hand(mob/user)
	if(!user.is_holding(src)) // This check keeps the cartridges from ejecting when the injector is in the user's pocket.
		..()
		return
	if(cart)
		cart.forceMove(drop_location())
		user.put_in_hands(cart)
		cart = null
		cartcolor = null
		to_chat(user, "<span class='notice'>You eject the cartridge from \the [src].</span>")
		playsound(loc, 'sound/weapons/gun_magazine_remove_empty_1.ogg', 80, 0)
	update_icon()
	update_desc()
	update_name()

/obj/item/reagent_containers/jetinjector/attack(mob/M, mob/user, def_zone)
	var/contained = cart.reagents.log_list()
	var/fraction = min(inj_amount/cart.reagents.total_volume, 1) // The value we get from this equation gets multiplied by cart.reagents.total_volume later.
	if (!cart)
		to_chat(user, "<span class='notice'>There's no cartridge loaded in \the [src].</span>")
		return
	if (!cart.reagents.total_volume) 
		to_chat(user, "<span class='notice'>\The [cart] is empty!</span>")
		return
	if (M.reagents.has_reagent("[cart.cartcontents]", 20) && !(cart.cartcontents == "mutadone")) // We protect against overdosing on chems that have an overdose threshhold.
		to_chat(user, "<span class='notice'>The trigger locks as \the [src]'s overdose prevention mechanism activates.</span>")
		playsound(M.loc, 'sound/weapons/gun_dry_fire_4.ogg', 80, 0)
		return
	if (ismob(M))
		M.visible_message("<span class='notice'>[user] injects [M] with \the [src].</span>")
		cart.reagents.reaction(M, INJECT, fraction) // This proc's third argument wants a number between 0 and 1, and multiplies it by the total volume of reagents. This is basically a complicated way of passing ourselves inj_amount again.
		cart.reagents.trans_to(M, inj_amount)
		add_logs(user, M, "injected", src, addition="which had [contained]")
		to_chat(user, "<span class='notice'>You inject [inj_amount] units of [cart.cartcontents] from the cartridge. It now contains [cart.reagents.total_volume] units.</span>")
		playsound(M.loc, 'sound/weapons/gun_slide_lock_1.ogg', 80, 0)
	else
		to_chat(user, "<span class='notice'>[src] can only be used on living organisms.</span>")
	update_icon()
	update_desc()

/obj/item/reagent_containers/jetinjector/update_icon()
	cut_overlays()
	if (cart)
		var/c_volume = cart.reagents.total_volume // Since we know that the injection amount and possible volumes are static, we can skip some math.
		add_overlay("over_[cartcolor]") 
		add_overlay("jetinjector_[c_volume]")

/obj/item/reagent_containers/jetinjector/proc/update_name()
	if (!cart)
		name = "jet injector"
	if (cart)
		name = "jet injector ([cart.cartcontents])"

/obj/item/reagent_containers/jetinjector/proc/update_desc() // We provide the player with information about the cartridge only when there actually is one.
	if (!cart)
		desc = "A reloadable, cartridge-based chemical injector. Accepts pre-filled, proprietary cartridges." 
	if (cart)
		desc = "A reloadable, cartridge-based chemical injector. It is loaded with a cartridge of [cart.cartcontents]. The volume light indicates that the cartridge has [cart.reagents.total_volume] units left."

// Cartridges

/obj/item/reagent_containers/jetcart
	name = "injector cartridge"
	desc = "A disposable chemical cartridge, used with jet injectors. Bane of janitors company-wide." // The prefilled cartridges give gameplay hints in their description.
	icon = 'icons/obj/chemical.dmi'
	icon_state = "cartred"
	volume = 40
	container_type = TRANSPARENT
	var/cartcontents = null

/obj/item/reagent_containers/jetcart/attack_self(mob/user) // Same as before.
	return

/obj/item/reagent_containers/jetcart/emergency
	name = "injector cartridge (epinephrine)"
	desc = "A disposable chemical cartridge, preloaded with epinephrine for stabilizing critical patients."
	list_reagents = list("epinephrine" = 40)
	cartcontents = "epinephrine"

/obj/item/reagent_containers/jetcart/brute
	name = "injector cartridge (bicaridine)"
	desc = "A disposable chemical cartridge, preloaded with medicine to treat brute trauma."
	icon_state = "cartpink"
	list_reagents = list("bicaridine" = 40)
	cartcontents = "bicaridine"

/obj/item/reagent_containers/jetcart/burn
	name = "injector cartridge (kelotane)"
	desc = "A disposable chemical cartridge, preloaded with medicine to treat burn damage."
	icon_state = "cartyellow"
	list_reagents = list("kelotane" = 40)
	cartcontents = "kelotane"

/obj/item/reagent_containers/jetcart/toxin
	name = "injector cartridge (antitoxin)"
	desc = "A disposable chemical cartridge, preloaded with medicine to counteract toxins."
	icon_state = "cartgreen"
	list_reagents = list("antitoxin" = 40)
	cartcontents = "antitoxin"

/obj/item/reagent_containers/jetcart/genetic
	name = "injector cartridge (mutadone)"
	desc = "A disposable chemical cartridge, preloaded with medicine to correct genetic irregularities."
	icon_state = "cartpurple"
	list_reagents = list("mutadone" = 40)
	cartcontents = "mutadone"

/obj/item/reagent_containers/jetcart/oxy
	name = "injector cartridge (dexalin)"
	desc = "A disposable chemical cartridge, preloaded with medicine to treat oxygen deprivation."
	icon_state = "cartblue"
	list_reagents = list("dexalin" = 40)
	cartcontents = "dexalin"