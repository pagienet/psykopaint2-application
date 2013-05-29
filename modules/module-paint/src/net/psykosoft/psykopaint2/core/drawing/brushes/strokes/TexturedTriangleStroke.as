package net.psykosoft.psykopaint2.core.drawing.brushes.strokes
{
	import flash.display3D.Context3D;
	import flash.display3D.Context3DVertexBufferFormat;
	import flash.display3D.VertexBuffer3D;
	import flash.display3D.textures.TextureBase;
	
	import net.psykosoft.psykopaint2.core.model.CanvasModel;
	import net.psykosoft.psykopaint2.tdsi.FastBuffer;

	public class TexturedTriangleStroke extends TriangleStroke
	{
		public function TexturedTriangleStroke()
		{
			super();
	}

		
		override public function append( appendVO:StrokeAppendVO ) : void
		{
			//check for maximum vertex count
			if ( _numVertices >= 65531 ) return;
			
			var verticesAndUV:Vector.<Number> = appendVO.verticesAndUV;
			_maxX = Math.max( verticesAndUV[0],verticesAndUV[4],verticesAndUV[8],_maxX );
			_minX = Math.min( verticesAndUV[0],verticesAndUV[4],verticesAndUV[8],_minX );
			_maxY = Math.max( verticesAndUV[1],verticesAndUV[5],verticesAndUV[9],_maxY );
			_minY = Math.min( verticesAndUV[1],verticesAndUV[5],verticesAndUV[9],_minY );
			
			//_fastBuffer.addInterleavedFloatsToVertices(verticesAndUV,_vIndex,4,4);
			_fastBuffer.addFloatsToVertices(verticesAndUV,_vIndex);
			_vIndex += 48;
			
			_numVertices += 3;
			_numIndices += 3;
			
			invalidateBuffers();
			invalidateBounds();
		}

		override public function drawColor(context3d : Context3D, canvas : CanvasModel, source : TextureBase = null) : void
		{
			var vertexBuffer : VertexBuffer3D = getVertexBuffer(context3d);

			context3d.setProgram(getColorProgram(context3d));
			context3d.setVertexBufferAt(0, vertexBuffer, 0, Context3DVertexBufferFormat.FLOAT_2);
			context3d.setVertexBufferAt(1, vertexBuffer, 2, Context3DVertexBufferFormat.FLOAT_2); 
			context3d.setTextureAt(0, _brushTexture);

			context3d.drawTriangles(getIndexBuffer(context3d), 0, _numIndices/3);

			context3d.setTextureAt(0, null);
			context3d.setVertexBufferAt(0, null);
			context3d.setVertexBufferAt(1, null);
			
		}

		override protected function getColorVertexCode() : String
		{
			return "mov v0, va1\n"+
				   "mov op, va0\n";
		}

		override protected function getColorFragmentCode() : String
		{
			return "tex oc, v0, fs0 <2d, clamp, linear, miplinear >\n";
		}

		override protected function get numElementsPerVertex() : int
		{
			return 4;
		}

		override protected function get topologyIndexType() : int
		{
			return FastBuffer.INDEX_MODE_TRIANGLES;
		}
	}
}
