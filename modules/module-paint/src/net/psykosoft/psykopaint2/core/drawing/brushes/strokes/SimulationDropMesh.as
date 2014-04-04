package net.psykosoft.psykopaint2.core.drawing.brushes.strokes
{
	import avm2.intrinsics.memory.si16;

	import flash.display3D.Context3D;
	import flash.display3D.Context3DVertexBufferFormat;
	import flash.display3D.VertexBuffer3D;
	import flash.display3D.textures.TextureBase;
	import flash.geom.Rectangle;

	import net.psykosoft.psykopaint2.core.configuration.CoreSettings;

	import net.psykosoft.psykopaint2.core.model.CanvasModel;
	import net.psykosoft.psykopaint2.core.rendering.BlendSubTextureCMYK;
	import net.psykosoft.psykopaint2.core.rendering.CopySubTexture;
	import net.psykosoft.psykopaint2.core.intrinsics.FastBuffer;

	import org.osflash.signals.Signal;

	public class SimulationDropMesh extends AbstractBrushMesh implements SimulationMesh
	{
		public static const NO_UVS : int = 0;
		public static const BRUSH_TEXTURE_UVS : int = 1;
		public static const CANVAS_TEXTURE_UVS : int = 2;

		private static const NUM_SEGMENTS : int = 20;
		private static const MAX_VERTICES:int = int(65535 / (NUM_SEGMENTS + 1)) * (NUM_SEGMENTS + 1);

		private static var _tmpData : Vector.<Number>;

		private var _subtractiveBlending : Boolean;
		private var _buffersFullSignal : Signal = new Signal();

		public function SimulationDropMesh(subtractiveBlending : Boolean = false)
		{
			super();

			if (!_tmpData)
				_tmpData = new Vector.<Number>((NUM_SEGMENTS + 1) * numElementsPerVertex, true);

			_subtractiveBlending = subtractiveBlending;
		}

		public function get buffersFullSignal():Signal
		{
			return _buffersFullSignal;
		}

		override public function customBlending() : Boolean
		{
			return _subtractiveBlending;
		}

		override public function append( appendVO:StrokeAppendVO ) : void
		{
			appendDrop(appendVO);
			invalidateBuffers();
			invalidateBounds();
		}

		private function appendDrop(appendVO : StrokeAppendVO) : void
		{
			if (_numVertices >= MAX_VERTICES) return;

			var colorsRGBA:Vector.<Number> =  appendVO.point.colorsRGBA;
			var halfSizeX : Number = appendVO.size * appendVO.point.size * .5;
			var halfSizeY : Number = halfSizeX * CoreSettings.ASPECT_RATIO;
			var centerX : Number = appendVO.point.normalX;
			var centerY : Number = appendVO.point.normalY;

			if (centerX + halfSizeX > _maxX) _maxX = centerX + halfSizeX;
			else if (centerX - halfSizeX < _minX) _minX = centerX - halfSizeX;
			if (centerY + halfSizeY > _maxY) _maxY = centerY + halfSizeY;
			else if (centerY - halfSizeY < _minY) _minY = centerY - halfSizeY;

			var index : int = 0;

			var segmentAngle : Number = Math.PI * 2 / NUM_SEGMENTS;
			var angle : Number = segmentAngle;

			_tmpData[index] = centerX;
			_tmpData[uint(index + 1)] = centerY;
			_tmpData[uint(index + 2)] = .5;
			_tmpData[uint(index + 3)] = 1;
			_tmpData[uint(index + 4)] = colorsRGBA[0];
			_tmpData[uint(index + 5)] = colorsRGBA[1];
			_tmpData[uint(index + 6)] = colorsRGBA[2];
			_tmpData[uint(index + 7)] = colorsRGBA[3];
			_tmpData[uint(index + 8)] = centerX * .5 + .5;
			_tmpData[uint(index + 9)] = .5 - centerY * .5;

			index += 10;

			for (var i : int = 0; i < NUM_SEGMENTS; ++i) {
				var x : Number = centerX + Math.cos(angle)*halfSizeX;
				var y : Number = centerY + Math.sin(angle)*halfSizeY;

				_tmpData[index] = x;
				_tmpData[uint(index + 1)] = y;
				_tmpData[uint(index + 2)] = .5;
				_tmpData[uint(index + 3)] = 0;
				_tmpData[uint(index + 4)] = colorsRGBA[4];
				_tmpData[uint(index + 5)] = colorsRGBA[5];
				_tmpData[uint(index + 6)] = colorsRGBA[6];
				_tmpData[uint(index + 7)] = colorsRGBA[7];
				_tmpData[uint(index + 8)] = x * .5 + .5;
				_tmpData[uint(index + 9)] = .5 - y * .5;
				angle += segmentAngle;
				index += 10;
			}

			_fastBuffer.addFloatsToVertices(_tmpData, _vIndex);
			_vIndex += index*4;

			_numVertices += NUM_SEGMENTS + 1;
			_numIndices += NUM_SEGMENTS*3;

			if (_numVertices >= MAX_VERTICES) {
				_buffersFullSignal.dispatch();
			}
		}

		override public function drawColor(context3d : Context3D, canvas : CanvasModel, source : TextureBase = null) : void
		{
			if (_numIndices < 6) return;

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
			if (_numIndices < 6) return;

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
			return FastBuffer.INDEX_MODE_CUSTOM;
		}

		override protected function get numElementsPerVertex() : int
		{
			return 10;
		}

		public function get stationaryTriangleCount():int
		{
			return 0;
		}

		public function appendStationary():void
		{
		}

		override protected function createIndices(offset:int):void
		{
			var i:int = 0;
			var centerIndex : int = 0;

			while (i < 87381) {
				for (var s : int = 1; s < NUM_SEGMENTS; ++s) {
					si16(centerIndex, offset);
					si16(centerIndex + s, offset + 2);
					si16(centerIndex + s + 1, offset + 4);
					offset += 6;
					if (++i >= 87381) return;
				}

				// closing segment:
				si16(centerIndex, offset);
				si16(centerIndex + NUM_SEGMENTS, offset + 2);
				si16(centerIndex + 1, offset + 4);
				offset += 6;
				++i;

				centerIndex += NUM_SEGMENTS + 1;
			}
		}
	}
}
