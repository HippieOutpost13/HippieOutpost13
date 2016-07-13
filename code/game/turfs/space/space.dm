var/global/planets = 1
var/global/planettospawn = rand(1, 4) //1 = snow, 2 = grass, 3 = sand, 4 = rock
var/global/pressure = 0
var/global/temp = 0
var/global/timeofday = 1 //rand(0, 1)

//DEBUG
var/conv = 0
var/maxconv = 10000
var/global/shitinrange = list()
var/global/debug = 0

/turf/open/space
	icon = 'icons/turf/terrain.dmi'
	name = "terrain"
	icon_state = "default"
	intact = 0
	initial_gas_mix = "o2=22;n2=82;TEMP=293.15"
	temperature = T20C
	var/destination_z
	var/destination_x
	var/destination_y
	var/global/datum/gas_mixture/space/space_gas = new
//turf/open/space/planet/New()

/turf/open/space/New()
	switch(planettospawn)
		if(1)
			name = "snow"
			icon_state = "snow[rand(0, 13)]"
			var/X = 0
			for(var/obj/structure/flora/tree/pine/G in range(15, src))
				X++
			if(X == 0)
				var/obj/structure/flora/tree/pine/T = new(get_turf(src))
				T.x = T.x + rand(0, 10)
				T.y = T.y + rand(0, 10)
				var/turf/G = get_turf(T)
				if(!istype(G,/turf/open/space))
					shitinrange += G
					qdel(T)
		if(2)
			name = "grass"
			icon_state = "grass"
			var/X = 0
			for(var/obj/structure/flora/ausbushes/G in range(8, src))
				X++
			if(X == 0)
				var/obj/structure/flora/ausbushes/T = new(get_turf(src))
				T.x = T.x + rand(0, 10)
				T.y = T.y + rand(0, 10)
				var/turf/G = get_turf(T)
				if(!istype(G,/turf/open/space))
					shitinrange += G
					qdel(T)
		if(3)
			name = "sand"
			icon_state = "sand[rand(0, 12)]"
			var/X = 0
			for(var/obj/structure/flora/cactus/G in range(15, src))
				X++
			if(X == 0)
				var/obj/structure/flora/cactus/T = new(get_turf(src))
				T.x = T.x + rand(0, 10)
				T.y = T.y + rand(0, 10)
				var/turf/G = get_turf(T)
				if(!istype(G,/turf/open/space))
					shitinrange += G
					qdel(T)
		if(4)
			name = "rock"
			icon_state = "rock[rand(0, 12]"
			var/X = 0
			for(var/obj/structure/flora/rock/G in range(10, src))
				X++
			if(X == 0)
				var/obj/structure/flora/rock/T = new(get_turf(src))
				T.x = T.x + rand(0, 10)
				T.y = T.y + rand(0, 10)
				var/turf/G = get_turf(T)
				if(!istype(G,/turf/open/space))
					shitinrange += G
					qdel(T)
		else
			name = "dirt"
			icon_state = "default"
	switch(planettospawn)
		if(1)
			temperature = rand(150, 200)
		if(2)
			temperature = rand(250, 300)
		if(3)
			temperature = rand(300, 350)
		else
			temperature = rand(400, 600)
	temp = temperature
	air = space_gas
	if(timeofday)
		return

/client/verb/debugplanets()
	set category = "debug"
	set name = "debugplanets"

	for(var/C in shitinrange)
		conv++
		if(conv < 10)
			usr << C

	usr << debug


/turf/open/space/Destroy(force)
	if(force)
		. = ..()
	else
		return QDEL_HINT_LETMELIVE

/turf/open/space/attack_ghost(mob/dead/observer/user)
	if(destination_z)
		var/turf/T = locate(destination_x, destination_y, destination_z)
		user.forceMove(T)

/turf/open/space/Initalize_Atmos(times_fired)
	return

/turf/open/space/ChangeTurf(path)
	. = ..()

/turf/open/space/TakeTemperature(temp)

/turf/open/space/AfterChange()
	..()
	atmos_overlay_types.Cut()

/turf/open/space/Assimilate_Air()
	return

