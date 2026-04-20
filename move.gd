class_name Move

extends Control


@export var exists: bool = false;
@export_multiline var move_name: String = "";
@export var type: AmorosData.AmorosType = AmorosData.AmorosType.None;
@export_range(0, 60, 5) var power: int = 10;
@export var category: AmorosData.AmorosMoveCategory = AmorosData.AmorosMoveCategory.Top;
@export_multiline var description: String = "";
@export_range(-10, 10) var priority: int = 0;



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if not exists:
		($Data).visible = false
		($Background).color = AmorosData.type_to_color(AmorosData.AmorosType.None);
		return;
	else:
		($Data).visible = true
	
	($Background).color = AmorosData.type_to_color(type);
	
	if type == AmorosData.AmorosType.None:
		($Data/Type).visible = false
	else:
		($Data/Type).visible = true
		($Data/Type).texture = AmorosData.type_to_texture(type);
	
	($Data/Name).text = move_name;
	
	if power == 0:
		($Data/Power).text = "-";
	else:
		($Data/Power).text = str(power);
	
	($Data/Category).text = AmorosData.move_cat_to_string(category);
	($Data/Description).text = description;
	
	if priority == 0:
		($Data/Priority).text = "";
	elif priority > 0:
		($Data/Priority).text = "+" + str(priority);
	else:
		($Data/Priority).text = str(priority);


func load_data(data: MoveData):
	move_name = data.name;
	type = data.type;
	power = data.power;
	category = data.category;
	description = data.description;
	priority = data.priority;
