package net.psykosoft.psykopaint2.core.rendering
{
	import com.adobe.utils.AGALMiniAssembler;

	import flash.display.BitmapData;

	import flash.display3D.Context3D;
	import flash.display3D.Context3DProgramType;
	import flash.display3D.Context3DVertexBufferFormat;
	import flash.display3D.IndexBuffer3D;
	import flash.display3D.Program3D;
	import flash.display3D.VertexBuffer3D;
	import flash.display3D.textures.TextureBase;
	import flash.geom.Rectangle;
	import flash.utils.ByteArray;

	public class CopySubTexture
	{
		private static var _context3D : Context3D;
		private static var _copyProgram : Program3D;
		private static var _quadVertices : VertexBuffer3D;
		private static var _quadIndices : IndexBuffer3D;
		private static var _props : Vector.<Number> = Vector.<Number>([0, 0, 0, 0, 1, 1, 0, 1, 1, 1, 0, 1, 0, 0, 0, 0]);

		private static function initProgram() : void
		{
			var vertexCode : String =
							"mul vt0, va0, vc1\n" +	// calculate size
							"add vt0, vt0, vc0\n" +
							"neg vt0.y, vt0.y\n" +
							"mov op, vt0\n" +

							"mul vt0, va0, vc3\n" +
							"add vt0, vt0, vc2\n" +
							"mov v0, vt0";
			var fragmentCode : String = "tex oc, v0, fs0 <2d, clamp, nearest, mipnone>";
			var vertexByteCode : ByteArray = new AGALMiniAssembler().assemble(Context3DProgramType.VERTEX, vertexCode);
			var fragmentByteCode : ByteArray = new AGALMiniAssembler().assemble(Context3DProgramType.FRAGMENT, fragmentCode);
			_copyProgram = _context3D.createProgram();
			_copyProgram.upload(vertexByteCode, fragmentByteCode);
		}

		public static function copy(source : TextureBase, sourceRect : Rectangle, destRect : Rectangle, context3D : Context3D) : void
		{
			if (context3D != _context3D) {
				dispose();
				_context3D = context3D;
			}
			if (!_copyProgram) initProgram();
			if (!_quadVertices) initGeometry();

			_props[0] = destRect.x*2 - 1;
			_props[1] = destRect.y*2 - 1;
			_props[4] = 2*destRect.width;
			_props[5] = 2*destRect.height;

			_props[8] = sourceRect.x; 	// uv coords
			_props[9] = sourceRect.y;
			_props[12] = sourceRect.width;
			_props[13] = sourceRect.height;

			_context3D.setProgram(_copyProgram);
			_context3D.setProgramConstantsFromVector(Context3DProgramType.VERTEX, 0, _props, 4);
			_context3D.setVertexBufferAt(0, _quadVertices, 0, Context3DVertexBufferFormat.FLOAT_2); // vertices
			_context3D.setTextureAt(0, source);
			_context3D.drawTriangles(_quadIndices,0,2);
			_context3D.setTextureAt(0, null);
			_context3D.setVertexBufferAt(0, null);
		}

		private static function dispose() : void
		{
			if (_copyProgram) _copyProgram.dispose();
			if (_quadVertices) _quadVertices.dispose();
			if (_quadIndices) _quadIndices.dispose();
			_copyProgram = null;
			_quadVertices = null;
			_quadIndices = null;
		}

		private static function initGeometry() : void
		{
			_quadVertices = _context3D.createVertexBuffer(4, 2);
			_quadIndices = _context3D.createIndexBuffer(6);
			_quadVertices.uploadFromVector(new <Number>[	0.0, 0.0,
															1.0, 0.0,
															1.0, 1.0,
															0.0, 1.0], 0, 4);
			_quadIndices.uploadFromVector(new <uint>[0, 1, 2, 0, 2, 3], 0, 6);
		}
	}
}
