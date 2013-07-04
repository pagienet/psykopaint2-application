package net.psykosoft.psykopaint2.core.data
{

	import away3d.tools.utils.TextureUtils;

	import flash.display.BitmapData;
	import flash.utils.ByteArray;

	public class PaintingInfoVO
	{
		public static const DEFAULT_VO_ID:String = "new";

		public var thumbnail:BitmapData;
		public var colorSurfacePreview:ByteArray;
		public var normalsSurfacePreview:ByteArray;
		public var lastSavedOnDateMs:Number;

		public var fileVersion:String = PaintingSerializer.PAINTING_FILE_VERSION;
		public var id:String = DEFAULT_VO_ID;

		private var _previewWidth:int;
		private var _previewHeight:int;
		private var _textureWidth:int;
		private var _textureHeight:int;

		public function PaintingInfoVO() {
			super();
		}

		public function toString():String {
			return "PaintingVO - " +
					"fileVersion: " + fileVersion +
					", id: " + id +
					", lastSavedOnDateMs: " + lastSavedOnDateMs;
		}

		// ---------------------------------------------------------------------
		// Setters and getters.
		// ---------------------------------------------------------------------

		public function set previewWidth( value:int ):void {
			_previewWidth = value;
			_textureWidth = TextureUtils.getBestPowerOf2( _previewWidth );
		}

		public function get previewWidth():int {
			return _previewWidth;
		}

		public function set previewHeight( value:int ):void {
			_previewHeight = value;
			_textureHeight = TextureUtils.getBestPowerOf2( _previewHeight );
		}

		public function get previewHeight():int {
			return _previewHeight;
		}

		public function get textureWidth():int {
			return _textureWidth;
		}

		public function get textureHeight():int {
			return _textureHeight;
		}
	}
}
