shader_type spatial;

void vertex() {
	// Called for every vertex the material is visible on.
}

float sdSphere( vec3 p, float r )
{
	return length(p) - r;
}

float sdBoxFrame( vec3 p, vec3 b, float e )
{
    p = abs(p  )-b;
	vec3 q = abs(p+e)-e;
  	return min(min(
    length(max(vec3(p.x,q.y,q.z),0.0))+min(max(p.x,max(q.y,q.z)),0.0),
    length(max(vec3(q.x,p.y,q.z),0.0))+min(max(q.x,max(p.y,q.z)),0.0)),
    length(max(vec3(q.x,q.y,p.z),0.0))+min(max(q.x,max(q.y,p.z)),0.0));
}


float sdScene(vec3 p)
{
    return min(sdSphere(p, 1.0), sdBoxFrame(p, vec3(1.3), 0.05));
}


vec3 calcNormals(vec3 p)
{
	float ep = 0.01;
	vec3 q = p;

	vec3 result = p;

	q.x -= ep;
	result.x = sdScene(p) - sdScene(q); // slope of x on distance function
	q.x = p.x;

	q.y -= ep;
	result.y = sdScene(p) - sdScene(q); // slope of y on distance function
	q.y = p.y;

	q.z -= ep;
	result.z = sdScene(p) - sdScene(q); // slope of z on distance function

	return result/ep; // someone please tell me theres a less cringe way to do this

}

void fragment() 
{
	vec3 ro = CAMERA_POSITION_WORLD;
	vec3 rd = normalize((INV_VIEW_MATRIX * vec4(VERTEX, 0.0)).xyz); 

	float t = 0.; 

	for (int i = 0; i < 80; i++)
	{
		vec3 p = ro + rd * t;

		float d = sdScene(p); 

		t += d; 

		ALBEDO = calcNormals(p) * 0.5 + 0.5; 

		if (d < .001) break; 
		if (t > 100.) break; 
	}
}

