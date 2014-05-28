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
		private var _context3D : Context3D;
		private var _copyProgram : Program3D;
		private var _quadVertices : VertexBuffer3D;
		private var _quadIndices : IndexBuffer3D;
		private var _vertexConstants : Vector.<Number> = Vector.<Number>([0, 0, 0, 0, 1, 1, 0, 1, 1, 1, 0, 1, 0, 0, 0, 0]);
		private var _fragmentConstants : Vector.<Number> = Vector.<Number>([1, 0, 0, 0]);
		private var _smoothing:Boolean;

		private static var GLOBAL_INSTANCE : CopySubTexture;


		public function CopySubTexture(smoothing : Boolean = false)
		{
			_smoothing = smoothing;
		}

		public function get alpha():Number
		{
			return _fragmentConstants[0];
		}

		public function set alpha(value:Number):void
		{
			_fragmentConstants[0] = value;
		}

		private function initProgram() : void
		{
			var vertexCode : String =
							"mul vt0, va0, vc1\n" +	// calculate size
							"add vt0, vt0, vc0\n" +
							"neg vt0.y, vt0.y\n" +
							"mov op, vt0\n" +

							"mul vt0, va0, vc3\n" +
							"add vt0, vt0, vc2\n" +
							"mov v0, vt0";

			var filter : String = _smoothing? "linear" : "nearest";
			var fragmentCode : String = "tex ft0, v0, fs0 <2d, clamp, " + filter + ", mipnone>\n" +
										"mul ft0.w, ft0.w, fc0.x\n" +
										"mov oc, ft0";

			var vertexByteCode : ByteArray = new AGALMiniAssembler().assemble(Context3DProgramType.VERTEX, vertexCode);
			var fragmentByteCode : ByteArray = new AGALMiniAssembler().assemble(Context3DProgramType.FRAGMENT, fragmentCode);
			_copyProgram = _context3D.createProgram();
			_copyProgram.upload(vertexByteCode, fragmentByteCode);
		}

		public static function copy(source : TextureBase, sourceRect : Rectangle, destRect : Rectangle, context3D : Context3D) : void
		{
			if (!GLOBAL_INSTANCE) GLOBAL_INSTANCE = new CopySubTexture();
			GLOBAL_INSTANCE.copy(source, sourceRect, destRect, context3D);
		}

		public function copy(source : TextureBase, sourceRect : Rectangle, destRect : Rectangle, context3D : Context3D) : void
		{
			if (context3D != _context3D) {
				dispose();
				_context3D = context3D;
			}
			if (!_copyProgram) initProgram();
			if (!_quadVertices) initGeometry();

			_vertexConstants[0] = destRect.x*2 - 1;
			_vertexConstants[1] = destRect.y*2 - 1;
			_vertexConstants[4] = 2*destRect.width;
			_vertexConstants[5] = 2*destRect.height;

			_vertexConstants[8] = sourceRect.x; 	// uv coords
			_vertexConstants[9] = sourceRect.y;
			_vertexConstants[12] = sourceRect.width;
			_vertexConstants[13] = sourceRect.height;

			_context3D.setProgram(_copyProgram);
			_context3D.setProgramConstantsFromVector(Context3DProgramType.VERTEX, 0, _vertexConstants, 4);
			_context3D.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 0, _fragmentConstants, 1);
			_context3D.setVertexBufferAt(0, _quadVertices, 0, Context3DVertexBufferFormat.FLOAT_2); // vertices
			_context3D.setTextureAt(0, source);
			_context3D.drawTriangles(_quadIndices,0,2);
			_context3D.setTextureAt(0, null);
			_context3D.setVertexBufferAt(0, null);
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

		private function initGeometry() : void
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
