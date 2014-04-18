package net.psykosoft.psykopaint2.core.drawing.brushes.strokes
{
	import com.quasimondo.geom.ColorMatrix;
	
	import flash.display3D.Context3D;
	import flash.display3D.Context3DProgramType;
	import flash.display3D.Context3DVertexBufferFormat;
	import flash.display3D.VertexBuffer3D;
	import flash.display3D.textures.RectangleTexture;
	import flash.display3D.textures.TextureBase;
	import flash.geom.Rectangle;
	
	import net.psykosoft.psykopaint2.core.configuration.CoreSettings;
	import net.psykosoft.psykopaint2.core.drawing.paths.SamplePoint;
	import net.psykosoft.psykopaint2.core.intrinsics.FastBuffer;
	import net.psykosoft.psykopaint2.core.model.CanvasModel;
	

	public class EffectMesh extends AbstractBrushMesh
	{
		protected static var _tmpData:Vector.<Number>;
		private var _colorTexture:RectangleTexture;
		private var _colorMatrixData:Vector.<Number>;
		
		public function EffectMesh()
		{
			super();

			if (!_tmpData )
			{
				_tmpData = new Vector.<Number>(40,true);
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
			data[8]  = (vx + 1)*0.5;
			data[9]  = 1 -(vy + 1)*0.5;
			
			vx = (pnx + cos2 + ox) * ndcScaleX - 1.0;
			vy = -((pny + sin2 + oy) * ndcScaleY - 1.0);

			if (vx < _minX) _minX = vx;
			if (vx > _maxX) _maxX = vx;
			if (vy < _minY) _minY = vy;
			if (vy > _maxY) _maxY = vy;

			data[10] =vx;
			data[11] =vy;
			data[18]  = (vx + 1)*0.5;
			data[19]  = 1 - (vy + 1)*0.5;

			vx = (pnx + cos1 + ox) * ndcScaleX - 1.0;
			vy = -((pny + sin1 + oy) * ndcScaleY - 1.0);

			if (vx < _minX) _minX = vx;
			if (vx > _maxX) _maxX = vx;
			if (vy < _minY) _minY = vy;
			if (vy > _maxY) _maxY = vy;

			data[20]  =vx;
			data[21]  =vy;
			data[28]  = (vx + 1)*0.5;
			data[29]  = 1 -(vy + 1)*0.5;
			
			vx = (pnx - cos2 + ox) * ndcScaleX - 1.0;
			vy = -((pny - sin2 + oy) * ndcScaleY - 1.0);

			if (vx < _minX) _minX = vx;
			if (vx > _maxX) _maxX = vx;
			if (vy < _minY) _minY = vy;
			if (vy > _maxY) _maxY = vy;

			data[30]  =vx;
			data[31]  =vy;
			data[38]  = (vx + 1)*0.5;
			data[39]  = 1 -(vy + 1)*0.5;
		
			data[2]  = data[32] = uvBounds.left;
			data[3]  = data[13] = uvBounds.top;
			data[12] = data[22] = uvBounds.right;
			data[23] = data[33] = uvBounds.bottom;
			
			
			//used by bump map:
			var rotCos : Number = Math.cos(angle);
			var rotSin : Number = Math.sin(angle);
			data[4] = data[14] = data[24] = data[34] = rotCos;
			data[5] = data[15] = data[25] = data[35] =-rotSin;
			data[6] = data[16] = data[26] = data[36] = rotSin;
			data[7] = data[17] = data[27] = data[37] = rotCos;
			
			
			
			//_fastBuffer.addInterleavedFloatsToVertices( data,_vIndex,8,4);
			//_fastBuffer.addInterleavedFloatsToVertices( point.colorsRGBA,_vIndex+32,4,8);
			_fastBuffer.addInterleavedFloatsToVertices( data,_vIndex,10,8);
			_fastBuffer.addInterleavedFloatsToVertices( point.colorsRGBA,_vIndex+40,4,14);
			_fastBuffer.addInterleavedFloatsToVertices( point.bumpFactors,_vIndex+56,4,14);
			//_vIndex += 192;
			_vIndex += 288;
			
			_numVertices += 4;
			_numIndices += 6;

			invalidateBuffers();
			invalidateBounds();
		}

		override public function drawColor(context3d : Context3D, canvas : CanvasModel, source : TextureBase = null) : void
		{
			var vertexBuffer : VertexBuffer3D = getVertexBuffer(context3d);

			context3d.setProgram(getColorProgram(context3d));
			context3d.setVertexBufferAt(0, vertexBuffer, 0, Context3DVertexBufferFormat.FLOAT_2); //vertex
			context3d.setVertexBufferAt(1, vertexBuffer, 2, Context3DVertexBufferFormat.FLOAT_2); //uv brush
			context3d.setVertexBufferAt(2, vertexBuffer, 8, Context3DVertexBufferFormat.FLOAT_2); //uv source
			context3d.setVertexBufferAt(3, vertexBuffer, 10, Context3DVertexBufferFormat.FLOAT_4); //color
			
			
			context3d.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT,0, _colorMatrixData);
			
			context3d.setTextureAt(0, _brushTexture);
			context3d.setTextureAt(1, _colorTexture);
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
			return "tex ft1, v1, fs1 <2d, clamp, linear, mipnone >\n"+
				   "m44 ft1, ft1, fc0\n"+
				   "add ft1, ft1, fc4\n"+
				   "sat ft1,ft1\n"+
				   "tex ft0, v0, fs0 <2d, clamp, linear, miplinear >\n"+
				   "mul oc,ft1,ft0.x\n";
		}

		override protected function get numElementsPerVertex() : int
		{
			return 18;
		}

		override protected function get topologyIndexType() : int
		{
			return FastBuffer.INDEX_MODE_QUADS;
		}

		public function get colorTexture():RectangleTexture
		{
			return _colorTexture;
		}

		public function set colorTexture(value:RectangleTexture):void
		{
			_colorTexture = value;
		}
		
		public function set colorMatrixData( data:Vector.<Number> ):void
		{
			_colorMatrixData = data;
		}

		

	}
}
