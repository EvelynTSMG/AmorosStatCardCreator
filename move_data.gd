class_name MoveData
extends Object


@export_multiline var name: String = "";
@export var type: AmorosData.AmorosType = AmorosData.AmorosType.None;
@export_range(0, 60, 5) var power: int = 10;
@export var category: AmorosData.AmorosMoveCategory = AmorosData.AmorosMoveCategory.Top;
@export_multiline var description: String = "";
@export_range(-10, 10) var priority: int = 0;


# This function is static, it can't be shadowing the instance fields above!!! Stupid Godot!
@warning_ignore("shadowed_variable")
static func create(
	name: String,
	type: AmorosData.AmorosType,
	power: int,
	category: AmorosData.AmorosMoveCategory,
	description: String,
	priority: int
) -> MoveData:
	var data = new();
	
	data.name = name;
	data.type = type;
	data.power = power;
	data.category = category;
	data.description = description;
	data.priority = priority;
	
	return data;


static func verify_json(id: String, json: Dictionary) -> bool:
	if not json.has("name"):
		print("[ERROR] Failed to load move data: ", id, " has no \"name\" field");
		return false;
	
	if typeof(json["name"]) != TYPE_STRING:
		print("[ERROR] Failed to load move data: ", id, " has non-string name");
		return false;
	
	if not json.has("type"):
		print("[ERROR] Failed to load move data: ", id, " has no \"type\" field");
		return false;
	
	if AmorosData.AmorosType.get(json["type"]) == null:
		print("[ERROR] Failed to load move data: ", id, " has unrecognized type");
		return false;
	
	if not json.has("power"):
		print("[ERROR] Failed to load move data: ", id, " has no \"power\" field");
		return false;
	
	if typeof(json["power"]) != TYPE_INT and (typeof(json["power"]) != TYPE_FLOAT or json["power"] != json["power"] as int):
		print("[ERROR] Failed to load move data: ", id, " has non-int power");
		return false;
	
	if not json.has("category"):
		print("[ERROR] Failed to load move data: ", id, " has no \"category\" field");
		return false;
	
	if AmorosData.AmorosMoveCategory.get(json["category"]) == null:
		print("[ERROR] Failed to load move data: ", id, " has unrecognized category");
		return false;
	
	if not json.has("description"):
		print("[ERROR] Failed to load move data: ", id, " has no \"description\" field");
		return false;
	
	if typeof(json["description"]) != TYPE_STRING:
		print("[ERROR] Failed to load move data: ", id, " has non-string description");
		return false;
	
	if not json.has("priority"):
		print("[ERROR] Failed to load move data: ", id, " has no \"priority\" field");
		return false;
	
	if typeof(json["priority"]) != TYPE_INT and (typeof(json["priority"]) != TYPE_FLOAT or json["priority"] != json["priority"] as int):
		print("[ERROR] Failed to load move data: ", id, " has non-int priority");
		return false;
	
	return true;


static func from_json(json: Dictionary) -> MoveData:
	return create(
		json["name"],
		AmorosData.AmorosType.get(json["type"]),
		json["power"],
		AmorosData.AmorosMoveCategory.get(json["category"]),
		json["description"],
		json["priority"],
	);
