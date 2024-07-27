 /**
  * tgui state: observer_state
  *
  * Checks that the user is an observer/ghost.
 **/

GLOBAL_DATUM_INIT(tgui_observer_state, /datum/tgui_state/observer_state, new)

/datum/tgui_state/observer_state/can_use_topic(src_object, mob/user)
	if(isobserver(user))
		return UI_INTERACTIVE
	return UI_CLOSE

