/datum/job/chief_engineer
	title = "Engineering Director"
	department = "Engineering"
	supervisors = "the Site Director"
	department_flag = ENG|COM
	selection_color = "#b69a3f"
	head_position = 1
	total_positions = 1
	spawn_positions = 1
	economic_power = 10
	ideal_character_age = 35
	minimal_player_age = 20
	requirements = list(EXP_TYPE_ENGINEERING = 720)
	outfit_type = /decl/hierarchy/outfit/job/command/chief_engineer
	class = CLASS_A
	hud_icon = "hudchiefengineer"

	access = list(
		ACCESS_ENG_COMMS,
		ACCESS_SECURITY_LVL1,
		ACCESS_SCIENCE_LVL1,
		ACCESS_SCIENCE_LVL2,
		ACCESS_SCIENCE_LVL3,
		ACCESS_SCIENCE_LVL4,
		ACCESS_ADMIN_LVL1,
		ACCESS_ADMIN_LVL2,
		ACCESS_ADMIN_LVL3,
		ACCESS_ENGINEERING_LVL1,
		ACCESS_ENGINEERING_LVL2,
		ACCESS_ENGINEERING_LVL3,
		ACCESS_ENGINEERING_LVL4,
		ACCESS_ENGINEERING_LVL5,
		ACCESS_ATMOSPHERICS,
		ACCESS_ENGINE_EQUIP,
		ACCESS_KEYAUTH,
		ACCESS_NETWORK
	)
	minimal_access = list()

	min_skill = list(
		SKILL_COMPUTER     = SKILL_BASIC,
	    SKILL_HAULING      = SKILL_EXPERIENCED,
	    SKILL_CONSTRUCTION = SKILL_EXPERIENCED,
	    SKILL_ELECTRICAL   = SKILL_EXPERIENCED,
	    SKILL_ATMOS        = SKILL_EXPERIENCED,
	    SKILL_ENGINES      = SKILL_EXPERIENCED
	)

	max_skill = list(
		SKILL_CONSTRUCTION = SKILL_MASTER,
	    SKILL_ELECTRICAL   = SKILL_MASTER,
	    SKILL_ATMOS        = SKILL_MASTER,
	    SKILL_ENGINES      = SKILL_MASTER
	)

	roleplay_difficulty = "Medium - Hard"
	mechanical_difficulty = "Hard"
	duties = "Manage the Engineering department. Delegate construction and repair work. Facilitate larger projects."
	codex_guides = list("<l>Hacking Wires</l>")

/datum/job/achief_engineer
	title = "Assistant Engineering Director"
	department = "Engineering"
	supervisors = "the Site Director and Engineering Director"
	department_flag = ENG|COM
	selection_color = "#b69a3f"
	total_positions = 1
	spawn_positions = 1
	economic_power = 10
	ideal_character_age = 35
	minimal_player_age = 20
	requirements = list(EXP_TYPE_ENGINEERING = 560)
	outfit_type = /decl/hierarchy/outfit/job/command/achief_engineer
	class = CLASS_A
	hud_icon = "hudassistantengineer"

	access = list(
		ACCESS_ENG_COMMS,
		ACCESS_SECURITY_LVL1,
		ACCESS_SCIENCE_LVL1,
		ACCESS_SCIENCE_LVL2,
		ACCESS_SCIENCE_LVL3,
		ACCESS_SCIENCE_LVL4,
		ACCESS_ADMIN_LVL1,
		ACCESS_ADMIN_LVL2,
		ACCESS_ADMIN_LVL3,
		ACCESS_ENGINEERING_LVL1,
		ACCESS_ENGINEERING_LVL2,
		ACCESS_ENGINEERING_LVL3,
		ACCESS_ENGINEERING_LVL4,
		ACCESS_ATMOSPHERICS,
		ACCESS_ENGINE_EQUIP,
		ACCESS_KEYAUTH,
		ACCESS_NETWORK
	)
	minimal_access = list()

	min_skill = list(
		SKILL_COMPUTER     = SKILL_BASIC,
	    SKILL_HAULING      = SKILL_EXPERIENCED,
	    SKILL_CONSTRUCTION = SKILL_EXPERIENCED,
	    SKILL_ELECTRICAL   = SKILL_EXPERIENCED,
	    SKILL_ATMOS        = SKILL_EXPERIENCED,
	    SKILL_ENGINES      = SKILL_EXPERIENCED
	)

	max_skill = list(
		SKILL_CONSTRUCTION = SKILL_MASTER,
	    SKILL_ELECTRICAL   = SKILL_MASTER,
	    SKILL_ATMOS        = SKILL_MASTER,
	    SKILL_ENGINES      = SKILL_MASTER
	)

	roleplay_difficulty = "Medium"
	mechanical_difficulty = "Medium - Hard"
	duties = "Perform constructions and repairs. Manage lower engineers."
	codex_guides = list("<l>Hacking Wires</l>")

