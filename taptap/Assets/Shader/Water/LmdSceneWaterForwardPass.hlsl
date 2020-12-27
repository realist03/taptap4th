#ifndef UNIVERSAL_FORWARD_LMD_SCENE_WATER_PASS_INCLUDED
#define UNIVERSAL_FORWARD_LMD_SCENE_WATER_PASS_INCLUDED

#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
#include "LmdSceneWaterInput.hlsl"
#include "LmdSceneWaterLighting.hlsl"

struct Attributes
{
    float4 positionOS   : POSITION;
    float3 normalOS     : NORMAL;
    float4 tangentOS    : TANGENT;
    float2 texcoord     : TEXCOORD0;
    float2 lightmapUV   : TEXCOORD1;
    UNITY_VERTEX_INPUT_INSTANCE_ID
};

struct Varyings
{
    float2 uv                       : TEXCOORD0;
    DECLARE_LIGHTMAP_OR_SH(lightmapUV, vertexSH, 1);

#if defined(REQUIRES_WORLD_SPACE_POS_INTERPOLATOR) || defined(_ADDITIONAL_LIGHTS_FORWARD_PLUS)
    float3 positionWS               : TEXCOORD2;
#endif

    float3 normalWS                 : TEXCOORD3;
#if defined(_NORMALMAP) || defined(_ANISOTROPIC_ON)
    float4 tangentWS                : TEXCOORD4;    // xyz: tangent, w: sign
#endif
    float3 viewDirWS                : TEXCOORD5;

    half4 fogFactorAndVertexLight   : TEXCOORD6; // x: fogFactor, yzw: vertex light

#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
    float4 shadowCoord              : TEXCOORD7;
#endif

	float4 positionSS				: TEXCOORD8;

	float4 viewRayOS				: TEXCOORD9;
	float3 cameraPosOS				: TEXCOORD10;

    float4 positionCS               : SV_POSITION;
    UNITY_VERTEX_INPUT_INSTANCE_ID
    UNITY_VERTEX_OUTPUT_STEREO
};

WaterInputData InitializeWaterInputData(Varyings input)
{
	WaterInputData inputData = (WaterInputData)0;

#if defined(REQUIRES_WORLD_SPACE_POS_INTERPOLATOR) || defined(_ADDITIONAL_LIGHTS_FORWARD_PLUS)
    inputData.positionWS = input.positionWS;
#endif

    half3 viewDirWS = SafeNormalize(input.viewDirWS);
    inputData.viewDirectionWS = viewDirWS;

	
	//flow
	half flowOffset0, flowOffset1;
	half flowWeight0, flowWeight1;
	GetWaterFlowOffsetWeights(_TimeScale, _half_period, flowOffset0, flowOffset1, flowWeight0, flowWeight1);

#ifdef _FLOWMAP_ON
	half2 flow = GetWaterFlowInfoFromMap(input.uv * _WaterFlowMap_ST.xy + _WaterFlowMap_ST.zw, TEXTURE2D_ARGS(_WaterFlowMap, sampler_WaterFlowMap), _FlowScale);
#else
	half2 flow = GetWaterFlowInfoFromDir(_FlowDir.xy, _FlowScale);
#endif

	inputData.tangentWS = input.tangentWS;
	//normal map with flow
	half3x3 TransformDirToWMat = BuildDirTangentToWorldMat(inputData.tangentWS, input.normalWS);

	half3 normalWS0 = GetWaterFlowNormalMapToNormalWS(input.uv, _NormalMapTileOffset.xy, TEXTURE2D_ARGS(_WaveNormalMap, sampler_WaveNormalMap),
		_NormalScale, flow, flowOffset0, flowOffset1, flowWeight0, flowWeight1, TransformDirToWMat);

	half3 normalWS1 = GetWaterFlowNormalMapToNormalWS(input.uv, _NormalMapTileOffset1.xy, TEXTURE2D_ARGS(_WaveNormalMap1, sampler_WaveNormalMap1),
		_NormalScale1, flow, flowOffset0, flowOffset1, flowWeight0, flowWeight1, TransformDirToWMat);

	half3 normalWS = normalize(normalWS0 + normalWS1);

	inputData.normalWS = normalWS;

#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
    inputData.shadowCoord = input.shadowCoord;
#elif defined(MAIN_LIGHT_CALCULATE_SHADOWS)
    inputData.shadowCoord = TransformWorldToShadowCoord(inputData.positionWS);
#else
    inputData.shadowCoord = float4(0, 0, 0, 0);
#endif

    inputData.fogCoord = input.fogFactorAndVertexLight.x;
    inputData.vertexLighting = input.fogFactorAndVertexLight.yzw;
    inputData.bakedGI = SAMPLE_GI(input.lightmapUV, input.vertexSH, inputData.normalWS);

//#ifdef _ADDITIONAL_LIGHTS_FORWARD_PLUS
	inputData.positionSS = input.positionSS;
//#endif

	inputData.positionCS = input.positionCS;
	inputData.uv = input.uv;
	return inputData;
}

