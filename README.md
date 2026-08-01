# godot-raymarch-shaders

Raymarching / SDF shaders in Godot 4

## Note:

I know very little linear algebra and I've only been working on shaders for about 2 months.
Some of the information in this repo may be inaccurate.

### Ray setup

```gdshader
vec3 ro = CAMERA_POSITION_WORLD; // camera position as ray origin

vec3 rd = normalize((INV_VIEW_MATRIX * vec4(VERTEX, 0.0)).xyz); 
 // Transform position of the fragment (pixel), in view space to a directional world space vector.

float t = 0.; // total ray distance travelled
```

### The march loop

```gdshader
 for (int i = 0; i < 80; i++){
	vec3 p = ro + rd * t; // this is what marches the ray. 
	
	float d = SdScene(p); // Signed distance map. 
						  // This can just be a primitive or multiple primitives using combinators.

	t += d; // march the ray length by its distance to the scene.

	ALBEDO = vec3(float(i)) / 80.; // This colors by steps. 
							       // since we step by distance, near miss rays will have more steps, 
								   // which creates a glowing effect.

	if (d < .001) break; // ray distance to sphere is so small we count it as a hit and break.
	if (t > 100.) break; // ray shot off into narnia, so break.

	// these early break conditions are good for performance, as well as coloring using the iteration count.
}
```

### SDFs

## Signed Distance Sphere:

```gdshader
length(point) - radius
``` 
returns the distance from a point to the origin minus the radius of the sphere.
positive values mean the point is outside of the sphere, negative means inside.

![Signed Distance Sphere](imgs/SdSphere.png)

## Translating Distance Function:

https://github.com/user-attachments/assets/c282c089-4721-4cd3-a437-46ef0aa91ee1

## Signed Distance Fractals - From Jon Baker's SDF entries (https://jbaker.graphics/writings/DEC.html):

```gdshader
float de( vec3 p0 )
{
    vec4 p = vec4(p0, 1.);
    for(int i = 0; i < 8; i++){
      p.xyz = mod(p.xyz-1., 2.)-1.;
      p*=(1.2/dot(p.xyz,p.xyz));
    }
    p/=p.w;
    return abs(p.x)*0.25;
}
```

![Signed Distance Fractal](imgs/SdFractal.png)

## Combinators

Smooth Minimum function from Inigo Quilez
(https://iquilezles.org/articles/smin/):

```gdshader
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
```

https://github.com/user-attachments/assets/5cc9fbb7-a65e-47a0-935f-af4cf6cef252

### Normals / Ray-tracing

SDF Normal Calculation:

```gdshader
// https://iquilezles.org/articles/normalsSDF/for05.png
vec3 calcNormals(vec3 p)
{
    vec2 e = vec2(0.01, 0.0);
    return normalize(vec3(sdScene(p + vec3(e.x, 0,   0  )).x - sdScene(p).x, 
						  sdScene(p + vec3(0,   e.x, 0  )).x - sdScene(p).x, 
						  sdScene(p + vec3(0,   0,   e.x)).x - sdScene(p).x));
}
```



Raytrace Loop and sdScene:

```gdshader
vec2 sdScene(vec3 p)
{
	float d1 = sdOctahedron(p, 1.0);
	float d2 = SdFractal(p);

	// 1 -- Octahedron, 0 -- Fractal
	float d_closest = d1 < d2 ? 1.0 : 0.0; 

    return vec2(min(d1, d2), d_closest);
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
```

https://github.com/user-attachments/assets/dc79a980-26a9-4714-a151-2231d3dd88b2



## Reference

https://www.youtube.com/watch?v=khblXafu7iA - An introduction to Raymarching by kishimisu
											  the structure of my raymarching shader came from this video for the most part.

https://iquilezles.org/articles/distfunctions/ - distance functions by Inigo Quilez

https://docs.godotengine.org/en/stable/tutorials/shaders/shader_reference/spatial_shader.html - GDShader built-ins and other documentation

https://jbaker.graphics/writings/DEC.html - Even more signed distance functions. 

## Troubles

SdSphere is drawing on the quad from where my camera is pointing. I want the sphere to be in a fixed position.

```gdshader
vec3 ro = CAMERA_POSITION_WORLD; // ray origin
vec3 rd = normalize(VERTEX); 	 // vertex position as the ray direction
```
The problem: VERTEX is the pixel position in view space. Transforming this position into a directional world space vector fixes the position of the sphere.


SdFractal looks like it has planes in the Y axis occluding the rest of the fractal.
