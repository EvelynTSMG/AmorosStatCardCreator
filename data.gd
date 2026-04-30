class_name AmorosData;

enum AmorosType {
	None,
	Vanilla,
	Loving,
	Muscle,
	Control,
	Instinct,
	Toy,
	Freak,
	Spoiled,
	Group,
	Pathetic,
	Tentacle,
	Stoic,
	Rage,
}

static var type_texture_vanilla  = preload("res://types/vanilla.png");
static var type_texture_loving   = preload("res://types/loving.png");
static var type_texture_muscle   = preload("res://types/muscle.png");
static var type_texture_control  = preload("res://types/control.png");
static var type_texture_instinct = preload("res://types/instinct.png");
static var type_texture_toy      = preload("res://types/toy.png");
static var type_texture_freak    = preload("res://types/freak.png");
static var type_texture_spoiled  = preload("res://types/spoiled.png");
static var type_texture_group    = preload("res://types/group.png");
static var type_texture_pathetic = preload("res://types/pathetic.png");
static var type_texture_tentacle = preload("res://types/tentacle.png");
static var type_texture_stoic    = preload("res://types/stoic.png");
static var type_texture_rage     = preload("res://types/rage.png");


static func type_to_texture(type: AmorosType) -> Texture:
	match type:
		AmorosType.Vanilla:  return type_texture_vanilla
		AmorosType.Loving:   return type_texture_loving
		AmorosType.Muscle:   return type_texture_muscle
		AmorosType.Control:  return type_texture_control
		AmorosType.Instinct: return type_texture_instinct
		AmorosType.Toy:      return type_texture_toy
		AmorosType.Freak:    return type_texture_freak
		AmorosType.Spoiled:  return type_texture_spoiled
		AmorosType.Group:    return type_texture_group
		AmorosType.Pathetic: return type_texture_pathetic
		AmorosType.Tentacle: return type_texture_tentacle
		AmorosType.Stoic:    return type_texture_stoic
		AmorosType.Rage:     return type_texture_rage
		_: return null


static func type_to_color(type: AmorosType):
	match type:
		AmorosType.Vanilla:  return "e4d9cc"
		AmorosType.Loving:   return "ffa5c5"
		AmorosType.Muscle:   return "f0aa64"
		AmorosType.Control:  return "6a7be2"
		AmorosType.Instinct: return "fe8063"
		AmorosType.Toy:      return "7fe4b5"
		AmorosType.Freak:    return "9d7fe4"
		AmorosType.Spoiled:  return "7bd6f6"
		AmorosType.Group:    return "a6d276"
		AmorosType.Pathetic: return "ffe276"
		AmorosType.Tentacle: return "d37dc4"
		AmorosType.Stoic:    return "ae7f6b"
		AmorosType.Rage:     return "e85764"
		_: return "fffaeb"


enum AmorosMoveCategory {
	Top,
	Bottom,
	Status,
}

static func move_cat_to_string(category: AmorosMoveCategory) -> String:
	match category:
		AmorosMoveCategory.Top: return "Top"
		AmorosMoveCategory.Bottom: return "Bottom"
		AmorosMoveCategory.Status: return "Status"
		_: return "-"


enum AmorosCompanionType {
	Leader,
	Human,
	Pokemon,
}

enum AmorosBadges {
	Pity,
	Second,
	Third,
	Fourth,
	Fifth,
	Sixth,
	Seventh,
	Eighth,
}


static var known_moves: Dictionary[String, MoveData];
static var custom_moves: Dictionary[String, MoveData];

static func load_known_moves() -> void:
	var base_dir = "res://" if OS.has_feature("editor") else OS.get_executable_path().get_base_dir() + "/";
	var filepath = base_dir + "assets/moves.json";
	
	if not FileAccess.file_exists(filepath):
		print("[ERROR] Failed to read known moves: Unable to find file `", filepath, "`");
		return;
	
	var file = FileAccess.open(filepath, FileAccess.ModeFlags.READ);
	var json_string = file.get_as_text();
	file.close();

	var json = JSON.new();
	var error = json.parse(json_string);
	
	if error != OK:
		print("[ERROR] Failed to read known moves: ", json.get_error_message(), " at line ", json.get_error_line());
		return;
	
	var data_received = json.data;
	
	if typeof(data_received) != TYPE_DICTIONARY:
		print("[ERROR] Failed to read known moves: JSON root is `", str(typeof(data_received)), "` instead of `TYPE_DICTIONARY`");
		return;
	
	var dict = data_received as Dictionary;
	
	for key in dict.keys():
		if MoveData.verify_json(key, dict[key]):
			known_moves[key] = MoveData.from_json(dict[key]);

static func load_custom_moves() -> void:
	var base_dir = "res://" if OS.has_feature("editor") else OS.get_executable_path().get_base_dir() + "/";
	var filepath = base_dir + "assets/custom_moves.json";
	
	if not FileAccess.file_exists(filepath):
		print("[INFO] No custom moves detected");
		return;
	
	var file = FileAccess.open(filepath, FileAccess.ModeFlags.READ);
	var json_string = file.get_as_text();
	file.close();
	
	var json = JSON.new();
	var error = json.parse(json_string);
	
	if error != OK:
		print("[ERROR] Failed to read custom moves: ", json.get_error_message(), " at line ", json.get_error_line());
		return;
	
	var data_received = json.data;
	
	if typeof(data_received) != TYPE_DICTIONARY:
		print("[ERROR] Failed to read custom moves: JSON root is `", str(typeof(data_received)), "` instead of `TYPE_DICTIONARY`");
		return;
	
	var dict = data_received as Dictionary;
	
	for key in dict.keys():
		if MoveData.verify_json(key, dict[key]):
			custom_moves[key] = MoveData.from_json(dict[key]);


static func save_custom_moves() -> void:
	var base_dir = "res://" if OS.has_feature("editor") else OS.get_executable_path().get_base_dir() + "/";
	var filepath = base_dir + "assets/custom_moves.json";
	
	var json: Dictionary = {};
	
	for key in custom_moves.keys():
		json[key] = custom_moves[key].into_json();
	
	var file = FileAccess.open(filepath, FileAccess.ModeFlags.WRITE);
	file.store_string(JSON.stringify(json));
	file.close();


static func infer_type(move_ids: Array[String]) -> Array[AmorosType]:
	var moves: Array[MoveData] = [];
	
	for move_id in move_ids:
		if move_id != "None":
			if move_id in known_moves.keys():
				moves.append(known_moves[move_id]);
			elif move_id in custom_moves.keys():
				moves.append(custom_moves[move_id]);
	
	var type_counts: Dictionary[int, int] = {};
	
	for move in moves:
		if move.type == AmorosType.None:
			continue;
		
		if move.type in type_counts:
			type_counts[move.type] += 1;
		else:
			type_counts[move.type] = 1;
	
	var types: Array[AmorosType] = [];
	
	for type in type_counts.keys():
		# If 3 or more of one type, we're monotype!
		if type_counts[type] >= 3:
			return [type];
		
		# If 2, we qualify for that type!
		if type_counts[type] >= 2:
			types.append(type);
	
	# Edge case to not have double vanilla typing
	if len(types) == 1 and types[0] == AmorosType.Vanilla:
		return [ AmorosType.Vanilla ];
	
	# Edge case to have vanilla always come second
	if len(types) == 2 and types[0] == AmorosType.Vanilla:
		return [ types[1], types[0] ];
	
	match len(types):
		1: return [ types[0], AmorosType.Vanilla ];
		2: return types;
		_: return [ AmorosType.Vanilla ];
