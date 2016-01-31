Shader "Camp Cult/Generators/ShaderName" {
Properties {
 }
Category {

Blend SrcAlpha OneMinusSrcAlpha
Tags {"Queue"="Transparent"}
SubShader {

Pass {

Cull Front

CGPROGRAM

#include "UnityCG.cginc"
#pragma vertex vert_img
#pragma fragment frag


uniform float4 camForward;

// tweaked copy of https://www.shadertoy.com/view/Xds3zN by inigo quilez - iq/2013
// License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.

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

float sdOcta( float3 p, float h, float w ){
    p.xz = abs(p.xz);
    p.y = abs(p.y)-h;
    return max(p.z,p.x)+(p.y*w);    
}

float2 map( in float3 pos )
{
    //pos.x += sin(pos.x+25.0+_Time.y)*0.2;
    //pos.y += cos(pos.x+pos.z+25.0+_Time.y)*0.2;
    
    float size = .923;
    float3 p = abs(fmod(pos.xyz+size,size*2.)-size)-size;
    float box = sdBox( p, float3(.3,.3,.3));
    float cyl = sdCappedCylinder( p, float2(.31, .32));
     
    float2  res = float2(box ,1.5); 
    
    return res;
}

float2 castRay( in float3 ro, in float3 rd )
{
    float tmin = 0.0;
    float tmax = 30.0;
    
    float t = tmin;
    float m = -1.0;
    for( int i=0; i<30; i++ )
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
    for( int i=0; i<5; i++ )
    {
        float hr = 0.01 + 0.12*float(i)/4.0;
        float3 aopos =  nor * hr + pos;
        float dd = map( aopos ).x;
        occ += -(dd-hr)*sca;
        sca *= .95;
    }
    return clamp( 1.0 - 3.0*occ, 0.0, 1.0 );    
}




float3 render( in float3 ro, in float3 rd )
{ 
    float3 col = float3(0.0, 0.0, 0.0);
    float2 res = castRay(ro,rd);
    float t = res.x;
	float m = res.y;
    
    if( m>-0.5 )
    {
        float3 pos = ro + t*rd;
        float3 nor = calcNormal( pos );
        float3 ref = reflect( rd, nor );
        
        // material        
        float occ = calcAO( pos, nor );
		col = 1.0 - hue(float3(ref),res.x + _Time.y);
		col = lerp( col, float3(1.0, 1.0, 1.0), 1.0-exp( -.002*t*t ) );

    }

return float3( clamp(col,0.0,1.0) );
}

float3x3 setCamera( in float3 ro, in float3 ta, float cr )
{
float3 cw = normalize(ta-ro);
float3 cp = float3(sin(cr), cos(cr),0.0);
float3 cu = normalize( cross(cw,cp) );
float3 cv = normalize( cross(cu,cw) );
    return float3x3( cu, cv, cw );
}

fixed4 frag (v2f_img i) : COLOR
{
	float2 q = i.uv;
    float2 p = (-1.0+2.0*q);
 
	// camera
	float3 ro = float3(0., 0., _Time.y );
	
    float3 ta = ro+float3( cos(p.x*3.14159), sin(p.y*3.14159), 1.);
	
    // camera-to-world transformation
    float3x3 ca = setCamera( ro, ta, 0. );

    // ray directio
	float3 rd = mul(ca,normalize(float3(cos(p.x*3.14159),sin(p.y*3.14159),2.5)));

    // render
    float3 col = render( ro, rd );
    //float kkkk = cos( p.x*3.14159);
    //col = float3(kkkk, kkkk, kkkk);

    return float4( col.x,col.y,col.z, 1.0 );
}
ENDCG
}
}
}
FallBack "Unlit"
}
