package net.psykosoft.psykopaint2.base.utils.io
{

	import flash.display.BitmapData;
	import flash.events.Event;
	import flash.media.CameraRoll;

	public class IosImageSaveUtil
	{
		private var _onCompleteCallBack:Function;

		public function saveImageToCameraRoll( bmd:BitmapData, onComplete:Function ):void {
			_onCompleteCallBack = onComplete;
			var cameraRoll:CameraRoll = new CameraRoll();
			cameraRoll.addEventListener( Event.COMPLETE, onAddBitmapDataComplete );
			cameraRoll.addBitmapData( bmd );
		}

		private function onAddBitmapDataComplete( event:Event ):void {
			_onCompleteCallBack();
		}
	}
}
