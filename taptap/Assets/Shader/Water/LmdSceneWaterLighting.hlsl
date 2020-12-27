#ifndef LMD_SCENE_WATER_LIGHTING_INCLUDED
#define LMD_SCENE_WATER_LIGHTING_INCLUDED
#include "LmdSceneWaterForwardPass.hlsl"

float SoftParticles(float near, float far, float sceneZ, float thisZ)
{
    float fade = 1;
    fade = saturate (far * ((sceneZ - near) - thisZ));
    return fade;
}

// Camera fade - returns alpha value for fading particles based on camera distance
half CameraFade(float near, float far, float thisZ)
{
    return saturate((thisZ - near) * far);
}

float4 BaseColor(float depth, float4 refractionColor)
{
    float4 deepColor = lerp(_DiffuseGrazingColor,_DiffuseGrazingColor*refractionColor,depth*(1-_DiffuseGrazingColor.a));
    float4 color = lerp(_DiffuseColor*refractionColor,_DiffuseGrazingColor*refractionColor,depth);
    return float4(color);
}

float2 RefractUV(half3 viewDirWS, half3 normalWS, half2 screenUV, float ndcZ, float depth, half refractionStrength, half refractionFactor)
{
	half3 refractDirWS = refract(-viewDirWS, normalWS, lerp(refractionFactor, 1, screenUV.y));
	half3 refractDirCS = normalize(mul(UNITY_MATRIX_VP, half4(refractDirWS, 0))).xyz;
	half3 negateViewDirCS = normalize(mul(UNITY_MATRIX_VP, half4(-viewDirWS, 0))).xyz;
	half2 refractionUV = (refractDirCS.xy - negateViewDirCS.xy) * refractionStrength * depth;
    return refractionUV;
}

float4 ToonWaterLit(WaterInputData inputData)
{
    float sceneZ =  LinearEyeDepth(SAMPLE_TEXTURE2D_X(_CameraDepthTexture, sampler_CameraDepthTexture, 
                        UnityStereoTransformScreenSpaceTex(inputData.positionSS.xy / inputData.positionSS.w)).r, _ZBufferParams);
    float thisZ = LinearEyeDepth(inputData.positionSS.z / inputData.positionSS.w, _ZBufferParams);
    float sceneDepth = SoftParticles(_DepthNear,_DepthFar,sceneZ,thisZ);
    float camDepth = CameraFade(_DepthNear,_DepthFar,thisZ);
    float depth = saturate(pow(sceneDepth*camDepth,_DepthPow));
    half2 screenUV = inputData.positionSS.xy/inputData.positionSS.w;
	float ndcZ = inputData.positionSS.z / inputData.positionSS.w;
    half2 refractUV = RefractUV(inputData.viewDirectionWS, inputData.normalWS, screenUV, ndcZ, depth, _RefractionStrength,_RefractionFactor);

    half4 color = 0;
//BaseColor
  //Refraction
    float mask = sceneDepth;
    half3 refractionColor = GetWaterRefractionColor(inputData.viewDirectionWS, inputData.normalWS, screenUV, ndcZ, 1, _RefractionStrength * mask,
	_RefractionFactor, TEXTURE2D_ARGS(_CameraOpaqueTexture, sampler_CameraOpaqueTexture), TEXTURE2D_ARGS(_CameraDepthTexture, sampler_CameraDepthTexture),_DepthRefractionStrength);
    
    float4 baseColor = BaseColor(depth,half4(refractionColor,1));
    //baseColor.a *= depth;
    color = baseColor;

//Specular
	Light mainLight = GetMainLight(inputData.shadowCoord);

	half3 halfVec = normalize(mainLight.direction + _ViewDir.xyz);

    float3 specular = GetWaterBlinnPhoneSpLighting(inputData.normalWS, halfVec, _SpecularBaseFactor, _SpecularPower, _SpecularColor.rgb);
    specular = step(0.1,specular);
    specular *= _SpecularIntensity * depth;
    color.rgb += specular;

//Shoreline
    half noise = SAMPLE_TEXTURE2D(_Noise,sampler_Noise,(inputData.uv*3-0.5)+(1+(_Time.y/2)*_ShorelineWide*0.1) + 0.5).r;
    half noise1 = SAMPLE_TEXTURE2D(_Noise,sampler_Noise,(inputData.uv*7-0.5)+(1+(_Time.y/1.5)*_ShorelineWide*0.2) + 0.5).r;
    //noise = clamp(noise,0,1);
    half4 shoreline = saturate(step(1,(1-sceneDepth)*(_ShorelineWide+noise*0.05)));
    //shoreline -= saturate(step(1,(1-sceneDepth)*((_ShorelineWide-_ShorelineWideMinus)*_ShorelineWide+noise*0.05)));

    float sceneDepth1 = SoftParticles(_DepthNear1*_DepthNear,_DepthFar1*_DepthFar,sceneZ,thisZ);
    half4 shoreline1 = saturate(step(1,(1-sceneDepth1)*(_ShorelineWide1*_ShorelineWide+noise1*0.07)));
    shoreline1 -= saturate(step(1,(1-sceneDepth1)*((_ShorelineWide1-_ShorelineWide1Minus)*_ShorelineWide+noise1*0.07)));

    float sceneDepth2 = SoftParticles(_DepthNear2*_DepthNear,_DepthFar2*_DepthFar,sceneZ,thisZ);
    half4 shoreline2 = saturate(step(1,(1-sceneDepth2)*(_ShorelineWide2*_ShorelineWide+noise*0.09)));
    shoreline2 -= saturate(step(1,(1-sceneDepth1)*((_ShorelineWide2-_ShorelineWide2Minus)+noise*0.09)));

    color += shoreline;
    color += shoreline1;
    color += shoreline2;

//Reflection
    //half refA = 1;
	//half3 reflectionColor = GetWaterReflectionColor(screenUV, inputData.normalWS, inputData.viewDirectionWS, _PlanarReflectionNormalsStrength, _ReflectionRoughness,
	//	                        _ReflectionColor.rgb, TEXTURE2D_ARGS(_ReflectionTex, sampler_ReflectionTex), refA) * color.rgb;
    //half reflectionFactor = GetWaterReflectionFactor(inputData.normalWS, inputData.viewDirectionWS, _FresneR, _FresnelPower, _ReflectionFactor);
//
    //color.rgb += reflectionColor*reflectionFactor;

    //return half4(inputData.normalWS,1);
    return half4(color);
}
#endif