/datum/job/cmo
	title = "Medical Director"
	supervisors = "the Site Director"
	economic_power = 10
	req_admin_notify = 1
	minimal_player_age = 15
	ideal_character_age = 48
	outfit_type = /decl/hierarchy/outfit/job/command/cmo
	class = CLASS_A
	hud_icon = "hudchiefmedicalofficer"
	department = "Medical"
	department_flag = MED|COM
	selection_color = "#026865"
	requirements = list(EXP_TYPE_MEDICAL = 720)

	head_position = TRUE
	total_positions = 1
	spawn_positions = 1

	access = list(
		ACCESS_COM_COMMS,
		ACCESS_MED_COMMS,
		ACCESS_MEDICAL_EQUIP,
		ACCESS_KEYAUTH,
		ACCESS_MEDICAL_LVL1,
		ACCESS_MEDICAL_LVL2,
		ACCESS_MEDICAL_LVL3,
		ACCESS_MEDICAL_LVL4,
		ACCESS_MEDICAL_LVL5,
		ACCESS_SECURITY_LVL1,
		ACCESS_SCIENCE_LVL1,
		ACCESS_ADMIN_LVL1,
		ACCESS_ADMIN_LVL2,
		ACCESS_ADMIN_LVL3,
		ACCESS_ENGINEERING_LVL1
	)
	minimal_access = list()

	min_skill = list(
	    SKILL_MEDICAL     = SKILL_EXPERIENCED,
		SKILL_ANATOMY     = SKILL_EXPERIENCED,
	    SKILL_CHEMISTRY   = SKILL_BASIC,
		SKILL_DEVICES     = SKILL_TRAINED
	)

	max_skill = list(
		SKILL_MEDICAL     = SKILL_MASTER,
	    SKILL_ANATOMY     = SKILL_MASTER,
	    SKILL_CHEMISTRY   = SKILL_MASTER
	)
	skill_points = 28
	roleplay_difficulty = "Medium - Hard"
	mechanical_difficulty = "Medium - Hard"
	duties = "Manage the Medical department. Delegate treatment and surgeries. Facilitate responses to emergencies."

/datum/job/acmo
	title = "Assistant Medical Director"
	supervisors = "the Site Director and Medical Director"
	economic_power = 10
	req_admin_notify = 1
	minimal_player_age = 15
	ideal_character_age = 44
	outfit_type = /decl/hierarchy/outfit/job/command/acmo
	class = CLASS_A
	hud_icon = "hudassistantmedicalofficer"
	department = "Medical"
	department_flag = MED|COM
	selection_color = "#026865"
	requirements = list(EXP_TYPE_MEDICAL = 560)

	total_positions = 1
	spawn_positions = 1

	access = list(
		ACCESS_COM_COMMS,
		ACCESS_MED_COMMS,
		ACCESS_MEDICAL_EQUIP,
		ACCESS_KEYAUTH,
		ACCESS_MEDICAL_LVL1,
		ACCESS_MEDICAL_LVL2,
		ACCESS_MEDICAL_LVL3,
		ACCESS_MEDICAL_LVL4,
		ACCESS_SECURITY_LVL1,
		ACCESS_SCIENCE_LVL1,
		ACCESS_ADMIN_LVL1,
		ACCESS_ADMIN_LVL2,
		ACCESS_ADMIN_LVL3,
		ACCESS_ENGINEERING_LVL1
	)
	minimal_access = list()

	min_skill = list(
	    SKILL_MEDICAL     = SKILL_EXPERIENCED,
		SKILL_ANATOMY     = SKILL_TRAINED,
	    SKILL_CHEMISTRY   = SKILL_BASIC,
		SKILL_DEVICES     = SKILL_TRAINED
	)

	max_skill = list(
		SKILL_MEDICAL     = SKILL_MASTER,
	    SKILL_ANATOMY     = SKILL_MASTER,
	    SKILL_CHEMISTRY   = SKILL_MASTER
	)
	skill_points = 26