/datum/job/conteng
	title = "Containment Engineer"
	department = "Engineering"
	total_positions = 2
	spawn_positions = 2
	department = "Engineering"
	department_flag = ENG
	selection_color = "#5b4d20"
	supervisors = "the Engineering Director and Assistant Engineering Director"
	economic_power = 5
	minimal_player_age = 10
	ideal_character_age = 30
	outfit_type = /decl/hierarchy/outfit/job/engineering/conteng
	requirements = list(EXP_TYPE_ENGINEERING = 600)
	class = CLASS_B
	hud_icon = "hudcontainmentengineer"

	access = list(
		ACCESS_ENG_COMMS,
		ACCESS_SECURITY_LVL1,
		ACCESS_SECURITY_LVL2,
		ACCESS_SECURITY_LVL3,
		ACCESS_SCIENCE_LVL1,
		ACCESS_SCIENCE_LVL2,
		ACCESS_SCIENCE_LVL3,
		ACCESS_SCIENCE_LVL4,
		ACCESS_ENGINEERING_LVL1,
		ACCESS_ENGINEERING_LVL2,
		ACCESS_ENGINEERING_LVL3,
		ACCESS_ENGINEERING_LVL4,
		ACCESS_ATMOSPHERICS,
		ACCESS_ENGINE_EQUIP,
		ACCESS_CONTAINMENT_SCP_012,
		ACCESS_CONTAINMENT_SCP_013,
		ACCESS_CONTAINMENT_SCP_017,
		ACCESS_CONTAINMENT_SCP_049,
		ACCESS_CONTAINMENT_SCP_066,
		ACCESS_CONTAINMENT_SCP_078,
		ACCESS_CONTAINMENT_SCP_079,
		ACCESS_CONTAINMENT_SCP_080,
		ACCESS_CONTAINMENT_SCP_082,
		ACCESS_CONTAINMENT_SCP_087_B,
		ACCESS_CONTAINMENT_SCP_096,
		ACCESS_CONTAINMENT_SCP_106,
		ACCESS_CONTAINMENT_SCP_113,
		ACCESS_CONTAINMENT_SCP_131,
		ACCESS_CONTAINMENT_SCP_151,
		ACCESS_CONTAINMENT_SCP_173,
		ACCESS_CONTAINMENT_SCP_247,
		ACCESS_CONTAINMENT_SCP_263,
		ACCESS_CONTAINMENT_SCP_280,
		ACCESS_CONTAINMENT_SCP_294,
		ACCESS_CONTAINMENT_SCP_343,
		ACCESS_CONTAINMENT_SCP_399,
		ACCESS_CONTAINMENT_SCP_409,
		ACCESS_CONTAINMENT_SCP_513,
		ACCESS_CONTAINMENT_SCP_529,
		ACCESS_CONTAINMENT_SCP_714,
		ACCESS_CONTAINMENT_SCP_896,
		ACCESS_CONTAINMENT_SCP_953,
		ACCESS_CONTAINMENT_SCP_966,
		ACCESS_CONTAINMENT_SCP_999,
		ACCESS_CONTAINMENT_SCP_1102_RU,
		ACCESS_CONTAINMENT_SCP_1025,
		ACCESS_CONTAINMENT_SCP_1366,
		ACCESS_CONTAINMENT_SCP_1499
	)
	minimal_access = list()

	min_skill = list(
		SKILL_COMPUTER     = SKILL_BASIC,
	    SKILL_HAULING      = SKILL_EXPERIENCED,
	    SKILL_CONSTRUCTION = SKILL_EXPERIENCED,
	    SKILL_ELECTRICAL   = SKILL_EXPERIENCED,
	    SKILL_ATMOS        = SKILL_EXPERIENCED,
	    SKILL_ENGINES      = SKILL_EXPERIENCED
	)

	max_skill = list(
		SKILL_CONSTRUCTION = SKILL_MASTER,
	    SKILL_ELECTRICAL   = SKILL_MASTER,
	    SKILL_ATMOS        = SKILL_MASTER,
	    SKILL_ENGINES      = SKILL_MASTER
	)
	roleplay_difficulty = "Easy"
	mechanical_difficulty = "Medium - Hard"
	duties = "Perform constructions and repairs on SCP containment chambers."
	codex_guides = list("<l>Hacking Wires</l>")

