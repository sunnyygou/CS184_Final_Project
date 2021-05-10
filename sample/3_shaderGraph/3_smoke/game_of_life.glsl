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
    float temperature;
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
    float color_l = texelFetch(previous_output0, ivec2(cood.x-1, cood.y), 0).r;
    float color_r = texelFetch(previous_output0, ivec2(cood.x+1, cood.y), 0).r;
    float color_u = texelFetch(previous_output0, ivec2(cood.x, cood.y+1), 0).r;
    float color_d = texelFetch(previous_output0, ivec2(cood.x, cood.y-1), 0).r;
    float color_lu = texelFetch(previous_output0, ivec2(cood.x-1, cood.y+1), 0).r;
    float color_ru = texelFetch(previous_output0, ivec2(cood.x+1, cood.y+1), 0).r;
    float color_ld = texelFetch(previous_output0, ivec2(cood.x-1, cood.y-1), 0).r;
    float color_rd = texelFetch(previous_output0, ivec2(cood.x+1, cood.y-1), 0).r;
    float color_ll = texelFetch(previous_output0, ivec2(cood.x-2, cood.y), 0).r;
    float color_rr = texelFetch(previous_output0, ivec2(cood.x+2, cood.y), 0).r;
    float color_uu = texelFetch(previous_output0, ivec2(cood.x, cood.y+2), 0).r;
    float color_dd = texelFetch(previous_output0, ivec2(cood.x, cood.y-2), 0).r;
    
    // coeffecients that determine the direction of the smoke movement. When all 1s, the smoke does not move
    //float coef_l = 1;
    //float coef_r = 1;
    float coef_u = buo_f(buoyancy)[0];
    float coef_d = buo_f(buoyancy)[1];
    //float coef_total = coef_u + coef_d + coef_l + coef_r;
    //float delta_f = 0.15 * (coef_l * color_l + coef_r * color_r + coef_u * color_u + coef_d * color_d  - coef_total * f);
    float coef_total = 10 + coef_u + coef_d;
    float delta_f = (0.05 * (temperature/300)) * (color_l + color_r + color_u * coef_u + color_d * coef_d + color_lu + color_ru + color_ld + color_rd + color_ll + color_rr + color_uu + color_dd - coef_total * f);
    
    // small delta offset that converts extremely small coef to 0, so no grey residual left on screen
    if (delta_f >= -0.003 && delta_f < 0.0) {
        delta_f = -0.003;
    }
    f += delta_f;
    return vec4(f);
}

void main()
{outColor = SampleColor(gl_FragCoord.st);}



