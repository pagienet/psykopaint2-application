package net.psykosoft.psykopaint2.core.model
{

	import com.quasimondo.color.RGBProximityQuantizer;
	
	import flash.display.BitmapData;
	import flash.display.Stage;
	import flash.display.Stage3D;
	import flash.display3D.Context3D;
	import flash.display3D.Context3DTextureFormat;
	import flash.display3D.textures.RectangleTexture;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.ByteArray;
	
	import net.psykosoft.psykopaint2.base.utils.misc.TrackedBitmapData;
	import net.psykosoft.psykopaint2.base.utils.misc.TrackedRectTexture;
	import net.psykosoft.psykopaint2.core.configuration.CoreSettings;
	import net.psykosoft.psykopaint2.core.data.SurfaceDataVO;
	import net.psykosoft.psykopaint2.core.drawing.colortransfer.ColorTransfer;
	import net.psykosoft.psykopaint2.core.intrinsics.PyramidMapIntrinsics;
	import net.psykosoft.psykopaint2.core.signals.NotifyMemoryWarningSignal;

	public class CanvasModel
	{
		[Inject]
		public var stage3D : Stage3D;

		[Inject]
		public var stage : Stage;

		[Inject]
		public var memoryWarningSignal : NotifyMemoryWarningSignal;

		private var _sourceTexture : TrackedRectTexture;		// used during export (rendering)
		private var _fullSizeBackBuffer : TrackedRectTexture;	// used during export (rendering)
		private var _colorTexture : TrackedRectTexture;			// used during export (rendering)
		private var _normalSpecularMap : TrackedRectTexture;	// RGB = slope, A = height, half sized
		
		private var _width : Number;
		private var _height : Number;

		private var _pyramidMap : PyramidMapIntrinsics;
		private var _colorTransfer : ColorTransfer;
		
		

		// TODO: should originals be a string path to packaged asset?
		//MATHIEU: WHO DID THIS COMMENT? WOULD BE GREAT TO KNOW WHOM.
		private var _normalSpecularOriginal : BitmapData;		// used during export (reference)
		private var _colorBackgroundOriginal : ByteArray;
		// used during export (reference)
		
		//MATHIEU ADDED THIS. NEED TO FINISH
		private var _surfacedataVO:SurfaceDataVO;

		public function CanvasModel()
		{

		}

	

		public function get surfacedataVO():SurfaceDataVO
		{
			return _surfacedataVO;
		}

		public function get surfaceID():int
		{
			return _surfacedataVO.id;
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

		public function setSourceBitmapData(sourceBitmapData : BitmapData) : void
		{
			if (!sourceBitmapData) {
				sourceBitmapData = new TrackedBitmapData(1024,768,false,0xffffffff);
			}

			var fixed : BitmapData = fixSourceDimensions(sourceBitmapData);
			
			if (_pyramidMap)
				_pyramidMap.setSource(fixed);
			else
				_pyramidMap = new PyramidMapIntrinsics(fixed);

			if (!_sourceTexture) _sourceTexture = createCanvasTexture(false);
			_sourceTexture.texture.uploadFromBitmapData(fixed);

			
			fixed.dispose();
			
			//setTimeout(initColorTransfer,5);
		}
		
		private function initColorTransfer():void
		{
			//TODO: This a temporary test and will be replaced later:
			_colorTransfer = new ColorTransfer();
			_colorTransfer.setTargetFromPyramidMap(_pyramidMap);
		}

		private function fixSourceDimensions(sourceBitmapData : BitmapData) : BitmapData
		{
			// this is only required for the quickstart test where images are loaded in the wrong dimensions
			if (sourceBitmapData.width != _width || sourceBitmapData.height != _height) {
				var tmpBmd : BitmapData = new TrackedBitmapData(_width, _height, false, 0xffffffff);
				var scl : Number = Math.min(_width / sourceBitmapData.width, _height / sourceBitmapData.height);

				var m : Matrix = new Matrix(scl, 0, 0, scl, 0.5 * (_width - sourceBitmapData.width * scl), 0);
				
				tmpBmd.draw(sourceBitmapData, m, null, "normal", null, true);
				
				// This part fills the lower quarter of the texture with the lowest pixel line of the source in order to avoid white bleeding when painting
				// currently this assumes that the incoming source is landscape
				// TODO: fix it for portrait format images 
				var tmpBmd2:BitmapData = new BitmapData(_width,1,false,0);
				tmpBmd2.copyPixels(tmpBmd,new Rectangle(0,int( scl * sourceBitmapData.height-2),_width,1),new Point());
				tmpBmd.draw(tmpBmd2, new Matrix(1,0,0,_height - scl * sourceBitmapData.height,0,int( scl * sourceBitmapData.height-1)), null, "normal", null,false);
				tmpBmd2.dispose();
				sourceBitmapData.dispose();
				
				return tmpBmd;
			} else {
				return sourceBitmapData;
			}
		}


		public function get pyramidMap() : PyramidMapIntrinsics
		{
			return _pyramidMap;
		}

		public function get normalSpecularMap() : RectangleTexture
		{
			return _normalSpecularMap.texture;
		}

		public function get fullSizeBackBuffer() : RectangleTexture
		{
			if (!_fullSizeBackBuffer)
				_fullSizeBackBuffer = createCanvasTexture(true);
			return _fullSizeBackBuffer.texture;
		}

		public function get sourceTexture() : RectangleTexture
		{
			return _sourceTexture? _sourceTexture.texture : null;
		}

		public function get colorTexture() : RectangleTexture
		{
			return _colorTexture.texture;
		}

		public function init(canvasWidth : uint, canvasHeight : uint) : void
		{
			if (canvasWidth == _width && canvasHeight == _height)
				return;

			dispose();
			_width = canvasWidth;
			_height = canvasHeight;
		}

		public function createPaintTextures() : void
		{
			trace ("Creating paint textures");
			if (!_colorTexture)
				_colorTexture = createCanvasTexture(true);

			if (!_normalSpecularMap)
				_normalSpecularMap = createCanvasTexture(true);
		}
		
		public function setSurfaceDataVO(dataVO:SurfaceDataVO):void
		{
			this._surfacedataVO = dataVO;
			
			setNormalSpecularOriginal(dataVO.normalSpecular);
			setColorBackgroundOriginal(dataVO.color);
			
		}
		
		private function setNormalSpecularOriginal(value : BitmapData) : void
		{
			if (_normalSpecularOriginal && _normalSpecularOriginal != value)
				_normalSpecularOriginal.dispose();

			_normalSpecularOriginal = value;
		}
		
		
		private function setColorBackgroundOriginal(value : ByteArray) : void
		{
		if (_colorBackgroundOriginal) _colorBackgroundOriginal.clear();
		
		if (value)
		_colorBackgroundOriginal = value;
		else
		_colorBackgroundOriginal = null;
		}

		public function createCanvasTexture(isRenderTarget : Boolean, scale : Number = 1) : TrackedRectTexture
		{
			var width : int = _width * scale;
			var height : int = _height * scale;
			var texture : RectangleTexture = stage3D.context3D.createRectangleTexture(width, height, Context3DTextureFormat.BGRA, isRenderTarget);
			if (isRenderTarget) {
				// sadly, this is necessary because of Flash's absolute broken RectangleTexture implementation
				var bmd : BitmapData = new BitmapData(width, height, false);
				texture.uploadFromBitmapData(bmd);
				bmd.dispose();
			}
			return new TrackedRectTexture(texture);
		}

		public function dispose() : void
		{
			disposeBackBuffer();
			if (_colorTexture) _colorTexture.dispose();
			if (_normalSpecularMap) _normalSpecularMap.dispose();
			if (_sourceTexture) _sourceTexture.dispose();
			if (_normalSpecularOriginal) _normalSpecularOriginal.dispose();
			if (_colorBackgroundOriginal) _colorBackgroundOriginal.clear();
			if (_colorTransfer) _colorTransfer.dispose();
			_colorTexture = null;
			_normalSpecularMap = null;
			_sourceTexture = null;
			_normalSpecularOriginal = null;
			_colorBackgroundOriginal = null;
			_colorTransfer = null;
			
			if (_pyramidMap )
			{
				_pyramidMap.dispose();
				_pyramidMap = null;
			}
			
		}

		public function disposeBackBuffer() : void
		{
			if (_fullSizeBackBuffer) _fullSizeBackBuffer.dispose();
			_fullSizeBackBuffer = null;
		}

		public function swapColorLayer() : void
		{
			_colorTexture = swapFullSized(_colorTexture);
		}

		public function swapNormalSpecularLayer() : void
		{
			_normalSpecularMap = swapFullSized(_normalSpecularMap);
		}

		public function swapFullSized(target : TrackedRectTexture) : TrackedRectTexture
		{
			var temp : TrackedRectTexture = target;
			target = _fullSizeBackBuffer;
			_fullSizeBackBuffer = temp;
			return target;
		}
		
		public function get colorTransfer() : ColorTransfer
		{
			if ( _colorTransfer == null ) initColorTransfer();
			return _colorTransfer;
		}

		private function onMemoryWarning() : void
		{
		}

		public function clearColorTexture() : void
		{
			if (_colorBackgroundOriginal)
				_colorTexture.texture.uploadFromByteArray(_colorBackgroundOriginal, 0);
			else {
				var context : Context3D = stage3D.context3D;
				context.setRenderToTexture(_colorTexture.texture);
				context.clear(0, 0, 0, 0);
				context.setRenderToBackBuffer();
			}
		}

		public function clearNormalSpecularTexture() : void
		{
			_normalSpecularMap.texture.uploadFromBitmapData(_normalSpecularOriginal);
		}

		public function getColorBackgroundOriginal() : ByteArray
		{
			return _colorBackgroundOriginal;
		}

		public function getNormalSpecularOriginal() : BitmapData
		{
			return _normalSpecularOriginal;
		}

		public function getColorPaletteFromSource( colorCount:int ):Vector.<uint>
		{
			return RGBProximityQuantizer.getPalette( _pyramidMap,colorCount,3);
		}
		
		
	}
}
