#ifndef UNIVERSAL_LMD_URP_COMMON_INCLUDED
#define UNIVERSAL_LMD_URP_COMMON_INCLUDED

#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Packing.hlsl"
#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/CommonMaterial.hlsl"

//从flow map中读取flow信息
half2 GetWaterFlowInfoFromMap(half2 uv, TEXTURE2D_PARAM(flowMap, sampler_flowMap), half flowStrength)
{
	return (SAMPLE_TEXTURE2D(flowMap, sampler_flowMap, uv).rg * 2.0 - 1.0) * flowStrength;
}

half2 GetWaterFlowInfoFromDir(half2 dir, half flowStrength)
{
	return dir * flowStrength;
}

//时间系数确定flow偏移和权重
void GetWaterFlowOffsetWeights(half timeScale, half halfPeriod, out half offset0, out half offset1, out half weight0, out half weight1)
{
	half time = _Time.y * timeScale;
	half period = halfPeriod * 2;

	offset0 = fmod(time, period);
	offset1 = fmod(time + halfPeriod, period);

	half weight = offset0 / halfPeriod;
	half flag = step(1, weight);

	weight0 = (2.0 - weight) * flag + (1.0 - flag) * weight;
	weight1 = 1.0 - weight0;
}

half3x3 BuildDirTangentToWorldMat(half4 tangentWS, half3 normalWS)
{
	half sgn = tangentWS.w;      // should be either +1 or -1
	half3 bitangentWS = sgn * cross(normalWS.xyz, tangentWS.xyz);
	return half3x3(tangentWS.xyz, bitangentWS.xyz, normalWS.xyz);
}

//flow影响法线贴图
half3 GetWaterFlowNormalMapToNormalWS(half2 uv, half2 uvTile, TEXTURE2D_PARAM(normalMap, sampler_normalMap), half normalScale, half2 flow,
	half offset0, half offset1, half weight0, half weight1, half3x3 TransformDirToWMat)
{
	half2 tiledUV = uv * uvTile;
	half3 normalTS0 = UnpackNormalScale(SAMPLE_TEXTURE2D(normalMap, sampler_normalMap, tiledUV + flow * offset0), normalScale);
	half3 normalTS1 = UnpackNormalScale(SAMPLE_TEXTURE2D(normalMap, sampler_normalMap, tiledUV + flow * offset1), normalScale);
	normalTS0 = normalize(normalTS0);
	normalTS1 = normalize(normalTS1);

	//half3 normalTS = normalize(normalTS0 * weight0 + normalTS1 * weight1);
	half3 normalTS = normalTS0 * weight0 + normalTS1 * weight1;

	return normalize(TransformTangentToWorld(normalTS, TransformDirToWMat));
}

//折射颜色
half3 GetWaterRefractionColor(half3 viewDirWS, half3 normalWS, half2 screenUV, float ndcZ, float refractionMask, half refractionStrength,
	half refractionFactor, TEXTURE2D_PARAM(screenColorMap, sampler_screenColorMap), TEXTURE2D_PARAM(depthMap, sampler_depthMap), float depthRefractionStrength)
{
	//half2 screenUV = screenPosition.xy / screenPosition.ww;

	//离屏幕边缘约近,折射率率约小
	half3 refractDirWS = refract(-viewDirWS, normalWS, lerp(refractionFactor, 1, screenUV.y));

	//half3 refractDirCS = normalize(mul(UNITY_MATRIX_VP, half4(refractDirWS, 0))).xyz;
	//half3 negateViewDirCS = normalize(mul(UNITY_MATRIX_VP, half4(-viewDirWS, 0))).xyz;
	//half2 refractionUV = (refractDirCS.xy - negateViewDirCS.xy) * refractionStrength;

	half3 refractDirV = normalize(mul(UNITY_MATRIX_V, half4(refractDirWS, 0))).xyz;
	half3 negateViewDirV = normalize(mul(UNITY_MATRIX_V, half4(-viewDirWS, 0))).xyz;
	half2 refractionUV = (negateViewDirV.xy - refractDirV.xy) * refractionStrength;

//#if UNITY_UV_STARTS_AT_TOP
	refractionUV.y *= -1;
//#endif

	half2 refractionUVDetermine = screenUV + refractionUV;
	float linearPixelZ = LinearEyeDepth(ndcZ, _ZBufferParams);
	float linearScreenZDetermine = LinearEyeDepth(SAMPLE_TEXTURE2D_X(depthMap, sampler_depthMap, refractionUVDetermine).r, _ZBufferParams);
	//float linearScreenZ = LinearEyeDepth(SAMPLE_TEXTURE2D_X(depthMap, sampler_depthMap, screenUV).r, _ZBufferParams);

	//refractionUV *= step(linearPixelZ, linearScreenZDetermine);
	refractionUV *= saturate((linearScreenZDetermine - linearPixelZ) * depthRefractionStrength);

	//depthDiffFactor = 1;

	//out put color
	return SAMPLE_TEXTURE2D(screenColorMap, sampler_screenColorMap, screenUV + refractionUV * refractionMask).rgb;
}