///////////////////////////////////////////////////////////////////////////////
//                  Vertex and Fragment functions                            //
///////////////////////////////////////////////////////////////////////////////

// Used in Standard (Physically Based) shader
Varyings LitPassVertex(Attributes input)
{
    Varyings output = (Varyings)0;

    UNITY_SETUP_INSTANCE_ID(input);
    UNITY_TRANSFER_INSTANCE_ID(input, output);
    UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output);

    VertexPositionInputs vertexInput = GetVertexPositionInputs(input.positionOS.xyz);
    
    // normalWS and tangentWS already normalize.
    // this is required to avoid skewing the direction during interpolation
    // also required for per-vertex lighting and SH evaluation
    VertexNormalInputs normalInput = GetVertexNormalInputs(input.normalOS, input.tangentOS);
    float3 viewDirWS = GetCameraPositionWS() - vertexInput.positionWS;
    half3 vertexLight = VertexLighting(vertexInput.positionWS, normalInput.normalWS);
    half fogFactor = ComputeFogFactor(vertexInput.positionCS.z);

	output.uv = input.texcoord;//TRANSFORM_TEX(input.texcoord, _BaseMap);

    // already normalized from normal transform to WS.
    output.normalWS = normalInput.normalWS;
    output.viewDirWS = viewDirWS;
#if defined(_NORMALMAP) || defined(_ANISOTROPIC_ON)
    real sign = input.tangentOS.w * GetOddNegativeScale();
    output.tangentWS = half4(normalInput.tangentWS.xyz, sign);
#endif

    OUTPUT_LIGHTMAP_UV(input.lightmapUV, unity_LightmapST, output.lightmapUV);
    OUTPUT_SH(output.normalWS.xyz, output.vertexSH);

    output.fogFactorAndVertexLight = half4(fogFactor, vertexLight);

#if defined(REQUIRES_WORLD_SPACE_POS_INTERPOLATOR) || defined(_ADDITIONAL_LIGHTS_FORWARD_PLUS)
    output.positionWS = vertexInput.positionWS;
#endif

#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
    output.shadowCoord = GetShadowCoord(vertexInput);
#endif

//#ifdef _ADDITIONAL_LIGHTS_FORWARD_PLUS
	output.positionSS = ComputeScreenPos(vertexInput.positionCS);
//#endif

    output.positionCS = vertexInput.positionCS;

#ifdef _USEPROJECTCAUSTIC
	float3 viewRay = TransformWorldToView(TransformObjectToWorld(input.positionOS.xyz));
	output.viewRayOS.w = viewRay.z;
	viewRay *= -1;
	float4x4 ViewToObjectMatrix = mul(UNITY_MATRIX_I_M,UNITY_MATRIX_I_V);
	output.viewRayOS.xyz = mul((float3x3)ViewToObjectMatrix, viewRay);
	Light light = GetMainLight();
	half3 lightDir = TransformWorldToObjectDir(light.direction);
	output.cameraPosOS = mul(ViewToObjectMatrix,float4(-lightDir,1)).xyz;
#endif

    return output;
}

/*struct WaterInputData
{
	float3  positionWS;
	half3   normalWS;
	half4   tangentWS;
	half3   viewDirectionWS;
	float4  shadowCoord;
	half    fogCoord;
	half3   vertexLighting;
	half3   bakedGI;
	half4   positionSS;
};*/