/datum/job/it_tech
	title = "IT Technician"
	department = "Engineering"
	selection_color = "#5b4d20"
	department_flag = ENG
	total_positions = 1
	spawn_positions = 1
	supervisors = "the Engineering Director and Assistant Engineering Director"
	economic_power = 4
	minimal_player_age = 3
	ideal_character_age = 30
	requirements = list(EXP_TYPE_ENGINEERING = 120)
	outfit_type = /decl/hierarchy/outfit/job/engineering/it_tech
	class = CLASS_B
	hud_icon = "hudittech"

	access = list(
		ACCESS_ENG_COMMS,
		ACCESS_ENGINEERING_LVL1,
		ACCESS_ENGINEERING_LVL2,
		ACCESS_ENGINEERING_LVL3,
		ACCESS_ADMIN_LVL1,
		ACCESS_SCIENCE_LVL1,
		ACCESS_NETWORK
	)
	minimal_access = list()

	min_skill = list(
		SKILL_COMPUTER     = SKILL_EXPERIENCED,
	    SKILL_CONSTRUCTION = SKILL_BASIC,
	    SKILL_ELECTRICAL   = SKILL_BASIC
	)

	max_skill = list(
		SKILL_COMPUTER     = SKILL_MASTER
	)

	roleplay_difficulty = "Easy - Medium"
	mechanical_difficulty = "Medium"
	duties = "Maintain and expand the advanced technology behind the site's server infrastructure. Resolve technical problems. Prepare and protect against cybersecurity attacks."

/datum/job/seneng
	title = "Senior Engineer"
	department = "Engineering"
	total_positions = 2
	spawn_positions = 2
	department = "Engineering"
	department_flag = ENG
	selection_color = "#5b4d20"
	supervisors = "the Engineering Director"
	economic_power = 5
	minimal_player_age = 7
	ideal_character_age = 30
	requirements = list(EXP_TYPE_ENGINEERING = 480)
	alt_titles = list(
		"Senior Maintenance Technician",
		"Senior Engine Technician",
		"Senior Damage Control Technician",
		"Senior Electrician"
		)
	outfit_type = /decl/hierarchy/outfit/job/engineering/seneng
	class = CLASS_C
	hud_icon = "hudseniorengineer"

	access = list(
		ACCESS_ENG_COMMS,
		ACCESS_ENGINEERING_LVL1,
		ACCESS_ENGINEERING_LVL2,
		ACCESS_ENGINEERING_LVL3,
		ACCESS_ENGINEERING_LVL4,
		ACCESS_SCIENCE_LVL1
	)
	minimal_access = list()
	min_skill = list(
		SKILL_COMPUTER     = SKILL_BASIC,
	    SKILL_HAULING      = SKILL_EXPERIENCED,
	    SKILL_CONSTRUCTION = SKILL_EXPERIENCED,
	    SKILL_ELECTRICAL   = SKILL_EXPERIENCED,
	    SKILL_ATMOS        = SKILL_EXPERIENCED,
	    SKILL_ENGINES      = SKILL_EXPERIENCED
	)
	max_skill = list(
		SKILL_CONSTRUCTION = SKILL_MASTER,
	    SKILL_ELECTRICAL   = SKILL_MASTER,
	    SKILL_ATMOS        = SKILL_MASTER,
	    SKILL_ENGINES      = SKILL_MASTER
	)
	roleplay_difficulty = "Medium - Hard"
	mechanical_difficulty = "Medium - Hard"
	duties = "Manage the Engineering department. Delegate construction and repair work. Facilitate larger projects."
	codex_guides = list("<l>Hacking Wires</l>")

/datum/job/it_tech
	title = "IT Technician"
	department = "Engineering"
	selection_color = "#5b4d20"
	department_flag = ENG
	total_positions = 1
	spawn_positions = 1
	supervisors = "the Engineering Director and Assistant Engineering Director"
	economic_power = 4
	minimal_player_age = 3
	ideal_character_age = 30
	requirements = list(EXP_TYPE_ENGINEERING = 120)
	outfit_type = /decl/hierarchy/outfit/job/engineering/it_tech
	class = CLASS_B
	hud_icon = "hudittech"

	access = list(
		ACCESS_ENG_COMMS,
		ACCESS_ENGINEERING_LVL1,
		ACCESS_ENGINEERING_LVL2,
		ACCESS_ENGINEERING_LVL3,
		ACCESS_ADMIN_LVL1,
		ACCESS_SCIENCE_LVL1,
		ACCESS_NETWORK
	)
	minimal_access = list()

	min_skill = list(
		SKILL_COMPUTER     = SKILL_EXPERIENCED,
	    SKILL_CONSTRUCTION = SKILL_BASIC,
	    SKILL_ELECTRICAL   = SKILL_BASIC
	)

	max_skill = list(
		SKILL_COMPUTER     = SKILL_MASTER
	)

	roleplay_difficulty = "Easy - Medium"
	mechanical_difficulty = "Medium"
	duties = "Maintain and expand the advanced technology behind the site's server infrastructure. Resolve technical problems. Prepare and protect against cybersecurity attacks."

	roleplay_difficulty = "Easy - Medium"
	mechanical_difficulty = "Medium - Hard"
	duties = "Perform constructions and repairs. Manage lower engineers."
	codex_guides = list("<l>Hacking Wires</l>")

