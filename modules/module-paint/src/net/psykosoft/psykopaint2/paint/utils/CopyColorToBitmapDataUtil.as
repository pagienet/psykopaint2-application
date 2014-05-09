package net.psykosoft.psykopaint2.paint.utils
{
	import com.adobe.utils.AGALMiniAssembler;

	import flash.display.BitmapData;
	import flash.display.BlendMode;
	import flash.display3D.Context3D;
	import flash.display3D.Context3DBlendFactor;
	import flash.display3D.Context3DProgramType;
	import flash.display3D.Context3DVertexBufferFormat;
	import flash.display3D.IndexBuffer3D;
	import flash.display3D.Program3D;
	import flash.display3D.VertexBuffer3D;
	import flash.utils.ByteArray;

	import net.psykosoft.psykopaint2.base.utils.misc.TrackedBitmapData;

	import net.psykosoft.psykopaint2.core.model.CanvasModel;

	public class CopyColorToBitmapDataUtil
	{
		protected var _fragmentShaderData : Vector.<Number> = new <Number>[0, 0, 0, 1];

		protected var _context3D : Context3D;
		protected var _copyProgram : Program3D;
		protected var _quadVertices : VertexBuffer3D;
		protected var _quadIndices : IndexBuffer3D;
		protected var _props : Vector.<Number> = Vector.<Number>([0, 0, 0, 0, 1, 1, 0, 1, 1, 1, 0, 1, 0, 0, 0, 0]);

		public function execute(canvas : CanvasModel, target : BitmapData = null) : BitmapData
		{
			target ||= new TrackedBitmapData(canvas.width, canvas.height, false);
			var context3D : Context3D = canvas.stage3D.context3D;
			context3D.setBlendFactors(Context3DBlendFactor.ONE, Context3DBlendFactor.ZERO);
			context3D.setRenderToBackBuffer();
			context3D.clear();
			copy(canvas, context3D, target.width / canvas.width, target.height / canvas.height);
			context3D.drawToBitmapData(target);

			return target;
		}



		protected function initProgram() : void
		{
			var vertexCode : String =
							"mul vt0, va0, vc1\n" +	// calculate size
							"add vt0, vt0, vc0\n" +
							"neg vt0.y, vt0.y\n" +
							"mov op, vt0\n" +

							"mul vt0, va0, vc3\n" +
							"add vt0, vt0, vc2\n" +
							"mov v0, vt0";
			var fragmentCode : String =
							"tex ft0, v0, fs0 <2d, nearest, mipnone>\n" +
							"sub ft0.xyz, ft0.xyz, fc0.w\n" +
							"mul ft0.xyz, ft0.xyz, ft0.w\n" +
							"add ft0.xyz, ft0.xyz, fc0.w\n" +
							"mov ft0.w, fc0.w\n" +
							"mov oc, ft0";
			var vertexByteCode : ByteArray = new AGALMiniAssembler().assemble(Context3DProgramType.VERTEX, vertexCode);
			var fragmentByteCode : ByteArray = new AGALMiniAssembler().assemble(Context3DProgramType.FRAGMENT, fragmentCode);
			_copyProgram = _context3D.createProgram();
			_copyProgram.upload(vertexByteCode, fragmentByteCode);
		}

		protected function copy(canvas : CanvasModel, context3D : Context3D, scaleX : Number, scaleY : Number) : void
		{
			_context3D = context3D;
			if (!_copyProgram) initProgram();
			if (!_quadVertices) initGeometry();

			_props[0] = -1;
			_props[1] = -1;
			_props[4] = scaleX * 2;
			_props[5] = scaleY * 2;

			_props[8] = 0; 	// uv coords
			_props[9] = 0;
			_props[12] = 1;
			_props[13] = 1;

			_context3D.setProgram(_copyProgram);
			_context3D.setProgramConstantsFromVector(Context3DProgramType.VERTEX, 0, _props, 4);
			context3D.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 0, _fragmentShaderData, 1);
			_context3D.setVertexBufferAt(0, _quadVertices, 0, Context3DVertexBufferFormat.FLOAT_2); // vertices
			_context3D.setTextureAt(0, canvas.colorTexture);
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

		protected function initGeometry() : void
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