/datum/job/surgeon
	title = "Surgeon"
	department = "Medical"
	department_flag = MED
	selection_color = "#013d3b"
	total_positions = 3
	spawn_positions = 3
	ideal_character_age = 30
	economic_power = 5
	requirements = list(EXP_TYPE_MEDICAL = 360)
	supervisors = "the Medical Director and Assistant Medical Director"
	minimal_player_age = 3
	outfit_type = /decl/hierarchy/outfit/job/medical/surgeon
	class = CLASS_B
	hud_icon = "hudsurgeon"

	access = list(
		ACCESS_MED_COMMS,
		ACCESS_MEDICAL_EQUIP,
		ACCESS_MEDICAL_LVL1,
		ACCESS_MEDICAL_LVL2,
		ACCESS_MEDICAL_LVL3,
		ACCESS_SCIENCE_LVL1,
		ACCESS_SCIENCE_LVL2
	)
	minimal_access = list()

	min_skill = list(
	    SKILL_MEDICAL     = SKILL_EXPERIENCED,
	    SKILL_ANATOMY     = SKILL_EXPERIENCED,
	    SKILL_CHEMISTRY   = SKILL_BASIC,
		SKILL_DEVICES     = SKILL_TRAINED
	)

	max_skill = list(
		SKILL_MEDICAL     = SKILL_MASTER,
	    SKILL_ANATOMY     = SKILL_MASTER,
	    SKILL_CHEMISTRY   = SKILL_MASTER
	)
	skill_points = 27

/datum/job/chemist
	title = "Chemist"
	department = "Medical"
	department_flag = MED
	minimal_player_age = 3
	total_positions = 2
	spawn_positions = 2
	requirements = list(EXP_TYPE_MEDICAL = 120)
	supervisors = "the Medical Director, Assistant Medical Director and Senior Doctor"
	selection_color = "#013d3b"
	economic_power = 4
	alt_titles = list("Pharmacist")
	ideal_character_age = 30
	outfit_type = /decl/hierarchy/outfit/job/medical/chemist
	class = CLASS_C
	hud_icon = "hudpharmacist"

	access = list(
		ACCESS_MED_COMMS,
		ACCESS_MEDICAL_EQUIP,
		ACCESS_MEDICAL_LVL1,
		ACCESS_MEDICAL_LVL2
	)
	minimal_access = list()

	min_skill = list(
	    SKILL_MEDICAL     = SKILL_TRAINED,
	    SKILL_ANATOMY     = SKILL_TRAINED,
	    SKILL_CHEMISTRY   = SKILL_EXPERIENCED,
		SKILL_DEVICES     = SKILL_TRAINED
	)

	max_skill = list(
		SKILL_MEDICAL     = SKILL_MASTER,
	    SKILL_ANATOMY     = SKILL_MASTER,
	    SKILL_CHEMISTRY   = SKILL_MASTER
	)
	skill_points = 24

	roleplay_difficulty = "Easy"
	mechanical_difficulty = "Medium - Hard"
	duties = "Mix up medicines for your department. Experiment with chemistry-based anomalies."

/datum/job/psychiatrist
	title = "Psychiatrist"
	department = "Medical"
	department_flag = MED
	selection_color = "#013d3b"
	total_positions = 1
	spawn_positions = 1
	minimal_player_age = 3
	ideal_character_age = 40
	economic_power = 5
	supervisors = "the Medical Director, Assistant Medical Director and Senior Doctor"
	alt_titles = list("Counselor")
	outfit_type = /decl/hierarchy/outfit/job/medical/psychiatrist
	class = CLASS_C
	hud_icon = "hudcounselor"

	access = list(
		ACCESS_MED_COMMS,
		ACCESS_MEDICAL_EQUIP,
		ACCESS_MEDICAL_LVL1
	)
	minimal_access = list()

	min_skill = list(
	    SKILL_MEDICAL     = SKILL_TRAINED,
	    SKILL_ANATOMY     = SKILL_TRAINED,
		SKILL_CHEMISTRY   = SKILL_BASIC,
		SKILL_DEVICES     = SKILL_TRAINED
	)

	max_skill = list(
		SKILL_MEDICAL     = SKILL_MASTER,
	    SKILL_ANATOMY     = SKILL_MASTER,
	    SKILL_CHEMISTRY   = SKILL_MASTER
	)
	skill_points = 24

	roleplay_difficulty = "Medium - Hard"
	mechanical_difficulty = "Easy"
	duties = "Administer therapy and drugs to maintain mental health, in personnel and SCPs alike."

