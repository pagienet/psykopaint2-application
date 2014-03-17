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
	
	public class SimulationQuadMesh extends AbstractBrushMesh implements SimulationMesh
	{
		public static const NO_UVS : int = 0;
		public static const BRUSH_TEXTURE_UVS : int = 1;
		public static const CANVAS_TEXTURE_UVS : int = 2;

		private static var _tmpData : Vector.<Number>;

		private var _subtractiveBlending : Boolean;

		public function SimulationQuadMesh(subtractiveBlending : Boolean = false)
		{
			super();

			if (!_tmpData)
				_tmpData = new Vector.<Number>(40, true);

			_subtractiveBlending = subtractiveBlending
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
			var colorsRGBA:Vector.<Number> =  appendVO.point.colorsRGBA;
			var halfSize : Number = appendVO.size * .5;
			var x : Number = appendVO.point.normalX;
			var y : Number = appendVO.point.normalY;
			var right : Number = x + halfSize;
			var bottom : Number = y + halfSize;
			var left : Number = x - halfSize;
			var top : Number = y - halfSize;

			if (right > _maxX) _maxX = right;
			else if (right < _minX) _minX = right;
			if (bottom > _maxY) _maxY = bottom;
			else if (bottom < _minY) _minY = bottom;
			if (left > _maxX) _maxX = left;
			else if (left < _minX) _minX = left;
			if (top > _maxY) _maxY = top;
			else if (top < _minY) _minY = top;

			_tmpData[0] = left;
			_tmpData[1] = top;
			_tmpData[2] = 0;
			_tmpData[3] = 0;
			_tmpData[4] = colorsRGBA[0];
			_tmpData[5] = colorsRGBA[1];
			_tmpData[6] = colorsRGBA[2];
			_tmpData[7] = colorsRGBA[3];
			_tmpData[8] = left * .5 + .5;
			_tmpData[9] = .5 - top * .5;


			_tmpData[10] = right;
			_tmpData[11] = top;
			_tmpData[12] = 1;
			_tmpData[13] = 0;
			_tmpData[14] = colorsRGBA[4];
			_tmpData[15] = colorsRGBA[5];
			_tmpData[16] = colorsRGBA[6];
			_tmpData[17] = colorsRGBA[7];
			_tmpData[18] = right * .5 + .5;
			_tmpData[19] = .5 - top * .5;

			_tmpData[20] = right;
			_tmpData[21] = bottom;
			_tmpData[22] = 1;
			_tmpData[23] = 1;
			_tmpData[24] = colorsRGBA[4];
			_tmpData[25] = colorsRGBA[5];
			_tmpData[26] = colorsRGBA[6];
			_tmpData[27] = colorsRGBA[7];
			_tmpData[28] = right * .5 + .5;
			_tmpData[29] = .5 - bottom * .5;

			_tmpData[30] = left;
			_tmpData[31] = bottom;
			_tmpData[32] = 0;
			_tmpData[33] = 1;
			_tmpData[34] = colorsRGBA[0];
			_tmpData[35] = colorsRGBA[1];
			_tmpData[36] = colorsRGBA[2];
			_tmpData[37] = colorsRGBA[3];
			_tmpData[38] = left * .5 + .5;
			_tmpData[39] = .5 - bottom * .5;


			_fastBuffer.addFloatsToVertices(_tmpData, _vIndex);
			_vIndex += 160;

			_numVertices += 4;
			_numIndices += 6;
		}

		override public function drawColor(context3d : Context3D, canvas : CanvasModel, source : TextureBase = null) : void
		{
			if (_numIndices < 6) return;

			var bounds : Rectangle = getBounds();
			var ratioX : Number = canvas.textureWidth / _bakedTexture.width;
			var ratioY : Number = canvas.textureHeight / _bakedTexture.height;
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
			return FastBuffer.INDEX_MODE_QUADS;
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
	}
}
