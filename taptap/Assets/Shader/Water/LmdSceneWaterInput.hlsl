#ifndef UNIVERSAL_LMD_SCENE_WATER_INPUT_INCLUDED
#define UNIVERSAL_LMD_SCENE_WATER_INPUT_INCLUDED

#include "LmdURPCommon.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/CommonMaterial.hlsl"
#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Packing.hlsl"
//#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/StandardSurfaceInput.hlsl"
//#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DeclareDepthTexture.hlsl"
//#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DeclareReflectionTexture.hlsl"

CBUFFER_START(UnityPerMaterial)
half4 _WaterFlowMap_ST;

half4 _ReflectionColor;
half4 _DiffuseColor;
half4 _DiffuseGrazingColor;
half4 _FlowDir;
half4 _NormalMapTileOffset;
half4 _NormalMapTileOffset1;
half4 _SpecularColor;
half4 _ViewDir;

half _TimeScale;
half _RefractionFactor;
half _DepthFogDensityFloat;
half _RefractionStrength;
half _DepthRefractionStrength;
half _RefractionFactorAsEnd;
half _half_period;
half _FlowScale;
half _NormalScale;
half _NormalScale1;
half _SpecularBaseFactor;
half _SpecularPower;
half _ReflectionRoughness;
half _PlanarReflectionNormalsStrength;
half _FresnelPower;
half _FresneR;
half _ReflectionFactor;
half _DepthNear;
half _DepthFar;
half _DepthNear1;
half _DepthFar1;
half _DepthNear2;
half _DepthFar2;

half _DepthPow;
half _SpecularIntensity;
half _ShorelinePow;
half _ShorelineWide;
half _ShorelineWideMinus;
half _ShorelineWide1;
half _ShorelineWide1Minus;
half _ShorelineWide2;
half _ShorelineWide2Minus;

half _CausticTile;
half _CausticStrength;
CBUFFER_END

TEXTURE2D(_WaterFlowMap);		SAMPLER(sampler_WaterFlowMap);
TEXTURE2D(_WaveNormalMap);      SAMPLER(sampler_WaveNormalMap);
TEXTURE2D(_WaveNormalMap1);     SAMPLER(sampler_WaveNormalMap1);
TEXTURE2D(_MaskTex);			SAMPLER(sampler_MaskTex);
//TEXTURE2D(_CameraColorTexture); SAMPLER(sampler_CameraColorTexture);
TEXTURE2D(_CameraOpaqueTexture); SAMPLER(sampler_CameraOpaqueTexture);
TEXTURE2D(_CameraDepthTexture); SAMPLER(sampler_CameraDepthTexture);
TEXTURE2D(_Noise);				SAMPLER(sampler_Noise);
TEXTURE2D(_Caustic);				SAMPLER(sampler_Caustic);

struct WaterInputData
{
	float3  positionWS;
	half3   normalWS;
	half4   tangentWS;
	half3   viewDirectionWS;
	float4  shadowCoord;
	half    fogCoord;
	half3   vertexLighting;
	half3   bakedGI;
	float4  positionSS;
	float4  positionCS;
	float2  uv;
};

/*inline void InitializeStandardLitSurfaceData(
#ifdef _PARALLAXMAP
	float3 viewDirForParallax,
#endif
	float2 uv, out SurfaceData outSurfaceData)
{
#ifdef _PARALLAXMAP
	half height = SAMPLE_TEXTURE2D(_ParallaxMap, sampler_ParallaxMap, uv).r;
	half parallax = height * _Parallax - _Parallax / 2;
	viewDirForParallax = normalize(viewDirForParallax);
	uv = (viewDirForParallax.xy / (viewDirForParallax.z + 0.42)) * parallax + uv;
#endif

    half4 albedoAlpha = SampleAlbedoAlpha(uv, TEXTURE2D_ARGS(_BaseMap, sampler_BaseMap));
    outSurfaceData.alpha = Alpha(albedoAlpha.a, _BaseColor, _Cutoff);
	outSurfaceData.albedo = albedoAlpha.rgb * _BaseColor.rgb;

#ifdef _MASKMAP
	half4 mask = SAMPLE_TEXTURE2D(_MaskMap, sampler_MaskMap, uv);

	outSurfaceData.metallic = min(mask.r * _Metallic, 1);
	outSurfaceData.smoothness = min(mask.b * _Smoothness, 1);
	outSurfaceData.occlusion = mask.g * _AOFactor;
	outSurfaceData.anisotropic = mask.a * _AnisotropicValue;
#else
	outSurfaceData.metallic = min(_Metallic, 1);
	outSurfaceData.smoothness = min(_Smoothness, 1);
	outSurfaceData.occlusion = _AOFactor;
	outSurfaceData.anisotropic = _AnisotropicValue;
#endif

#ifdef _SSSTMAP
	outSurfaceData.sssT = SAMPLE_TEXTURE2D(_TranslucencyMap, sampler_TranslucencyMap, uv).r;
#else
	outSurfaceData.sssT = 1;
#endif

    outSurfaceData.normalTS = SampleNormal(uv, TEXTURE2D_ARGS(_NormalMap, sampler_NormalMap), _NormalScale);
	outSurfaceData.emission = SampleEmission(uv, _EmissionColor.rgb, TEXTURE2D_ARGS(_EmissionMap, sampler_EmissionMap));
}*/

#endif // UNIVERSAL_INPUT_SURFACE_PBR_INCLUDED
