shader_type spatial;

void vertex() 
{
}

float SdSphere(vec3 p, float r)
{
	p = fract(p) - 0.5; 
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

		float d = SdSphere(p, 0.3);

		t += d; 

		ALBEDO = vec3(float(i)) / 80.; 

		if (d < .0001) break; 
		if (t > 100.) break; 
	}
}