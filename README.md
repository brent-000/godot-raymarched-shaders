# godot-raymarch-shaders

Raymarching / SDF shaders in Godot 4

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
	
	float d = SdSphere(p, 1.0); // distance to sphere of radius 1.

	t += d; // march the ray length by its distance to the sphere.

	ALBEDO = vec3(float(i)) / 80.; // This colors by steps to converge. 
							       // since we step by distance, near miss rays will have more steps, 
								   // so this value approaches 1 which creates a glowing effect.

	if (d < .001) break; // ray distance to sphere is so small we count it as a hit and break.
	if (t > 100.) break; // ray shot off into narnia, so break.

	// these early break conditions are good for performance, as well as coloring using the iteration count.
}
```

### SDFs

Signed Distance Sphere:

length(point) - radius --- returns the distance from a point to the origin minus the radius of the sphere.
                           positive values mean the point is outside of the sphere, negative means inside.

Signed Distance Fractals: TODO

### Combinators (TODO)

### Normals / lighting (TODO)


## Reference

	https://www.youtube.com/watch?v=khblXafu7iA -  An introduction to Raymarching by kishimisu
												the structure of my raymarching shader came from this video for the most part.

	https://iquilezles.org/articles/distfunctions/ - distance functions by Inigo Quilez

	https://docs.godotengine.org/en/stable/tutorials/shaders/shader_reference/spatial_shader.html - GDShader built-ins and other documentation

## Troubles

SdSphere is drawing on the quad from where my camera is pointing. I want the sphere to be in a fixed position.

```gdshader
vec3 ro = CAMERA_POSITION_WORLD; // ray origin
vec3 rd = normalize(VERTEX); 	 // vertex position as the ray direction
```
The problem: VERTEX is the pixel position in view space. Transforming this position into a directional world space vector fixes the position of the sphere.

