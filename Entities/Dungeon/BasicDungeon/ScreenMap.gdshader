shader_type canvas_item;
uniform vec4 red_abberation : source_color;
uniform float ca_strength = 10.0;
uniform float color_influence : hint_range(0.0, 1.0, 0.01);
uniform sampler2D offset_texture : hint_default_white;
uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;
uniform bool is_flashing;
uniform vec3 flash_color : source_color;
uniform float FPS : hint_range(5.0, 60.0, 1.);

float jiggle_sine_chaos(){
	return sin(TIME*sin(TIME))*sin(floor(TIME*FPS)/FPS);
}
float jiggle_tan_chaos(){
	return tan(floor(TIME*FPS)/FPS*tan(floor(TIME*FPS)/FPS))*tan(floor(TIME*FPS)/FPS);
}
float jiggle_tan_lawful(){
	float funk = 3.353;
	return tan(TIME)+sin(funk*TIME)+sin((funk*2.0*TIME)/2.0)+sin((funk*4.2*TIME)/3.2);
}
float jiggle_sine_lawful(){
	float funk = 3.353;
	return sin(floor(TIME*FPS)/FPS)+sin(funk*floor(TIME*FPS)/FPS)+sin((funk*2.0*floor(TIME*FPS)/FPS)/2.0)+sin((funk*4.2*floor(TIME*FPS)/FPS)/3.2);
}

vec3 static(vec3 color, sampler2D tex, vec2 uv, float adjust_amount){
	color.r = texture(tex, vec2(uv.x + adjust_amount, uv.y + adjust_amount)).r;
	color.g = texture(tex, uv).g;
	color.b = texture(tex, vec2(uv.x - adjust_amount, uv.y - adjust_amount)).b;
	return color;
}

vec3 shifting(vec3 color, sampler2D tex, vec2 uv, float adjust_amount){
	color.r = texture(tex, vec2(uv.x + adjust_amount * jiggle_sine_lawful(), uv.y + adjust_amount * cos(floor(TIME*FPS)/FPS))).r;
	color.g = texture(tex, uv).g;
	color.b = texture(tex, vec2(uv.x - adjust_amount * cos(floor(TIME*FPS)/FPS), uv.y - adjust_amount * jiggle_tan_chaos())).b;
	return color;
}

vec3 shifting_horizontal(vec3 color, sampler2D tex, vec2 uv, float adjust_amount){
	color.r = texture(tex, vec2(uv.x - adjust_amount * tan(TIME), uv.y)).r;
	color.g = texture(tex, vec2(uv.x, uv.y + adjust_amount * abs(tan(TIME)))).g;
	color.b = texture(tex, vec2(uv.x + adjust_amount * cos(TIME), uv.y)).b;
	return color;
}
vec3 shifting_vertical(vec3 color, sampler2D tex, vec2 uv, float adjust_amount){
	color.r = texture(tex, vec2(uv.x, uv.y + adjust_amount * abs(sin(TIME)))).r;
	color.g = texture(tex, uv).g;
	color.b = texture(tex, vec2(uv.x, uv.y - adjust_amount * abs(cos(TIME)))).b;
	return color;
}

vec3 paint(vec3 color){
	if(color.r > 0.1 || color.g > 0.1 || color.b > 0.1){ //we dont want to apply it to the blacj bg
		if(color != vec3(1.0,1.0,1.0)){ //and we dont want to apply it to the white main body
			color = mix(color, red_abberation.rgb, color_influence);
		}
	}
	return color;
}

void fragment() {
	vec4 color = texture(TEXTURE, UV);
	
	float adjust_amount = ca_strength * texture(offset_texture, SCREEN_UV).r / 1000.0;
	
	adjust_amount = adjust_amount * sin(floor(TIME * FPS)/(FPS));
	color.rgb = shifting(color.rgb, TEXTURE, UV, adjust_amount);
	color.rgb = paint(color.rgb);
	
	if(is_flashing){
		color.rgb = flash_color;
	}
	
	COLOR = color;
	//COLOR = vec4(vec2(UV.x , UV.y - adjust_amount * tan(TIME)),0.0,1.0);
}