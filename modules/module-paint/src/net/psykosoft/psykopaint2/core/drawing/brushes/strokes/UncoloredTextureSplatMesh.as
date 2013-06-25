package net.psykosoft.psykopaint2.core.drawing.brushes.strokes
{
	import flash.display3D.Context3D;
	import flash.display3D.Context3DProgramType;
	import flash.display3D.Context3DVertexBufferFormat;
	import flash.display3D.VertexBuffer3D;
	import flash.display3D.textures.TextureBase;
	import flash.geom.Rectangle;
	
	import net.psykosoft.psykopaint2.core.drawing.paths.SamplePoint;
	import net.psykosoft.psykopaint2.core.model.CanvasModel;
	import net.psykosoft.psykopaint2.tdsi.FastBuffer;

	public class UncoloredTextureSplatMesh extends AbstractBrushMesh
	{
		protected static var _tmpData:Vector.<Number>;

		// amount of color luminance that gets multiplied into the texture
		// 0 = none
		// 0.5 = half of it
		// 1 = all
		public var luminanceFactor : Number = 0.3;

		public function UncoloredTextureSplatMesh()
		{
			super();

			if (!_tmpData )
			{
				_tmpData = new Vector.<Number>(16,true);
			}
		}

		override public function append( appendVO:StrokeAppendVO ) : void
		{
			//check for maximum vertex count
			if (_numVertices >= 65531) return;
			
			var uvBounds:Rectangle = appendVO.uvBounds;
			var baseAngle : Number = appendVO.diagonalAngle;
			var halfSize : Number = appendVO.size * Math.SQRT1_2;
			var angle : Number = appendVO.point.angle;
			var cos1 : Number =  halfSize * Math.cos( baseAngle + angle);
			var sin1 : Number = -halfSize * Math.sin( baseAngle + angle);
			var cos2 : Number =  halfSize * Math.cos(-baseAngle + angle);
			var sin2 : Number = -halfSize * Math.sin(-baseAngle + angle);

			
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
			
			var data : Vector.<Number> = _tmpData;
			data[0] = pnx - cos1;
			data[1] = pny - sin1;
			data[2] = uvBounds.left;
			data[3] = uvBounds.top;

			data[4] = pnx + cos2;
			data[5] = pny  + sin2;
			data[6] = uvBounds.right;
			data[7] = uvBounds.top;

			data[8] =  pnx + cos1;
			data[9] = pny  + sin1;
			data[10] = uvBounds.right;
			data[11] = uvBounds.bottom;

			data[12] = pnx - cos2;
			data[13] = pny  - sin2;
			data[14] = uvBounds.left;
			data[15] = uvBounds.bottom;

			_fastBuffer.addInterleavedFloatsToVertices(data, _vIndex, 4, 4);
			_fastBuffer.addInterleavedFloatsToVertices(appendVO.point.colorsRGBA, _vIndex + 16, 4, 4);

			_vIndex += 128;

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
			context3d.setVertexBufferAt(2, vertexBuffer, 4, Context3DVertexBufferFormat.FLOAT_4);

			context3d.setTextureAt(0, _brushTexture);
			context3d.setProgramConstantsFromVector(Context3DProgramType.VERTEX, 0, Vector.<Number>([0.299, 0.587, 0.114, 1.6, 1 - luminanceFactor, 0, 0, 0]));

			context3d.drawTriangles(getIndexBuffer(context3d), 0, _numIndices / 3);

			context3d.setTextureAt(0, null);

			context3d.setVertexBufferAt(0, null);
			context3d.setVertexBufferAt(1, null);
			context3d.setVertexBufferAt(2, null);

		}

		override protected function getColorVertexCode() : String
		{
			return "mov v0, va1\n" +
					"mov v1, va2\n" +
					"mov vt0, va2\n" +
					"div vt0.xyz, vt0.xyz, vt0.w\n" +
					"dp3 vt0.x, vt0.xyz, vc0.xyz\n" +
					"mul vt0.x, vt0.x, vc0.w\n" +
					"add vt0.x, vt0.x, vc1.x\n" +
					"add vt0.x, vt0.x, vc0.z\n" +
					"sat v1.x, vt0.x\n" +
					"mov op, va0\n";
		}

		override protected function getColorFragmentCode() : String
		{
			return "tex ft0, v0, fs0 <2d, clamp, linear, miplinear >\n" +
					"mul ft0.xyz,ft0.xyz, v1.x\n" +
					"mul oc, ft0, v1.w\n";
		}

		override protected function get numElementsPerVertex() : int
		{
			return 8;
		}

		override protected function get topologyIndexType() : int
		{
			return FastBuffer.INDEX_MODE_QUADS;
		}
	}
}
