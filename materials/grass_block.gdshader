shader_type spatial;

uniform sampler2D texture_top : source_color, filter_nearest;
uniform sampler2D texture_side : source_color, filter_nearest;
uniform sampler2D texture_bottom : source_color, filter_nearest;

uniform vec3 block_size = vec3(0.5, 0.25, 0.5); // Default size based on blocks.tscn

varying vec3 local_pos;
varying vec3 local_normal;

void vertex() {
	local_pos = VERTEX;
	local_normal = NORMAL;
}

void fragment() {
	vec3 normal = normalize(local_normal);
	vec4 albedo_tex;
	vec2 uv;
	
	// Adjust UVs based on face orientation (Object Space Mapping)
	// We map the local position to 0-1 range based on block_size
	
	float epsilon = 0.5; // Tolerance for normal check
	
	if (normal.y > epsilon) {
		// Top Face
		// Map XZ to UV
		// X: -size.x/2 to size.x/2 -> 0 to 1
		uv.x = (local_pos.x / block_size.x) + 0.5;
		uv.y = (local_pos.z / block_size.z) + 0.5;
		albedo_tex = texture(texture_top, uv);
		
	} else if (normal.y < -epsilon) {
		// Bottom Face
		// Map XZ to UV
		uv.x = (local_pos.x / block_size.x) + 0.5;
		uv.y = (local_pos.z / block_size.z) + 0.5;
		albedo_tex = texture(texture_bottom, uv);
		
	} else {
		// Side Faces
		// We need to determine if it's X-aligned or Z-aligned
		
		if (abs(normal.x) > abs(normal.z)) {
			// X-facing sides (Left/Right)
			// Map ZY to UV
			uv.x = (local_pos.z / block_size.z) + 0.5;
			// For Y, we map -size.y/2 to size.y/2 -> 0 to 1?
			// Typically V=0 is top. local_pos.y is max at top.
			// So (local_pos.y / size.y) + 0.5 gives 0 to 1 (bottom to top).
			// We want 1 to 0 (top to bottom).
			uv.y = 1.0 - ((local_pos.y / block_size.y) + 0.5);
		} else {
			// Z-facing sides (Front/Back)
			// Map XY to UV
			uv.x = (local_pos.x / block_size.x) + 0.5;
			uv.y = 1.0 - ((local_pos.y / block_size.y) + 0.5);
		}
		
		albedo_tex = texture(texture_side, uv);
	}
	
	ALBEDO = albedo_tex.rgb;
}
