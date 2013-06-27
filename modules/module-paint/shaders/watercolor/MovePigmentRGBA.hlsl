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
	temp2.x = velocity.x * currentPigment.x;
	temp2.y = velocityLeft.x * currentPigment.x;
	temp2.z = velocity.y * currentPigment.x;
	temp2.w = velocityTop.y * currentPigment.x;

	currentPigment.x += max(0.0, temp1.x) - max(0.0, temp2.x) +
						max(0.0, temp1.z) - max(0.0, temp2.z) +
						min(0.0, temp2.y) - min(0.0, temp1.y) +
						min(0.0, temp2.w) - min(0.0, temp1.w);

	temp1.x = velocityLeft.x * pigmentLeft.y;
	temp1.y = velocity.x * pigmentRight.y;
	temp1.z = velocityTop.y * pigmentTop.y;
	temp1.w = velocity.y * pigmentBottom.y;
	temp2.x = velocity.x * currentPigment.y;
	temp2.y = velocityLeft.x * currentPigment.y;
	temp2.z = velocity.y * currentPigment.y;
	temp2.w = velocityTop.y * currentPigment.y;

	currentPigment.y += max(0.0, temp1.x) - max(0.0, temp2.x) +
						max(0.0, temp1.z) - max(0.0, temp2.z) +
						min(0.0, temp2.y) - min(0.0, temp1.y) +
						min(0.0, temp2.w) - min(0.0, temp1.w);


	temp1.x = velocityLeft.x * pigmentLeft.z;
	temp1.y = velocity.x * pigmentRight.z;
	temp1.z = velocityTop.y * pigmentTop.z;
	temp1.w = velocity.y * pigmentBottom.z;
	temp2.x = velocity.x * currentPigment.z;
	temp2.y = velocityLeft.x * currentPigment.z;
	temp2.z = velocity.y * currentPigment.z;
	temp2.w = velocityTop.y * currentPigment.z;

	currentPigment.z += max(0.0, temp1.x) - max(0.0, temp2.x) +
						max(0.0, temp1.z) - max(0.0, temp2.z) +
						min(0.0, temp2.y) - min(0.0, temp1.y) +
						min(0.0, temp2.w) - min(0.0, temp1.w);

	temp1.x = velocityLeft.x * pigmentLeft.w;
	temp1.y = velocity.x * pigmentRight.w;
	temp1.z = velocityTop.y * pigmentTop.w;
	temp1.w = velocity.y * pigmentBottom.w;
	temp2.x = velocity.x * currentPigment.w;
	temp2.y = velocityLeft.x * currentPigment.w;
	temp2.z = velocity.y * currentPigment.w;
	temp2.w = velocityTop.y * currentPigment.w;

	currentPigment.w += max(0.0, temp1.x) - max(0.0, temp2.x) +
						max(0.0, temp1.z) - max(0.0, temp2.z) +
						min(0.0, temp2.y) - min(0.0, temp1.y) +
						min(0.0, temp2.w) - min(0.0, temp1.w);

   return currentPigment;
}