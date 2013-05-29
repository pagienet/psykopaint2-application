//
// Generated by Microsoft (R) HLSL Shader Compiler 9.30.9200.16384
//
///
// Parameters:
//
//   float drag;
//   float dt;
//   Texture2D linearSampler+field;
//   float viscosity;
//
//
// Registers:
//
//   Name                Reg   Size
//   ------------------- ----- ----
//   viscosity           c0       1
//   drag                c1       1
//   dt                  c2       1
//   linearSampler+field s0       1
//

    ps_3_0
    def c3, -0.5, 2, 8, 0.5
    dcl_texcoord v0.xy
    dcl_texcoord1 v1.xy
    dcl_texcoord2 v2.xy
    dcl_texcoord3 v3.xy
    dcl_texcoord4 v4.xy
    dcl_texcoord5 v5.xy
    dcl_texcoord6 v6.xy
    dcl_2d s0
    texld r0, v2, s0
    add r0.zw, r0.xyxy, c3.x
    add r0.zw, r0, r0
    texld r1, v1, s0
    add r2.xy, r1, c3.x
    mad r0.zw, r2.xyxy, c3.y, r0
    texld r2, v3, s0
    add r2.zw, r2.xyxy, c3.x
    mad r0.zw, r2, c3.y, r0
    texld r3, v4, s0
    add r2.zw, r3.xyxy, c3.x
    mad r0.zw, r2, c3.y, r0
    texld r4, v0, s0
    add r2.zw, r4.xyxy, c3.x
    mad r0.zw, r2, -c3.z, r0
    texld r5, v5, s0
    add r1.w, r5.y, c3.x
    add r1.w, r1.w, r1.w
    lrp r5.xy, c3.y, c3.x, -r4
    add r2.zw, r2, r2
    add r0.xy, r0, r5
    add r1.xy, r1, r5
    mov r4.x, r1.z
    mul r1.x, r1.x, r1.x
    mad r0.x, r0.x, r0.x, -r1.x
    add r1.xz, r2.xyyw, r5.xyyw
    add r2.xy, r3, r5
    mov r4.y, r3.z
    mad r0.x, r1.x, r1.w, r0.x
    mad r3.x, r2.x, -r1.y, r0.x
    mul r0.x, r2.y, r2.y
    mad r0.x, r1.z, r1.z, -r0.x
    texld r5, v6, s0
    add r1.x, r5.x, c3.x
    add r1.x, r1.x, r1.x
    mad r0.x, r1.x, r0.y, r0.x
    mad r3.y, r2.x, -r1.y, r0.x
    mad r0.xy, c0.x, r0.zwzw, r3
    mad r0.xy, c1.x, -r2.zwzw, r0
    add r0.xy, r4.z, r0
    mov oC0.zw, r4
    add r0.xy, -r4, r0
    mad r0.xy, c2.x, r0, r2.zwzw
    mad oC0.xy, r0, c3.w, c3.w

// approximately 44 instruction slots used (7 texture, 37 arithmetic)