/turf/open/space/proc/update_starlight()
	if(config.starlight)
		for(var/t in RANGE_TURFS(1,src)) //RANGE_TURFS is in code\__HELPERS\game.dm
			if(istype(t, /turf/open/space))
				//let's NOT update this that much pls
				continue
			SetLuminosity(4,1)
			return
		SetLuminosity(0)

/turf/open/space/attack_paw(mob/user)
	return src.attack_hand(user)

/turf/open/space/attackby(obj/item/C, mob/user, params)
	..()
	if(istype(C, /obj/item/stack/rods))
		var/obj/item/stack/rods/R = C
		var/obj/structure/lattice/L = locate(/obj/structure/lattice, src)
		var/obj/structure/lattice/catwalk/W = locate(/obj/structure/lattice/catwalk, src)
		if(W)
			user << "<span class='warning'>There is already a catwalk here!</span>"
			return
		if(L)
			if(R.use(1))
				user << "<span class='notice'>You begin constructing catwalk...</span>"
				playsound(src, 'sound/weapons/Genhit.ogg', 50, 1)
				qdel(L)
				ReplaceWithCatwalk()
			else
				user << "<span class='warning'>You need two rods to build a catwalk!</span>"
			return
		if(R.use(1))
			user << "<span class='notice'>Constructing support lattice...</span>"
			playsound(src, 'sound/weapons/Genhit.ogg', 50, 1)
			ReplaceWithLattice()
		else
			user << "<span class='warning'>You need one rod to build a lattice.</span>"
		return
	if(istype(C, /obj/item/stack/tile/plasteel))
		var/obj/structure/lattice/L = locate(/obj/structure/lattice, src)
		if(L)
			var/obj/item/stack/tile/plasteel/S = C
			if(S.use(1))
				qdel(L)
				playsound(src, 'sound/weapons/Genhit.ogg', 50, 1)
				user << "<span class='notice'>You build a floor.</span>"
				ChangeTurf(/turf/open/floor/plating)
			else
				user << "<span class='warning'>You need one floor tile to build a floor!</span>"
		else
			user << "<span class='warning'>The plating is going to need some support! Place metal rods first.</span>"

/turf/open/space/Entered(atom/movable/A)
	..()
	if ((!(A) || src != A.loc))
		return

	if(destination_z)
		A.x = destination_x
		A.y = destination_y
		A.z = destination_z

		if(isliving(A))
			var/mob/living/L = A
			if(L.pulling)
				var/turf/T = get_step(L.loc,turn(A.dir, 180))
				L.pulling.loc = T

		//now we're on the new z_level, proceed the space drifting
		stoplag()//Let a diagonal move finish, if necessary
		A.newtonian_move(A.inertia_dir)

/turf/open/space/proc/Sandbox_Spacemove(atom/movable/A)
	var/cur_x
	var/cur_y
	var/next_x = src.x
	var/next_y = src.y
	var/target_z
	var/list/y_arr
	var/list/cur_pos = src.get_global_map_pos()
	if(!cur_pos)
		return
	cur_x = cur_pos["x"]
	cur_y = cur_pos["y"]

	if(src.x <= 1)
		next_x = (--cur_x||global_map.len)
		y_arr = global_map[next_x]
		target_z = y_arr[cur_y]
		next_x = world.maxx - 2
	else if (src.x >= world.maxx)
		next_x = (++cur_x > global_map.len ? 1 : cur_x)
		y_arr = global_map[next_x]
		target_z = y_arr[cur_y]
		next_x = 3
	else if (src.y <= 1)
		y_arr = global_map[cur_x]
		next_y = (--cur_y||y_arr.len)
		target_z = y_arr[next_y]
		next_y = world.maxy - 2
	else if (src.y >= world.maxy)
		y_arr = global_map[cur_x]
		next_y = (++cur_y > y_arr.len ? 1 : cur_y)
		target_z = y_arr[next_y]
		next_y = 3

	var/turf/T = locate(next_x, next_y, target_z)
	A.Move(T)

/turf/open/space/handle_slip()
	return

/turf/open/space/singularity_act()
	icon_state = "default"
	return

/turf/open/space/can_have_cabling()
	if(locate(/obj/structure/lattice/catwalk, src))
		return 1
	return 0

/turf/open/space/proc/update_icon()
	icon_state = SPACE_ICON_STATE