class_name CustomMoveEditor
extends VBoxContainer


var move_menu: PopupMenu;
var last_selected_move_idx: int;


func _ready() -> void:
	move_menu = ($Columns/LeftColumn/Remover/Dropdown).get_popup();
	
	rebuild_move_list();
	
	move_menu.index_pressed.connect(_select_move_dropdown);


func rebuild_move_list() -> void:
	move_menu.clear();
	
	for key in AmorosData.custom_moves.keys():
		move_menu.add_item(key);


func _add_move(bypass_replace_checks: bool = false) -> void:
	var new_id: String = ($Columns/LeftColumn/Adder/Id).text;
	
	if new_id == "":
		($AddFailBadIdPopup).show();
		return;
	
	if new_id in AmorosData.known_moves.keys():
		($AddFailKnownMovePopup).show();
		return;
	
	if not bypass_replace_checks and new_id in AmorosData.custom_moves.keys():
		($ReplacePopup).show();
		return;
	
	if ($Name).text == "":
		($AddFailBadNamePopup).show();
		return;
	
	if ($Description).text == "":
		($AddFailBadDescriptionPopup).show();
		return;
	
	if ($Columns/RightColumn/Type).text == "None":
		($AddFailBadTypePopup).show();
		return;
	
	if ($Columns/RightColumn/DamageStats/Power).text == "":
		($AddFailBadPowerPopup).show();
		return;
	
	if ($Columns/RightColumn/DamageStats/Priority).text == "":
		($AddFailBadPriorityPopup).show();
		return;
	
	var move_name: String = ($Name).text;
	var description: String = ($Description).text;
	
	var type: AmorosData.AmorosType \
			= AmorosData.AmorosType.get(($Columns/RightColumn/Type).text);
	var category: AmorosData.AmorosMoveCategory \
			= AmorosData.AmorosMoveCategory.get(($Columns/RightColumn/Category).text);
	
	var power := float(($Columns/RightColumn/DamageStats/Power).text);
	var priority := float(($Columns/RightColumn/DamageStats/Priority).text);
	
	if power != int(power):
		($AddFailBadPowerPopup).show();
		return;
	
	if priority != int(priority):
		($AddFailBadPriorityPopup).show();
		return;
	
	var new_move := MoveData.create(move_name, type, int(power), category, description, int(priority));
	($/root/Creator as Creator).add_custom_move(new_id, new_move);


func _select_move_dropdown(idx: int) -> void:
	last_selected_move_idx = idx;
	
	if ($Name).text != "" \
			or ($Description).text != "" \
			or ($Columns/RightColumn/Type).text != "None" \
			or ($Columns/RightColumn/DamageStats/Power).text != "" \
			or (
				($Columns/RightColumn/DamageStats/Priority).text != ""
				and ($Columns/RightColumn/DamageStats/Priority).text != "0"
			):
		($ConfirmSelectionPopup).show();
		return;
	
	_select_move(idx);


func _select_last_move() -> void:
	_select_move(last_selected_move_idx);


func _select_move(idx: int) -> void:
	var move_id = move_menu.get_item_text(idx);
	var data = AmorosData.custom_moves[move_id];
	
	($Columns/LeftColumn/Remover/Dropdown).text = move_id;
	($Columns/LeftColumn/Adder/Id).text = move_id;
	
	($Name).text = data.name;
	($Description).text = data.description;
	
	($Columns/RightColumn/Type).select(data.type);
	($Columns/RightColumn/Category).select(data.category);
	
	($Columns/RightColumn/DamageStats/Power).text = str(data.power);
	($Columns/RightColumn/DamageStats/Priority).text = str(data.priority);


func _remove_move() -> void:
	var move_id: String = ($Columns/LeftColumn/Remover/Dropdown).text;
	
	if move_id == "":
		($RemoveFailBadIdPopup).show();
		return;
	
	($Columns/LeftColumn/Remover/Dropdown).text = "";
	($/root/Creator as Creator).remove_custom_move(move_id);
