struct FragmentData
{
	float2 brushUV : TEXCOORD0;
	float4 color : COLOR;
	float2 canvasUV : TEXCOORD1;
};

Texture2D brush;
Texture2D sourceField;

SamplerState linearSampler
{
	Filter = LINEAR;
};

float4 main(FragmentData input) : SV_Target
{
	float brushAlpha = brush.Sample(linearSampler, input.brushUV).w;
	float4 sourceRGB = sourceField.Sample(linearSampler, input.canvasUV);
	float4 output;
	float4 topColor = input.color*brushAlpha;
	float3 topCMY = topColor.a - topColor.rgb;
	float3 bottomCMY = sourceRGB.a - sourceRGB.rgb;
	float3 blendCMY = topCMY + bottomCMY;

	// alpha blending
	output.a = topColor.a + sourceRGB.a*(1.0-topColor.a);

	output.rgb = output.a - blendCMY;

	return output;
}