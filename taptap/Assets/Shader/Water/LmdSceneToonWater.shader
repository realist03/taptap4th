Shader "Universal Render Pipeline/LMD/SceneToonWater"
{
    Properties
    {
		_DiffuseColor("Diffuse颜色", Color) = (0,0,0.8018868,0)
        _DiffuseGrazingColor("边缘Diffuse颜色", Color) = (0.4746947,0.01134743,0.8018868,0)
		_TimeScale("TimeScale", Range(0 , 2)) = 1
        
        [Header(DepthLayer0)]
        _DepthNear("DepthNear",Float) = 0
        _DepthFar("DepthFar",Float) = 1
        _DepthPow("DepthPow",Float) = 1

        [Header(DepthLayer1)]
        _DepthNear1("DepthNea1r",Float) = 0
        _DepthFar1("DepthFar1",Float) = 1
        _DepthPow1("DepthPow1",Float) = 1

        [Header(DepthLayer2)]
        _DepthNear2("DepthNear2",Float) = 0
        _DepthFar2("DepthFar2",Float) = 1
        _DepthPow2("DepthPow2",Float) = 1

        [space(5)][Header(Flow)]
		[Toggle]_FLOWMAP("是否使用流动图", Float) = 0
		_half_period("half_period", Range(0 , 5)) = 1
		_FlowDir("水流方向", Vector) = (-0.2,-0.2,0,0)
		[Texture]_WaterFlowMap("水流动图", 2D) = "gray" {}
		_FlowScale("流速强度", Range(-5 , 5)) = 1
		[Texture]_WaveNormalMap("波浪法线图0", 2D) = "bump" {}
		[Texture]_WaveNormalMap1("波浪法线图1", 2D) = "bump" {}
		_NormalMapTileOffset("法线贴图TileOffset", Vector) = (1,1,0,0)
		_NormalMapTileOffset1("法线贴图TileOffset1", Vector) = (1,1,0,0)
		_NormalScale("法线强度", Range(-2 , 10)) = 1
		_NormalScale1("法线强度1", Range(-2 , 10)) = 1

        [space(5)][Header(Specular)]
		_SpecularColor("高光颜色", Color) = (1,1,1,1)
		_SpecularBaseFactor("高光Base因子", Range(0 , 5)) = 1
		_SpecularPower("高光强度", Range(0 , 1000)) = 1000
        _SpecularIntensity("SpecularIntensity",Float) = 1
        _ViewDir("ViewDir",Vector) = (0,0,0,0)

        _ShorelineWide("ShorelineWide",Float) = 1
        _ShorelineWideMinus("ShorelineWideMinus",Float) = 1
        _ShorelineWide1("ShorelineWide1",Float) = 1
        _ShorelineWide1Minus("ShorelineWide1Minus",Float) = 1
        _ShorelineWide2("ShorelineWide2",Float) = 1
        _ShorelineWide2Minus("ShorelineWide2Minus",Float) = 1

		[Texture]_Noise("Noise", 2D) = "white" {}

        [space(5)][Header(Reflection)]
		_ReflectionColor("反射颜色", Color) = (1,1,1,1)
		_ReflectionRoughness("反射粗糙等级", Float) = 0
		_PlanarReflectionNormalsStrength("法线影响反射的强度", Range(0 , 10)) = 1
		_FresnelPower("菲涅尔强度", Range(0 , 100)) = 0
		_FresneR("反射菲涅尔系数", Range(0 , 2)) = 1
		_ReflectionFactor("反射系数", Range(0 , 2)) = 1

		[space(5)][Header(Refraction)]
		_RefractionFactor("折射率", Range(0 , 2)) = 1
		_DepthFogDensityFloat("折射基础比率", Float) = 1
		_RefractionStrength("水面折射强度", Range(0 , 1)) = 0
		_DepthRefractionStrength("水面根据深度的折射强度", Range(0,2)) = 1
		_RefractionFactorAsEnd("折射最终比率调整", Range(0 , 10)) = 1

        [Toggle(_USEPROJECTCAUSTIC)]_UseProjectCaustic("Use Project Caustic",Float) = 0
		[Texture]_Caustic("Caustic", 2D) = "white" {}
        _CausticTile("CausticTile",Range(0,1)) = 1
        _CausticStrength("CausticStrength",Range(0,2)) = 1
    }
    SubShader
    {
        Tags{"RenderType" = "Geometry" "Queue" = "Transparent" "RenderPipeline" = "UniversalPipeline" "IgnoreProjector" = "True"}
        
        LOD 300

        Pass
        {
            Name "ForwardLit"
            Tags{"LightMode" = "UniversalForward"}

            //Blend SrcAlpha OneMinusSrcAlpha
            ZWrite Off
			Cull Back

			//Stencil
			//{
			//    Ref 1
			//	Comp Always
			//	Pass Replace
//
			//}

            HLSLPROGRAM
            #pragma prefer_hlslcc gles
            #pragma exclude_renderers d3d11_9x
            #pragma target 3.0

            #pragma multi_compile _ _MAIN_LIGHT_SHADOWS
            #pragma multi_compile _ _MAIN_LIGHT_SHADOWS_CASCADE
            #pragma multi_compile _ _ADDITIONAL_LIGHTS_VERTEX _ADDITIONAL_LIGHTS _ADDITIONAL_LIGHTS_FORWARD_PLUS
            #pragma multi_compile _ _ADDITIONAL_LIGHT_SHADOWS
            #pragma multi_compile _ _SHADOWS_SOFT _SHADOWS_PCSS
            #pragma multi_compile _ _MIXED_LIGHTING_SUBTRACTIVE

            #pragma multi_compile _ DIRLIGHTMAP_COMBINED
            #pragma multi_compile _ LIGHTMAP_ON
            #pragma multi_compile_fog

            #pragma multi_compile_instancing

			#define _NORMALMAP 1
			#pragma shader_feature _FLOWMAP_ON
			#pragma multi_compile _ _REFLECTION_ON
            #pragma shader_feature _USEPROJECTCAUSTIC
            #pragma vertex LitPassVertex
            #pragma fragment ToonLitPassFragment

            #include "LmdSceneWaterInput.hlsl"
            #include "LmdSceneWaterForwardPass.hlsl"

            ENDHLSL
        }
    }
    CustomEditor"HybirdGUI"
}
