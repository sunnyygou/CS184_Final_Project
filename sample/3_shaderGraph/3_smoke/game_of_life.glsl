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
    };

layout(push_constant) uniform Parameters {
  float sourceSize;
  float buoyancy;
};


layout(binding = 3) uniform sampler2D previous_output0;


vec2 buo_f(in float buoyancy){
    if (buoyancy>0){
        return vec2(1+buoyancy, 1);
    } else{
        return vec2(1, 1 + buoyancy*(-1));
    }
}


vec4 SampleColor(in vec2 cood){
    
    ivec2 px = ivec2( cood );
    float f = 0.0;
    if ((distance(px, iMouse.xy) < sourceSize ) ){
        f = 1.0;
    } else{
        f = texelFetch(previous_output0, ivec2(cood), 0).r ;
    }
    
    // colors of the neighboring pixels
    float left_color = texelFetch(previous_output0, ivec2(cood.x-1, cood.y), 0).r;
    float right_color = texelFetch(previous_output0, ivec2(cood.x+1, cood.y), 0).r;
    float up_color = texelFetch(previous_output0, ivec2(cood.x, cood.y+1), 0).r;
    float down_color = texelFetch(previous_output0, ivec2(cood.x, cood.y-1), 0).r;
    
    // coeffecients that determine the direction of the smoke movement. When all 1s, the smoke does not move
    float left_coef = 1;
    float right_coef = 1;
    float up_coef = buo_f(buoyancy)[0];
    float down_coef = buo_f(buoyancy)[1];
    float total_coef = up_coef + down_coef + left_coef + right_coef;
    
    
    float delta_f = 0.15 * (left_coef * left_color + right_coef * right_color + up_coef * up_color + down_coef * down_color  - total_coef * f);
    
    // small delta offset that converts extremely small coef to 0, so no grey residual left on screen
    if (delta_f >= -0.003 && delta_f < 0.0) {
        delta_f = -0.003;
    }
    f += delta_f;
    return vec4(f);
}

void main()
{outColor = SampleColor(gl_FragCoord.st);}



