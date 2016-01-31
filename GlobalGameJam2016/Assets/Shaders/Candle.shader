﻿Shader "Custom/Candle" {
	Properties {
		_Color ("Color", Color) = (1,1,1,1)
		_MainTex ("Albedo (RGB)", 2D) = "white" {}
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

		struct Input {
			float2 uv_MainTex;
		};

		fixed4 _Color;

		void surf (Input IN, inout SurfaceOutputStandard o) {
			fixed4 c = tex2D(_MainTex, IN.uv_MainTex);

			o.Albedo = c;
			o.Alpha = c.a;
		}

		void finalcolor (Input IN, SurfaceOutputStandard o, inout fixed4 color){
			color.rgb = lerp(color.rgb, fixed3(1,1,.7), .6);
		}

		ENDCG
	}
	FallBack "Diffuse"
}
