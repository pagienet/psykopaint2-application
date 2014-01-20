package net.psykosoft.psykopaint2.core.drawing.brushes.strokes
{
	import flash.display3D.Context3D;
	import flash.display3D.Context3DVertexBufferFormat;
	import flash.display3D.VertexBuffer3D;
	import flash.display3D.textures.TextureBase;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;
	
	import net.psykosoft.psykopaint2.core.drawing.paths.SamplePoint;
	import net.psykosoft.psykopaint2.core.model.CanvasModel;
	import net.psykosoft.psykopaint2.core.intrinsics.FastBuffer;
	
	public class DrawingApiMesh extends AbstractBrushMesh
	{
		protected static var _tmpData:Vector.<Number>;

		public function DrawingApiMesh()
		{
			super();

			if (!_tmpData )
			{
				_tmpData = new Vector.<Number>(32,true);
			}
		}

		override public function append( appendVO:StrokeAppendVO ):void
		{
			//check for maximum vertex count
			if ( _numVertices >= 65531 ) return;
			
			var uvBounds:Rectangle = appendVO.uvBounds;
			var baseAngle:Number = appendVO.diagonalAngle; //Math.atan2(uvBounds.height,uvBounds.width);
			var halfSize : Number = appendVO.size * appendVO.diagonalLength * 0.5;//appendVO.size * Math.SQRT1_2;
			var angle : Number = appendVO.point.angle;
			var cos1 : Number =   halfSize * Math.cos(  baseAngle + angle); // 0.5
			var sin1 : Number =  -halfSize * Math.sin(  baseAngle + angle); // -0.5
			var cos2 : Number =   halfSize * Math.cos( -baseAngle + angle); // 0.5
			var sin2 : Number =  -halfSize * Math.sin( -baseAngle + angle); // 0.5
			
			var point:SamplePoint = appendVO.point;
			var pnx:Number = point.normalX;
			var pny:Number = point.normalY;
			
			var v : Number;
			var m:Number = Math.max( cos1, -cos1, cos2, -cos2 );
			if ((v = pnx + m) > _maxX) _maxX = v;
			if ((v = pnx - m) < _minX) _minX = v;
			m = Math.max( sin1, -sin1, sin2, -sin2 );
			if ((v = pny + m) > _maxY) _maxY = v;
			if ((v = pny - m) < _minY) _minY = v;
			
			var data:Vector.<Number> = _tmpData;
			data[0]  = pnx - cos1;
			data[1]  = pny - sin1;
			data[8]  = pnx + cos2;
			data[9]  = pny + sin2;
			data[16] = pnx + cos1;
			data[17] = pny + sin1;
			data[24] = pnx - cos2;
			data[25] = pny - sin2;
			
			data[2]  = data[26] = uvBounds.left;
			data[3]  = data[11] = uvBounds.top;
			data[10] = data[18] = uvBounds.right;
			data[19] = data[27] = uvBounds.bottom;
			
			//used by bump map:
			var rotCos : Number = Math.cos(angle);
			var rotSin : Number = Math.sin(angle);
			data[4] = data[12] = data[20] = data[28] = rotCos;
			data[5] = data[13] = data[21] = data[29] =-rotSin;
			data[6] = data[14] = data[22] = data[30] = rotSin;
			data[7] = data[15] = data[23] = data[31] = rotCos;
			 
			
			//_fastBuffer.addInterleavedFloatsToVertices( data,_vIndex,8,4);
			//_fastBuffer.addInterleavedFloatsToVertices( point.colorsRGBA,_vIndex+32,4,8);
			_fastBuffer.addInterleavedFloatsToVertices( data,_vIndex,8,8);
			_fastBuffer.addInterleavedFloatsToVertices( point.bumpFactors,_vIndex+48,4,12);

			//_vIndex += 192;
			_vIndex += 256;
			
			_numVertices += 4;
			_numIndices += 6;

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
			return "tex oc, v0, fs0 <2d, clamp, linear, mipnone>";
		}

		override protected function get numElementsPerVertex() : int
		{
			return 16;
		}

		override protected function get topologyIndexType() : int
		{
			return FastBuffer.INDEX_MODE_QUADS;
		}
	}
}
