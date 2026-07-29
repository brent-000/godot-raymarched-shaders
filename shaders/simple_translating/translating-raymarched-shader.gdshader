shader_type spatial;

void vertex() 
{

}

instance uniform float amplitude : hint_range(0.0, 5.0) = 0.0;

float TranslatingSdSphere(vec3 p, float r)
{
	p.z += 10.0; // move further back to see x/y translations better
	p.y += cos(TIME) * amplitude; // Using time in godot for translation.
	p.x += sin(TIME) * amplitude; // Also, translating is as simple as changing the xyz values.
					  
	return length(p) - r;
}

void fragment() 
{
	vec3 ro = CAMERA_POSITION_WORLD;
	vec3 rd = normalize((INV_VIEW_MATRIX * vec4(VERTEX, 0.0)).xyz); 
	float t = 0.;

	for (int i = 0; i < 80; i++)
	{
		vec3 p = ro + rd * t; 
		float d = TranslatingSdSphere(p, 1.0); // Sphere x and y translation using sin.
		t += d; 

		ALBEDO = vec3(float(i)) / 80.; 
								       
		if (d < .001) break; 
		if (t > 100.) break;
	}
}
