package net.psykosoft.psykopaint2.core.model
{

	import flash.display.BitmapData;
	import flash.display.Stage;
	import flash.display.Stage3D;
	import flash.display3D.Context3D;
	import flash.display3D.Context3DTextureFormat;
	import flash.display3D.textures.Texture;
	import flash.filters.BlurFilter;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.ByteArray;

	import net.psykosoft.psykopaint2.base.utils.misc.TrackedBitmapData;
	import net.psykosoft.psykopaint2.base.utils.misc.TrackedTexture;
	import net.psykosoft.psykopaint2.core.configuration.CoreSettings;
	import net.psykosoft.psykopaint2.core.signals.NotifyMemoryWarningSignal;
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

		private var _sourceTexture : TrackedTexture;
		private var _fullSizeBackBuffer : TrackedTexture;
		private var _colorTexture : TrackedTexture;
		private var _normalSpecularMap : TrackedTexture;	// RGB = slope, A = height, half sized

		private var _width : Number;
		private var _height : Number;

		private var _pyramidMap : PyramidMapTdsi;
		private var _textureWidth : Number;
		private var _textureHeight : Number;

		// TODO: should originals be a string path to packaged asset?
		private var _normalSpecularOriginal : ByteArray;
		private var _colorBackgroundOriginal : ByteArray;

		public function CanvasModel()
		{

		}

		public function get pyramidMap() : PyramidMapTdsi
		{
			return _pyramidMap;
		}

		public function get normalSpecularMap() : Texture
		{
			return _normalSpecularMap.texture;
		}

		public function get fullSizeBackBuffer() : Texture
		{
			return _fullSizeBackBuffer.texture;
		}

		[PostConstruct]
		public function postConstruct() : void
		{
			init(CoreSettings.STAGE_WIDTH, CoreSettings.STAGE_HEIGHT);
			memoryWarningSignal.add(onMemoryWarning);
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
			if (!sourceBitmapData) {
				if (_pyramidMap) {
					_pyramidMap.dispose();
					_pyramidMap = null;
				}
				return;
			}

			// TODO: this is not ideal since in wastes 25% memory by making a square bitmap
			// if we ever need to free some memory this is a good place to start digging.
			var fixed : BitmapData = fixSourceDimensions(sourceBitmapData);
			
			if (_pyramidMap)
				_pyramidMap.setSource(fixed);
			else
				_pyramidMap = new PyramidMapTdsi(fixed);

			if (_sourceTexture)
				_pyramidMap.uploadMipLevel(_sourceTexture.texture, 0);

			fixed.dispose();
		}

		private function fixSourceDimensions(sourceBitmapData : BitmapData) : BitmapData
		{
			// this is only required for the quickstart test where images are loaded in the wrong dimensions
			if (sourceBitmapData.width != _textureWidth || sourceBitmapData.height != _textureHeight) {
				var tmpBmd : BitmapData = new TrackedBitmapData(_textureWidth, _textureHeight, false, 0xffffffff);
				var scl : Number = Math.min(textureWidth / sourceBitmapData.width, textureHeight / sourceBitmapData.height);

				var m : Matrix = new Matrix(scl, 0, 0, scl, 0.5 * (_textureWidth - sourceBitmapData.width * scl), 0);
				
				tmpBmd.draw(sourceBitmapData, m, null, "normal", null, true);
				
				// This part fills the lower quarter of the texture with the lowest pixel line of the source in order to avoid white bleeding when painting
				// currently this assumes that the incoming source is landscape
				// TODO: fix it for portrait format images 
				var tmpBmd2:BitmapData = new BitmapData(_textureWidth,1,false,0);
				tmpBmd2.copyPixels(tmpBmd,new Rectangle(0,int( scl * sourceBitmapData.height-2),_textureWidth,1),new Point());
				tmpBmd.draw(tmpBmd2, new Matrix(1,0,0,_textureHeight - scl * sourceBitmapData.height,0,int( scl * sourceBitmapData.height-1)), null, "normal", null,false);
				
				
				return tmpBmd;
			} else {
				return sourceBitmapData;
			}
		}

		public function setColorBackgroundOriginal(value : ByteArray) : void
		{
			if (_colorBackgroundOriginal) _colorBackgroundOriginal.clear();

			if (value)
				_colorBackgroundOriginal = value;
			else
				_colorBackgroundOriginal = null;
		}

		public function get sourceTexture() : Texture
		{
			if (!_pyramidMap) return null;
			if (!_sourceTexture) initSourceTexture();
			return _sourceTexture.texture;
		}

		private function initSourceTexture() : void
		{
			_sourceTexture = createCanvasTexture(false);
			_pyramidMap.uploadMipLevel(_sourceTexture.texture, 0);
		}

		public function init(canvasWidth : uint, canvasHeight : uint) : void
		{
			if (canvasWidth == _width && canvasHeight == _height)
				return;

			dispose();
			_width = canvasWidth;
			_height = canvasHeight;
			_textureWidth = TextureUtils.getBestPowerOf2(_width);
			_textureHeight = TextureUtils.getBestPowerOf2(_height);
		}

		public function createPaintTextures() : void
		{
			trace ("Creating paint textures");
			if (!_colorTexture)
				_colorTexture = createCanvasTexture(true);

			if (!_normalSpecularMap)
				_normalSpecularMap = createCanvasTexture(true);

			if (!_fullSizeBackBuffer)
				_fullSizeBackBuffer = createCanvasTexture(true);
		}

		public function setNormalSpecularOriginal(value : ByteArray) : void
		{
			if (_normalSpecularOriginal)
				_normalSpecularOriginal.clear();

			_normalSpecularOriginal = value;
		}

		public function disposePaintTextures() : void
		{
			trace ("Disposing paint textures");
			if (_colorTexture) _colorTexture.dispose();
			if (_fullSizeBackBuffer) _fullSizeBackBuffer.dispose();
			if (_normalSpecularMap) _normalSpecularMap.dispose();
			if (_sourceTexture) _sourceTexture.dispose();
			if (_normalSpecularOriginal) _normalSpecularOriginal.clear();
			if (_colorBackgroundOriginal) _colorBackgroundOriginal.clear();
			_colorTexture = null;
			_fullSizeBackBuffer = null;
			_normalSpecularMap = null;
			_sourceTexture = null;
			_normalSpecularOriginal = null;
			_colorBackgroundOriginal = null;
		}

		public function createCanvasTexture(isRenderTarget : Boolean, scale : Number = 1) : TrackedTexture
		{
			return new TrackedTexture(stage3D.context3D.createTexture(_textureWidth * scale, _textureHeight * scale, Context3DTextureFormat.BGRA, isRenderTarget, 0));
		}

		public function dispose() : void
		{
			disposePaintTextures();
		}

		public function swapColorLayer() : void
		{
			_colorTexture = swapFullSized(_colorTexture);
		}

		public function swapNormalSpecularLayer() : void
		{
			_normalSpecularMap = swapFullSized(_normalSpecularMap);
		}

		public function swapFullSized(target : TrackedTexture) : TrackedTexture
		{
			var temp : TrackedTexture = target;
			target = _fullSizeBackBuffer;
			_fullSizeBackBuffer = temp;
			return target;
		}

		public function get colorTexture() : Texture
		{
			return _colorTexture.texture;
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
			if (_colorBackgroundOriginal)
				uploadColorBackgroundOriginal();
			else {
				var context : Context3D = stage3D.context3D;
				context.setRenderToTexture(_colorTexture.texture);
				context.clear(0, 0, 0, 0);
				context.setRenderToBackBuffer();
			}
		}

		private function uploadColorBackgroundOriginal() : void
		{
			var oldLen : int = _colorBackgroundOriginal.length;
			_colorBackgroundOriginal.length = _textureWidth * _textureHeight * 4;
			_colorTexture.texture.uploadFromByteArray(_colorBackgroundOriginal, 0);
			_colorBackgroundOriginal.length = oldLen;
		}

		public function clearNormalSpecularTexture() : void
		{
			uploadNormalSpecularOriginal();
		}

		private function uploadNormalSpecularOriginal() : void
		{
			var oldLen : int = _normalSpecularOriginal.length;
			_normalSpecularOriginal.length = _textureWidth * _textureHeight * 4;
			_normalSpecularMap.texture.uploadFromByteArray(_normalSpecularOriginal, 0);
			_normalSpecularOriginal.length = oldLen;
		}

		public function getColorBackgroundOriginal() : ByteArray
		{
			return _colorBackgroundOriginal;
		}

		public function getNormalSpecularOriginal() : ByteArray
		{
			return _normalSpecularOriginal;
		}

		public function hasSourceImage() : Boolean
		{
			return _pyramidMap != null;
		}
	}
}
