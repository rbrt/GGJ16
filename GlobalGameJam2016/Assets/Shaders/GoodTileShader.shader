Shader "Custom/TileShader" {
	Properties {
		_Color ("Color", Color) = (1,1,1,1)
		_MainTex ("Albedo (RGB)", 2D) = "white" {}
		_FloorTex ("Floor", 2D) = "white" {}
		_ShowGlyph ("ShowGlyph", Range(0,1)) = 0
		_Saturation ("Saturation", Range(0,1)) = 1
	}
	SubShader {
		Tags { "RenderType"="Opaque" }
		LOD 200

		CGPROGRAM
		// Physically based Standard lighting model, and enable shadows on all light types
		#pragma surface surf Standard fullforwardshadows finalcolor:finalcolor

		// Use shader model 3.0 target, to get nicer looking lighting
		#pragma target 3.0

		sampler2D _MainTex;
		sampler2D _FloorTex;

		struct Input {
			float2 uv_MainTex;
		};

		fixed4 _Color;
		float _ShowGlyph;
		float _Saturation;

		fixed3 saturation(fixed3 col){
			return lerp(dot(col, fixed3(.222, .707, .071)), col, _Saturation);
		}

		void surf (Input IN, inout SurfaceOutputStandard o) {
			float2 newUV = IN.uv_MainTex;

			fixed4 floor = tex2D(_FloorTex, newUV);
			fixed4 c = tex2D (_MainTex, newUV);
			if (distance(c, fixed4(0,0,0,0)) < .1){
				o.Albedo = _Color.rgb;
			}
			else{
				o.Albedo = c.rgb * _ShowGlyph;
			}

			o.Albedo = lerp(o.Albedo, floor.rgb, .3);
			o.Alpha = c.a;
		}

		void finalcolor (Input IN, SurfaceOutputStandard o, inout fixed4 color){
			color.rgb = saturation(color.rgb);
		}

		ENDCG
	}
	FallBack "Diffuse"
}
