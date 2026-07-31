shader_type spatial;

void vertex() 
{

}

float SdFractal(vec3 p0){
	vec4 p = vec4(p0, 1.);
	p.xyz += 1.0;
    for(int i = 0; i < 8; i++){
      p.xyz = mod(p.xyz-1., 2.)-1.;
      p*=((1.2+sin(TIME)*0.1)/dot(p.xyz,p.xyz));
	 
    }
    p/=p.w;
    return abs(p.y)*0.25;
}


void fragment() 
{
	vec3 ro = CAMERA_POSITION_WORLD;
	vec3 rd = normalize((INV_VIEW_MATRIX * vec4(VERTEX, 0.0)).xyz); 
	float t = 0.;

	for (int i = 0; i < 256; i++)
	{
		vec3 p = ro + rd * t; 
		float d = SdFractal(p);
		t += d; 

		ALBEDO = vec3(float(i)) / 80.; 
								       
		if (d < .001) break; 
		if (t > 100.) break;
	}
}
