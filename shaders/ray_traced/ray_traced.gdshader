shader_type spatial;

//https://www.youtube.com/watch?v=khblXafu7iA&t=1212s
mat2 rot2D(float angle)
{
	float s = sin(angle);
	float c = cos(angle);
	return mat2(vec2(c, s), vec2(-s, c));
}

float sdOctahedron( vec3 p, float s )
{
	// Rotating the octahedron to show off reflections.
	p.xz *= rot2D(TIME * 0.5);
	p.yz *= rot2D(TIME * 0.5);

  	p = abs(p);
  	float m = p.x+p.y+p.z-s;
  	vec3 q;
  	if( 3.0*p.x < m ) q = p.xyz;
  	else if( 3.0*p.y < m ) q = p.yzx;
  	else if( 3.0*p.z < m ) q = p.zxy;
  	else return m*0.57735027;
	
  	float k = clamp(0.5*(q.z-q.y+s),0.0,s); 
  	return length(vec3(q.x,q.y-s+k,q.z-k)); 
}

float SdFractal(vec3 p0){
	vec4 p = vec4(p0, 1.);
	p.xyz += 1.0;
    for(int i = 0; i < 8; i++){
      p.xyz = mod(p.xyz-1., 2.)-1.;
      p*=((1.2)/dot(p.xyz,p.xyz));
	 
    }
    p/=p.w;
    return abs(p.y)*0.25;
}

vec2 sdScene(vec3 p)
{
	float d1 = sdOctahedron(p, 1.0);
	float d2 = SdFractal(p);

	// 1 -- Octahedron, 0 -- Fractal
	float d_closest = d1 < d2 ? 1.0 : 0.0; 

    return vec2(min(d1, d2), d_closest);
}

// https://iquilezles.org/articles/normalsSDF/for05.png
vec3 calcNormals(vec3 p)
{
    vec2 e = vec2(0.01, 0.0);
    return normalize(vec3(sdScene(p + vec3(e.x, 0,   0  )).x - sdScene(p).x, 
						  sdScene(p + vec3(0,   e.x, 0  )).x - sdScene(p).x, 
						  sdScene(p + vec3(0,   0,   e.x)).x - sdScene(p).x));
}
void fragment() 
{
	vec3 ro = CAMERA_POSITION_WORLD;
	vec3 rd = normalize((INV_VIEW_MATRIX * vec4(VERTEX, 0.0)).xyz); 

	float t = 0.; 

	for (int i = 0; i < 3; i++)
	{
		vec2 d;
		vec3 p;
		t = 0.;
		for (int j = 0; j < 80; j++)
		{
		    p = ro + rd * t;
		    d = sdScene(p);
		    t += d.x;

			// True (Closest SDF is Fractal and "hit") - Color scene and break
			if (d.y < 0.5 && d.x < .001) {ALBEDO = vec3(float(j)/80.0); break;} 
		    if (d.x < .001 || t > 100.) break;
		}

		if (t > 100.) { ALBEDO = vec3(0); break; }
		
		// Break if fractal is closest SDF in outer loop.
		// We only want the octahedron to reflect.
		if (d.y < 0.5) { break; }

		vec3 n = calcNormals(p);

		// https://registry.khronos.org/OpenGL-Refpages/gl4/html/reflect.xhtml
		rd = reflect(rd, n);
		
		ro = p + n * 0.01;
	}
}