//折射与散射的比率
half GetWaterRefractionScatterFactor(half3 viewDirWS, half depthFogDensity, half refractionFactorAsEnd)
{
	half viewYFactor = saturate(abs(1.0 - viewDirWS.y) * depthFogDensity);
	return viewYFactor * refractionFactorAsEnd;
}

//散射颜色
half3 GetWaterScatterColor(half3 diffuseColor, half3 diffuseGrazingColor, half3 viewDirWS)
{
	return lerp(diffuseColor, diffuseGrazingColor, abs(1.0 - viewDirWS.y));
}

//反射颜色
half3 GetWaterReflectionColor(half2 screenUV, half3 normalWS, half3 viewDirWS, half planarReflectionNormalsStrength, half ReflectionRoughness,
	half3 reflectionColor, TEXTURE2D_PARAM(reflectionMap, sampler_reflectionMap),out half reflectionAlpha)
{
	half3 reflectionDirWSUseNormal = reflect(-viewDirWS, normalWS);
	half3 reflectionDirCSUseNormal = normalize(mul(UNITY_MATRIX_VP, half4(reflectionDirWSUseNormal, 0)).xyz);
	half3 reflectionDirWSNoNormal = reflect(-viewDirWS, half3(0, 1, 0));
	half3 reflectionDirCSNoNormal = normalize(mul(UNITY_MATRIX_VP, half4(reflectionDirWSNoNormal, 0)).xyz);

	half2 reflectionUV = (reflectionDirCSUseNormal.xy - reflectionDirCSNoNormal.xy) * planarReflectionNormalsStrength;
	half4 mapColor = SAMPLE_TEXTURE2D_LOD(reflectionMap, sampler_reflectionMap, screenUV + reflectionUV, ReflectionRoughness);
	reflectionAlpha = mapColor.a;
	return mapColor.rgb * reflectionColor;
}

//反射系数
half GetWaterReflectionFactor(half3 normalWS, half3 viewDirWS, half fresneR, float fresnelPower, half factor)
{
	half nv = max(0, dot(normalWS, viewDirWS));
	float fresneBase = max(0, 1.0 - nv);
	half reflection = (1.0 - fresneR) * pow(fresneBase, fresnelPower) + fresneR;
	return reflection * factor;
}

//BlinnPhone
half3 GetWaterBlinnPhoneSpLighting(half3 normalWS, half3 halfVecWS, half specularBaseFactor, float specularPower, half3 specularColor)
{
	float base = max(0, dot(normalWS, halfVecWS)) * specularBaseFactor;
	return specularColor * pow(abs(base), specularPower);
}

//合并水的各个元素的颜色
half3 AppendWaterColor(half3 scatterColor, half3 refractionColor, half refractionScatterFactor, half3 reflectionColor, half reflectionAlpha, 
	half reflectionFactor, half3 blinnPhoneSpColor, half maskRefraction)
{
	half3 diffuse = lerp(refractionColor, scatterColor, refractionScatterFactor);
	diffuse = lerp(diffuse, reflectionColor, reflectionFactor * reflectionAlpha);
	half3 color = diffuse + blinnPhoneSpColor;

	return lerp(refractionColor, color, maskRefraction);
}

#endif
