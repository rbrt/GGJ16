Shader "Unlit/TripPortal2"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
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
			
			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = mul(UNITY_MATRIX_MVP, v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				UNITY_TRANSFER_FOG(o,o.vertex);
				return o;
			}

			float hash( float n )
			{
			    return frac(sin(n)*43758.5453123);
			}

			float noise( in fixed2 x )
			{
			    float2 p = floor(x);
			    float2 f = frac(x);

			    f = f*f*(3.0-2.0*f);

			    float n = p.x + p.y*157.0;

			    return lerp(lerp( hash(n+  0.0), hash(n+  1.0),f.x),
			               lerp( hash(n+157.0), hash(n+158.0),f.x),f.y);
			}

			float2 kale(float2 uv, float angle, float base, float spin) {
				float a = atan(uv.y/uv.x)+spin;
				float d = length(uv);
				a = fmod(a,angle*2.0);
				a = abs(a-angle);
				uv.x = sin(a+base)*d;
				uv.y = cos(a+base)*d;
			    return uv;
			}

			fixed4 frag (v2f i) : SV_Target
			{
				// sample the texture
				fixed4 col = tex2D(_MainTex, i.uv);

			    fixed2 uv = abs(i.uv * 2.0 - 1.0);
			    uv = kale(uv, 0.05, _Time.x, uv.x + 3.14159 );

			    float c = sin(uv.y*45.*uv.x+(_Time.x))*.5+.5;
			    return fixed4(c,c,c, 1.0);
			}
			ENDCG
		}
	}
}