half3 UniversalLmdFragmentWaterLighting(WaterInputData inputData, half2 uv)
{
	half3 scatterColor = GetWaterScatterColor(_DiffuseColor.rgb, _DiffuseGrazingColor.rgb, inputData.viewDirectionWS);
	half refractionScatterFactor = GetWaterRefractionScatterFactor(inputData.viewDirectionWS, _DepthFogDensityFloat, _RefractionFactorAsEnd);

	half4 mask = SAMPLE_TEXTURE2D(_MaskTex, sampler_MaskTex, uv);

	//refraction
	half2 screenUV = inputData.positionSS.xy / inputData.positionSS.ww;
	float ndcZ = inputData.positionCS.z;
	//float ndcZ = inputData.positionSS.z;

	half3 refractionColor = GetWaterRefractionColor(inputData.viewDirectionWS, inputData.normalWS, screenUV, ndcZ, mask.r, _RefractionStrength * mask.g,
		_RefractionFactor, TEXTURE2D_ARGS(_CameraOpaqueTexture, sampler_CameraOpaqueTexture), TEXTURE2D_ARGS(_CameraDepthTexture, sampler_CameraDepthTexture),_DepthRefractionStrength);

	//reflection
#ifdef _REFLECTION_ON
	half reflectionAlpha = 0;

	half3 reflectionColor = GetWaterReflectionColor(screenUV, inputData.normalWS, inputData.viewDirectionWS, _PlanarReflectionNormalsStrength, _ReflectionRoughness,
		_ReflectionColor.rgb, TEXTURE2D_ARGS(_ReflectionTex, sampler_ReflectionTex), reflectionAlpha);

	half reflectionFactor = GetWaterReflectionFactor(inputData.normalWS, inputData.viewDirectionWS, _FresneR, _FresnelPower, _ReflectionFactor);
#else
	half reflectionAlpha = 0;
	half3 reflectionColor = 0;
	half reflectionFactor = 0;
#endif

	half3 color = 0;

	//main light
	Light mainLight = GetMainLight(inputData.shadowCoord);

	half3 halfVec = normalize(mainLight.direction + inputData.viewDirectionWS);
	half3 blinnPhoneSpColor = GetWaterBlinnPhoneSpLighting(inputData.normalWS, halfVec, _SpecularBaseFactor, _SpecularPower, _SpecularColor.rgb);

	half3 diffuseColor = scatterColor * mainLight.distanceAttenuation * mainLight.shadowAttenuation;
	half3 specularColor = blinnPhoneSpColor * mainLight.distanceAttenuation * mainLight.shadowAttenuation;
	//color += AppendWaterColor(scatterColor, refractionColor, refractionScatterFactor, reflectionColor, reflectionAlpha, reflectionFactor, blinnPhoneSpColor,
	//	mainLight.color, mainLight.distanceAttenuation * mainLight.shadowAttenuation, mask.r);

	//MixRealtimeAndBakedGI(mainLight, inputData.normalWS, inputData.bakedGI, half4(0, 0, 0, 0));

	//indirect diffuse lighting
	//color.rgb += inputData.bakedGI * occlusion * indirectDiffuseLightingFactor;

#ifdef _ADDITIONAL_LIGHTS
	uint pixelLightCount = GetAdditionalLightsCount();
	for (uint lightIndex = 0u; lightIndex < pixelLightCount; ++lightIndex)
	{
		Light light = GetAdditionalLight(lightIndex, inputData.positionWS);

		halfVec = normalize(light.direction + inputData.viewDirectionWS);
		blinnPhoneSpColor = GetWaterBlinnPhoneSpLighting(inputData.normalWS, halfVec, _SpecularBaseFactor, _SpecularPower, _SpecularColor.rgb);

		diffuseColor += scatterColor * light.distanceAttenuation * light.shadowAttenuation;
		specularColor += blinnPhoneSpColor * light.distanceAttenuation * light.shadowAttenuation;
		//color += AppendWaterColor(scatterColor, refractionColor, refractionScatterFactor, reflectionColor, reflectionAlpha, reflectionFactor, blinnPhoneSpColor,
		//	light.color, light.distanceAttenuation * light.shadowAttenuation, mask.r);
	}

	color = AppendWaterColor(diffuseColor, refractionColor, refractionScatterFactor, reflectionColor,
		reflectionAlpha, reflectionFactor, specularColor, mask.r);
#endif

#ifdef _ADDITIONAL_LIGHTS_VERTEX
	color.rgb += inputData.vertexLighting * scatterColor;
#endif

#ifdef _ADDITIONAL_LIGHTS_FORWARD_PLUS
	inputData.positionSS.xy = inputData.positionSS.xy / inputData.positionSS.ww;

	uint2 gridIndexXY;
	gridIndexXY.x = floor(inputData.positionSS.x / _TileWHinfo.x);
	gridIndexXY.y = floor(inputData.positionSS.y / _TileWHinfo.y);

	uint gridIndex = gridIndexXY.y * _TileWidth + gridIndexXY.x;

#ifdef _TRANSPARENT_ON
	int head = _AdditionalLightHeadGrid[gridIndex + 1].y;
#else
	int head = _AdditionalLightHeadGrid[gridIndex + 1].x;
#endif

	while (any(head))
	{
#ifdef _TRANSPARENT_ON
		int2 linked = _AdditionalLightIndexList[head].zw;
#else
		int2 linked = _AdditionalLightIndexList[head].xy;
#endif

		if (ObjectHasTheAdditionalLight(linked.x))
		{
			Light light = GetAdditionalLight(linked.x, inputData.positionWS);

			//if (light.layer & asint(unity_RenderingLayer.x) != 0)
			//{
				halfVec = normalize(light.direction + inputData.viewDirectionWS);
				blinnPhoneSpColor = GetWaterBlinnPhoneSpLighting(inputData.normalWS, halfVec, _SpecularBaseFactor, _SpecularPower, _SpecularColor.rgb);

				diffuseColor += scatterColor * light.distanceAttenuation * light.shadowAttenuation;
				specularColor += blinnPhoneSpColor * light.distanceAttenuation * light.shadowAttenuation;
				//color += AppendWaterColor(scatterColor, refractionColor, refractionScatterFactor, reflectionColor, reflectionAlpha, reflectionFactor, blinnPhoneSpColor,
				//	light.color, light.distanceAttenuation * light.shadowAttenuation, mask.r);
			//}
		}
		
		head = linked.y;
	}

	color = AppendWaterColor(diffuseColor, refractionColor, refractionScatterFactor, reflectionColor,
		reflectionAlpha, reflectionFactor, specularColor, mask.r);
#endif

	

	return color;
}