/datum/job/medicaldoctor
	title = "Medical Doctor"
	department = "Medical"
	department_flag = MED
	selection_color = "#013d3b"
	total_positions = 5
	spawn_positions = 5
	requirements = list(EXP_TYPE_MEDICAL = 120)
	supervisors = "the Medical Director, Assistant Medical Director and Senior Doctor"
	ideal_character_age = 26
	minimal_player_age = 3
	economic_power = 5
	alt_titles = list("Coroner")
	outfit_type = /decl/hierarchy/outfit/job/medical/medicaldoctor
	class = CLASS_C
	hud_icon = "hudphysician"

	access = list(
		ACCESS_MED_COMMS,
		ACCESS_MEDICAL_EQUIP,
		ACCESS_MEDICAL_LVL1,
		ACCESS_MEDICAL_LVL2,
		ACCESS_MEDICAL_LVL3,
		ACCESS_SCIENCE_LVL1
	)
	minimal_access = list()

	min_skill = list(
	    SKILL_MEDICAL     = SKILL_TRAINED,
	    SKILL_ANATOMY     = SKILL_TRAINED,
	    SKILL_CHEMISTRY   = SKILL_TRAINED,
		SKILL_DEVICES     = SKILL_TRAINED
	)

	max_skill = list(
		SKILL_MEDICAL     = SKILL_MASTER,
	    SKILL_ANATOMY     = SKILL_MASTER,
	    SKILL_CHEMISTRY   = SKILL_MASTER
	)
	skill_points = 24
	roleplay_difficulty = "Easy"
	mechanical_difficulty = "Medium"
	duties = "Diagnose and administer treatment to incoming patients. Triage the wounded in times of duress."

/datum/job/surgeon
	title = "Surgeon"

/datum/job/emt
	title = "Emergency Medical Technician"
	department = "Medical"
	department_flag = MED
	selection_color = "#013d3b"
	total_positions = 4
	spawn_positions = 4
	ideal_character_age = 40
	economic_power = 5
	requirements = list(EXP_TYPE_MEDICAL = 240)
	//duties = "<big><b>As the EMT it is your job to man the medical post near the Class D cell block, and treat any injuries there of the guards or Class D's. You only have limited supplies, so it's best to make them count.</b></big>"
	supervisors = "the Medical Director and Assistant Medical Director"
	outfit_type = /decl/hierarchy/outfit/job/medical/emt
	class = CLASS_C
	hud_icon = "hudemt"

	access = list(
		ACCESS_MED_COMMS,
		ACCESS_MEDICAL_EQUIP,
		ACCESS_SECURITY_LVL1,
		ACCESS_SCIENCE_LVL1,
		ACCESS_ENGINEERING_LVL1,
		ACCESS_ADMIN_LVL1,
		ACCESS_MEDICAL_LVL1,
		ACCESS_MEDICAL_LVL2
	)
	minimal_access = list()

	min_skill = list(
	    SKILL_MEDICAL     = SKILL_TRAINED,
	    SKILL_ANATOMY     = SKILL_TRAINED,
	    SKILL_CHEMISTRY   = SKILL_BASIC,
		SKILL_DEVICES     = SKILL_TRAINED
	)

	max_skill = list(
		SKILL_MEDICAL     = SKILL_MASTER,
	    SKILL_ANATOMY     = SKILL_MASTER,
	    SKILL_CHEMISTRY   = SKILL_MASTER
	)
	skill_points = 20
	roleplay_difficulty = "Easy"
	mechanical_difficulty = "Hard"
	duties = "Perform surgery on patients, both routine and during emergencies."

/datum/job/emt
	title = "Emergency Medical Technician"

/datum/job/medicalintern
	title = "Medical Intern"
	department = "Medical"
	department_flag = MED
	selection_color = "#013d3b"
	total_positions = 4
	spawn_positions = 4
	ideal_character_age = 40
	economic_power = 5
	supervisors = "the Medical Director and Assistant Medical Director"
	alt_titles = list("Resident", "Medical Attendant")
	outfit_type = /decl/hierarchy/outfit/job/medical/medicalintern
	class = CLASS_C
	hud_icon = "hudtraineemedicaltechnician"

	access = list(
		ACCESS_MED_COMMS,
		ACCESS_MEDICAL_EQUIP,
		ACCESS_MEDICAL_LVL1,
		ACCESS_MEDICAL_LVL2,
		ACCESS_SCIENCE_LVL1
	)
	minimal_access = list()

	min_skill = list(
	    SKILL_MEDICAL     = SKILL_TRAINED,
	    SKILL_ANATOMY     = SKILL_BASIC,
	    SKILL_CHEMISTRY   = SKILL_BASIC,
		SKILL_DEVICES     = SKILL_TRAINED
	)

	max_skill = list(
		SKILL_MEDICAL     = SKILL_EXPERIENCED,
	    SKILL_ANATOMY     = SKILL_TRAINED,
	    SKILL_CHEMISTRY   = SKILL_EXPERIENCED
	)
	skill_points = 20

	roleplay_difficulty = "Easy"
	mechanical_difficulty = "Medium - Hard"
	duties = "Quickly respond to emergencies. Triage the wounded. Stabilize patients and bring them to a Medical post if possible."
