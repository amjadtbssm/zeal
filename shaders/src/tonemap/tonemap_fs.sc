#include <bgfx_shader.sh>
#include "../tonemapping.sh"

uniform vec4 u_exposureVec;
#define u_exposure u_exposureVec.x

uniform vec4 u_tonemappingModeVec;
#define u_tonemappingMode int(u_tonemappingModeVec.x)

#define TONEMAP_NONE 0
#define TONEMAP_EXPONENTIAL 1
#define TONEMAP_REINHARD 2
#define TONEMAP_REINHARD_LUM 3
#define TONEMAP_HABLE 4
#define TONEMAP_DUIKER 5
#define TONEMAP_ACES 6
#define TONEMAP_ACES_LUM 7

SAMPLER2D(s_texColor, 0);

void main()
{
    vec2 texcoord = gl_FragCoord.xy / u_viewRect.zw;
    vec4 result = texture2D(s_texColor, texcoord);
    result.rgb *= u_exposure;

    // switch statement requires GLSL 130 (and by extension, OpenGL 3.0)
    // even if we compile with that version, compilation fails at runtime
    // because bgfx uses OpenGL 2.1
    /*
    switch(u_tonemappingMode)
    {
        //default:
        case TONEMAP_NONE:
            result.rgb = saturate(result.rgb);
            break;
        case TONEMAP_EXPONENTIAL:
            result.rgb = tonemap_exponential(result.rgb);
            break;
        case TONEMAP_REINHARD:
            result.rgb = tonemap_reinhard(result.rgb);
            break;
        case TONEMAP_REINHARD_LUM:
            result.rgb = tonemap_reinhard_luminance(result.rgb);
            break;
        case TONEMAP_HABLE:
            result.rgb = tonemap_hable(result.rgb);
            break;
        case TONEMAP_DUIKER:
            result.rgb = tonemap_duiker(result.rgb);
            break;
        case TONEMAP_ACES:
            result.rgb = tonemap_aces(result.rgb);
            break;
        case TONEMAP_ACES_LUM:
            result.rgb = tonemap_aces_luminance(result.rgb);
            break;
    }
    */

    if(u_tonemappingMode == TONEMAP_NONE)
    {
        result.rgb = saturate(result.rgb);
    }
    else if(u_tonemappingMode == TONEMAP_EXPONENTIAL)
    {
        result.rgb = tonemap_exponential(result.rgb);
    }
    else if(u_tonemappingMode == TONEMAP_REINHARD)
    {
        result.rgb = tonemap_reinhard(result.rgb);
    }
    else if(u_tonemappingMode == TONEMAP_REINHARD_LUM)
    {
        result.rgb = tonemap_reinhard_luminance(result.rgb);
    }
    else if(u_tonemappingMode == TONEMAP_HABLE)
    {
        result.rgb = tonemap_hable(result.rgb);
    }
    else if(u_tonemappingMode == TONEMAP_DUIKER)
    {
        result.rgb = tonemap_duiker(result.rgb);
    }
    else if(u_tonemappingMode == TONEMAP_ACES)
    {
        result.rgb = tonemap_aces(result.rgb);
    }
    else if(u_tonemappingMode == TONEMAP_ACES_LUM)
    {
        result.rgb = tonemap_aces_luminance(result.rgb);
    }

    // gamma correction
    result.rgb = LinearTosRGB(result.rgb);

    gl_FragColor = result;
}
