struct FragmentData
{
	float2 offsetUV : TEXCOORD0;
	float2 canvasUV : TEXCOORD1;
};

Texture2D top;
Texture2D bottom;

SamplerState linearSampler
{
	Filter = LINEAR;
};

float4 main(FragmentData input) : SV_Target
{
	float4 topRGBA = top.Sample(linearSampler, input.offsetUV);
	float4 bottomRGBA = bottom.Sample(linearSampler, input.canvasUV);
	float4 output;
	output.a = topRGBA.a + bottomRGBA.a*(1.0-topRGBA.a);
	output.rgb = topRGBA.rgb + bottomRGBA.rgb - bottomRGBA.a*topRGBA.a;
	return output;
}