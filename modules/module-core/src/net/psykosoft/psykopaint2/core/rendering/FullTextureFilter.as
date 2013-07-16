package net.psykosoft.psykopaint2.core.rendering
{
	import away3d.errors.AbstractMethodError;

	import com.adobe.utils.AGALMiniAssembler;

	import flash.display3D.Context3D;
	import flash.display3D.Context3DProgramType;
	import flash.display3D.Context3DVertexBufferFormat;
	import flash.display3D.IndexBuffer3D;
	import flash.display3D.Program3D;
	import flash.display3D.VertexBuffer3D;
	import flash.display3D.textures.TextureBase;
	import flash.utils.ByteArray;

	public class FullTextureFilter
	{
		protected var _context3D : Context3D;
		protected var _program : Program3D;
		protected var _quadVertices : VertexBuffer3D;
		protected var _quadIndices : IndexBuffer3D;
		protected var _vertexShaderData : Vector.<Number> = new <Number>[-1, 1, 0, 0, 2, 2, 1, 1, 1, 1, 1, 1, 0, 1, 0, 0];

		public function FullTextureFilter()
		{
		}

		public function dispose() : void
		{
			if (_program) _program.dispose();
			if (_quadVertices) _quadVertices.dispose();
			if (_quadIndices) _quadIndices.dispose();
			_program = null;
			_quadVertices = null;
			_quadIndices = null;
		}

		protected function initProgram() : void
		{
			var vertexByteCode : ByteArray = new AGALMiniAssembler().assemble(Context3DProgramType.VERTEX, getVertexCode());
			var fragmentByteCode : ByteArray = new AGALMiniAssembler().assemble(Context3DProgramType.FRAGMENT, getFragmentCode());
			_program = _context3D.createProgram();
			_program.upload(vertexByteCode, fragmentByteCode);
		}

		protected function getVertexCode() : String
		{
			// x' = x * w * 2 - 1
			// y' = (y - 1) * h * 2 + 1
			// 0 = -h*2 + 1
			// 1 = 1
			return 	"mul vt0, vc1, va0\n" +	// pos * (w, h) * 2
					"add op, vt0, vc0\n" +	// pos * (w, h) * 2 - (1, 1)
					"mul v0, vc2, va1\n"; 	// uv * (w, h)
		}

		protected function getFragmentCode() : String
		{
			throw new AbstractMethodError();
			return null;
		}

		protected function initGeometry() : void
		{
			_quadVertices = _context3D.createVertexBuffer(4,4);
			_quadIndices = _context3D.createIndexBuffer(6);
			_quadVertices.uploadFromVector(new <Number>[	0.0, -1.0, 0.0, 1.0,
				1.0, -1.0, 1.0, 1.0,
				1.0, 0.0, 1.0, 0.0,
				0.0, 0.0, 0.0, 0.0], 0, 4);
			_quadIndices.uploadFromVector(new <uint>[0, 1, 2, 0, 2, 3], 0, 6);
		}

		public function init(context3D : Context3D) : void
		{
			if (context3D != _context3D) {
				this.dispose();
				_context3D = context3D;
			}
			if (!_program) initProgram();
			if (!_quadVertices) initGeometry();
		}

		public function draw(source : TextureBase, context3D : Context3D, width : Number, height : Number) : void
		{
			init(context3D);

			_vertexShaderData[4] = width*2;
			_vertexShaderData[5] = height*2;
			_vertexShaderData[8] = width;
			_vertexShaderData[9] = height;

			_context3D.setProgram(_program);
			_context3D.setProgramConstantsFromVector(Context3DProgramType.VERTEX, 0, _vertexShaderData, 4);
			setRenderState(source);
			_context3D.drawTriangles(_quadIndices,0,2);
			clearRenderState();
		}

		protected function setRenderState(source : TextureBase) : void
		{
			_context3D.setVertexBufferAt(0, _quadVertices, 0, Context3DVertexBufferFormat.FLOAT_2); // vertices
			_context3D.setVertexBufferAt(1, _quadVertices, 2, Context3DVertexBufferFormat.FLOAT_2);	// uvs
			_context3D.setTextureAt(0, source);
		}

		protected function clearRenderState() : void
		{
			_context3D.setTextureAt(0, null);
			_context3D.setVertexBufferAt(0, null);
			_context3D.setVertexBufferAt(1, null);
		}
	}
}
