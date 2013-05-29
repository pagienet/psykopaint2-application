struct FragmentData
{
	float3 uv : TEXCOORD;
};

cbuffer ShaderData
{
	float3 lightPosition;
	float3 eyePosition;
	float bumpiness;
	float3 lightColor;
	float3 ambientColor;
	float2 factors; // x = 1.0 - 0.5 * (roughnessSquared / (roughnessSquared + 0.57));
    				// y = 0.45 * (roughnessSquared / (roughnessSquared + 0.09));
};

Texture2D normalHeightMap;
Texture2D lookUp;

SamplerState nearestSampler
{
	Filter = NEAREST;
};

SamplerState linearSampler
{
	Filter = LINEAR;
};

float4 main(FragmentData input) : SV_Target
{
	float3 n = normalHeightMap.Sample(nearestSampler, input.uv.xy).xyz - .5;
	n.xy *= bumpiness;
	n = normalize(n);
    float3 l = normalize(input.uv - lightPosition);
	float3 v = normalize(eyePosition - input.uv);

    float VdotN = dot(v, n);
    float LdotN = dot(l, n);
    float gamma = dot(v - n*VdotN, l - n*LdotN);

	float2 tc = float2((VdotN + 1.0) / 2.0, (LdotN + 1.0) / 2.0);
	float C = (lookUp.Sample(linearSampler, tc).x - .5) * 2.0 * 1.4;

    float3 final = (factors.x + factors.y * max(0.0f, gamma) * C);

    return float4(ambientColor + lightColor * max(0.0f, dot(n, l)) * final, 1.0f);
}