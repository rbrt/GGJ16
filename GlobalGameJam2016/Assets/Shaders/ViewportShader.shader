Shader "Unlit/ViewportShader"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_Saturation ("Saturation", Range(0,1)) = 1
		_Blackout ("Blackout", Range(0,1)) = 0
		_Chroma ("Chroma", Range(0,1)) = 0
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

			#include "UnityCG.cginc"

			struct appdata {
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
			};

			struct v2f {
				float2 uv : TEXCOORD0;
				UNITY_FOG_COORDS(1)
				float4 vertex : SV_POSITION;
			};

			sampler2D _MainTex;
			float4 _MainTex_ST;
			float4 _MainTex_TexelSize;
			float _Saturation;
			float _Blackout;
			float _Chroma;

			float3 vignette(float2 uv, float3 col){
				float2 centerUV = abs(uv * 2 - half2(1,1));
				float dist = distance(centerUV, fixed2(0,0));
				float threshold = (.75 + sin(_Time.x * _Time.x * _Time.x) * .05);
				if (dist > threshold){
					float val = (dist - threshold) * 2;
					col *= (1 - val * val);
				}
				return col;
			}

			float3 chroma(float3 col, float2 uv){
				uv.x += _MainTex_TexelSize.x * (1 + _Chroma * 8);
				fixed4 colA = tex2D(_MainTex, uv);
				uv.x -= _MainTex_TexelSize.x * (1 + _Chroma * 16);
				fixed4 colB = tex2D(_MainTex, uv);
				fixed3 newColor = fixed3(col.r, colA.g, colB.b);

				return newColor;

			}

			v2f vert (appdata v) {
				v2f o;
				o.vertex = mul(UNITY_MATRIX_MVP, v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				return o;
			}

			fixed4 frag (v2f i) : SV_Target {
				fixed4 col = tex2D(_MainTex, i.uv);

				col.rgb = lerp(dot(col.rgb, fixed3(.222, .707, .071)), col.rgb, _Saturation);

				col.rgb = lerp(col.rgb, chroma(col.rgb, i.uv), _Chroma);

				col.rgb = vignette(i.uv, col.rgb);

				col.rgb *= _Blackout;
				return col;
			}
			ENDCG
		}
	}
}
