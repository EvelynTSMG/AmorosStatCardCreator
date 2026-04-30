extends Control
class_name Creator


# Frankly, I'm more comfortable using C# than GDScript,
# so this code is probably rather messy.
# Also, I don't want to spend the time to figure out how to make it better q:


enum ColorSet {
	Red,
	Green,
	Blue,
	Custom1,
	Custom2,
}


@export_group("Colors")
@export var color_set = ColorSet.Green;
@export var color1: Color;
@export var color2: Color;

@export_group("Basic Details")
@export var character_name = "";

@export var companion_type = AmorosData.AmorosCompanionType.Pokemon;

@export var pronouns: String = "";
@export var genitals: String = "";
@export var species: String = "";

@export var auto_infer_type: bool = true;
@export var type1 := AmorosData.AmorosType.None;
@export var type2 := AmorosData.AmorosType.None;

@export_group("Stats")
@export_range(1,60) var stamina: int = 10;
@export_range(1,60) var top_atk: int = 10;
@export_range(1,60) var bot_atk: int = 10;
@export_range(1,60) var top_def: int = 10;
@export_range(1,60) var bot_def: int = 10;
@export_range(1,60) var horniness: int = 10;

@export_range(0,120) var current_health: int = 20;

@export_group("Badges, Bond, Experience")
@export_range(0, 10) var experience: int = 0;
@export_range(0, 10) var locked_experience: int = 0;
@export_range(0, 6) var bond: int = 0;
@export var badges_always_visible: bool = false;

@export_subgroup("Badges")
@export var pity = false;
@export var badge2 = false;
@export var badge3 = false;
@export var badge4 = false;
@export var badge5 = false;
@export var badge6 = false;
@export var badge7 = false;
@export var badge8 = false;

@export_subgroup("Held Badges")
@export var holding_pity = false;
@export var holding_badge2 = false;
@export var holding_badge3 = false;
@export var holding_badge4 = false;
@export var holding_badge5 = false;
@export var holding_badge6 = false;
@export var holding_badge7 = false;
@export var holding_badge8 = false;


static var bond_texture = preload("res://icons/bond.png");
static var exp_texture  = preload("res://icons/exp.png");
static var lock_texture = preload("res://icons/exp_lock.png");

static var shader_white = preload("res://white.gdshader");
static var shader_black = preload("res://black.gdshader");


var move_menu1: PopupMenu;
var move_menu2: PopupMenu;
var move_menu3: PopupMenu;
var move_menu4: PopupMenu;

var selected_move1: int;
var selected_move2: int;
var selected_move3: int;
var selected_move4: int;


var has_unsaved_changes: bool = false;


func _ready() -> void:
	get_tree().set_auto_accept_quit(false);
	
	($ScreenshotView).world_2d = get_viewport().world_2d;
	($ScreenshotView).render_target_update_mode = SubViewport.UPDATE_ALWAYS;
	($ScreenshotView).canvas_transform.origin = Vector2(-100, -300);
	
	($EditorUI/ScrollContainer/MarginContainer/OptionPanels/BasicDetails/CompanionType).selected = 2;
	
	# Populate move lists
	AmorosData.load_known_moves();
	AmorosData.load_custom_moves();
	
	move_menu1 = ($EditorUI/ScrollContainer/MarginContainer/OptionPanels/MoveSet/MoveList/Move1).get_popup();
	move_menu2 = ($EditorUI/ScrollContainer/MarginContainer/OptionPanels/MoveSet/MoveList/Move2).get_popup();
	move_menu3 = ($EditorUI/ScrollContainer/MarginContainer/OptionPanels/MoveSet/MoveList/Move3).get_popup();
	move_menu4 = ($EditorUI/ScrollContainer/MarginContainer/OptionPanels/MoveSet/MoveList/Move4).get_popup();
	
	rebuild_move_lists();
	($EditorUI/ScrollContainer/MarginContainer/OptionPanels/CustomMoveEditor as CustomMoveEditor).rebuild_move_list();
	
	move_menu1.index_pressed.connect(select_move1);
	move_menu2.index_pressed.connect(select_move2);
	move_menu3.index_pressed.connect(select_move3);
	move_menu4.index_pressed.connect(select_move4);


