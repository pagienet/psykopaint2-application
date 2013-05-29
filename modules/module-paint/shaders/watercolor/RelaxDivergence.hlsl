struct FragmentData
{
	float2 uv0 : TEXCOORD0;
	float2 uv1 : TEXCOORD1; // - texelSize.xz
	float2 uv2 : TEXCOORD2; // + texelSize.zy
	float2 uv3 : TEXCOORD3; // + texelSize.xz
	float2 uv4 : TEXCOORD4; // + texelSize.xy
	float2 uv5 : TEXCOORD5; // - texelSize.zy
	float2 uv6 : TEXCOORD6; // - texelSize.xy
};

cbuffer ShaderData
{
	float3 texelSize;	// (1/canvasWidth, -1/canvasHeight)
};

Texture2D field;

SamplerState linearSampler
{
	Filter = LINEAR;
};

float4 main(FragmentData input) : SV_Target
{
	float4 current = field.Sample(linearSampler, input.uv0);
	float4 left = field.Sample(linearSampler, input.uv1);
	float4 top = field.Sample(linearSampler, input.uv2);

	// samples are not unpacked, *2 below is the scale factor of unpacking
	float divergence = .1*(current.x - left.x + current.y - top.y);
	current.xyz -= divergence;
	current.z -= divergence;	// current.z += 2*incoming (due to unpacked halving)
	
	float4 right = field.Sample(linearSampler, input.uv3);
	float4 topRight = field.Sample(linearSampler, input.uv4);
	float4 bottom = field.Sample(linearSampler, input.uv5);
	float4 bottomLeft = field.Sample(linearSampler, input.uv6);
	float2 outgoingDivergence;
	outgoingDivergence.x = right.x - current.x + right.y - topRight.y;
	outgoingDivergence.y = bottom.x - bottomLeft.x + bottom.y - current.y;
	current.xy += .1*outgoingDivergence;

	return current;
}