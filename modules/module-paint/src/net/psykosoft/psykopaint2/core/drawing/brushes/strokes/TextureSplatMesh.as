package net.psykosoft.psykopaint2.core.drawing.brushes.strokes
{
	import flash.display3D.Context3D;
	import flash.display3D.Context3DVertexBufferFormat;
	import flash.display3D.VertexBuffer3D;
	import flash.display3D.textures.TextureBase;
	import flash.geom.Rectangle;

	import net.psykosoft.psykopaint2.core.configuration.CoreSettings;

	import net.psykosoft.psykopaint2.core.drawing.paths.SamplePoint;
	import net.psykosoft.psykopaint2.core.model.CanvasModel;
	import net.psykosoft.psykopaint2.core.intrinsics.FastBuffer;
	

	public class TextureSplatMesh extends AbstractBrushMesh
	{
		protected static var _tmpData:Vector.<Number>;

		public function TextureSplatMesh()
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
			var cos1 : Number = halfSize * Math.cos(  baseAngle + angle);
			var sin1 : Number = halfSize * Math.sin(  baseAngle + angle);
			var cos2 : Number = halfSize * Math.cos( -baseAngle + angle);
			var sin2 : Number = halfSize * Math.sin( -baseAngle + angle);

			var point:SamplePoint = appendVO.point;
			var pnx:Number = point.x;
			var pny:Number = point.y;
			
			var data:Vector.<Number> = _tmpData;

			var ox:Number = appendVO.quadOffsetRatio * (-cos1 - cos2);
			var oy:Number = appendVO.quadOffsetRatio * (-sin1 - sin2);
			
			var ndcScaleX:Number = 2/CoreSettings.STAGE_WIDTH;
			var ndcScaleY:Number = 2/CoreSettings.STAGE_HEIGHT;

			var vx : Number = (pnx - cos1 + ox) * ndcScaleX - 1.0;
			var vy : Number = -((pny - sin1 + oy) * ndcScaleY - 1.0);

			if (vx < _minX) _minX = vx;
			if (vx > _maxX) _maxX = vx;
			if (vy < _minY) _minY = vy;
			if (vy > _maxY) _maxY = vy;

			data[0]  = vx;
			data[1]  = vy;

			vx = (pnx + cos2 + ox) * ndcScaleX - 1.0;
			vy = -((pny + sin2 + oy) * ndcScaleY - 1.0);

			if (vx < _minX) _minX = vx;
			if (vx > _maxX) _maxX = vx;
			if (vy < _minY) _minY = vy;
			if (vy > _maxY) _maxY = vy;

			data[8] = vx;
			data[9] = vy;

			vx = (pnx + cos1 + ox) * ndcScaleX - 1.0;
			vy = -((pny + sin1 + oy) * ndcScaleY - 1.0);

			if (vx < _minX) _minX = vx;
			if (vx > _maxX) _maxX = vx;
			if (vy < _minY) _minY = vy;
			if (vy > _maxY) _maxY = vy;

			data[16] = vx;
			data[17] = vy;

			vx = (pnx - cos2 + ox) * ndcScaleX - 1.0;
			vy = -((pny - sin2 + oy) * ndcScaleY - 1.0);

			if (vx < _minX) _minX = vx;
			if (vx > _maxX) _maxX = vx;
			if (vy < _minY) _minY = vy;
			if (vy > _maxY) _maxY = vy;

			data[24] = vx;
			data[25] = vy;
			
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
			_fastBuffer.addInterleavedFloatsToVertices( point.colorsRGBA,_vIndex+32,4,12);
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
			context3d.setVertexBufferAt(2, vertexBuffer, 8, Context3DVertexBufferFormat.FLOAT_4);
			
			context3d.setTextureAt(0, _brushTexture);
			context3d.drawTriangles(getIndexBuffer(context3d), 0, _numIndices/3);

			context3d.setTextureAt(0, null);

			context3d.setVertexBufferAt(0, null);
			context3d.setVertexBufferAt(1, null);
			context3d.setVertexBufferAt(2, null);
			
		}


		override protected function getColorVertexCode() : String
		{
			return "mov v0, va1\n"+
				   "mov v1, va2\n" +
				   "mov op, va0\n";
		}

		override protected function getColorFragmentCode() : String
		{
			return "tex ft0, v0, fs0 <2d, clamp, linear, miplinear >\n" +
				   "mul oc, v1, ft0.x\n";
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