// Used in Standard (Physically Based) shader
//half4 LitPassFragment(Varyings input) : SV_Target
//{
//    UNITY_SETUP_INSTANCE_ID(input);
//    UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);
//
//	WaterInputData inputData = InitializeWaterInputData(input);
//	//InitializeWaterInputData(input, inputData);
//
//	half4 color;
//	color.rgb = UniversalLmdFragmentWaterLighting(inputData, input.uv);
//
//	color.rgb = MixFog(color.rgb, inputData.fogCoord);
//	color.a = 1;//OutputAlpha(color.a);
//
//    return color;
//}

float2 ProjectUV(Varyings input)
{
    input.viewRayOS /= input.viewRayOS.w;
	float sceneCameraSpaceDepth = LinearEyeDepth(SAMPLE_TEXTURE2D(_CameraDepthTexture, sampler_CameraDepthTexture,input.positionSS.xy/input.positionSS.w).r, _ZBufferParams);
    float3 decalSpaceScenePos = input.cameraPosOS.xyz + input.viewRayOS.xyz * sceneCameraSpaceDepth;
    float2 decalSpaceUV = decalSpaceScenePos.xy;
	return decalSpaceUV;
}

float3 Caustic(float2 uv)
{
	half noise = SAMPLE_TEXTURE2D(_Noise,sampler_Noise,uv+(_Time.y)/15).r;
	half noise1 = SAMPLE_TEXTURE2D(_Noise,sampler_Noise,uv+(_Time.y)/18).r;

	float r = SAMPLE_TEXTURE2D(_Caustic,sampler_Caustic,half2(uv.x-(_Time.y)/15.0001+sin(_Time.x),uv.y)).r;
	float g = SAMPLE_TEXTURE2D(_Caustic,sampler_Caustic,half2(uv.x-(_Time.y)/15.0005+sin(_Time.x),uv.y)).g;
	float b = SAMPLE_TEXTURE2D(_Caustic,sampler_Caustic,half2(uv.x-(_Time.y)/15.0009+sin(_Time.x),uv.y)).b;
	return half3(r,g,b);

}

// Used in Standard (Physically Based) shader
half4 LitPassFragment(Varyings input) : SV_Target
{
    UNITY_SETUP_INSTANCE_ID(input);
    UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);

	WaterInputData inputData = InitializeWaterInputData(input);
	//InitializeWaterInputData(input, inputData);

	half4 color;
	color.rgb = UniversalLmdFragmentWaterLighting(inputData, input.uv);

	color.rgb = MixFog(color.rgb, inputData.fogCoord);
	color.a = 1;//OutputAlpha(color.a);

    return color;
}

half4 ToonLitPassFragment(Varyings input) : SV_Target
{
	float2 proUV = ProjectUV(input)*_CausticTile;
	float3 caustic = Caustic(proUV)*_CausticStrength;
	WaterInputData inputData = InitializeWaterInputData(input);
	half4 color = ToonWaterLit(inputData);
	color.rgb += caustic*saturate(1-color.a*2);
	return color;
}

#endif
