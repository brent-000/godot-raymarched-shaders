shader_type spatial;

void vertex() 
{
}

float SdSphere(vec3 p, float r)
{
	// The sphere is defined by its radius, 
	// length(p) - r will tell us the distance from the point p to the sphere's surface.
	// a negative value means the ray has gone through the sphere.

	return length(p) - r;
}

void fragment() 
{
	// Called for every pixel the material is visible on.

	//ALBEDO = VERTEX;

	vec3 ro = CAMERA_POSITION_WORLD; // camera position as ray origin
	vec3 rd = normalize((INV_VIEW_MATRIX * vec4(VERTEX, 0.0)).xyz); // Transform position of the fragment (pixel), in view space to a directional world space vector.

	float t = 0.; // total ray distance travelled

	// Raymarching loop

	for (int i = 0; i < 80; i++)
	{
		vec3 p = ro + rd * t;

		float d = SdSphere(p, 1.0); // distance to sphere of radius 1.

		t += d; // march the ray length by its distance to the sphere.

		ALBEDO = vec3(float(i)) / 80.; // This colors by steps to converge. 
									   // since we step by distance, near miss rays will have more steps, so this value approaches 1 which creates a glowing effect.

		if (d < .001) break; // ray distance to sphere is so small we count it as a hit and break.
		if (t > 100.) break; // ray shot off into narnia, so break.
		// these early break conditions are good for performance, as well as coloring using the iteration count.
	}
	

	

}