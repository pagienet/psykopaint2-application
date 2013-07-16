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
	import flash.display3D.textures.TextureBase;
	import flash.utils.ByteArray;

	public class CopyTextureChannel
	{
		private var _context3D : Context3D;
		private var _copyProgram : Program3D;
		private var _quadVertices : VertexBuffer3D;
		private var _quadIndices : IndexBuffer3D;
		private var _sourceChannel : String;
		private var _targetChannel : String;
		private var _color : Vector.<Number>;

		public function CopyTextureChannel(sourceChannel : String, targetChannel : String)
		{
			_sourceChannel = sourceChannel;
			_targetChannel = targetChannel;
			_color = new <Number>[0, 0, 0, 1];
		}

		public function copy(source : TextureBase, context3D : Context3D) : void
		{
			if (context3D != _context3D) {
				dispose();
				_context3D = context3D;
			}
			if (!_copyProgram) initProgram();
			if (!_quadVertices) initGeometry();

			_context3D.setProgram(_copyProgram);
			_context3D.setVertexBufferAt(0, _quadVertices, 0, Context3DVertexBufferFormat.FLOAT_2); // vertices
			_context3D.setVertexBufferAt(1, _quadVertices, 2, Context3DVertexBufferFormat.FLOAT_2);	// uvs
			_context3D.setTextureAt(0, source);
			_context3D.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 0, _color, 1);
			_context3D.drawTriangles(_quadIndices,0,2);
			_context3D.setTextureAt(0, null);
			_context3D.setVertexBufferAt(0, null);
			_context3D.setVertexBufferAt(1, null);
		}

		public function dispose() : void
		{
			if (_copyProgram) _copyProgram.dispose();
			if (_quadVertices) _quadVertices.dispose();
			if (_quadIndices) _quadIndices.dispose();
			_copyProgram = null;
			_quadVertices = null;
			_quadIndices = null;
		}

		private function initProgram() : void
		{
			var vertexCode : String = "mov op, va0;\nmov v0, va1;";
			var fragmentCode : String =
					"tex ft0, v0, fs0 <2d, clamp, nearest, mipnone>\n" +
					"mov ft1, fc0\n" +
					"mov ft1." + _targetChannel + ", ft0." + _sourceChannel + "\n" +
					"mov oc, ft1";
			var vertexByteCode : ByteArray = new AGALMiniAssembler().assemble(Context3DProgramType.VERTEX, vertexCode);
			var fragmentByteCode : ByteArray = new AGALMiniAssembler().assemble(Context3DProgramType.FRAGMENT, fragmentCode);
			_copyProgram = _context3D.createProgram();
			_copyProgram.upload(vertexByteCode, fragmentByteCode);
		}

		private function initGeometry() : void
		{
			_quadVertices = _context3D.createVertexBuffer(4,4);
			_quadIndices = _context3D.createIndexBuffer(6);
			_quadVertices.uploadFromVector(new <Number>[	-1.0, -1.0, 0.0, 1.0,
				1.0, -1.0, 1.0, 1.0,
				1.0, 1.0, 1.0, 0.0,
				-1.0, 1.0, 0.0, 0.0], 0, 4);
			_quadIndices.uploadFromVector(new <uint>[0, 1, 2, 0, 2, 3], 0, 6);
		}
	}
}
