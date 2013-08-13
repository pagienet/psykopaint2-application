package net.psykosoft.psykopaint2.core.data
{

	import away3d.tools.utils.TextureUtils;

	import flash.display.BitmapData;
	import flash.utils.ByteArray;

	import net.psykosoft.psykopaint2.core.configuration.CoreSettings;

	import net.psykosoft.psykopaint2.core.debug.UndisposedObjects;

	import net.psykosoft.psykopaint2.core.managers.misc.UnDisposedObjectsManager;
	import net.psykosoft.psykopaint2.core.managers.rendering.RefCountedByteArray;

	public class PaintingInfoVO
	{
		public static const DEFAULT_VO_ID:String = "new";

		public var thumbnail:BitmapData;
		public var colorPreviewData:RefCountedByteArray;
		public var colorPreviewBitmap:BitmapData;
		public var normalSpecularPreviewData:RefCountedByteArray;
		public var lastSavedOnDateMs:Number;

		public var fileVersion:String = PaintingFileUtils.PAINTING_FILE_VERSION;
		public var id:String = DEFAULT_VO_ID;

		private var _width:int;
		private var _height:int;
		private var _textureWidth:int;
		private var _textureHeight:int;

		public function PaintingInfoVO() {
			super();
			if (CoreSettings.TRACK_NON_GCED_OBJECTS)
				UndisposedObjects.getInstance().add(this);
		}

		public function clone() : PaintingInfoVO
		{
			var clone : PaintingInfoVO = new PaintingInfoVO();
			if (thumbnail) clone.thumbnail = thumbnail.clone();
			if (colorPreviewData) {
				clone.colorPreviewData = new RefCountedByteArray();
				clone.colorPreviewData.writeBytes(colorPreviewData);
			}
			if (colorPreviewBitmap) clone.colorPreviewBitmap = colorPreviewBitmap.clone();

			clone.normalSpecularPreviewData = new RefCountedByteArray();
			clone.normalSpecularPreviewData.writeBytes(normalSpecularPreviewData);
			clone.lastSavedOnDateMs = lastSavedOnDateMs;
			clone.fileVersion = fileVersion;
			clone.id = id;
			clone.width = _width;
			clone.height = _height;
			return clone;
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

		public function set width( value:int ):void {
			_width = value;
			_textureWidth = TextureUtils.getBestPowerOf2( _width );
		}

		public function get width():int {
			return _width;
		}

		public function set height( value:int ):void {
			_height = value;
			_textureHeight = TextureUtils.getBestPowerOf2( _height );
		}

		public function get height():int {
			return _height;
		}

		public function get textureWidth():int {
			return _textureWidth;
		}

		public function get textureHeight():int {
			return _textureHeight;
		}

		public function dispose() : void
		{
			if (CoreSettings.TRACK_NON_GCED_OBJECTS)
				UndisposedObjects.getInstance().remove(this);

			if (colorPreviewData)
				colorPreviewData.dispose();

			if (colorPreviewBitmap)
				colorPreviewBitmap.dispose();

			normalSpecularPreviewData.dispose();
			if (thumbnail) thumbnail.dispose();
			colorPreviewData = null;
			colorPreviewBitmap = null;
			normalSpecularPreviewData = null;
			thumbnail = null;
		}
	}
}