func _notification(msg) -> void:
	if msg == NOTIFICATION_WM_CLOSE_REQUEST:
		if has_unsaved_changes:
			($UnsavedMovesExitConfirmation).show();
		else:
			get_tree().quit();


func close() -> void:
	get_tree().quit();


func select_move(idx: int, menu: MenuButton, move: Move) -> void:
	var move_id = menu.get_popup().get_item_text(idx);
	menu.text = move_id;
	
	if move_id == "None":
		move.exists = false;
		return;

	move.exists = true;
	if move_id in AmorosData.known_moves.keys():
		move.load_data(move_id, AmorosData.known_moves[move_id]);
	else:
		move.load_data(move_id, AmorosData.custom_moves[move_id]);

func select_move1(idx: int) -> void:
	select_move(
		idx,
		($EditorUI/ScrollContainer/MarginContainer/OptionPanels/MoveSet/MoveList/Move1),
		($Card/RightPanel/MoveSet/Move1)
	);
	selected_move1 = idx;

func select_move2(idx: int) -> void:
	select_move(
		idx,
		($EditorUI/ScrollContainer/MarginContainer/OptionPanels/MoveSet/MoveList/Move2),
		($Card/RightPanel/MoveSet/Move2)
	);
	selected_move2 = idx;

func select_move3(idx: int) -> void:
	select_move(
		idx,
		($EditorUI/ScrollContainer/MarginContainer/OptionPanels/MoveSet/MoveList/Move3),
		($Card/RightPanel/MoveSet/Move3)
	);
	selected_move3 = idx;

func select_move4(idx: int) -> void:
	select_move(
		idx,
		($EditorUI/ScrollContainer/MarginContainer/OptionPanels/MoveSet/MoveList/Move4),
		($Card/RightPanel/MoveSet/Move4)
	);
	selected_move4 = idx;


func rebuild_move_lists() -> void:
	move_menu1.clear();
	move_menu2.clear();
	move_menu3.clear();
	move_menu4.clear();
	
	move_menu1.add_item("None");
	move_menu2.add_item("None");
	move_menu3.add_item("None");
	move_menu4.add_item("None");
	
	for key in AmorosData.known_moves:
		move_menu1.add_item(key);
		move_menu2.add_item(key);
		move_menu3.add_item(key);
		move_menu4.add_item(key);
	
	for key in AmorosData.custom_moves:
		move_menu1.add_item(key);
		move_menu2.add_item(key);
		move_menu3.add_item(key);
		move_menu4.add_item(key);


func add_custom_move(id: String, data: MoveData) -> void:
	AmorosData.custom_moves[id] = data;
	has_unsaved_changes = true;
	
	# Easier to reset then sort
	rebuild_move_lists();
	($EditorUI/ScrollContainer/MarginContainer/OptionPanels/CustomMoveEditor as CustomMoveEditor).rebuild_move_list();
	
	# Make sure to reload it
	if ($Card/RightPanel/MoveSet/Move1 as Move).move_id == id:
		select_move(
			selected_move1,
			($EditorUI/ScrollContainer/MarginContainer/OptionPanels/MoveSet/MoveList/Move1),
			($Card/RightPanel/MoveSet/Move1)
		);
	
	if ($Card/RightPanel/MoveSet/Move2 as Move).move_id == id:
		select_move(
			selected_move2,
			($EditorUI/ScrollContainer/MarginContainer/OptionPanels/MoveSet/MoveList/Move2),
			($Card/RightPanel/MoveSet/Move2)
		);
	
	if ($Card/RightPanel/MoveSet/Move3 as Move).move_id == id:
		select_move(
			selected_move3,
			($EditorUI/ScrollContainer/MarginContainer/OptionPanels/MoveSet/MoveList/Move3),
			($Card/RightPanel/MoveSet/Move3)
		);
	
		select_move(
			selected_move4,
			($EditorUI/ScrollContainer/MarginContainer/OptionPanels/MoveSet/MoveList/Move4),
			($Card/RightPanel/MoveSet/Move4)
		);


