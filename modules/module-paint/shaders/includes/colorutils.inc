float4 ConvertRGBToCMYK(float3 rgb)
{
	float4 cmyk;

	float maxValue = max(rgb.x, rgb.y);
	maxValue = max(maxValue, rgb.z);
	cmyk.w = 1.0 - maxValue;
	cmyk.x = (1.0 - rgb.x - cmyk.w) / (1.0 - cmyk.w);
	cmyk.y = (1.0 - rgb.y - cmyk.w) / (1.0 - cmyk.w);
	cmyk.z = (1.0 - rgb.z - cmyk.w) / (1.0 - cmyk.w);

	return cmyk;
}

float3 ConvertCMYKToRGB(float4 cmyk)
{
	float3 rgb;
	rgb.r = (1.0 - cmyk.x) * (1.0 - cmyk.w);
	rgb.g = (1.0 - cmyk.y) * (1.0 - cmyk.w);
	rgb.b = (1.0 - cmyk.z) * (1.0 - cmyk.w);
	return rgb;
}