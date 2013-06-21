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
	import net.psykosoft.psykopaint2.tdsi.FastBuffer;

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
		
			var baseAngle:Number = Math.atan2(uvBounds.height,uvBounds.width);
			var halfSize : Number = appendVO.size * Math.SQRT1_2;
			var angle : Number = appendVO.point.angle;
			var cos1 : Number =   halfSize*Math.cos(baseAngle + angle);
			var sin1 : Number =  -halfSize*Math.sin(baseAngle + angle);
			var cos2 : Number =   halfSize*Math.cos( -baseAngle + angle);
			var sin2 : Number =  -halfSize*Math.sin( -baseAngle + angle);
			var rotCos : Number = Math.cos(angle);
			var rotSin : Number = Math.sin(angle);

			var point:SamplePoint = appendVO.point;
			var vx : Number, vy : Number;
			var data:Vector.<Number> = _tmpData;
			vx = point.normalX - cos1;
			vy = point.normalY - sin1;
			data[0] = vx;
			data[1] = vy;
			data[2] = uvBounds.left;
			data[3] = uvBounds.top;

			data[4] = rotCos;
			data[5] = -rotSin;
			data[6] = rotSin;
			data[7] = rotCos;

			if (vx > _maxX) _maxX = vx;
			else if (vx < _minX) _minX = vx;
			if (vy > _maxY) _maxY = vy;
			else if (vy < _minY) _minY = vy;

			vx = point.normalX + cos2;
			vy = point.normalY + sin2;
			data[8] = vx;
			data[9] = vy;
			data[10] = uvBounds.right;
			data[11] = uvBounds.top;
			data[12] = rotCos;
			data[13] = -rotSin;
			data[14] = rotSin;
			data[15] = rotCos;

			if (vx > _maxX) _maxX = vx;
			else if (vx < _minX) _minX = vx;
			if (vy > _maxY) _maxY = vy;
			else if (vy < _minY) _minY = vy;

			vx = point.normalX + cos1;
			vy = point.normalY + sin1;
			data[16] = vx;
			data[17] = vy;
			data[18] = uvBounds.right;
			data[19] = uvBounds.bottom;
			data[20] = rotCos;
			data[21] = -rotSin;
			data[22] = rotSin;
			data[23] = rotCos;

			if (vx > _maxX) _maxX = vx;
			else if (vx < _minX) _minX = vx;
			if (vy > _maxY) _maxY = vy;
			else if (vy < _minY) _minY = vy;

			vx = point.normalX - cos2;
			vy = point.normalY - sin2;
			data[24] = vx;
			data[25] = vy;
			data[26] = uvBounds.left;
			data[27] = uvBounds.bottom;
			data[28] = rotCos;
			data[29] = -rotSin;
			data[30] = rotSin;
			data[31] = rotCos;

			if (vx > _maxX) _maxX = vx;
			else if (vx < _minX) _minX = vx;
			if (vy > _maxY) _maxY = vy;
			else if (vy < _minY) _minY = vy;

			_fastBuffer.addInterleavedFloatsToVertices(data,_vIndex,8,4);
			_fastBuffer.addInterleavedFloatsToVertices(appendVO.point.colorsRGBA,_vIndex+32,4,8);

			_vIndex += 192;

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
			return 12;
		}

		override protected function get topologyIndexType() : int
		{
			return FastBuffer.INDEX_MODE_QUADS;
		}
	}
}
