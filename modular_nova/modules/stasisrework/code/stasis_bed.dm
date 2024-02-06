/obj/machinery/stasis/Initialize(mapload)
	. = ..()

	if (mapload)
		var/obj/machinery/stasissleeper/sleeper = new /obj/machinery/stasissleeper(loc)
		sleeper.dir = SOUTH
		qdel(src)
