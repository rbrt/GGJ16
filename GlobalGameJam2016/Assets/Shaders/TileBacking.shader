Shader "Custom/TileBacking"
{
	Properties
	{
		_MainTex("MainTex", 2D) = "white" {}
		_Color ("Color", Color) = (1,1,1,1)
	}
	SubShader
	{
		Tags { "RenderType"="Transparent" "IgnoreProjector"="True" "RenderQueue"="Transparent" }
		LOD 100
		Blend SrcAlpha OneMinusSrcAlpha


		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			// make fog work
			#pragma multi_compile_fog

			#include "UnityCG.cginc"

			struct appdata {
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
			};

			struct v2f {
				float2 uv : TEXCOORD0;
				float4 vertex : SV_POSITION;
			};

			fixed4 _Color;
			float4 _MainTex_ST;

			v2f vert (appdata v) {
				v2f o;
				o.vertex = mul(UNITY_MATRIX_MVP, v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				return o;
			}

			fixed4 frag (v2f i) : SV_Target {
				fixed4 col = fixed4(0,0,0,0);

				float2 centerUV = abs(i.uv * 2 - half2(1,1));

				if (fmod(floor(abs(centerUV.x - _Time.x * 5) * 10), 2) < 1 && centerUV.y < centerUV.x){
					col = _Color * .4;
				}
				else if (fmod(floor(abs(centerUV.y - _Time.x * 5) * 10), 2) < 1 && centerUV.x < centerUV.y){
					col = _Color * .4;
				}

				return col;
			}
			ENDCG
		}
	}
}
