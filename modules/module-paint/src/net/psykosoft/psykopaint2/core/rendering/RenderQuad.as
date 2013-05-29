package net.psykosoft.psykopaint2.core.rendering
{
	import com.adobe.utils.AGALMiniAssembler;

	import flash.display3D.Context3D;
	import flash.display3D.Context3DProgramType;
	import flash.display3D.Context3DVertexBufferFormat;
	import flash.display3D.IndexBuffer3D;
	import flash.display3D.Program3D;
	import flash.display3D.VertexBuffer3D;
	import flash.display3D.textures.Texture;

	public class RenderQuad
	{
		private var _vertexBuffer : VertexBuffer3D;
		private var _indexBuffer : IndexBuffer3D;
		private var _program : Program3D;
		private var _context3D : Context3D;
		private var _vertexData : Vector.<Number>;

		public function RenderQuad()
		{
			_vertexData = new <Number>[1, 1, 1, 1, 0, 0, 0, 0];
		}

		public function activate(context3D : Context3D, texture : Texture) : void
		{
			if (_context3D != context3D) {
				_context3D = context3D;
				dispose();
				initBuffers();
				initProgram3D();
			}
			_context3D.setProgram(_program);
			_context3D.setTextureAt(0, texture);
			_context3D.setVertexBufferAt(0, _vertexBuffer, 0, Context3DVertexBufferFormat.FLOAT_2);
			_context3D.setVertexBufferAt(1, _vertexBuffer, 2, Context3DVertexBufferFormat.FLOAT_1);
		}

		public function deactivate() : void
		{
			_context3D.setTextureAt(0, null);
			_context3D.setVertexBufferAt(0, null);
			_context3D.setVertexBufferAt(1, null);
		}

		public function draw(x : Number, y : Number, width : Number, height : Number, colors : Vector.<Number>) : void
		{
			_vertexData[0] = width;
			_vertexData[1] = height;
			_vertexData[4] = x;
			_vertexData[5] = y;

			_context3D.setProgramConstantsFromVector("vertex", 0, _vertexData, 2);
			_context3D.setProgramConstantsFromVector("vertex", 2, colors, 4);
			_context3D.drawTriangles(_indexBuffer, 0, 2);
		}

		private function initProgram3D() : void
		{
			_program = _context3D.createProgram();
			_program.upload(
					new AGALMiniAssembler().assemble(Context3DProgramType.VERTEX, getVertexCode()),
					new AGALMiniAssembler().assemble(Context3DProgramType.FRAGMENT, getFragmentCode())
			);
		}

		private function getVertexCode() : String
		{
			return 	"mov v0, va0\n" +
					"mov v1, vc[va1.x]\n" +
					"mul vt0, va0, vc0\n" +
					"add op, vt0, vc1\n";

		}

		private function getFragmentCode() : String
		{
			return "tex ft0, v0, fs0 <2d, linear, miplinear>\n" +
					"mul oc, ft0.w, v1\n";
		}

		private function initBuffers() : void
		{
			_vertexBuffer = _context3D.createVertexBuffer(4, 3);
			_indexBuffer = _context3D.createIndexBuffer(6);
			_vertexBuffer.uploadFromVector(new <Number>[
				0, 0, 2,	// x, y, colorIndex
				1, 0, 3,    // x, y, colorIndex
				1, 1, 4,	// x, y, colorIndex
				0, 1, 5		// x, y, colorIndex
			], 0, 4);
			_indexBuffer.uploadFromVector(new <uint>[0, 1, 2, 0, 2, 3], 0, 6);
		}

		public function dispose() : void
		{
			if (_vertexBuffer) _vertexBuffer.dispose();
			if (_indexBuffer) _indexBuffer.dispose();
			if (_program) _program.dispose();
		}
	}
}
