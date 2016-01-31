Shader "Custom/PentagramShader" {
	Properties {
		_Color ("Color", Color) = (1,1,1,1)
		_MainTex ("Albedo (RGB)", 2D) = "white" {}
		_EnableEffect ("EnableEffect", Range(0,1)) = 0
	}
	SubShader {
		Tags { "Queue"="AlphaTest" "IgnoreProjector"="True" "RenderType"="TransparentCutout" }
		LOD 100
		Blend SrcAlpha OneMinusSrcAlpha

		CGPROGRAM
		// Physically based Standard lighting model, and enable shadows on all light types
		#pragma surface surf Standard fullforwardshadows finalcolor:finalcolor keepalpha

		// Use shader model 3.0 target, to get nicer looking lighting
		#pragma target 3.0

		sampler2D _MainTex;
		float _EnableEffect;
		float4 _MainTex_TexelSize;

		struct Input {
			float2 uv_MainTex;
		};

		fixed4 _Color;

		half2 spin(float theta, float2 inUV){
			float2 uv = float2(.1, .1);
			float2 newPoint = float2((cos(theta) * (uv.x) + sin(theta) * (uv.y)),
							  (-sin(theta) * (uv.x) + cos(theta) * (uv.y)));
			float2 result = inUV * 2 - half2(1,1);
			result += newPoint;
			return (result + half2(1,1)) / 2;
		}

		void surf (Input IN, inout SurfaceOutputStandard o) {
			fixed4 c = tex2D(_MainTex, IN.uv_MainTex) * _Color;;

			if (_EnableEffect > 0 && c.a < .1){
				float theta = _Time.z * (_EnableEffect) * 7;
				float2 newUV = spin(theta, IN.uv_MainTex);
				c = tex2D(_MainTex, newUV) * _Color * .4;
				if (c.a < .1){
					theta = _Time.z * (_EnableEffect * 2) * 3;
					newUV = spin(theta, IN.uv_MainTex);
					c = tex2D(_MainTex, newUV) * _Color * .4;
				}
			}

			o.Alpha = c.a;
		}

		void finalcolor (Input IN, SurfaceOutputStandard o, inout fixed4 color){
			color.rgb = lerp(color.rgb, _Color.rgb, .6);
		}

		ENDCG
	}
	FallBack "Diffuse"
}