func remove_custom_move(id: String) -> void:
	AmorosData.custom_moves.erase(id);
	has_unsaved_changes = true;
	
	# Easier to reset then try to find it
	rebuild_move_lists();
	($EditorUI/ScrollContainer/MarginContainer/OptionPanels/CustomMoveEditor as CustomMoveEditor).rebuild_move_list();
	
	# Make sure to not keep it around
	if ($Card/RightPanel/MoveSet/Move1 as Move).move_id == id:
		selected_move1 = 0;
		select_move(
			0,
			($EditorUI/ScrollContainer/MarginContainer/OptionPanels/MoveSet/MoveList/Move1),
			($Card/RightPanel/MoveSet/Move1)
		);
	
	if ($Card/RightPanel/MoveSet/Move2 as Move).move_id == id:
		selected_move2 = 0;
		select_move(
			0,
			($EditorUI/ScrollContainer/MarginContainer/OptionPanels/MoveSet/MoveList/Move2),
			($Card/RightPanel/MoveSet/Move2)
		);
	
	if ($Card/RightPanel/MoveSet/Move3 as Move).move_id == id:
		selected_move4 = 0;
		select_move(
			0,
			($EditorUI/ScrollContainer/MarginContainer/OptionPanels/MoveSet/MoveList/Move3),
			($Card/RightPanel/MoveSet/Move3)
		);
	
	if ($Card/RightPanel/MoveSet/Move4 as Move).move_id == id:
		selected_move4 = 0;
		select_move(
			0,
			($EditorUI/ScrollContainer/MarginContainer/OptionPanels/MoveSet/MoveList/Move4),
			($Card/RightPanel/MoveSet/Move4)
		);


func save_custom_moves() -> void:
	AmorosData.save_custom_moves();
	has_unsaved_changes = false;


func export_card(path: String) -> void:
	var json = {
		"Colors": {
			"Set": str(color_set),
			"Color1": color1.to_html(),
			"Color2": color2.to_html(),
		},
		
		"Basic Details": {
			"Name": character_name,
			"Type": str(companion_type),
			"Pronouns": pronouns,
			"Genitals": genitals,
			"Species": species,
		},
		
		"Types": {
			"AutoInfer": auto_infer_type,
			"Type1": str(type1),
			"Type2": str(type2),
		},
		
		"Stats": {
			"Stamina": stamina,
			"Top Atk": top_atk,
			"Bot Atk": bot_atk,
			"Top Def": top_def,
			"Bot Def": bot_def,
			"Horniness": horniness,
			"Current Health": current_health,
		},
		
		"Move Set": {
			"Move 1": selected_move1,
			"Move 2": selected_move2,
			"Move 3": selected_move3,
			"Move 4": selected_move4,
		},
		
		"Progress": {
			"Experience": experience,
			"Locked Experience": locked_experience,
			"Bond": bond,
			
			"Badges": {
				"Always Visible": badges_always_visible,
				"Pity": pity,
				"Badge 2": badge2,
				"Badge 3": badge3,
				"Badge 4": badge4,
				"Badge 5": badge5,
				"Badge 6": badge6,
				"Badge 7": badge7,
				"Badge 8": badge8,
			},
			
			"Held Badges": {
				"Pity": holding_pity,
				"Badge 2": holding_badge2,
				"Badge 3": holding_badge3,
				"Badge 4": holding_badge4,
				"Badge 5": holding_badge5,
				"Badge 6": holding_badge6,
				"Badge 7": holding_badge7,
				"Badge 8": holding_badge8,
			},
		}
	}
	
	var json_string = JSON.stringify(json);
	var file = FileAccess.open(path, FileAccess.WRITE);
	file.store_string(json_string);
	file.close();


func open_export_dialog() -> void:
	($ExportCardFileDialog).popup_file_dialog();


