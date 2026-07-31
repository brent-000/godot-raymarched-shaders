shader_type spatial;

// circular smooth min
float smin( float a, float b, float k )
{
    k *= 1.0/(1.0-sqrt(0.5));
    float h = max( k-abs(a-b), 0.0 )/k;
    return min(a,b) - k*0.5*(1.0+h-sqrt(1.0-h*(h-2.0)));
}

float sdOctahedron( vec3 p, float s )
{
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

float SdSphere(vec3 p)
{
    p.x += sin(TIME) * 3.5;
    float r = 1.0;
    return length(p) - r;
}

float SdScene(vec3 p)
{
	return smin(sdOctahedron(p, 1.0), SdSphere(p), 0.5);
}

void fragment() 
{
	vec3 ro = CAMERA_POSITION_WORLD; 
	vec3 rd = normalize((INV_VIEW_MATRIX * vec4(VERTEX, 0.0)).xyz); 

	float t = 0.; 

	for (int i = 0; i < 80; i++)
	{
		vec3 p = ro + rd * t;
		float d = SdScene(p); 

		t += d;

		ALBEDO = vec3(float(i)) / 80.; 

		if (d < .001) break;
		if (t > 100.) break; 
	}
}