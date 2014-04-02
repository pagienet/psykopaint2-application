package net.psykosoft.psykopaint2.core.drawing.brushes.strokes
{
	import flash.display3D.Context3D;
	import flash.display3D.Context3DVertexBufferFormat;
	import flash.display3D.VertexBuffer3D;
	import flash.display3D.textures.TextureBase;
	import flash.geom.Rectangle;
	
	import net.psykosoft.psykopaint2.core.drawing.paths.SamplePoint;
	import net.psykosoft.psykopaint2.core.model.CanvasModel;
	import net.psykosoft.psykopaint2.core.rendering.BlendSubTextureCMYK;
	import net.psykosoft.psykopaint2.core.rendering.CopySubTexture;
	import net.psykosoft.psykopaint2.core.intrinsics.FastBuffer;

	import org.osflash.signals.Signal;

	public class SimulationRibbonMesh extends AbstractBrushMesh implements SimulationMesh
	{
		public static const NO_UVS : int = 0;
		public static const BRUSH_TEXTURE_UVS : int = 1;
		public static const CANVAS_TEXTURE_UVS : int = 2;

		private static const MAX_VERTICES:int = 65532;

		private static var _tmpData : Vector.<Number>;

		private var _subtractiveBlending : Boolean;

		private var _prevX : Number;
		private var _prevY : Number;
		private var _prevNormalX : Number;
		private var _prevNormalY : Number;
		private var _prevAppendVO : StrokeAppendVO;
		private var _stationaryTriangleCount : int;

		private var _buffersFullSignal : Signal = new Signal();

		public function SimulationRibbonMesh(subtractiveBlending : Boolean = false)
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
			appendRibbon(appendVO);

			invalidateBuffers();
			invalidateBounds();
		}

		private function appendRibbon(appendVO:StrokeAppendVO):void
		{
			_stationaryTriangleCount = 0;
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

			_prevX = point.normalX;
			_prevY = point.normalY;
			_prevNormalX = normalX;
			_prevNormalY = normalY;
			_prevAppendVO = appendVO;
		}

		public function appendStationary() : void
		{
			const numSegments : int = 7;
			//TODO I ran into a case when doing a single click and no motion that sometimes _prevAppendVO is null.
			// this check patches it:
			if ( _prevAppendVO )
			{
				_stationaryTriangleCount = numSegments*2;
				appendConnection(_prevNormalX, _prevNormalY, -_prevNormalX, -_prevNormalY, _prevAppendVO, numSegments);
				_prevNormalX = -_prevNormalX;
				_prevNormalY = -_prevNormalY;
			}
			invalidateBuffers();
			invalidateBounds();
		}

		public function get stationaryTriangleCount() : int
		{
			return _stationaryTriangleCount;
		}

		private function appendConnection(startNormalX : Number, startNormalY : Number, endNormalX : Number, endNormalY : Number, appendVO : StrokeAppendVO, numSegments : uint) : void
		{
			// not slerping because angle between normals isn't always the correct value
			var startAngle : Number = Math.atan2(startNormalY, startNormalX);
			var endAngle : Number = Math.atan2(endNormalY, endNormalX);

			for (var i : int = 1; i <= numSegments +1; ++i) {
				var t : Number = i / numSegments;
				var angle : Number = startAngle + t * (endAngle - startAngle);

				var interpNormalX : Number = Math.cos(angle);
				var interpNormalY : Number = Math.sin(angle);

				appendSegment(_prevX, _prevY, appendVO, interpNormalX, interpNormalY);
			}
		}

		private function appendSegment(x : Number, y : Number, appendVO : StrokeAppendVO, normalX : Number, normalY : Number) : void
		{
			if (_numVertices >= MAX_VERTICES) return;

			var colorsRGBA:Vector.<Number> =  appendVO.point.colorsRGBA;
			var halfSize : Number = appendVO.size * .5;
			var vx : Number = x + normalX * halfSize;
			var vy : Number = y + normalY * halfSize;
			if (vx > _maxX) _maxX = vx;
			else if (vx < _minX) _minX = vx;
			if (vy > _maxY) _maxY = vy;
			else if (vy < _minY) _minY = vy;
			_tmpData[0] = vx;
			_tmpData[1] = vy;
			_tmpData[2] = .5;
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
			_tmpData[12] = .5;
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

			if (_numVertices >= 65532)	// = int(65535 / 6) * 6
				_buffersFullSignal.dispatch();
		}

		override public function drawColor(context3d : Context3D, canvas : CanvasModel, source : TextureBase = null) : void
		{
			if (_numIndices < 3) return;

			var bounds : Rectangle = getBounds();
			var ratioX : Number = canvas.width / _bakedTexture.width;
			var ratioY : Number = canvas.height / _bakedTexture.height;
			var sourceRect : Rectangle = new Rectangle(0, 0, bounds.width * ratioX, bounds.height * ratioY);

			if (_subtractiveBlending) {
				// todo: rewrite BlendSubTextureCMYK.copy to match CopySubTexture
				// local maxima in texture
				BlendSubTextureCMYK.copy(_bakedTexture.texture, context3d, source, bounds, ratioX, ratioY);
			}
			else
				CopySubTexture.copy(_bakedTexture.texture, sourceRect, bounds, context3d);
		}

		public function drawMesh(context3d : Context3D, uvMode : int, numTriangles : int = -1, useColor : Boolean = true, offset : int = 0) : void
		{
			if (_numIndices < 3) return;

			if (numTriangles < 0) numTriangles = _numIndices / 3 - offset;

			var vertexBuffer : VertexBuffer3D = getVertexBuffer(context3d);
			context3d.setVertexBufferAt(0, vertexBuffer, 0, Context3DVertexBufferFormat.FLOAT_2);
			if (uvMode != NO_UVS) context3d.setVertexBufferAt(1, vertexBuffer, (uvMode & BRUSH_TEXTURE_UVS) ? 2 : 8, Context3DVertexBufferFormat.FLOAT_2);
			if (uvMode == (BRUSH_TEXTURE_UVS | CANVAS_TEXTURE_UVS))
				context3d.setVertexBufferAt(3, vertexBuffer, 8, Context3DVertexBufferFormat.FLOAT_2);
			if (useColor) context3d.setVertexBufferAt(2, vertexBuffer, 4, Context3DVertexBufferFormat.FLOAT_4);
			context3d.drawTriangles(getIndexBuffer(context3d), offset * 3, numTriangles);
			context3d.setVertexBufferAt(0, null);
			context3d.setVertexBufferAt(1, null);
			context3d.setVertexBufferAt(2, null);
			context3d.setVertexBufferAt(3, null);
		}


		override protected function getColorVertexCode() : String
		{
			return "mov op, va0\n" +
					"mov v0, va1\n" +
					"mov v1, va2\n";
		}

		override protected function getColorFragmentCode() : String
		{
			return "tex ft0, v0, fs0 <2d, clamp, linear, mipnone>\n" +
					"mov ft1, v1\n" +	// apply colour
				// due to precision limitations in the merger state, we need to premultiply alpha in the shader
					"mul ft1.xyz, ft1.xyz, v1.w\n" +
					"mul ft1, ft1, ft0.w\n" +
					"mov oc, ft1\n";	// apply colour
		}

		override protected function get topologyIndexType() : int
		{
			return FastBuffer.INDEX_MODE_TRIANGLESTRIP;
		}

		override protected function get numElementsPerVertex() : int
		{
			return 10;
		}

		public function get buffersFullSignal():Signal
		{
			return _buffersFullSignal;
		}
	}
}
