Shader "Unlit/ViewportShader"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_Saturation ("Saturation", Range(0,1)) = 1
		_Crush ("Crush", Range(0, 600)) = 600
	}
	SubShader
	{
		Tags { "RenderType"="Opaque" }
		LOD 100

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			// make fog work
			#pragma multi_compile_fog

			#include "UnityCG.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				UNITY_FOG_COORDS(1)
				float4 vertex : SV_POSITION;
			};

			sampler2D _MainTex;
			float4 _MainTex_ST;
			float _Saturation;
			float _Crush;

			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = mul(UNITY_MATRIX_MVP, v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				return o;
			}

			fixed4 frag (v2f i) : SV_Target
			{
				i.uv = floor(i.uv * _Crush) / _Crush;
				fixed4 col = tex2D(_MainTex, i.uv);

				col.rgb = lerp(dot(col.rgb, fixed3(.222, .707, .071)), col.rgb, _Saturation);

				return col;
			}
			ENDCG
		}
	}
}
