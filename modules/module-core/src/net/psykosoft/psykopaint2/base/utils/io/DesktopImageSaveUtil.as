package net.psykosoft.psykopaint2.base.utils.io
{
	import flash.display.BitmapData;
	import flash.display.PNGEncoderOptions;
	import flash.events.Event;
	import flash.filesystem.File;
	import flash.utils.ByteArray;

	public class DesktopImageSaveUtil
	{
		private var _onCompleteCallback:Function;

		public function saveImageToDesktop( bmd:BitmapData, onComplete:Function ):void {

			_onCompleteCallback = onComplete;

			// Encode to jpeg or png.
			var pngBytes:ByteArray = bmd.encode(bmd.rect, new PNGEncoderOptions(true));

			// Generate a dated image name.
			var nowDate:Date = new Date();
			var fileName:String = "psykopaint2_snapshot_" + nowDate.toString().split(":").join("-") + ".png";
			trace( "DesktopImageSaveUtil - saving image: " + fileName );
			
			// Save image to desktop.
			var file:File = File.documentsDirectory;
			file.addEventListener( Event.CANCEL, onUserCanceled );
			file.addEventListener( Event.COMPLETE, onSavingComplete );
			file.save(pngBytes,fileName);
		}

		private function onSavingComplete( event:Event ):void {
			_onCompleteCallback();
		}

		private function onUserCanceled( event:Event ):void {
			_onCompleteCallback();
		}
	}
}
