shader_type canvas_item;

void fragment() {
	COLOR = vec4(1.0, 0.98, 0.92, 1.0);
	vec2 pos = vec2(UV.x * 1080.0, UV.y * 330.0);
	float r = 18.0;
	
	if (pos.x <= r && pos.y <= r) {
		float dist = length(pos - vec2(r));
		
		if (dist > r && dist - r > 1.0) {
			COLOR.a = 0.0;
		} else if (dist > r) {
			COLOR.a = 1.0 - (dist - r);
		}
	}
}
