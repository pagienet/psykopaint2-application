package net.psykosoft.psykopaint2.core.drawing.brushes.strokes
{
	import flash.display3D.Context3D;
	import flash.display3D.Context3DProgramType;
	import flash.display3D.Context3DVertexBufferFormat;
	import flash.display3D.VertexBuffer3D;

	import net.psykosoft.psykopaint2.core.model.CanvasModel;

	public class GlossSplatMesh extends TextureSplatMesh
	{
		public function GlossSplatMesh()
		{
			super();
		}

		override protected function getNormalSpecularVertexCode() : String
		{
			return 	"mov op, va0\n" +

				// brushmap coords
					"mov v0, va1\n" +

				// canvas uvs
					"mul vt0, va0, vc1.xyww\n" +
					"add vt0, vt0, vc1.xxzz\n" +
					"mov v3, vt0\n" +
					"mul v4, va3, vc3\n";
		}

		// texture input is:
		// R = gloss blend (amount of "varnish")
		// G = gloss modulation (glossiness of material)
		// output should be (normalX, normalY, gloss, influence (alpha))
		// analytical solutions may be more optimal if possible
		override protected function getNormalSpecularFragmentCode() : String
		{
			var code : String = "tex ft1, v0, fs0 <2d, clamp, linear, miplinear >\n";

			// fetch original and replace gloss
			code += "tex ft6, v3, fs1 <2d, clamp, linear, nomip>\n" +
					"mul ft6.z, ft1.y, v4.x\n" +

				// lerp based on height, not really robust
					"mov ft6.w, ft1.x\n" +
					"mov oc, ft6";

			return code;
		}

		override public function drawNormalsAndSpecular(context3d : Context3D, canvas : CanvasModel, glossiness : Number, bumpiness : Number, influence : Number) : void
		{
			var vertexBuffer : VertexBuffer3D = getVertexBuffer(context3d);

			context3d.setProgram(getNormalSpecularProgram(context3d));
			context3d.setVertexBufferAt(0, vertexBuffer, 0, Context3DVertexBufferFormat.FLOAT_2);
			context3d.setVertexBufferAt(1, vertexBuffer, 2, Context3DVertexBufferFormat.FLOAT_2);
			context3d.setVertexBufferAt(3, vertexBuffer, 12, Context3DVertexBufferFormat.FLOAT_4);

			context3d.setTextureAt(0, _normalTexture);
			context3d.setTextureAt(1, canvas.normalSpecularMap);
			_normalSpecularVertexData[0] = 1/512;
			_normalSpecularVertexData[1] = 1/512;

			_normalSpecularVertexData[8] = 1/canvas.width;
			_normalSpecularVertexData[9] = 1/canvas.height;

			_normalSpecularVertexData[12] = glossiness;
			_normalSpecularVertexData[13] = bumpiness;
			_normalSpecularVertexData[15] = influence;

			context3d.setProgramConstantsFromVector(Context3DProgramType.VERTEX, 0, _normalSpecularVertexData, 4);
			context3d.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 0, _normalSpecularFragmentData, _numFragmentRegisters);
			context3d.drawTriangles(getIndexBuffer(context3d), 0, _numIndices/3);
			context3d.setTextureAt(0, null);
			context3d.setTextureAt(1, null);

			context3d.setVertexBufferAt(0, null);
			context3d.setVertexBufferAt(1, null);
			context3d.setVertexBufferAt(3, null);
		}
	}
}
