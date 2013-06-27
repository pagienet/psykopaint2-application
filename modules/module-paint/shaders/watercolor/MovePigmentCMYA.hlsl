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
	float pigmentFlow;
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

	currentPigment.xyz = 1.0 - currentPigment.xyz;
	pigmentRight.xyz = 1.0 - pigmentRight.xyz;
	pigmentLeft.xyz = 1.0 - pigmentLeft.xyz;
	pigmentBottom.xyz = 1.0 - pigmentBottom.xyz;
	pigmentTop.xyz = 1.0 - pigmentTop.xyz;

	velocity.xy -= .5;
	velocityLeft.xy -= .5;
	velocityTop.xy -= .5;
	velocity.xy *= pigmentFlow;
	velocityLeft.xy *= pigmentFlow;
	velocityTop.xy *= pigmentFlow;

	float4 temp1, temp2;
	temp1.x = velocityLeft.x * pigmentLeft.x;
	temp1.y = velocity.x * pigmentRight.x;
	temp1.z = velocityTop.y * pigmentTop.x;
	temp1.w = velocity.y * pigmentBottom.x;
	temp1.xz = max(float2(0.0, 0.0), temp1.xz);
	temp1.yw = -min(float2(0.0, 0.0), temp1.yw);

	temp2.x = velocity.x * currentPigment.x;
	temp2.y = velocityLeft.x * currentPigment.x;
	temp2.z = velocity.y * currentPigment.x;
	temp2.w = velocityTop.y * currentPigment.x;
	temp2.xz = max(float2(0.0, 0.0), temp2.xz);
	temp2.yw = -min(float2(0.0, 0.0), temp2.yw);

	currentPigment.x += dot(temp1 - temp2, float4(1.0, 1.0, 1.0, 1.0));

	temp1.x = velocityLeft.x * pigmentLeft.y;
	temp1.y = velocity.x * pigmentRight.y;
	temp1.z = velocityTop.y * pigmentTop.y;
	temp1.w = velocity.y * pigmentBottom.y;
	temp1.xz = max(float2(0.0, 0.0), temp1.xz);
	temp1.yw = -min(float2(0.0, 0.0), temp1.yw);

	temp2.x = velocity.x * currentPigment.y;
	temp2.y = velocityLeft.x * currentPigment.y;
	temp2.z = velocity.y * currentPigment.y;
	temp2.w = velocityTop.y * currentPigment.y;
	temp2.xz = max(float2(0.0, 0.0), temp2.xz);
	temp2.yw = -min(float2(0.0, 0.0), temp2.yw);

	currentPigment.y += dot(temp1 - temp2, float4(1.0, 1.0, 1.0, 1.0));

	temp1.x = velocityLeft.x * pigmentLeft.z;
	temp1.y = velocity.x * pigmentRight.z;
	temp1.z = velocityTop.y * pigmentTop.z;
	temp1.w = velocity.y * pigmentBottom.z;
	temp1.xz = max(float2(0.0, 0.0), temp1.xz);
	temp1.yw = -min(float2(0.0, 0.0), temp1.yw);

	temp2.x = velocity.x * currentPigment.z;
	temp2.y = velocityLeft.x * currentPigment.z;
	temp2.z = velocity.y * currentPigment.z;
	temp2.w = velocityTop.y * currentPigment.z;
	temp2.xz = max(float2(0.0, 0.0), temp2.xz);
	temp2.yw = -min(float2(0.0, 0.0), temp2.yw);

	currentPigment.z += dot(temp1 - temp2, float4(1.0, 1.0, 1.0, 1.0));

	temp1.x = velocityLeft.x * pigmentLeft.w;
	temp1.y = velocity.x * pigmentRight.w;
	temp1.z = velocityTop.y * pigmentTop.w;
	temp1.w = velocity.y * pigmentBottom.w;
	temp1.xz = max(float2(0.0, 0.0), temp1.xz);
	temp1.yw = -min(float2(0.0, 0.0), temp1.yw);

	temp2.x = velocity.x * currentPigment.w;
	temp2.y = velocityLeft.x * currentPigment.w;
	temp2.z = velocity.y * currentPigment.w;
	temp2.w = velocityTop.y * currentPigment.w;
	temp2.xz = max(float2(0.0, 0.0), temp2.xz);
	temp2.yw = -min(float2(0.0, 0.0), temp2.yw);

	currentPigment.w += dot(temp1 - temp2, float4(1.0, 1.0, 1.0, 1.0));

	currentPigment.xyz = 1.0 - currentPigment.xyz;

	return currentPigment;
}