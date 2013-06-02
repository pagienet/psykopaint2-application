//
// Generated by Microsoft (R) HLSL Shader Compiler 9.30.9200.16384
//
///
// Parameters:
//
//   Texture2D linearSampler+brush;
//   Texture2D linearSampler+sourceField;
//
//
// Registers:
//
//   Name                      Reg   Size
//   ------------------------- ----- ----
//   linearSampler+brush       s0       1
//   linearSampler+sourceField s1       1
//

    ps_3_0
    def c0, 1, 0, 0, 0
    dcl_texcoord v0.xy
    dcl_color v1
    dcl_texcoord1 v2.xy
    dcl_2d s0
    dcl_2d s1
    texld r0, v2, s1
    add r0.xyz, -r0, r0.w
    texld r1, v0, s0
    mul r2, r1.w, v1
    mad r1.xyz, v1.w, r1.w, -r2
    mad r1.w, v1.w, -r1.w, c0.x
    mad r0.w, r0.w, r1.w, r2.w
    add r0.xyz, r0, r1
    add oC0.xyz, -r0, r0.w
    mov oC0.w, r0.w

// approximately 10 instruction slots used (2 texture, 8 arithmetic)