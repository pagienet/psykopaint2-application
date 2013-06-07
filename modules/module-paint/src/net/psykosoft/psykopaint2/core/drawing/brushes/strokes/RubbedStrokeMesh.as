package net.psykosoft.psykopaint2.core.drawing.brushes.strokes
{
	import flash.display3D.Context3D;
import flash.display3D.Context3DProgramType;
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

        private var _vertexData : Vector.<Number>;
        private var _fragmentData : Vector.<Number>;

        private var _dirX:Number;
        private var _dirY:Number;

		public function RubbedStrokeMesh(subtractiveBlending : Boolean = false)
		{
			super();

			if (!_tmpData)
				_tmpData = new Vector.<Number>(24, true);

			_subtractiveBlending = subtractiveBlending;

            _vertexData = Vector.<Number>([0, 0, 0, 0]);
            _fragmentData = Vector.<Number>([0,.1, 0, 0]);
		}

        public function setSurfaceRelief(value : Number) : void
        {
            _fragmentData[0] = value;
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
                _dirX = 0;
                _dirY = 0;
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
                var invNorm : Number;
                _dirX = point.normalX - _prevX;
                _dirY = _prevY - point.normalY;
                invNorm = Math.sqrt(_dirX * _dirX + _dirY * _dirY);

                if (invNorm > 0.0001) {
                    invNorm = 1 / invNorm;
                    _dirX *= invNorm;
                    _dirY *= invNorm;
                }

                normalX = point.normalY - _prevY;
				normalY = _prevX - point.normalX;
				invNorm = Math.sqrt(normalX * normalX + normalY * normalY);

				if (invNorm > 0.0001) {
                    invNorm = 1 / invNorm;
                    normalX *= invNorm;
                    normalY *= invNorm;
                }
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
			_tmpData[10] = _dirX;
			_tmpData[11] = _dirY;

			vx = appendVO.point.normalX - normalX * halfSize;
			vy = appendVO.point.normalY - normalY * halfSize;
			if (vx > _maxX) _maxX = vx;
			else if (vx < _minX) _minX = vx;
			if (vy > _maxY) _maxY = vy;
			else if (vy < _minY) _minY = vy;
			_tmpData[12] = vx;
			_tmpData[13] = vy;
			_tmpData[14] = u;
			_tmpData[15] = 1;

			_tmpData[16] = colorsRGBA[4];
			_tmpData[17] = colorsRGBA[5];
			_tmpData[18] = colorsRGBA[6];
			_tmpData[19] = colorsRGBA[7];
			_tmpData[20] = vx * .5 + .5;
			_tmpData[21] = .5 - vy * .5;
			_tmpData[22] = _dirX;
			_tmpData[23] = _dirY;


			_fastBuffer.addFloatsToVertices(_tmpData, _vIndex);
			_vIndex += 96;

			_numVertices += 2;
			if (_numVertices > 2) _numIndices += 6;
		}

		override public function drawColor(context3d : Context3D, canvas : CanvasModel, source : TextureBase = null) : void
		{
			if (_numIndices < 3) return;

			var vertexBuffer : VertexBuffer3D = getVertexBuffer(context3d);

            _vertexData[0] = 1/canvas.textureWidth;
            _vertexData[1] = 1/canvas.textureHeight;

			context3d.setProgram(getColorProgram(context3d));
			context3d.setProgramConstantsFromVector(Context3DProgramType.VERTEX, 0, _vertexData, 1);
			context3d.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 0, _fragmentData, 1);
			context3d.setVertexBufferAt(0, vertexBuffer, 0, Context3DVertexBufferFormat.FLOAT_2);
			context3d.setVertexBufferAt(1, vertexBuffer, 2, Context3DVertexBufferFormat.FLOAT_2);
			context3d.setVertexBufferAt(2, vertexBuffer, 4, Context3DVertexBufferFormat.FLOAT_4);
			context3d.setVertexBufferAt(3, vertexBuffer, 8, Context3DVertexBufferFormat.FLOAT_2);
			context3d.setVertexBufferAt(4, vertexBuffer, 10, Context3DVertexBufferFormat.FLOAT_2);  // stroke direction

			context3d.setTextureAt(0, _brushTexture);
			context3d.setTextureAt(1, canvas.heightSpecularMap);
			context3d.drawTriangles(getIndexBuffer(context3d), 0, _numIndices/3);

			context3d.setTextureAt(0, null);
			context3d.setTextureAt(1, null);

			context3d.setVertexBufferAt(0, null);
			context3d.setVertexBufferAt(1, null);
			context3d.setVertexBufferAt(2, null);
			context3d.setVertexBufferAt(3, null);
			context3d.setVertexBufferAt(4, null);
		}

		override protected function getColorVertexCode() : String
		{
			return 	"mov v0, va1\n"+
					"mov v1, va2\n" +
					"mov v2, va3\n" +
                    "add v3, va3, vc0.xzzz\n" +
                    "add v4, va3, vc0.zyzz\n" +
                    "mov v5, va4\n" +
                    "mov op, va0\n";
		}

		override protected function getColorFragmentCode() : String
		{
            // todo: perhaps add a vertex property for "paint amount", so we can fade out over time?
            // this is for example used by pencil for pressure
			return 	"tex ft0, v0, fs0 <2d, clamp, nearest, nomip>\n" +  // brush "amount"
					"tex ft2, v2, fs1 <2d, clamp, nearest, nomip>\n" +  // canvas height (center)
					"tex ft3, v3, fs1 <2d, clamp, nearest, nomip>\n" +  // canvas height (right)
					"tex ft4, v4, fs1 <2d, clamp, nearest, nomip>\n" +  // canvas height (left)

                    "sub ft1.x, ft3.x, ft2.x\n" +
                    "sub ft1.y, ft4.x, ft2.x\n" +
                    "mov ft1.z, fc0.w\n" +    // 0
                    "nrm ft1.xyz, ft1.xyz\n" +
                    "dp3 ft1.x, ft1.xyz, v5\n" +    // match with stroke direction (1 = opposite directions -> no deposit)
                    "add ft1.x, ft1.x, fc0.y\n" +
                    "mul ft1.x, ft1.x, fc0.x\n" +
                    "sat ft1.x, ft1.x\n" +   // don't allow all this negativism!

                    "sub ft0.x, ft0.x, ft1.x\n" +
                    "max ft0.x, ft0.x, fc0.w\n" +
					"mul oc, v1, ft0.x\n";
		}

		override protected function get topologyIndexType() : int
		{
			return FastBuffer.INDEX_MODE_TRIANGLESTRIP;
		}

		override protected function get numElementsPerVertex() : int
		{
			return 12;
		}
	}
}