func import_card(path: String) -> void:
	var file = FileAccess.open(path, FileAccess.READ);
	var json = JSON.parse_string(file.get_as_text());
	file.close();
	
	color_set = json["Colors"]["Set"] as ColorSet;
	color1 = json["Colors"]["Color1"];
	color2 = json["Colors"]["Color2"];
	
	character_name = json["Basic Details"]["Name"];
	companion_type = json["Basic Details"]["Type"] as AmorosData.AmorosCompanionType;
	pronouns = json["Basic Details"]["Pronouns"];
	genitals = json["Basic Details"]["Genitals"];
	species = json["Basic Details"]["Species"];
	
	auto_infer_type = json["Types"]["AutoInfer"];
	type1 = json["Types"]["Type1"] as AmorosData.AmorosType;
	type2 = json["Types"]["Type2"] as AmorosData.AmorosType;
	
	stamina = json["Stats"]["Stamina"];
	top_atk = json["Stats"]["Top Atk"];
	bot_atk = json["Stats"]["Bot Atk"];
	top_def = json["Stats"]["Top Def"];
	bot_def = json["Stats"]["Bot Def"];
	horniness = json["Stats"]["Horniness"];
	current_health = json["Stats"]["Current Health"];
	
	selected_move1 = json["Move Set"]["Move 1"];
	selected_move2 = json["Move Set"]["Move 2"];
	selected_move3 = json["Move Set"]["Move 3"];
	selected_move4 = json["Move Set"]["Move 4"];
	
	experience = json["Progress"]["Experience"];
	locked_experience = json["Progress"]["Locked Experience"];
	bond = json["Progress"]["Bond"];
	
	badges_always_visible = json["Progress"]["Badges"]["Always Visible"];
	
	pity = json["Progress"]["Badges"]["Pity"];
	badge2 = json["Progress"]["Badges"]["Badge 2"];
	badge3 = json["Progress"]["Badges"]["Badge 3"];
	badge4 = json["Progress"]["Badges"]["Badge 4"];
	badge5 = json["Progress"]["Badges"]["Badge 5"];
	badge6 = json["Progress"]["Badges"]["Badge 6"];
	badge7 = json["Progress"]["Badges"]["Badge 7"];
	badge8 = json["Progress"]["Badges"]["Badge 8"];
	
	holding_pity = json["Progress"]["Held Badges"]["Pity"];
	holding_badge2 = json["Progress"]["Held Badges"]["Badge 2"];
	holding_badge3 = json["Progress"]["Held Badges"]["Badge 3"];
	holding_badge4 = json["Progress"]["Held Badges"]["Badge 4"];
	holding_badge5 = json["Progress"]["Held Badges"]["Badge 5"];
	holding_badge6 = json["Progress"]["Held Badges"]["Badge 6"];
	holding_badge7 = json["Progress"]["Held Badges"]["Badge 7"];
	holding_badge8 = json["Progress"]["Held Badges"]["Badge 8"];
	
	($EditorUI/ScrollContainer/MarginContainer/OptionPanels/BasicDetails/Name).text = character_name;
	($EditorUI/ScrollContainer/MarginContainer/OptionPanels/BasicDetails/CompanionType).select(companion_type);
	($EditorUI/ScrollContainer/MarginContainer/OptionPanels/BasicDetails/Pronouns).text = pronouns;
	($EditorUI/ScrollContainer/MarginContainer/OptionPanels/BasicDetails/Genitals).text = genitals;
	($EditorUI/ScrollContainer/MarginContainer/OptionPanels/BasicDetails/Species).text = species;
	
	($EditorUI/ScrollContainer/MarginContainer/OptionPanels/Types/AutoInfer).button_pressed = auto_infer_type;
	($EditorUI/ScrollContainer/MarginContainer/OptionPanels/Types/Type1).select(type1);
	($EditorUI/ScrollContainer/MarginContainer/OptionPanels/Types/Type2).select(type2);
	
	($EditorUI/ScrollContainer/MarginContainer/OptionPanels/Colors/ColorSet).select(color_set);
	($EditorUI/ScrollContainer/MarginContainer/OptionPanels/Colors/ColorMain).color = color1;
	($EditorUI/ScrollContainer/MarginContainer/OptionPanels/Colors/ColorLight).color = color2;
	
	($EditorUI/ScrollContainer/MarginContainer/OptionPanels/Stats/StatsGrid/CurrentHealth).text = str(current_health);
	($EditorUI/ScrollContainer/MarginContainer/OptionPanels/Stats/StatsGrid/Stamina).text = str(stamina);
	($EditorUI/ScrollContainer/MarginContainer/OptionPanels/Stats/StatsGrid/TopAtk).text = str(top_atk);
	($EditorUI/ScrollContainer/MarginContainer/OptionPanels/Stats/StatsGrid/BotAtk).text = str(bot_atk);
	($EditorUI/ScrollContainer/MarginContainer/OptionPanels/Stats/StatsGrid/TopDef).text = str(top_def);
	($EditorUI/ScrollContainer/MarginContainer/OptionPanels/Stats/StatsGrid/BotDef).text = str(bot_def);
	($EditorUI/ScrollContainer/MarginContainer/OptionPanels/Stats/Horniness).text = str(horniness);
	
	select_move(
		selected_move1,
		($EditorUI/ScrollContainer/MarginContainer/OptionPanels/MoveSet/MoveList/Move1),
		($Card/RightPanel/MoveSet/Move1)
	)
	
	select_move(
		selected_move2,
		($EditorUI/ScrollContainer/MarginContainer/OptionPanels/MoveSet/MoveList/Move2),
		($Card/RightPanel/MoveSet/Move2)
	)
	
	select_move(
		selected_move3,
		($EditorUI/ScrollContainer/MarginContainer/OptionPanels/MoveSet/MoveList/Move3),
		($Card/RightPanel/MoveSet/Move3)
	)
	
	select_move(
		selected_move4,
		($EditorUI/ScrollContainer/MarginContainer/OptionPanels/MoveSet/MoveList/Move4),
		($Card/RightPanel/MoveSet/Move4)
	)
	
	($EditorUI/ScrollContainer/MarginContainer/OptionPanels/EXPBond/Experience).text = str(experience);
	($EditorUI/ScrollContainer/MarginContainer/OptionPanels/EXPBond/LockedExperience).text = str(locked_experience);
	($EditorUI/ScrollContainer/MarginContainer/OptionPanels/EXPBond/Bond).text = str(bond);
	
	($EditorUI/ScrollContainer/MarginContainer/OptionPanels/BadgeOptions/BadgesAlwaysVisible).button_pressed = badges_always_visible;
	
	($EditorUI/ScrollContainer/MarginContainer/OptionPanels/BadgeOptions/BadgeLists/Badges/BadgeList/Badge1).button_pressed = pity;
	($EditorUI/ScrollContainer/MarginContainer/OptionPanels/BadgeOptions/BadgeLists/Badges/BadgeList/Badge2).button_pressed = badge2;
	($EditorUI/ScrollContainer/MarginContainer/OptionPanels/BadgeOptions/BadgeLists/Badges/BadgeList/Badge3).button_pressed = badge3;
	($EditorUI/ScrollContainer/MarginContainer/OptionPanels/BadgeOptions/BadgeLists/Badges/BadgeList/Badge4).button_pressed = badge4;
	($EditorUI/ScrollContainer/MarginContainer/OptionPanels/BadgeOptions/BadgeLists/Badges/BadgeList/Badge5).button_pressed = badge5;
	($EditorUI/ScrollContainer/MarginContainer/OptionPanels/BadgeOptions/BadgeLists/Badges/BadgeList/Badge6).button_pressed = badge6;
	($EditorUI/ScrollContainer/MarginContainer/OptionPanels/BadgeOptions/BadgeLists/Badges/BadgeList/Badge7).button_pressed = badge7;
	($EditorUI/ScrollContainer/MarginContainer/OptionPanels/BadgeOptions/BadgeLists/Badges/BadgeList/Badge8).button_pressed = badge8;
	
	($EditorUI/ScrollContainer/MarginContainer/OptionPanels/BadgeOptions/BadgeLists/BadgesHeld/BadgeList/Badge1).button_pressed = holding_pity;
	($EditorUI/ScrollContainer/MarginContainer/OptionPanels/BadgeOptions/BadgeLists/BadgesHeld/BadgeList/Badge2).button_pressed = holding_badge2;
	($EditorUI/ScrollContainer/MarginContainer/OptionPanels/BadgeOptions/BadgeLists/BadgesHeld/BadgeList/Badge3).button_pressed = holding_badge3;
	($EditorUI/ScrollContainer/MarginContainer/OptionPanels/BadgeOptions/BadgeLists/BadgesHeld/BadgeList/Badge4).button_pressed = holding_badge4;
	($EditorUI/ScrollContainer/MarginContainer/OptionPanels/BadgeOptions/BadgeLists/BadgesHeld/BadgeList/Badge5).button_pressed = holding_badge5;
	($EditorUI/ScrollContainer/MarginContainer/OptionPanels/BadgeOptions/BadgeLists/BadgesHeld/BadgeList/Badge6).button_pressed = holding_badge6;
	($EditorUI/ScrollContainer/MarginContainer/OptionPanels/BadgeOptions/BadgeLists/BadgesHeld/BadgeList/Badge7).button_pressed = holding_badge7;
	($EditorUI/ScrollContainer/MarginContainer/OptionPanels/BadgeOptions/BadgeLists/BadgesHeld/BadgeList/Badge8).button_pressed = holding_badge8;


