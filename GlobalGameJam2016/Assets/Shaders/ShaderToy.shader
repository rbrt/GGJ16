Shader "Hidden/ShaderToy"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
	}
	SubShader
	{
		// No culling or depth
		Cull Off

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			#include "UnityCG.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				float4 vertex : SV_POSITION;
			};

			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = mul(UNITY_MATRIX_MVP, v.vertex);
				o.uv = v.uv;
				return o;
			}
			uniform float4 iResolution;
			uniform float4 camForward;
			uniform float4 camUp;
			uniform float4 camRight;
			uniform float distFromOrigin;
			uniform float distFromPath;
			uniform float3 buddyPos;
			sampler2D _MainTex;

			
			// tweaked copy of https://www.shadertoy.com/view/Xds3zN by inigo quilez - iq/2013
			// License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.

			float sdPlane( float3 p )
			{
				return p.y;
			}

			float3 hue(float3 color, float shift) {
			
			    const float3  kRGBToYPrime = float3 (0.299, 0.587, 0.114);
			    const float3  kRGBToI     = float3 (0.596, -0.275, -0.321);
			    const float3  kRGBToQ     = float3 (0.212, -0.523, 0.311);
			
			    const float3  kYIQToR   = float3 (1.0, 0.956, 0.621);
			    const float3  kYIQToG   = float3 (1.0, -0.272, -0.647);
			    const float3  kYIQToB   = float3 (1.0, -1.107, 1.704);
			
			    // Convert to YIQ
			    float   YPrime  = dot (color, kRGBToYPrime);
			    float   I      = dot (color, kRGBToI);
			    float   Q      = dot (color, kRGBToQ);
			
			    // Calculate the hue and chroma
			    float   hue     = atan2 (Q, I);
			    float   chroma  = sqrt (I * I + Q * Q);
			
			    // Make the user's adjustments
			    hue += shift;
			
			    // Convert back to YIQ
			    Q = chroma * sin (hue);
			    I = chroma * cos (hue);
			
			    // Convert back to RGB
			    float3    yIQ   = float3 (YPrime, I, Q);
			    color.r = dot (yIQ, kYIQToR);
			    color.g = dot (yIQ, kYIQToG);
			    color.b = dot (yIQ, kYIQToB);
			
			    return color;
			}
			
			float sdBox( float3 p, float3 b )
			{
			  float3 d = abs(p) - b;
			  return min(max(d.x,max(d.y,d.z)),0.0) +
			         length(max(d,0.0));
			}
			
			float sdCappedCylinder( float3 p, float2 h ) {
			  float2 d = abs(float2(length(p.xy),p.z)) - h;
			  return min(max(d.x,d.y),0.0) + length(max(d,0.0));
			}
			
			float opS( float d1, float d2 )
			{
			    return max(-d1,d2);
			}

			float sdSphere( float3 p, float s )
			{
				return length(p)-s;
			}

			float sdOcta( float3 p, float h, float w ){
			    p.xz = abs(p.xz);
			    p.y = abs(p.y)-h;
			    return max(p.z,p.x)+(p.y*w);    
			}
			
			float3 mod(float3 x, float y)
			{
				return x - y * floor(x/y);
			}

			float2 rotate(float2 v, float a){
				float t = atan2(v.y,v.x)+a;
			    float d = length(v);
			    v.x = cos(t)*d;
			    v.y = sin(t)*d;
			    return v;
			}

			float camZ;
			float smin( float a, float b, float k ){
			    float h = clamp( 0.5+0.5*(b-a)/k, 0.0, 1.0 );
			    return lerp( b, a, h ) - k*h*(1.0-h);
			}

			float2 opU( float2 d1, float2 d2 )
			{
				return (d1.x<d2.x) ? d1 : d2;
			}

			float2 map(float3 pos )
			{
			    float3 pp = pos;
				float size = 0.2;

				pos.y -= sin(_Time.y+pos.z+abs(pos.x))*0.6*distFromOrigin - size*4.;

				//pos.xy = rotate(pos.xy,(pos.z+_Time.z)*0.025);
			    pos = mod(pos, size*10.)-size*5.;

			    float b = sdSphere(pos,size);
			    float haters = sdBox(pos,float3(size*0.2, size*3., size*0.5));
			    haters = min(haters, sdBox(pos-float3(0.,size,0.),float3(size*2., size*0.2, size*0.5)));

			    float2 res = float2(lerp(b, haters, distFromOrigin),abs(pp.y));
			   
			  	res.x = smin(res.x, sdPlane(pp+float3(0.,size*4.,0.)), .6);
			    res = opU(res, float2(sdBox(float3(pp.x,pp.y+size*0.85,fmod(pp.z,size*5.)), float3(size, size, size*4.9)), -1.)); 
			    
			    return res;
			}
			
			float2 castRay( in float3 ro, in float3 rd )
			{
			    float tmin = 0.0;
			    float tmax = 80.0;
			    
			    float t = tmin;
			    float m = -1.0;
			    for( int i=0; i<80; i++ )
			    {
			   		float2 res = map( ro+rd*t );
			        if(  t>tmax ) break;
			        t += res.x;
			   		m = res.y;
			    }
			
			    if( t>tmax ) m=-1.0;
			    return float2( t, m );
			}
			
			float3 calcNormal( in float3 pos )
			{
				float3 eps = float3( 0.01, 0.0, 0.0 );
				float3 nor = float3(
				map(pos+eps.xyy).x - map(pos-eps.xyy).x,
				map(pos+eps.yxy).x - map(pos-eps.yxy).x,
				map(pos+eps.yyx).x - map(pos-eps.yyx).x );
				return normalize(nor);
			}
			
			float calcAO( in float3 pos, in float3 nor )
			{
				float occ = 0.0;
			    float sca = 1.0;
			    for( int i=0; i<2; i++ )
			    {
			        float hr = 0.01 + 0.12*float(i)/4.0;
			        float3 aopos =  nor * hr + pos;
			        float dd = map( aopos ).x;
			        occ += -(dd-hr)*sca;
			        sca *= .95;
			    }
			    return clamp( 1.0 - 3.0*occ, 0.0, 1.0 );    
			}
			
			
			
			
		float3 palette( in float t, in float3 a, in float3 b, in float3 c, in float3 d )
		{
		    return a + b*cos( 6.28318*(c*t+d) );
		}

		float3 render( in float3 ro, in float3 rd )
		{ 
		    float3 col = float3(1.,1.,1.);
		    float2 res = castRay(ro,rd);
		   
		    float3 pos = ro + res.x*rd;
		    float3 nor = calcNormal( pos );
		    float3 ref = reflect( rd, nor );    

		    // lighitng        
		    float occ = calcAO( pos, nor );
		    float dom = smoothstep( -0.6, 0.6, ref.y );

		    //dom *= softshadow( pos, ref, .9, .15 );

		    const float3 a = float3(.2, .5, .0);
		    const float3 b = float3(0.5, 0.5, .8);
		    const float3 c = float3(0., 0.2, 0.2);
		    const float3 d = float3(.0,.9,.9);

		    if (res.y < 0.0) {
		    	col = float3(occ, occ, occ)*ref;
		    } else {
		    	col= 1.-palette((res.x*res.x*.01 + distFromOrigin*res.x*res.x + sin(_Time.z)) ,a,b,c,d)*occ*length(ref)*(1.8 +dom);
		    }
			col.rgb = col.grr;    

    		col = lerp( col, float3(.0,0.,0.), 1.0-exp( -0.001*res.x*res.x ) );
    		col -= distFromPath*0.9;	

		    return col;
		}
			float3x3 setCamera( in float3 ro, in float3 ta, float3 up)
			{
				float3 cw = normalize(ta-ro);
				float3 cp = up;
				float3 cu = normalize( cross(cp,cw) );
				float3 cv = normalize( cross(cu,cw) );
			    return transpose(float3x3( cu, cv, cw ));
			}
			
			float4 mainImage(in float2 fragCoord )
			{ 
				camZ = _Time.y;
				float2 q = fragCoord.xy/iResolution.xy;
			
			    float2 p = -1.0 + 2.0*q;
			
			    p.x *= iResolution.x/iResolution.y;
			 
				// camera
				float3 ro = buddyPos*0.1;
				
			    float3 ta = ro + camForward;
				
			    // camera-to-world transformation
			    float3x3 ca = transpose(float3x3(camRight.xyz, camUp.xyz, camForward.xyz));//setCamera( ro, ta, camUp);
			
			    // ray direction
				float3 rd = mul(ca, normalize(float3(p.xy,2.75)));
			
			    // render
			    float3 col = render( ro, rd );
			
			    float4 fragColor=float4( col, 1.0 );
			    
			    return fragColor;
			}
			fixed4 frag (v2f i) : SV_Target
			{
				fixed4 col;
				col = mainImage(i.uv*iResolution.xy);
				return col;
			}
			
			ENDCG
		}
	}
}
