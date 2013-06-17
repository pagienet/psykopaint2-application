package net.psykosoft.psykopaint2.core.drawing.brushes.strokes
{
	import flash.display3D.Context3D;
	import flash.display3D.Context3DVertexBufferFormat;
	import flash.display3D.VertexBuffer3D;
	import flash.display3D.textures.TextureBase;
	import flash.geom.Rectangle;
	
	import net.psykosoft.psykopaint2.core.model.CanvasModel;
	import net.psykosoft.psykopaint2.tdsi.FastBuffer;

	public class SourceCopyMesh extends AbstractBrushMesh
	{
		protected static var _tmpData:Vector.<Number>;
		
		public function SourceCopyMesh()
		{
			super();

			if (!_tmpData )
			{
				_tmpData = new Vector.<Number>(24,true);
			}
		}

		override public function append( appendVO:StrokeAppendVO ) : void
		{
			//check for maximum vertex count
			if ( _numVertices >= 65531 ) return;
			var verticesAndUV:Vector.<Number> = appendVO.verticesAndUV;
			
			_maxX = Math.max( verticesAndUV[0],verticesAndUV[6],verticesAndUV[12],verticesAndUV[18],_maxX );
			_minX = Math.min( verticesAndUV[0],verticesAndUV[6],verticesAndUV[12],verticesAndUV[18],_minX );
			_maxY = Math.max( verticesAndUV[1],verticesAndUV[7],verticesAndUV[13],verticesAndUV[19],_maxY );
			_minY = Math.min( verticesAndUV[1],verticesAndUV[7],verticesAndUV[13],verticesAndUV[19],_minY );
			
			_fastBuffer.addInterleavedFloatsToVertices(verticesAndUV,_vIndex,6,4);
			_fastBuffer.addInterleavedFloatsToVertices(appendVO.point.colorsRGBA,_vIndex+24,4,6);

			_vIndex += 160;
			
			_numVertices += 4;
			_numIndices += 6;

			invalidateBuffers();
			invalidateBounds();
		}

		override public function drawColor(context3d : Context3D, canvas : CanvasModel, source : TextureBase = null) : void
		{
			var vertexBuffer : VertexBuffer3D = getVertexBuffer(context3d);

			context3d.setProgram(getColorProgram(context3d));
			context3d.setVertexBufferAt(0, vertexBuffer, 0, Context3DVertexBufferFormat.FLOAT_2); // xy
			context3d.setVertexBufferAt(1, vertexBuffer, 2, Context3DVertexBufferFormat.FLOAT_2); // uv shape
			context3d.setVertexBufferAt(2, vertexBuffer, 4, Context3DVertexBufferFormat.FLOAT_2); // uv composite
			context3d.setVertexBufferAt(3, vertexBuffer, 6, Context3DVertexBufferFormat.FLOAT_4); // ARGB

			context3d.setTextureAt(0, _brushTexture);
			context3d.setTextureAt(1, canvas.sourceTexture);
			context3d.drawTriangles(getIndexBuffer(context3d), 0, _numIndices/3);

			context3d.setTextureAt(0, null);
			context3d.setTextureAt(1, null);

			context3d.setVertexBufferAt(0, null);
			context3d.setVertexBufferAt(1, null);
			context3d.setVertexBufferAt(2, null);
			context3d.setVertexBufferAt(3, null);
		}


		override protected function getColorVertexCode() : String
		{
			return "mov v0, va1\n"+
				   "mov v1, va2\n" +
				   "mov v2, va3\n" +
				   "mov op, va0\n";
		}

		override protected function getColorFragmentCode() : String
		{
			return "tex ft0, v0, fs0 <2d, clamp, linear, miplinear >\n" +
				   "tex ft1, v1, fs1 <2d, clamp, linear, mipnone >\n" +
				   "mul ft0.x, v2.w, ft0.x\n" +
				   "mul oc, ft1, ft0.x\n";
		}

		override protected function get numElementsPerVertex() : int
		{
			return 10;
		}

		override protected function get topologyIndexType() : int
		{
			return FastBuffer.INDEX_MODE_QUADS;
		}
	}
}
