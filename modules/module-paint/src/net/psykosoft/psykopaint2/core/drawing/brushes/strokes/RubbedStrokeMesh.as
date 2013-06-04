package net.psykosoft.psykopaint2.core.drawing.brushes.strokes
{
	import flash.display3D.Context3D;
	import flash.display3D.Context3DVertexBufferFormat;
	import flash.display3D.VertexBuffer3D;
	import flash.display3D.textures.TextureBase;

	import net.psykosoft.psykopaint2.core.drawing.paths.SamplePoint;
	import net.psykosoft.psykopaint2.core.model.CanvasModel;
	import net.psykosoft.psykopaint2.tdsi.FastBuffer;

	public class RubbedStrokeMesh extends AbstractBrushMesh
	{
		private static var _tmpData : Vector.<Number>;

		private var _subtractiveBlending : Boolean;

		private var _prevX : Number;
		private var _prevY : Number;
		private var _prevNormalX : Number;
		private var _prevNormalY : Number;
		private var _prevAppendVO : StrokeAppendVO;

		// todo: add "direction" of rub, do not move direction when drawing 'connections'
		public function RubbedStrokeMesh(subtractiveBlending : Boolean = false)
		{
			super();

			if (!_tmpData)
				_tmpData = new Vector.<Number>(20, true);

			_subtractiveBlending = subtractiveBlending
		}


		override public function clear() : void
		{
			super.clear();
			_prevNormalX = Number.NaN;
			_prevNormalY = Number.NaN;
		}

		override public function customBlending() : Boolean
		{
			return _subtractiveBlending;
		}

		override public function append( appendVO:StrokeAppendVO ) : void
		{
			var normalX : Number, normalY : Number;
			var point:SamplePoint = appendVO.point;
			if (_numVertices == 0) {
				// make it draw a full turn for starters at the starting pos
				_prevX = point.normalX;
				_prevY = point.normalY;
				normalX = 0;
				normalY = 1;
				_prevNormalX = 0;
				_prevNormalY = -1;
				// first should include "beginning" of stroke
			}
			else {
				normalX = point.normalY - _prevY;
				normalY = _prevX - point.normalX;
				var invNorm : Number = Math.sqrt(normalX * normalX + normalY * normalY);

				if (invNorm < 0.0001)
					return;

				invNorm = 1 / invNorm;
				normalX *= invNorm;
				normalY *= invNorm;
			}

			// if corner is sharp enough, add subsegments
			var dot : Number = _prevNormalX*normalX + _prevNormalY*normalY;

			if 	(dot < .25) {
				var numSegments : int = -(dot - .25)/1.25 * 7;
				if (numSegments < 2) numSegments = 2;
				appendConnection(_prevNormalX, _prevNormalY, normalX, normalY, appendVO, numSegments);
			}

			appendSegment(point.normalX, point.normalY, appendVO, normalX, normalY);

			invalidateBuffers();
			invalidateBounds();

			_prevX = point.normalX;
			_prevY = point.normalY;
			_prevNormalX = normalX;
			_prevNormalY = normalY;
			_prevAppendVO = appendVO;
		}

		public function appendStationary() : void
		{
			appendConnection(_prevNormalX, _prevNormalY, -_prevNormalX, -_prevNormalY, _prevAppendVO, 7);
			_prevNormalX = -_prevNormalX;
			_prevNormalY = -_prevNormalY;

			invalidateBuffers();
			invalidateBounds();
		}

		private function appendConnection(startNormalX : Number, startNormalY : Number, endNormalX : Number, endNormalY : Number, appendVO : StrokeAppendVO, numSegments : uint) : void
		{
			// not slerping because angle between normals isn't always the correct value
			var startAngle : Number = Math.atan2(startNormalY, startNormalX);
			var endAngle : Number = Math.atan2(endNormalY, endNormalX);

			for (var i : int = 1; i <= numSegments +1; ++i) {
				var t : Number = i / (numSegments + 1);
				var angle : Number = startAngle + t * (endAngle - startAngle);

				var interpNormalX : Number = Math.cos(angle);
				var interpNormalY : Number = Math.sin(angle);

				appendSegment(_prevX, _prevY, appendVO, interpNormalX, interpNormalY);
			}
		}

		private function appendSegment(x : Number, y : Number, appendVO : StrokeAppendVO, normalX : Number, normalY : Number) : void
		{
			var colorsRGBA:Vector.<Number> =  appendVO.point.colorsRGBA;
			var halfSize : Number = appendVO.size * .5;
			var vx : Number = x + normalX * halfSize;
			var vy : Number = y + normalY * halfSize;
			var u : Number = Math.random();
			if (vx > _maxX) _maxX = vx;
			else if (vx < _minX) _minX = vx;
			if (vy > _maxY) _maxY = vy;
			else if (vy < _minY) _minY = vy;
			_tmpData[0] = vx;
			_tmpData[1] = vy;
			_tmpData[2] = u;
			_tmpData[3] = 0;
			_tmpData[4] = colorsRGBA[0];
			_tmpData[5] = colorsRGBA[1];
			_tmpData[6] = colorsRGBA[2];
			_tmpData[7] = colorsRGBA[3];
			_tmpData[8] = vx * .5 + .5;
			_tmpData[9] = .5 - vy * .5;

			vx = appendVO.point.normalX - normalX * halfSize;
			vy = appendVO.point.normalY - normalY * halfSize;
			if (vx > _maxX) _maxX = vx;
			else if (vx < _minX) _minX = vx;
			if (vy > _maxY) _maxY = vy;
			else if (vy < _minY) _minY = vy;
			_tmpData[10] = vx;
			_tmpData[11] = vy;
			_tmpData[12] = u;
			_tmpData[13] = 1;

			_tmpData[14] = colorsRGBA[4];
			_tmpData[15] = colorsRGBA[5];
			_tmpData[16] = colorsRGBA[6];
			_tmpData[17] = colorsRGBA[7];
			_tmpData[18] = vx * .5 + .5;
			_tmpData[19] = .5 - vy * .5;


			_fastBuffer.addFloatsToVertices(_tmpData, _vIndex);
			_vIndex += 80;

			_numVertices += 2;
			if (_numVertices > 2) _numIndices += 6;
		}

		override public function drawColor(context3d : Context3D, canvas : CanvasModel, source : TextureBase = null) : void
		{
			if (_numIndices < 3) return;

			var vertexBuffer : VertexBuffer3D = getVertexBuffer(context3d);

			context3d.setProgram(getColorProgram(context3d));
			context3d.setVertexBufferAt(0, vertexBuffer, 0, Context3DVertexBufferFormat.FLOAT_2);
			context3d.setVertexBufferAt(1, vertexBuffer, 2, Context3DVertexBufferFormat.FLOAT_2);
			context3d.setVertexBufferAt(2, vertexBuffer, 4, Context3DVertexBufferFormat.FLOAT_4);
			context3d.setVertexBufferAt(3, vertexBuffer, 8, Context3DVertexBufferFormat.FLOAT_2);

			context3d.setTextureAt(0, _brushTexture);
			context3d.setTextureAt(1, canvas.heightSpecularMap);
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
			return 	"mov v0, va1\n"+
					"mov v1, va2\n" +
					"mov v2, va3\n" +
					"mov op, va0\n";
		}

		override protected function getColorFragmentCode() : String
		{
			return 	"tex ft0, v0, fs0 <2d, clamp, nearest, nomip>\n" +
					"tex ft1, v2, fs1 <2d, clamp, nearest, nomip>\n" +
					"mul oc, v1, ft0.x\n";
		}

		override protected function get topologyIndexType() : int
		{
			return FastBuffer.INDEX_MODE_TRIANGLESTRIP;
		}

		override protected function get numElementsPerVertex() : int
		{
			return 10;
		}
	}
}
