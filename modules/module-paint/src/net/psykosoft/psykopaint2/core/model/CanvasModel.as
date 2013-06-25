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
	import flash.utils.ByteArray;
	import flash.utils.ByteArray;

	import net.psykosoft.psykopaint2.core.rendering.CopySubTexture;

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
		private var _normalSpecularOriginal : ByteArray;

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
				var scl:Number = Math.min(textureWidth /  sourceBitmapData.width, textureHeight /  sourceBitmapData.height );
				
				var m:Matrix = new Matrix(scl,0,0,scl, 0.5 * (_textureWidth - sourceBitmapData.width*scl), 0)
				tmpBmd.draw(sourceBitmapData,m,null,"normal",null,true);
				return tmpBmd;
			} else {
				return sourceBitmapData;
			}
		}

		/**
		 * A texture containing height and specular data. normals on red/blue channel, specular strength on z, glossiness on w
		 */
		public function setNormalSpecularMap(value : ByteArray) : void
		{
			_normalSpecularOriginal = value;

			// not sure if this will be called before or after post construct
			if (_normalSpecularMap) {
				var inflated : ByteArray = new ByteArray();
				value.position = 0;
				inflated.writeBytes(value, 0, value.length);
				inflated.uncompress();
				_normalSpecularMap.uploadFromByteArray(inflated, 0);
			}
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
			_colorTexture.dispose();
			_fullSizeBackBuffer.dispose();
			_halfSizeBackBuffer.dispose();
			_normalSpecularMap.dispose();    	// storing height as well, you never know what we can use it for (raymarching for offline rendering \o/)
			_sourceTexture = null;
			_colorTexture = null;
			_fullSizeBackBuffer = null;
			_halfSizeBackBuffer = null;
			_normalSpecularMap = null;
			_normalSpecularOriginal = null;
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
			var context3d : Context3D = stage3D.context3D;
			context3d.setRenderToTexture(_colorTexture);
			context3d.clear(0, 0, 0, 0);
			context3d.setRenderToBackBuffer();
		}

		public function clearNormalSpecularTexture() : void
		{
			_normalSpecularMap.uploadFromByteArray(_normalSpecularOriginal, 0);
		}


		/**
		 * Returns a list of 3 ByteArrays containing data:
		 * 0: painted color layer
		 * 1: normal/specular layer
		 * 2: the source texture
		 *
		 * IMPORTANT: THE DATA IS SAVED IN ARGB ORDER - UNLIKE THE LOAD ORDER
		 */
		public function saveLayersARGB(): Vector.<ByteArray>
		{
			var bmp : BitmapData = new BitmapData(_width, _height, true);
			var layers : Vector.<ByteArray> = new Vector.<ByteArray>();
			layers.push(saveLayer(_colorTexture, bmp));
			layers.push(saveLayer(_normalSpecularMap, bmp));
			layers.push(saveLayer(sourceTexture, bmp));
			bmp.dispose();
			return layers;
		}

		// IMPORTANT, DATA INPUT MUST BE IN BGRA ORDER TO AVOID PRE-MULTIPLICATION ISSUES.
		// Conversion is not done here to allow fast native conversion
		public function loadLayersBGRA(data : Vector.<ByteArray>) : void
		{
			_colorTexture.uploadFromByteArray(data[0], 0, 0);
			_normalSpecularMap.uploadFromByteArray(data[1], 0, 0);
			sourceTexture.uploadFromByteArray(data[2], 0, 0);
		}

		private function saveLayer(layer : Texture, workerBitmapData : BitmapData) : ByteArray
		{
			var data : ByteArray = new ByteArray();
			var context : Context3D = stage3D.context3D;
			var sourceRect : Rectangle = new Rectangle(0, 0, usedTextureWidthRatio, usedTextureHeightRatio);
			var destRect : Rectangle = new Rectangle(0, 0, 1, 1);

			context.setRenderToBackBuffer();
			context.clear();
			CopySubTexture.copy(layer, sourceRect, destRect, context);
			context.drawToBitmapData(workerBitmapData);
			workerBitmapData.copyPixelsToByteArray(workerBitmapData.rect, data);
			return data;
		}
	}
}
