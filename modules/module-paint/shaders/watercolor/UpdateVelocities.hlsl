struct FragmentData
{
	float2 uv0 : TEXCOORD0;
	float2 uv1 : TEXCOORD1;	// + texelSize.xz
	float2 uv2 : TEXCOORD2;	// - texelSize.xz
	float2 uv3 : TEXCOORD3;	// + texelSize.zy
	float2 uv4 : TEXCOORD4;	// - texelSize.zy
	float2 uv5 : TEXCOORD5;	//  + halfTexelSize.xy + halfTexelSize.zy
	float2 uv6 : TEXCOORD6;	//   - halfTexelSize.xy - halfTexelSize.xz
};

cbuffer ShaderData
{
	float3 halfTexelSize;// (1/canvas.width, -1/canvas.height, 0)
	float3 texelSize;
	float viscosity;
	float drag;
	float dt;
};

Texture2D field;

SamplerState linearSampler
{
	Filter = LINEAR;
};

float4 main(FragmentData input) : SV_Target
{
	float4 current = field.Sample(linearSampler, input.uv0);
	float3 rightAll = field.Sample(linearSampler, input.uv1).xyz;
	float3 leftAll = field.Sample(linearSampler, input.uv2).xyz;
	float3 topAll = field.Sample(linearSampler, input.uv3).xyz;
	float3 bottomAll = field.Sample(linearSampler, input.uv4).xyz;

// todo: move unpacking of current and neighbours to after halftexel samples:
// so that calculations can be simplified (ie: inline unpacking and simplify equations)

	float2 correctedCurrent = current.xy - .5;
	correctedCurrent += correctedCurrent;
	float2 diffCurrent = correctedCurrent - current.xy;

	float2 sample_m5_0 = diffCurrent + leftAll.xy;
	float2 sample_5_0 = diffCurrent + rightAll.xy;
	float2 sample_0_m5 = diffCurrent + topAll.xy;
	float2 sample_0_5 = diffCurrent + bottomAll.xy;
	float2 sample_5_m1 = field.Sample(linearSampler, input.uv5).xy;
	float2 sample_m1_5 = field.Sample(linearSampler, input.uv6).xy;

	sample_5_m1 -= .5;
	sample_m1_5 -= .5;

	sample_5_m1 += sample_5_m1;
	sample_m1_5 += sample_m1_5;

	float2 A;
	A.x = sample_m5_0.x*sample_m5_0.x - sample_5_0.x*sample_5_0.x + sample_0_m5.x*sample_5_m1.y - sample_0_5.x*sample_5_0.y;   
	A.y = sample_0_m5.y*sample_0_m5.y - sample_0_5.y*sample_0_5.y + sample_m1_5.x*sample_m5_0.y - sample_0_5.x*sample_5_0.y;

	rightAll.xy -= .5;
	leftAll.xy -= .5;
	topAll.xy -= .5;
	bottomAll.xy -= .5;
	rightAll.xy += rightAll.xy;
	leftAll.xy += leftAll.xy;
	topAll.xy += topAll.xy;
	bottomAll.xy += bottomAll.xy;

	float2 B = rightAll.xy + leftAll.xy + topAll.xy + bottomAll.xy - 4.0 * correctedCurrent.xy;
	float2 adv = A + viscosity*B - drag*correctedCurrent.xy + current.zz - float2(rightAll.z, bottomAll.z);
	correctedCurrent.xy += dt*adv;
	current.xy = correctedCurrent.xy*.5 + .5;
	return current;
}