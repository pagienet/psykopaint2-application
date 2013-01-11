package net.psykosoft.psykopaint2.model.sourceimages
{

	import flash.display.BitmapData;

	import net.psykosoft.psykopaint2.signal.notifications.NotifySourceImagesUpdatedSignal;

	public class SourceImagesModel
	{
		[Inject]
		public var notifySourceImagesUpdatedSignal:NotifySourceImagesUpdatedSignal;

		private var _thumbs:Vector.<BitmapData>;
		private var _images:Vector.<BitmapData>;

		public function SourceImagesModel() {
			super();
		}

		public function set images( value:Vector.<BitmapData> ):void {
			_images = value;
		}

		public function set thumbs( value:Vector.<BitmapData> ):void {
			_thumbs = value;
			notifySourceImagesUpdatedSignal.dispatch( _thumbs );
		}
	}
}