func open_import_dialog() -> void:
	($ImportCardFileDialog).popup_file_dialog();


func save_card(path: String) -> void:
	var image: Image = ($ScreenshotView).get_texture().get_image()
	image.save_png(path);


func open_save_dialog() -> void:
	($SaveCardFileDialog).popup_file_dialog();


func import_portrait(path: String) -> void:
	var image = Image.load_from_file(path);
	($"/root/Creator/Card/DataPanel/Portrait").texture = ImageTexture.create_from_image(image);


func _unhandled_input(event: InputEvent) -> void:
	# For saving the image using F12
	if event.is_action_pressed("ui_screenshot"):
		open_save_dialog();
	
	# For pasting images using ctrl + V
	if event.is_action_pressed("ui_paste"):
		if DisplayServer.clipboard_has_image():
			var image = DisplayServer.clipboard_get_image()
			($"/root/Creator/Card/DataPanel/Portrait").texture = ImageTexture.create_from_image(image);


func open_portrait_dialog() -> void:
	($PortraitFileDialog).popup_file_dialog();


func set_value_of(valueof: String, value) -> void:
	set(valueof, value);


func _process(_delta: float) -> void:
	($Card/DataPanel/Name).text = character_name;

	# Details
	($Card/DataPanel/DetailsPanel/Pronouns).text = pronouns;
	($Card/DataPanel/DetailsPanel/Genitals).text = genitals;
	($Card/DataPanel/DetailsPanel/Species).text = species;
	
	# Stats
	($Card/DataPanel/StatList/StaminaStat/Value).text = str(stamina);
	($Card/DataPanel/StatList/TopAtkStat/Value).text = str(top_atk);
	($Card/DataPanel/StatList/BotAtkStat/Value).text = str(bot_atk);
	($Card/DataPanel/StatList/TopDefStat/Value).text = str(top_def);
	($Card/DataPanel/StatList/BotDefStat/Value).text = str(bot_def);
	($Card/DataPanel/StatList/HorninessStat/Value).text = str(horniness);
	
	($Card/DataPanel/BottomDataPanel/Items/CurrentHealthPanel/Health).text = "%d / %d" % [min(current_health, stamina * 2), stamina * 2];
	
	# Types
	var true_type1 = type1;
	var true_type2 = type2;
	
	if auto_infer_type:
		var move_ids: Array[String] = [
			move_menu1.get_item_text(selected_move1),
			move_menu2.get_item_text(selected_move2),
			move_menu3.get_item_text(selected_move3),
			move_menu4.get_item_text(selected_move4),
		];
		
		var auto_types = AmorosData.infer_type(move_ids);
		
		match len(auto_types):
			1:
				true_type1 = auto_types[0];
				true_type2 = AmorosData.AmorosType.None;
			2:
				true_type1 = auto_types[0];
				true_type2 = auto_types[1];
	
	if true_type1 != AmorosData.AmorosType.None:
		($Card/DataPanel/BottomDataPanel/Items/TypePanel/Type1).texture = AmorosData.type_to_texture(true_type1);
		($Card/DataPanel/BottomDataPanel/Items/TypePanel/Type1).visible = true;
	else:
		($Card/DataPanel/BottomDataPanel/Items/TypePanel/Type1).visible = false;
	
	if true_type2 != AmorosData.AmorosType.None:
		($Card/DataPanel/BottomDataPanel/Items/TypePanel/Type2).texture = AmorosData.type_to_texture(true_type2);
		($Card/DataPanel/BottomDataPanel/Items/TypePanel/Type2).visible = true;
	else:
		($Card/DataPanel/BottomDataPanel/Items/TypePanel/Type2).visible = false;

	# Color Sets
	var light_color: Color;
	var dark_color: Color;
	
	match color_set:
		ColorSet.Custom2:
			dark_color = color1;
			light_color = color2;
			
		ColorSet.Custom1:
			dark_color = color1;
			light_color = Color(color1)
			light_color.ok_hsl_l += 0.3
		
		ColorSet.Red:
			dark_color = Color("ff726f")
			light_color = Color("ffd8cc")
		
		ColorSet.Green:
			dark_color = Color("8eed8d");
			light_color = Color("c6f3bc");
		
		ColorSet.Blue:
			dark_color = Color("4b94e7");
			light_color = Color("cce6ef");

	($Background).color = dark_color;
	($Card/DataPanel/StatList/StaminaStat/Background).color = light_color;
	($Card/DataPanel/StatList/BotAtkStat/Background).color = light_color;
	($Card/DataPanel/StatList/BotDefStat/Background).color = light_color;
	
	# Held Badges
	($Card/DataPanel/HeldBadges/Pity).visible = holding_pity;
	($Card/DataPanel/HeldBadges/Badge2).visible = holding_badge2;
	($Card/DataPanel/HeldBadges/Badge3).visible = holding_badge3;
	($Card/DataPanel/HeldBadges/Badge4).visible = holding_badge4;
	($Card/DataPanel/HeldBadges/Badge5).visible = holding_badge5;
	($Card/DataPanel/HeldBadges/Badge6).visible = holding_badge6;
	($Card/DataPanel/HeldBadges/Badge7).visible = holding_badge7;
	($Card/DataPanel/HeldBadges/Badge8).visible = holding_badge8;
	
	# Limit experience
	if (10 - locked_experience) < experience:
		experience = 10 - locked_experience;
		($EditorUI/ScrollContainer/MarginContainer/OptionPanels/EXPBond/Experience).text = str(experience);
	
	# Bond/Exp/Badges
	match companion_type:
		AmorosData.AmorosCompanionType.Leader:
			($Card/RightPanel/BondExpData/ExpData).visible   = false;
			($Card/RightPanel/BondExpData/BondData).visible  = false;
			($Card/RightPanel/BondExpData/BadgeData).visible = true;
			
			var pips = ($Card/RightPanel/BondExpData/BadgeData/Pips).get_children();
			for pip_idx in range(0, 8):
				var pip = pips[pip_idx] as CanvasItem;
				
				var unlocked = false;
				match pip_idx:
					0: unlocked = pity;
					1: unlocked = badge2;
					2: unlocked = badge3;
					3: unlocked = badge4;
					4: unlocked = badge5;
					5: unlocked = badge6;
					6: unlocked = badge7;
					7: unlocked = badge8;
				
				if unlocked:
					pip.material.set("shader", null);
					pip.visible = true;
				elif badges_always_visible:
					pip.material.set("shader", shader_black);
					pip.visible = true;
				else:
					pip.visible = false;
		
		AmorosData.AmorosCompanionType.Human:
			($Card/RightPanel/BondExpData/ExpData).visible   = false;
			($Card/RightPanel/BondExpData/BondData).visible  = true;
			($Card/RightPanel/BondExpData/BadgeData).visible = false;
			
			var pips = ($Card/RightPanel/BondExpData/BondData/Pips).get_children();
			
			var bonded = bond;
			for pip_idx in range(0, 6):
				var pip = pips[pip_idx] as CanvasItem;
				
				if bonded > 0:
					pip.material.set("shader", shader_white);
				else:
					pip.material.set("shader", shader_black);

				bonded -= 1;
		
		AmorosData.AmorosCompanionType.Pokemon:
			($Card/RightPanel/BondExpData/ExpData).visible   = true;
			($Card/RightPanel/BondExpData/BondData).visible  = false;
			($Card/RightPanel/BondExpData/BadgeData).visible = false;
			
			var pips = ($Card/RightPanel/BondExpData/ExpData/Pips).get_children();
			
			var locked = locked_experience;
			var pip_idx = 9;
			while pip_idx >= 0:
				var pip = pips[pip_idx] as TextureRect;
				
				if locked == 1:
					pip.texture = lock_texture;
					pip.material.set("shader", shader_black);
					pip.custom_minimum_size.x = 42.0;
					pip.visible = true;
				elif locked > 0:
					pip.visible = false;
				else:
					pip.texture = exp_texture;
					pip.custom_minimum_size.x = 38.0;
					pip.visible = true;
				
				locked -= 1;
				pip_idx -= 1;
		
			var experienced = experience;
			for pip_idx2 in range(0, 10 - locked_experience):
				var pip = pips[pip_idx2] as CanvasItem;
				
				if experienced > 0:
					pip.material.set("shader", shader_white);
				else:
					pip.material.set("shader", shader_black);
				
				experienced -= 1;
