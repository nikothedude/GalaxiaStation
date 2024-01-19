// Slightly improved version of the normal RCD, mostly as an engineering 'I got hella bread' purchase
/obj/item/construction/rcd/improved
	name = "Improved RCD"
	desc = "A device used to rapidly build and deconstruct. Upgraded from the standard model with superior material storage, at the cost of build speed. Reload with iron, plasteel, glass or compressed matter cartridges."
	icon_state = "ircd"
	inhand_icon_state = "ircd"
	max_matter = 220
	matter = 220
	delay_mod = 1.3
	upgrade = RCD_UPGRADE_FRAMES | RCD_UPGRADE_SIMPLE_CIRCUITS

// Unimproved repainted RCD that Interdyne's cargo/atrium gets
/obj/item/construction/rcd/loaded/interdyne
	desc = "A device used to rapidly build and deconstruct. Reload with iron, plasteel, glass or compressed matter cartridges. This one looks like it has been repainted in black and red, though it retains standard functionality.";
	icon_state = "ircd"
	inhand_icon_state = "ircd"
