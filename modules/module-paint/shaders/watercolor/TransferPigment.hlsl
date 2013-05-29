struct FragmentData
{
	float2 uv : TEXCOORD;
};

cbuffer ShaderData
{
	float granulation;
	float density;
	float densityOverStainingPower;
};

Texture2D pigmentField;
Texture2D normalHeightMap;
Texture2D velocityDensityField;

SamplerState linearSampler
{
	Filter = LINEAR;
};

float4 main(FragmentData input) : SV_Target
{
	float4 pigment = pigmentField.Sample(linearSampler, input.uv);
	float4 height = normalHeightMap.Sample(linearSampler, input.uv);
	float down = pigment.x*(1.0 - height.w*granulation)*density;
	float up = pigment.y*(1.0 + (height.w - 1.0)*granulation)*densityOverStainingPower;
	float transferred = up - down;

	pigment.x += transferred;
	pigment.y -= transferred;

	return pigment;
}