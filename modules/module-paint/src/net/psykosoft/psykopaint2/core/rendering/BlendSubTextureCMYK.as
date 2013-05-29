package net.psykosoft.psykopaint2.core.rendering
{
	import com.adobe.utils.AGALMiniAssembler;

	import flash.display3D.Context3D;
	import flash.display3D.Context3DProgramType;
	import flash.display3D.Context3DVertexBufferFormat;
	import flash.display3D.IndexBuffer3D;
	import flash.display3D.Program3D;
	import flash.display3D.VertexBuffer3D;
	import flash.display3D.textures.TextureBase;
	import flash.geom.Rectangle;
	import flash.utils.ByteArray;

	import net.psykosoft.psykopaint2.core.utils.EmbedUtils;

	public class BlendSubTextureCMYK
	{
		private static var _context3D : Context3D;
		private static var _copyProgram : Program3D;
		private static var _quadVertices : VertexBuffer3D;
		private static var _quadIndices : IndexBuffer3D;
		private static var _vertexShaderData : Vector.<Number>;
		private static var _fragmentShaderData : Vector.<Number>;

		[Embed(source="/../shaders/agal/BlendCMYK.agal", mimeType="application/octet-stream")]
		private static var Shader : Class;

		public static function copy(top : TextureBase, context3D : Context3D, bottom : TextureBase, bounds : Rectangle, widthRatio : Number, heightRatio : Number) : void
		{
			_fragmentShaderData ||= Vector.<Number>([1, 0, 0, 0]);
			_vertexShaderData ||= Vector.<Number>([0, 0, 0, 1, 1, 1, 0, 0, 1, 1, 0, 1,.5, -.5, 0, 0]);

			if (context3D != _context3D) {
				dispose();
				_context3D = context3D;
			}
			if (!_copyProgram) initProgram();
			if (!_quadVertices) initGeometry();

			_vertexShaderData[0] = bounds.x*2 - 1;
			_vertexShaderData[1] = bounds.y*2 - 1;
			_vertexShaderData[4] = 2*bounds.width;
			_vertexShaderData[5] = 2*bounds.height;
			_vertexShaderData[8] = bounds.width*widthRatio; 	// uv coords
			_vertexShaderData[9] = bounds.height*heightRatio;


			_context3D.setProgram(_copyProgram);
			_context3D.setProgramConstantsFromVector(Context3DProgramType.VERTEX, 0, _vertexShaderData, 4);
			_context3D.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 0, _fragmentShaderData, 1);
			_context3D.setVertexBufferAt(0, _quadVertices, 0, Context3DVertexBufferFormat.FLOAT_2); // vertices
			_context3D.setVertexBufferAt(1, _quadVertices, 2, Context3DVertexBufferFormat.FLOAT_2);	// uvs
			_context3D.setTextureAt(0, top);
			_context3D.setTextureAt(1, bottom);
			_context3D.drawTriangles(_quadIndices,0,2);
			_context3D.setTextureAt(0, null);
			_context3D.setTextureAt(1, null);
			_context3D.setVertexBufferAt(0, null);
			_context3D.setVertexBufferAt(1, null);
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

		private static function initProgram() : void
		{
			var vertexCode : String =
					"mul vt0, va0, vc1\n" +	// calculate size
					"add vt1, vc0, vt0\n" +
					"mov op, vt1\n" +	// [ -1 -> 1]
					"mul vt1.xy, vt1.xy, vc3.xy\n" +  // [ -.5 -> .5 ]
					"add vt1.xy, vt1.xy, vc3.x\n" +	// [0 -> 1]
					"mov v1, vt1\n" +
					"mul vt0, va1, vc2\n" +
					"sub vt0.y, vc0.w, vt0.y\n" +
					"mov v0, vt0\n";
			var fragmentCode : String = EmbedUtils.StringFromEmbed(Shader);
			var vertexByteCode : ByteArray = new AGALMiniAssembler().assemble(Context3DProgramType.VERTEX, vertexCode);
			var fragmentByteCode : ByteArray = new AGALMiniAssembler().assemble(Context3DProgramType.FRAGMENT, fragmentCode);
			_copyProgram = _context3D.createProgram();
			_copyProgram.upload(vertexByteCode, fragmentByteCode);
		}

		private static function initGeometry() : void
		{
			_quadVertices = _context3D.createVertexBuffer(4,4);
			_quadIndices = _context3D.createIndexBuffer(6);
			_quadVertices.uploadFromVector(new <Number>[	0.0, 0.0, 0.0, 0.0,
															1.0, 0.0, 1.0, 0.0,
															1.0, 1.0, 1.0, 1.0,
															0.0, 1.0, 0.0, 1.0], 0, 4);
			_quadIndices.uploadFromVector(new <uint>[0, 1, 2, 0, 2, 3], 0, 6);
		}
	}
}