/datum/job/eng
	title = "Engineer"
	department = "Engineering"
	total_positions = 4
	spawn_positions = 4
	selection_color = "#5b4d20"
	department_flag = ENG
	supervisors = "the Engineering Director and Assistant Engineering Director"
	economic_power = 4
	minimal_player_age = 3
	ideal_character_age = 25
	requirements = list(EXP_TYPE_ENGINEERING = 60)
	alt_titles = list(
		"Maintenance Technician",
		"Engine Technician",
		"Damage Control Technician",
		"Electrician"
		)
	outfit_type = /decl/hierarchy/outfit/job/engineering/eng
	class = CLASS_C
	hud_icon = "hudengineer"
	access = list(
		ACCESS_ENG_COMMS,
		ACCESS_ENGINEERING_LVL1,
		ACCESS_ENGINEERING_LVL2,
		ACCESS_ENGINEERING_LVL3,
		ACCESS_SCIENCE_LVL1
	)
	minimal_access = list()
	min_skill = list(
		SKILL_COMPUTER     = SKILL_BASIC,
	    SKILL_HAULING      = SKILL_EXPERIENCED,
	    SKILL_CONSTRUCTION = SKILL_EXPERIENCED,
	    SKILL_ELECTRICAL   = SKILL_EXPERIENCED,
	    SKILL_ATMOS        = SKILL_EXPERIENCED,
	    SKILL_ENGINES      = SKILL_EXPERIENCED
	)
	max_skill = list(
		SKILL_CONSTRUCTION = SKILL_MASTER,
	    SKILL_ELECTRICAL   = SKILL_MASTER,
	    SKILL_ATMOS        = SKILL_MASTER,
	    SKILL_ENGINES      = SKILL_MASTER
	)

	roleplay_difficulty = "Easy"
	mechanical_difficulty = "Medium"
	duties = "Help with constructions and repairs."
	codex_guides = list("<l>Hacking Wires</l>")

/datum/job/juneng
	title = "Junior Engineer"
	department = "Engineering"
	total_positions = 6
	spawn_positions = 6
	department = "Engineering"
	department_flag = ENG
	selection_color = "#5b4d20"
	supervisors = "the Senior Engineers and Chief Engineer"
	economic_power = 3
	minimal_player_age = 0
	ideal_character_age = 20
	alt_titles = list(
		"Junior Maintenance Technician",
		"Junior Engine Technician",
		"Junior Damage Control Technician",
		"Junior Electrician"
		)
	outfit_type = /decl/hierarchy/outfit/job/engineering/juneng
	class = CLASS_C
	hud_icon = "hudengineertrainee"

	access = list(
		ACCESS_ENG_COMMS,
		ACCESS_ENGINEERING_LVL1,
		ACCESS_ENGINEERING_LVL2,
		ACCESS_SCIENCE_LVL1
	)
	minimal_access = list()

	min_skill = list(
		SKILL_COMPUTER     = SKILL_BASIC,
	    SKILL_HAULING      = SKILL_EXPERIENCED,
	    SKILL_CONSTRUCTION = SKILL_TRAINED,
	    SKILL_ELECTRICAL   = SKILL_TRAINED,
	    SKILL_ATMOS        = SKILL_TRAINED,
	    SKILL_ENGINES      = SKILL_EXPERIENCED
	)

	max_skill = list(
		SKILL_CONSTRUCTION = SKILL_MASTER,
	    SKILL_ELECTRICAL   = SKILL_MASTER,
	    SKILL_ATMOS        = SKILL_EXPERIENCED,
	    SKILL_ENGINES      = SKILL_MASTER
	)

	roleplay_difficulty = "Easy"
	mechanical_difficulty = "Easy - Medium"
	duties = "Help with constructions and repairs."
	codex_guides = list("<l>Hacking Wires</l>")
