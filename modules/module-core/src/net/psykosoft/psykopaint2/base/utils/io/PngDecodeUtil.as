package net.psykosoft.psykopaint2.base.utils.io
{

	import flash.display.BitmapData;
	import flash.display.Loader;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.utils.ByteArray;

	import net.psykosoft.psykopaint2.base.utils.misc.TrackedBitmapData;

	public class PngDecodeUtil
	{
		private var _pngDecodeCallback:Function;
		private var _loader:Loader;
		private var _bytes : ByteArray;
		private var _disposeWhenReady : Boolean;

		public function PngDecodeUtil() {
			super();
			_loader = new Loader();
			_loader.contentLoaderInfo.addEventListener( IOErrorEvent.IO_ERROR, onError );
			_loader.contentLoaderInfo.addEventListener( Event.INIT, onDecodingInit );
			_loader.contentLoaderInfo.addEventListener( Event.COMPLETE, onDecodingComplete );
		}

		private function onDecodingInit( event:Event ):void {
			trace( this, "decoding init." );
		}

		private function onError( event:Event ):void {
			trace( this, "decoding error: " + event );
		}

		public function decode( bytes:ByteArray, onComplete:Function, disposeWhenReady : Boolean = false ):void {
			trace( this, "decoding: " + bytes.length + " bytes." );
			_pngDecodeCallback = onComplete;
			_disposeWhenReady = disposeWhenReady;
			_bytes = bytes;
			_loader.loadBytes( _bytes );
		}

		private function onDecodingComplete( event:Event ):void {
			trace( this, "decoded." );
			if (_disposeWhenReady)
				_bytes.clear();
			var bmd:BitmapData = new TrackedBitmapData( _loader.width, _loader.height, false, 0 );
			bmd.draw( _loader );
			_pngDecodeCallback( bmd );
			_pngDecodeCallback = null;
		}
	}
}
