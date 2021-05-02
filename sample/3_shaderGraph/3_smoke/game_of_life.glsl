#version 450
layout(location = 0) out vec4 outColor;


layout(location = 0) in vec2 UV;

layout(binding = 0) uniform BuiltinConstants
{
  vec4 iMouse;
  vec3 iResolution;
  float iTime;
  float iTimeDelta;
  int iFrame;
  uniform vec2 res;
    };


layout(binding = 3) uniform sampler2D previous_output0;


// End code from shadertoy
vec4 SampleColor(in vec2 cood){
    
    ivec2 px = ivec2( cood );
    float f = 0.0;
    if ((distance(px, iMouse.xy) < 30.0 ) ){
        f = 1.0;
        
    } else{
        f = texelFetch(previous_output0, ivec2(cood), 0).r ;
    }
    
    float left_color = texelFetch(previous_output0, ivec2(cood.x-1, cood.y), 0).r;
    float right_color = texelFetch(previous_output0, ivec2(cood.x+1, cood.y), 0).r;
    float up_color = texelFetch(previous_output0, ivec2(cood.x, cood.y+1), 0).r;
    float down_color = texelFetch(previous_output0, ivec2(cood.x, cood.y-1), 0).r;
    float delta_f = 0.12 * (2*left_color + 2*right_color + 2.0*up_color + down_color  - 7.0 *  f);

    if (delta_f >= -0.003 && delta_f < 0.0) {
        delta_f = -0.003;
    }
    f += delta_f;
    return vec4(f);
}

void main()
{outColor = SampleColor(gl_FragCoord.st);}



