struct FragmentData
{
	float2 uv0 : TEXCOORD0;
	float2 uv1 : TEXCOORD1;	// + texelSize.xz
	float2 uv2 : TEXCOORD2; // - texelSize.xz
	float2 uv3 : TEXCOORD3; // + texelSize.zy
	float2 uv4 : TEXCOORD4; // - texelSize.zy
};

cbuffer ShaderData
{
	float3 texelSize;
};

Texture2D velocityField;
Texture2D pigmentField;

SamplerState linearSampler
{
	Filter = LINEAR;
};

float4 main(FragmentData input) : SV_Target
{
	float4 currentPigment = pigmentField.Sample(linearSampler, input.uv0);
	float4 pigmentRight = pigmentField.Sample(linearSampler, input.uv1);
	float4 pigmentLeft = pigmentField.Sample(linearSampler, input.uv2);
	float4 pigmentBottom = pigmentField.Sample(linearSampler, input.uv3);
	float4 pigmentTop = pigmentField.Sample(linearSampler, input.uv4);
	
	float4 velocity = velocityField.Sample(linearSampler, input.uv0);
	float4 velocityLeft = velocityField.Sample(linearSampler, input.uv2);
	float4 velocityTop = velocityField.Sample(linearSampler, input.uv4);

	velocity.xy -= .5;
	velocityLeft.xy -= .5;
	velocityTop.xy -= .5;
	velocity.xy += velocity.xy;
	velocityLeft.xy += velocityLeft.xy;
	velocityTop.xy += velocityTop.xy;

	float4 temp1;
	temp1.x = velocityLeft.x * pigmentLeft.x;
	temp1.y = velocity.x * pigmentRight.x;
	temp1.z = velocityTop.y * pigmentTop.x;
	temp1.w = velocity.y * pigmentBottom.x;
	temp1.xz = max(float2(0.0, 0.0), temp1.xz);
	temp1.yw = -min(float2(0.0, 0.0), temp1.yw);
	
	float4 temp2;
	temp2.x = velocity.x * currentPigment.x;
	temp2.y = velocityLeft.x * currentPigment.x;
	temp2.z = velocity.y * currentPigment.x;
	temp2.w = velocityTop.y * currentPigment.x;
	temp2.xz = max(float2(0.0, 0.0), temp2.xz);
	temp2.yw = -min(float2(0.0, 0.0), temp2.yw);
	
	currentPigment.x += dot(temp1 - temp2, float4(1.0, 1.0, 1.0, 1.0));

	return currentPigment;
}