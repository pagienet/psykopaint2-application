package net.psykosoft.psykopaint2.base.utils.gpu
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
	import flash.utils.ByteArray;
	
	import away3d.core.base.ISubGeometry;
	import away3d.entities.Mesh;
	
	public class CopyMeshToBitmapDataUtil 
	{
		protected var _fragmentShaderData : Vector.<Number> = new <Number>[0, 0, 0, 1];

		protected var _context3D : Context3D;
		protected var _copyProgram : Program3D;
		protected var _quadVertices : VertexBuffer3D;
		protected var _quadIndices : IndexBuffer3D;
		
		public function execute(mesh : Mesh, sourceTexture:TextureBase, target : BitmapData, context3D:Context3D) : BitmapData
		{
			context3D.setRenderToBackBuffer();
			context3D.clear();
			//context3D.setBlendFactors(Context3DBlendFactor.ONE, Context3DBlendFactor.ZERO);
			copy(mesh, sourceTexture, context3D);
			context3D.drawToBitmapData(target);
			dispose();
			
			return target;
		}

		protected function initProgram() : void
		{
			var vertexCode : String =
							"mov op, va0 \n" + // 4x4 matrix transform to output space
							"mov v0, va1      \n";  // pass texture coordinates to fragment program
							
			var fragmentCode : String =
							"tex oc, v0, fs0 <2d, linear, mipnone>\n";
			
			var vertexByteCode : ByteArray = new AGALMiniAssembler().assemble(Context3DProgramType.VERTEX, vertexCode);
			var fragmentByteCode : ByteArray = new AGALMiniAssembler().assemble(Context3DProgramType.FRAGMENT, fragmentCode);
			_copyProgram = _context3D.createProgram();
			_copyProgram.upload(vertexByteCode, fragmentByteCode);
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
			_quadVertices = _context3D.createVertexBuffer(4, 4);
			_quadIndices = _context3D.createIndexBuffer(6);
			_quadIndices.uploadFromVector(new <uint>[0, 2, 1, 0, 3, 2], 0, 6);
			
		}

		protected function copy(mesh : Mesh,sourceTexture:TextureBase, context3D : Context3D) : void
		{
			_context3D = context3D;
			if (!_copyProgram) initProgram();
			if (!_quadVertices) initGeometry();

			
			var props:Vector.<Number> =new <Number>[	
				-1.0, -1.0, 0.0,0.0,
				1.0, -1.0, 0.0,0.0,
				1.0, 1.0, 0.0,0.0,
				-1.0, 1.0, 0.0,0.0];
			
			
			var sg:ISubGeometry = mesh.geometry.subGeometries[0];
			var uvData:Vector.<Number> = sg.UVData;
			var uvOffset:int = sg.UVOffset;
			var uvStride:int = sg.UVStride;
			props[2] = uvData[uvOffset];
			props[3] = uvData[uvOffset+1];
			uvOffset += uvStride;
			props[6] = uvData[uvOffset];
			props[7] = uvData[uvOffset+1];
			uvOffset += uvStride;
			props[14] = uvData[uvOffset];
			props[15] = uvData[uvOffset+1];
			uvOffset += uvStride;
			props[10] = uvData[uvOffset];
			props[11] = uvData[uvOffset+1];
			
		
			_quadVertices.uploadFromVector(props, 0, 4);
			
			_context3D.setProgram(_copyProgram);
			_context3D.setVertexBufferAt(0, _quadVertices, 0, Context3DVertexBufferFormat.FLOAT_2); // vertices
			_context3D.setVertexBufferAt(1, _quadVertices, 2, Context3DVertexBufferFormat.FLOAT_2); // uv
			
		//	var m3d:Matrix3D = new Matrix3D();
		//	_context3D.setProgramConstantsFromMatrix(Context3DProgramType.VERTEX, 0, m3d, true);
			
			_context3D.setTextureAt(0, sourceTexture );
			
			_context3D.drawTriangles(_quadIndices,0,2);
			_context3D.setTextureAt(0, null);
			_context3D.setVertexBufferAt(0, null);
			_context3D.setVertexBufferAt(1, null);
		}
}
}
