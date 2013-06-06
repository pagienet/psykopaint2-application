package net.psykosoft.psykopaint2.core.model
{

	import flash.display.BitmapData;
	import flash.display.Stage;
	import flash.display.Stage3D;
	import flash.display3D.Context3D;
	import flash.display3D.Context3DTextureFormat;
	import flash.display3D.textures.Texture;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;

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

		private var _sourceTexture : Texture;
		private var _fullSizeBackBuffer : Texture;
		private var _halfSizeBackBuffer : Texture;
		private var _colorTexture : Texture;
		private var _heightSpecularMap : Texture;	// RGB = slope, A = height, half sized

		private var _width : Number;
		private var _height : Number;

		private var _pyramidMap : PyramidMapTdsi;
		private var _textureWidth : Number;
		private var _textureHeight : Number;

		private var _viewport : Rectangle;
		private var _heightSpecularOriginal : BitmapData;

		public function CanvasModel()
		{

		}

		public function get pyramidMap() : PyramidMapTdsi
		{
			return _pyramidMap;
		}

		public function get heightSpecularMap() : Texture
		{
			return _heightSpecularMap;
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
			sourceBitmapData = fixSourceDimensions( sourceBitmapData );
			
			if (_pyramidMap)
				_pyramidMap.setSource(sourceBitmapData);
			else
				_pyramidMap = new PyramidMapTdsi(sourceBitmapData);

			if (_sourceTexture)
				_pyramidMap.uploadMipLevel(_sourceTexture, 0);
		}
		
		private function fixSourceDimensions(sourceBitmapData:BitmapData):BitmapData
		{
			// this is only required for the quickstart test where images are loaded in the wrong dimensions
			if ( sourceBitmapData.width != _textureWidth || sourceBitmapData.height != _textureHeight )
			{
				var tmpBmd:BitmapData = new BitmapData( _textureWidth,_textureHeight ,false,0xffffffff);
				var scl:Number = Math.max(textureWidth /  sourceBitmapData.width, textureHeight /  sourceBitmapData.height );
				
				var m:Matrix = new Matrix(scl,0,0,scl, 0.5 * (_textureWidth - sourceBitmapData.width*scl), 0.5 * (_textureHeight - sourceBitmapData.height*scl))
				tmpBmd.draw(sourceBitmapData,m,null,"normal",null,true);
				return tmpBmd;
			} else {
				return sourceBitmapData;
			}
		}
		
		public function setHeightSpecularMap(value : BitmapData) : void
		{
			_heightSpecularOriginal = value;

			// not sure if this will be called before or after post construct
			if (_heightSpecularMap)
				_heightSpecularMap.uploadFromBitmapData(value);
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
			_heightSpecularMap = createCanvasTexture(true);

			if (_heightSpecularOriginal) setHeightSpecularMap(_heightSpecularOriginal);

			var tempBitmapData : BitmapData = new BitmapData(_textureWidth, _textureHeight, true, 0);
			_colorTexture.uploadFromBitmapData(tempBitmapData);
			tempBitmapData.dispose();
		}

		public function createCanvasTexture(isRenderTarget : Boolean, scale : Number = 1) : Texture
		{
			return stage3D.context3D.createTexture(_textureWidth * scale, _textureHeight * scale, Context3DTextureFormat.BGRA, isRenderTarget, 0);
		}

		public function dispose() : void
		{
			if (!_colorTexture) return;
			if (_sourceTexture) _sourceTexture.dispose();
			if (_heightSpecularOriginal) _heightSpecularOriginal.dispose();
			_colorTexture.dispose();
			_fullSizeBackBuffer.dispose();
			_halfSizeBackBuffer.dispose();
			_heightSpecularMap.dispose();    	// storing height as well, you never know what we can use it for (raymarching for offline rendering \o/)
			_sourceTexture = null;
			_colorTexture = null;
			_fullSizeBackBuffer = null;
			_halfSizeBackBuffer = null;
			_heightSpecularMap = null;
			_heightSpecularOriginal = null;
		}

		public function swapColorLayer() : void
		{
			_colorTexture = swapFullSized(_colorTexture);
		}

		public function swapHeightSpecularLayer() : void
		{
			_heightSpecularMap = swapFullSized(_heightSpecularMap);
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
			var context3d : Context3D = stage3D.context3D;
			context3d.setRenderToTexture(_colorTexture);
			context3d.clear(0, 0, 0, 0);
			context3d.setRenderToBackBuffer();
		}

		public function clearNormalHeightTexture() : void
		{
			setHeightSpecularMap(_heightSpecularOriginal);
		}
	}
}
