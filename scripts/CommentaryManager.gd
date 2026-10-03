extends Node

var crowd_lines := [
    "A parent in the bleachers shouts, 'Keep your eye on the ball!'",
    "Someone from the bench says, 'This is the best practice we ever had!'",
    "A teammate grins, 'We're gonna win this thing, no drama.'",
    "The crowd chants, 'Go girls! Go girls!'",
    "A parent laughs, 'Hey, don't forget the sunscreen!'"
]

var teammate_lines := [
    "The catcher flashes signs and says, 'We got this.'",
    "A teammate taps the bat: 'You're dialed in.'",
    "The dugout groans, then laughs: 'That was a weird one.'",
    "Someone says, 'Let's play loose and have fun.'",
    "The pitcher nods. 'Okay, reset. We move on.'"
]

var parent_lines := [
    "A parent says, 'You got this, honey! Just breathe.'",
    "From the bleachers: 'I swear that pitch looked like a comet.'",
    "A dad calls out, 'She'll get a hold of that one!'",
    "A mom shouts, 'That was a good swing! Don't overthink it.'",
    "A grandparent says, 'This is the kind of fun we came for.'"
]

func emit(message: String, source: String = "crowd") -> void:
    var lines := crowd_lines
    match source:
        "teammate":
            lines = teammate_lines
        "parent":
            lines = parent_lines

    if message != "":
        if get_parent() and get_parent().has_method("_set_commentary"):
            get_parent()._set_commentary(message)
            return

    if lines.size() > 0:
        var index := randi() % lines.size()
        if get_parent() and get_parent().has_method("_set_commentary"):
            get_parent()._set_commentary(lines[index])
