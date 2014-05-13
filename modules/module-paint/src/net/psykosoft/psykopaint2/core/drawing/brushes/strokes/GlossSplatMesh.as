package net.psykosoft.psykopaint2.core.drawing.brushes.strokes
{
	import away3d.core.math.PoissonLookup;

	import flash.display3D.Context3D;
	import flash.display3D.Context3DProgramType;
	import flash.display3D.Context3DVertexBufferFormat;
	import flash.display3D.VertexBuffer3D;
	import flash.display3D.textures.TextureBase;
	import flash.geom.Rectangle;

	import net.psykosoft.psykopaint2.core.configuration.CoreSettings;

	import net.psykosoft.psykopaint2.core.drawing.paths.SamplePoint;
	import net.psykosoft.psykopaint2.core.model.CanvasModel;
	import net.psykosoft.psykopaint2.core.intrinsics.FastBuffer;
	

	public class GlossSplatMesh extends TextureSplatMesh
	{
		public function GlossSplatMesh()
		{
			super();
		}


		// default code expects a height map + alpha map
		// texture input is:
		// R = height
		// G = gloss modulation
		// output should be (normalX, normalY, gloss, influence (alpha))
		// analytical solutions may be more optimal if possible
		override protected function getNormalSpecularFragmentCode() : String
		{
			var registers : Vector.<String> = new Vector.<String>();
			var i : uint;
			for (i = 1; i < _numFragmentRegisters; ++i) {
				registers.push("fc" + i + ".xy");
				registers.push("fc" + i + ".zw");
			}

			var code : String = "tex ft1, v0, fs0 <2d, clamp, linear, miplinear >\n" +
					"tex ft2, v1, fs0 <2d, clamp, linear, miplinear >\n" +
					"tex ft3, v2, fs0 <2d, clamp, linear, miplinear >\n" +
					"sub ft0.x, ft1.x, ft2.x\n" +
					"sub ft0.y, ft1.x, ft3.x\n" +

					"mul ft0.xy, ft0.xy, v4.y\n"; 	// bumpiness
			// ft0.xy contains bumpiness from brush

			// fetch original and replace gloss
			code += "tex ft6, v3, fs1 <2d, clamp, linear, nomip>\n" +
					"mov ft6.z, v4.x\n" +

				// lerp based on height, not really robust
					"mov ft6.w, ft1.x\n" +
					"mov oc, ft6";

			return code;
		}
	}
}
