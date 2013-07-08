package net.psykosoft.psykopaint2.core.model
{

	import flash.display.BitmapData;
	import flash.display.BitmapDataChannel;
	import flash.display.Stage;
	import flash.display.Stage3D;
	import flash.display3D.Context3D;
	import flash.display3D.Context3DBlendFactor;
	import flash.display3D.Context3DTextureFormat;
	import flash.display3D.textures.Texture;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.ByteArray;
	import flash.utils.ByteArray;
	import flash.utils.Endian;

	import net.psykosoft.psykopaint2.base.utils.images.BitmapDataUtils;
	import net.psykosoft.psykopaint2.core.data.PaintingDataVO;

	import net.psykosoft.psykopaint2.core.rendering.CopySubTexture;
	import net.psykosoft.psykopaint2.core.rendering.CopySubTextureChannels;
	import net.psykosoft.psykopaint2.core.rendering.CopyTexture;

	import net.psykosoft.psykopaint2.core.signals.NotifyMemoryWarningSignal;
	import net.psykosoft.psykopaint2.core.utils.NormalSpecularMapGenerator;
	import net.psykosoft.psykopaint2.core.utils.TextureUtils;
	import net.psykosoft.psykopaint2.tdsi.PyramidMapTdsi;

	public class CanvasModel
	{
		[Inject]
		public var stage3D : Stage3D;

		[Inject]
		public var stage : Stage;

		[Inject]
		public var memoryWarningSignal : NotifyMemoryWarningSignal;

		private var _sourceTexture : Texture;
		private var _fullSizeBackBuffer : Texture;
		private var _halfSizeBackBuffer : Texture;
		private var _colorTexture : Texture;
		private var _normalSpecularMap : Texture;	// RGB = slope, A = height, half sized

		private var _width : Number;
		private var _height : Number;

		private var _pyramidMap : PyramidMapTdsi;
		private var _textureWidth : Number;
		private var _textureHeight : Number;

		private var _viewport : Rectangle;

		// TODO: should originals be a string path to packaged asset
		private var _normalSpecularOriginal : ByteArray;
		private var _colorBackgroundOriginal : BitmapData;

		private var _copySubTextureChannelsRGB : CopySubTextureChannels;
		private var _copySubTextureChannelsA : CopySubTextureChannels;

		public function CanvasModel()
		{

		}

		public function get pyramidMap() : PyramidMapTdsi
		{
			return _pyramidMap;
		}

		public function get normalSpecularMap() : Texture
		{
			return _normalSpecularMap;
		}

		public function get fullSizeBackBuffer() : Texture
		{
			return _fullSizeBackBuffer;
		}

		public function get halfSizeBackBuffer() : Texture
		{
			return _halfSizeBackBuffer;
		}

		[PostConstruct]
		public function postConstruct() : void
		{
			init(stage.stageWidth, stage.stageHeight);
			memoryWarningSignal.add(onMemoryWarning);
		}

		public function get viewport() : Rectangle
		{
			return _viewport;
		}

		public function get width() : Number
		{
			return _width;
		}

		public function get height() : Number
		{
			return _height;
		}

		public function get textureWidth() : Number
		{
			return _textureWidth;
		}

		public function get textureHeight() : Number
		{
			return _textureHeight;
		}

		public function get usedTextureWidthRatio() : Number
		{
			return _width / _textureWidth;
		}

		public function get usedTextureHeightRatio() : Number
		{
			return _height / _textureHeight;
		}

		public function setSourceBitmapData(sourceBitmapData : BitmapData) : void
		{
			sourceBitmapData = fixSourceDimensions(sourceBitmapData);

			if (_pyramidMap)
				_pyramidMap.setSource(sourceBitmapData);
			else
				_pyramidMap = new PyramidMapTdsi(sourceBitmapData);

			if (_sourceTexture)
				_pyramidMap.uploadMipLevel(_sourceTexture, 0);
		}

		private function fixSourceDimensions(sourceBitmapData : BitmapData) : BitmapData
		{
			// this is only required for the quickstart test where images are loaded in the wrong dimensions
			if (sourceBitmapData.width != _textureWidth || sourceBitmapData.height != _textureHeight) {
				var tmpBmd : BitmapData = new BitmapData(_textureWidth, _textureHeight, false, 0xffffffff);
				var scl : Number = Math.min(textureWidth / sourceBitmapData.width, textureHeight / sourceBitmapData.height);

				var m : Matrix = new Matrix(scl, 0, 0, scl, 0.5 * (_textureWidth - sourceBitmapData.width * scl), 0)
				tmpBmd.draw(sourceBitmapData, m, null, "normal", null, true);
				return tmpBmd;
			} else {
				return sourceBitmapData;
			}
		}

		public function setColorBackgroundOriginal(value : BitmapData) : void
		{
			if (_colorBackgroundOriginal) _colorBackgroundOriginal.dispose();
			_colorBackgroundOriginal = value;

			if (_colorTexture)
				uploadColorBackgroundOriginal();
		}

		/**
		 * A texture containing height and specular data. normals on red/blue channel, specular strength on z, glossiness on w
		 */
		public function setNormalSpecularMap(value : ByteArray) : void
		{
			if (_normalSpecularOriginal) _normalSpecularOriginal.clear();

			_normalSpecularOriginal = value;

			// not sure if this will be called before or after post construct
			if (_normalSpecularMap)
				uploadNormalSpecularOriginal();
		}

		public function get sourceTexture() : Texture
		{
			if (!_sourceTexture) initSourceTexture();
			return _sourceTexture;
		}

		private function initSourceTexture() : void
		{
			_sourceTexture = createCanvasTexture(false);
			_pyramidMap.uploadMipLevel(_sourceTexture, 0);
		}

		public function init(canvasWidth : uint, canvasHeight : uint) : void
		{
			if (canvasWidth == _width && canvasHeight == _height)
				return;

			dispose();
			_viewport = new Rectangle(0, 0, _width, _height);
			_width = canvasWidth;
			_height = canvasHeight;
			_textureWidth = TextureUtils.getBestPowerOf2(_width);
			_textureHeight = TextureUtils.getBestPowerOf2(_height);

			_colorTexture = createCanvasTexture(true);
			_fullSizeBackBuffer = createCanvasTexture(true);

			_halfSizeBackBuffer = createCanvasTexture(true, .5);
			_normalSpecularMap = createCanvasTexture(true);

			if (_normalSpecularOriginal) setNormalSpecularMap(_normalSpecularOriginal);
			uploadColorBackgroundOriginal();
		}

		public function createCanvasTexture(isRenderTarget : Boolean, scale : Number = 1) : Texture
		{
			return stage3D.context3D.createTexture(_textureWidth * scale, _textureHeight * scale, Context3DTextureFormat.BGRA, isRenderTarget, 0);
		}

		public function dispose() : void
		{
			if (!_colorTexture) return;
			if (_sourceTexture) _sourceTexture.dispose();
			_colorTexture.dispose();
			_fullSizeBackBuffer.dispose();
			_halfSizeBackBuffer.dispose();
			_normalSpecularMap.dispose();    	// storing height as well, you never know what we can use it for (raymarching for offline rendering \o/)
			_normalSpecularOriginal.clear();
			_colorBackgroundOriginal.dispose();
			_sourceTexture = null;
			_colorTexture = null;
			_fullSizeBackBuffer = null;
			_halfSizeBackBuffer = null;
			_normalSpecularMap = null;
			_normalSpecularOriginal = null;
			_colorBackgroundOriginal = null;
		}

		public function swapColorLayer() : void
		{
			_colorTexture = swapFullSized(_colorTexture);
		}

		public function swapNormalSpecularLayer() : void
		{
			_normalSpecularMap = swapFullSized(_normalSpecularMap);
		}

		public function swapFullSized(target : Texture) : Texture
		{
			var temp : Texture = target;
			target = _fullSizeBackBuffer;
			_fullSizeBackBuffer = temp;
			return target;
		}

		public function swapHalfSized(target : Texture) : Texture
		{
			var temp : Texture = target;
			target = _halfSizeBackBuffer;
			_halfSizeBackBuffer = temp;
			return target;
		}

		public function get colorTexture() : Texture
		{
			return _colorTexture;
		}

		private function onMemoryWarning() : void
		{
			// HAH! BE GONE WITH THEE UNTIL THOU ART NEEDED HENCEFORTH!
			if (_sourceTexture) {
				_sourceTexture.dispose();
				_sourceTexture = null;
			}
		}

		public function clearColorTexture() : void
		{
			uploadColorBackgroundOriginal();
		}

		private function uploadColorBackgroundOriginal() : void
		{
			var tempBitmapData : BitmapData = new BitmapData(_textureWidth, _textureHeight, true, 0);
			if (_colorBackgroundOriginal)
				tempBitmapData.draw(_colorBackgroundOriginal);
			_colorTexture.uploadFromBitmapData(tempBitmapData, 0);
			tempBitmapData.dispose();
		}

		public function clearNormalSpecularTexture() : void
		{
			uploadNormalSpecularOriginal();
		}

		private function uploadNormalSpecularOriginal() : void
		{
			var inflated : ByteArray = new ByteArray();
			_normalSpecularOriginal.position = 0;
			inflated.writeBytes(_normalSpecularOriginal, 0, _normalSpecularOriginal.length);
			inflated.uncompress();
			_normalSpecularMap.uploadFromByteArray(inflated, 0);
		}

		/**
		 * Returns a list of 3 ByteArrays containing data:
		 * 0: painted color layer, in BGRA
		 * 1: normal/specular layer, in BGRA
		 * 2: the source texture, in RGBA!!! (because it's always used primarily as BitmapData)
		 */
		public function exportPaintingData() : PaintingDataVO
		{
			var paintingData : PaintingDataVO = new PaintingDataVO();
			stage3D.context3D.setBlendFactors(Context3DBlendFactor.ONE, Context3DBlendFactor.ZERO);
			var bmp : BitmapData = new BitmapData(_width, _height, false);
			var bmp2 : BitmapData = new BitmapData(_width, _height, false);

			paintingData.width = _width;
			paintingData.height = _height;
			paintingData.colorData = saveLayerWithAlpha(_colorTexture, bmp, bmp2);
			paintingData.normalSpecularData = saveLayerWithAlpha(_normalSpecularMap, bmp, bmp2);
			paintingData.sourceBitmapData = saveLayerNoAlpha(sourceTexture, bmp);

			bmp.dispose();
			bmp2.dispose();
			return paintingData;
		}

		private function saveLayerNoAlpha(layer : Texture, workerBitmapData : BitmapData) : ByteArray
		{
			var context : Context3D = stage3D.context3D;
			var sourceRect : Rectangle = new Rectangle(0, 0, usedTextureWidthRatio, usedTextureHeightRatio);
			var destRect : Rectangle = new Rectangle(0, 0, 1, 1);

			context.setRenderToBackBuffer();
			context.clear(0, 0, 0, 0);
			context.setBlendFactors(Context3DBlendFactor.ONE, Context3DBlendFactor.ZERO);
			CopySubTexture.copy(layer, sourceRect, destRect, context);
			context.drawToBitmapData(workerBitmapData);
			return workerBitmapData.getPixels(workerBitmapData.rect);
		}

		private function saveLayerWithAlpha(layer : Texture, workerBitmapData1 : BitmapData, workerBitmapData2 : BitmapData) : ByteArray
		{
			var context : Context3D = stage3D.context3D;
			var sourceRect : Rectangle = new Rectangle(0, 0, usedTextureWidthRatio, usedTextureHeightRatio);
			var destRect : Rectangle = new Rectangle(0, 0, 1, 1);

			_copySubTextureChannelsRGB ||= new CopySubTextureChannels("xyz", "xyz");
			_copySubTextureChannelsA ||= new CopySubTextureChannels("w", "z");

			context.setRenderToBackBuffer();
			context.setBlendFactors(Context3DBlendFactor.ONE, Context3DBlendFactor.ZERO);

			context.clear(0, 0, 0, 1);
			_copySubTextureChannelsRGB.copy(layer, sourceRect, destRect, context);
			context.drawToBitmapData(workerBitmapData1);

			context.clear(0, 0, 0, 1);
			_copySubTextureChannelsA.copy(layer, sourceRect, destRect, context);
			context.drawToBitmapData(workerBitmapData2);

			var rgbData : ByteArray = workerBitmapData1.getPixels(workerBitmapData1.rect);
			var alphaData : ByteArray = workerBitmapData2.getPixels(workerBitmapData2.rect);

			rgbData.position = 0;
			alphaData.position = 0;
			var outputData : ByteArray = new ByteArray();

			var len : int = _width * _height;
			for (var i : int = 0; i < len; ++i) {
				var rgb : uint = rgbData.readUnsignedInt();
				var r : uint = rgb & 0x00ff0000;
				var g : uint = rgb & 0x0000ff00;
				var b : uint = rgb & 0x000000ff;
				var a : uint = alphaData.readUnsignedInt() & 0x000000ff;

				outputData.writeUnsignedInt((r >> 8) | (g << 8) | (b << 24) | a);
			}

			return outputData;
		}

		public function importPaintingData(paintingData : PaintingDataVO) : void
		{
			if (_width != paintingData.width || _height != paintingData.height)
				throw new Error("Different painting sizes currently not supported!");

			var oldLength : int = paintingData.colorData.length;
			var newLength : int = _textureWidth * _textureHeight * 4;
			paintingData.colorData.length = newLength;
			paintingData.normalSpecularData.length = newLength;
			_colorTexture.uploadFromByteArray(paintingData.colorData, 0, 0);
			_normalSpecularMap.uploadFromByteArray(paintingData.normalSpecularData, 0, 0);
			paintingData.colorData.length = oldLength;
			paintingData.normalSpecularData.length = oldLength;

			var sourceBmd : BitmapData = BitmapDataUtils.getBitmapDataFromBytes(paintingData.sourceBitmapData, _width, _height, false);
			setSourceBitmapData(sourceBmd);
			sourceBmd.dispose();
		}

		// TODO: probably very slow, find alternative - note: david has altered this to be faster, but probably still need to do this outside of as3
		private function translateARGBtoBGRA(input : ByteArray) : ByteArray
		{
			input.position = 0;
			var output : ByteArray = new ByteArray();
			var len : int = input.length / 4;
			var i : int = 0;

			input.endian = Endian.BIG_ENDIAN;
			output.endian = Endian.LITTLE_ENDIAN;

			while (i++ < len)
				output.writeUnsignedInt(input.readUnsignedInt());

			output.length = _textureWidth * _textureHeight * 4;

			return output;
		}
	}
}
