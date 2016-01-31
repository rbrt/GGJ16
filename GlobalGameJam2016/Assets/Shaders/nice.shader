Shader "Camp Cult/Generators/nice" {
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
float sdPlane( float3 p )
{
return p.y;
}

float sdSphere( float3 p, float s )
{
    return length(p)-s;
}

float sdBox( float3 p, float3 b )
{
  float3 d = abs(p) - b;
  return min(max(d.x,max(d.y,d.z)),0.0) + length(max(d,0.0));
}

float sdEllipsoid( in float3 p, in float3 r )
{
    return (length( p/r ) - 1.0) * min(min(r.x,r.y),r.z);
}

float udRoundBox( float3 p, float3 b, float r )
{
  return length(max(abs(p)-b,0.0))-r;
}

float sdTorus( float3 p, float2 t )
{
  return length( float2(length(p.xz)-t.x,p.y) )-t.y;
}

float sdHexPrism( float3 p, float2 h )
{
    float3 q = abs(p);
#if 0
    return max(q.z-h.y,max((q.x*0.866025+q.y*0.5),q.y)-h.x);
#else
    float d1 = q.z-h.y;
    float d2 = max((q.x*0.866025+q.y*0.5),q.y)-h.x;
    return length(max(float2(d1,d2),0.0)) + min(max(d1,d2), 0.);
#endif
}

float sdCapsule( float3 p, float3 a, float3 b, float r )
{
float3 pa = p-a, ba = b-a;
float h = clamp( dot(pa,ba)/dot(ba,ba), 0.0, 1.0 );
return length( pa - ba*h ) - r;
}

float sdTriPrism( float3 p, float2 h )
{
    float3 q = abs(p);
#if 0
    return max(q.z-h.y,max(q.x*0.866025+p.y*0.5,-p.y)-h.x*0.5);
#else
    float d1 = q.z-h.y;
    float d2 = max(q.x*0.866025+p.y*0.5,-p.y)-h.x*0.5;
    return length(max(float2(d1,d2),0.0)) + min(max(d1,d2), 0.);
#endif
}

float sdCylinder( float3 p, float2 h )
{
  float2 d = abs(float2(length(p.xy),p.z)) - h;
  return min(max(d.x,d.y),0.0) + length(max(d,0.0));
}

float sdCone( in float3 p, in float3 c )
{
    float2 q = float2( length(p.xz), p.y );
    float d1 = -q.y-c.z;
    float d2 = max( dot(q,c.xy), q.y);
    return length(max(float2(d1,d2),0.0)) + min(max(d1,d2), 0.);
}

float sdConeSection( in float3 p, in float h, in float r1, in float r2 )
{
    float d1 = -p.y - h;
    float q = p.y - h;
    float si = 0.5*(r1-r2)/h;
    float d2 = max( sqrt( dot(p.xz,p.xz)*(1.0-si*si)) + q*si - r2, q );
    return length(max(float2(d1,d2),0.0)) + min(max(d1,d2), 0.);
}


float length2( float2 p )
{
return sqrt( p.x*p.x + p.y*p.y );
}

float length6( float2 p )
{
p = p*p*p; p = p*p;
return pow( p.x + p.y, 1.0/6.0 );
}

float length8( float2 p )
{
p = p*p; p = p*p; p = p*p;
return pow( p.x + p.y, 1.0/8.0 );
}

float sdTorus82( float3 p, float2 t )
{
  float2 q = float2(length2(p.xz)-t.x,p.y);
  return length8(q)-t.y;
}

float sdTorus88( float3 p, float2 t )
{
  float2 q = float2(length8(p.xz)-t.x,p.y);
  return length8(q)-t.y;
}

float sdCylinder6( float3 p, float2 h )
{
  return max( length6(p.xz)-h.x, abs(p.y)-h.y );
}

//----------------------------------------------------------------------

float opS( float d1, float d2 )
{
    return max(-d2,d1);
}

float2 opU( float2 d1, float2 d2 )
{
return (d1.x<d2.x) ? d1 : d2;
}

float opU( float d1, float d2 )
{
    return min(d2,d1);
}

float3 opRep( float3 p, float3 c )
{
    return fmod(p,c)-0.5*c;
}

float smin( float a, float b, float k ){
    float h = clamp( 0.5+0.5*(b-a)/k, 0.0, 1.0 );
    return lerp( b, a, h ) - k*h*(1.0-h);
}

float sdOcta( float3 p, float h, float w ){
    p.xz = abs(p.xz);
    p.y = abs(p.y)-h;
    return max(p.z,p.x)+(p.y*w);    
}

float2 rotate(float2 v, float a){
float t = atan2(v.y,v.x)+a;
    float d = length(v);
    v.x = cos(t)*d;
    v.y = sin(t)*d;
    return v;
}
float2 stretch(float2 v, float s){
float t = atan2(v.y,v.x);
    float d = length(v);
    d +=d*s;
    v.x = cos(t)*d;
    v.y = sin(t)*d;
    return v;  
}



float size = .5;
float width = .02;

float2 gif1(float3 pos){
    
    float3 p = pos;
    float d = (pos.z-_Time.y);
    //pos.x = abs(pos.x);
    
    pos.xy = rotate(pos.xy,d*.75);
    pos = fmod(pos, size*2.)-size;
    
    float b = sdSphere(pos,size);
    float2  res = float2(b,pos.y);
    
    //pos.x = abs(pos.x);

    //pos.x-=.5*(1.0-d*.1);
    //res.x = smin(res.x,b,d*.1);
    //p.y = -abs(p.y);
    //res.x = smin(res.x, sdPlane(p+float3(0.,width*50.,0.)), d*0.35-0.1);
    
    return res;
}

float2 gif2(float3 pos){
    float3 p = pos;
    float d = (pos.z-_Time.y);
    pos.x = abs(pos.x);
    
    pos.xy = rotate(pos.xy,d*.45);
    pos = fmod(pos, size*2.)-size;
    
    float b = sdSphere(pos,width);
    float2  res = float2(b,pos.y);
    
    pos.x = abs(pos.x);
    pos.x-=.7*(1.0-d*.1);
    pos.xy = rotate(pos.xy,d*.45);

    b = sdSphere(pos,width);
   
    res.x = smin(res.x,b,d*.4 + 0.4);
    res.x = smin(res.x, sdPlane(p+float3(0.,width*70.,0.)), d*0.25);
   
    return res;
}

float camZ;

float2 map(float3 pos )
{
    float d = (pos.z-_Time.y);

    pos.x += sin(pos.x+25.0+pos.z+_Time.y)*0.2;
    pos.y += cos(pos.x+pos.z+25.0+_Time.y)*0.2;
    
    float size = .923;
    float3 p = abs(fmod(pos.xyz+size,size*2.)-size)-size;
    float box = sdBox( p, float3(.3,.3,.3));
     
    float2  res = float2(box ,1.5); 
    
    return res;
}

float2 castRay( in float3 ro, in float3 rd )
{
    float tmin = 0.0;
    float tmax = 100.0;
    
    float t = tmin;
    float m = -1.0;
    for( int i=0; i<100; i++ )
    {
   float2 res = map( ro+rd*t );
        if(  t>tmax ) break;
        t += res.x;
   m = res.y;
    }

    if( t>tmax ) m=-1.0;
    return float2( t, m );
}


float softshadow( in float3 ro, in float3 rd, in float mint, in float tmax )
{
float res = 1.0;
    float t = mint;
    for( int i=0; i<20; i++ )
    {
float h = map( ro + rd*t ).x;
        res = min( res, 8.0*h/t );
        t += clamp( h, 0., 0.1 );
        if(t>tmax ) break;
    }
    return clamp( res, 0.0, 1.0 );

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

float3 palette( in float t, in float3 a, in float3 b, in float3 c, in float3 d )
{
    return a + b*cos( 6.28318*(c*t+d) );
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
		col = float3(res.x/100., res.x/100., res.x/100.)*occ;
		col = lerp( col, float3(1.0, 1.0, .0), 1.0-exp( -.002*t*t ) );

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
	camZ = _Time.y;
	float2 q = i.uv;
    float2 p = (-1.0+2.0*q);
 
	// camera
	float3 ro = float3(0., 0., camZ );
	
    float3 ta = ro+float3( cos(p.x*3.14159), sin(p.y*3.14159), 1.);
	
    // camera-to-world transformation
    float3x3 ca = setCamera( ro, ta, 0. );

    // ray directio
	float3 rd = mul(ca,normalize(float3(cos(p.x*3.14159),sin(p.y*3.14159),1.5)));

	float3 col = render( ro, rd );

    return float4( col.x,col.y,col.z, 1.0 );
}
ENDCG
}
}
}
FallBack "Unlit"
}
