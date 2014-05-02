package net.psykosoft.psykopaint2.paint.utils
{
	import com.adobe.utils.AGALMiniAssembler;
	
	import flash.display3D.Context3D;
	import flash.display3D.Context3DProgramType;
	import flash.display3D.Context3DVertexBufferFormat;
	import flash.utils.ByteArray;
	
	import net.psykosoft.psykopaint2.core.model.CanvasModel;

	public class CopyColorAndSourceToBitmapDataUtil extends CopyColorToBitmapDataUtil
	{
		public var sourceTextureAlpha:Number = 1.0;
		public var paintAlpha:Number = 1.0;
		
		override protected function initProgram() : void
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
							"tex ft0, v0, fs0 <2d, nearest, mipnone>\n" +  // source
							"tex ft1, v0, fs1 <2d, nearest, mipnone>\n" +  // paint
							"mul ft0, ft0, fc0.z\n" +  //multiply source with source alpha
							"mul ft1, ft1, fc0.w\n" +  //multiply paint with paint alpha
							"mov ft2, fc0\n"+  // copy constants
							"sub ft2.y, ft2.y, ft1.w\n"+  //1 - paint alpha
							"mul ft0.xyz, ft0.xyz, ft2.y\n"+  //source color * (1 - paint alpha)
							"add ft0.xyz, ft1.xyz, ft0.xyz\n"+ // source color + paint color
							"mul ft0.w, ft0.w, ft2.y\n"+  //source alpha * (1- paint alpha)
							"add ft0.w, ft0.w, ft1.w\n" +  //source alpha + paint alpha
							"sub ft0.xyz, ft0.xyz, fc0.y\n" + 
							"mul ft0.xyz, ft0.xyz, ft0.w\n" +
							"add ft0.xyz, ft0.xyz, fc0.y\n" +
							"mov ft0.w, fc0.y\n" +
							"mov oc, ft0";
			
			var vertexByteCode : ByteArray = new AGALMiniAssembler().assemble(Context3DProgramType.VERTEX, vertexCode);
			var fragmentByteCode : ByteArray = new AGALMiniAssembler().assemble(Context3DProgramType.FRAGMENT, fragmentCode);
			_copyProgram = _context3D.createProgram();
			_copyProgram.upload(vertexByteCode, fragmentByteCode);
		}

		override protected function copy(canvas : CanvasModel, context3D : Context3D, scaleX : Number, scaleY : Number) : void
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
			
			_fragmentShaderData[1] = 1;
			_fragmentShaderData[2] = sourceTextureAlpha;
			_fragmentShaderData[3] = paintAlpha;
		
			

			_context3D.setProgram(_copyProgram);
			_context3D.setProgramConstantsFromVector(Context3DProgramType.VERTEX, 0, _props, 4);
			context3D.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 0, _fragmentShaderData, 1);
			_context3D.setVertexBufferAt(0, _quadVertices, 0, Context3DVertexBufferFormat.FLOAT_2); // vertices
			_context3D.setTextureAt(0, canvas.sourceTexture);
			_context3D.setTextureAt(1, canvas.colorTexture);
			
			_context3D.drawTriangles(_quadIndices,0,2);
			_context3D.setTextureAt(0, null);
			_context3D.setTextureAt(1, null);
			_context3D.setVertexBufferAt(0, null);
		}
}
}
