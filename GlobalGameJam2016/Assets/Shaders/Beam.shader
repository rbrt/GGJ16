Shader "Custom/Beam" {
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
		#pragma vertex vert

		// Use shader model 3.0 target, to get nicer looking lighting
		#pragma target 3.0

		struct Input {
			float2 uv_MainTex: TEXCOORD0;
			float4 vertex: SV_POSITION;
		};

		sampler2D _MainTex;
		fixed4 _Color;

		fixed4 swirl(float2 uv){
			float rotation = .05 + sin(uv.x * 10 * _SinTime.x);

			float theta = rotation + _Time.z * .5;

			float centerCoordx = (uv.x * 2.0 - 1.0);
			float centerCoordy = (uv.y * 2.0 - 1.0);

			float len = sqrt(pow(centerCoordx, 2.0) + pow(centerCoordy, 2.0));

			float2 vecA = float2(centerCoordx, centerCoordy);
			float2 vecB = float2(len, 0);

			float initialValue = dot(vecA, vecB) / (len * 1.0);
			float degree = degrees(acos(initialValue));

			float thetamod = degree * len;
			float intensity = rotation * 20.0 + (_Time.z * 2 - 1) * .1;

			theta += thetamod * ((intensity) / 100.0);

			float2 newPoint = float2((cos(theta) * (uv.x * 2.0 - 1.0) + sin(theta) * (uv.y * 2.0 - 1.0) + 1.0)/2.0,
							  (-sin(theta) * (uv.x * 2.0 - 1.0) + cos(theta) * (uv.y * 2.0 - 1.0) + 1.0)/2.0);


			return tex2D(_MainTex, newPoint);
		}

		void vert (inout appdata_full v, out Input o) {
			UNITY_INITIALIZE_OUTPUT(Input, o);
			o.vertex = mul(UNITY_MATRIX_MVP, v.vertex);
      	}

		void surf (Input IN, inout SurfaceOutputStandard o) {
			fixed4 c = swirl(IN.uv_MainTex * .1) * _Color;
			o.Albedo = c.rgb;
			o.Alpha = c.a;
		}

		void finalcolor (Input IN, SurfaceOutputStandard o, inout fixed4 color){
			//color.rgb = lerp(color.rgb, _Color, .6);
			//color.rgb *= 4;
		}
		ENDCG
	}
	FallBack "Diffuse"
}
