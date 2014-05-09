package net.psykosoft.psykopaint2.home.commands
{

	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.events.Event;
	import flash.net.URLRequest;
	import flash.utils.ByteArray;
	
	import net.psykosoft.psykopaint2.base.robotlegs.commands.TracingCommand;
	import net.psykosoft.psykopaint2.base.utils.misc.TrackedByteArray;
	import net.psykosoft.psykopaint2.core.data.PaintingInfoVO;
	import net.psykosoft.psykopaint2.core.signals.NotifySurfacePreviewLoadedSignal;
	import net.psykosoft.psykopaint2.core.signals.RequestEaselUpdateSignal;
	
	import robotlegs.bender.framework.api.IContext;

	public class LoadSurfacePreviewCommand extends TracingCommand
	{
		[Inject]
		public var index:uint; // From signal. Which Signal???

		[Inject]
		public var context:IContext;

		[Inject]
		public var requestEaselPaintingUpdateSignal:RequestEaselUpdateSignal;

		[Inject]
		public var notifySurfacePreviewLoadedSignal:NotifySurfacePreviewLoadedSignal;

		private static var _busy:Boolean;

		private var _loader:Loader;
		private var _loadedNormalSpecularData:BitmapData;

		public function LoadSurfacePreviewCommand() {
			super();
		}

		override public function execute():void {
			super.execute();

			// Need to cancel previous active load?
			if( _busy ) {
				if (_loader) {
					_loader.close();
					_loader = null;
				}
				_busy = false;
			}
			else {
				context.detain( this );
				_busy = true;
			}
		}

		private function loadNormalSpecularData():void {
			_loader = new Loader();
			_loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onSurfaceLoaded);
			_loader.load( new URLRequest("/core-packaged/images/surfaces/canvas_normal_specular_" + index + "_512.png" ));
		}

		private function onSurfaceLoaded(event : Event):void {
			_loader.contentLoaderInfo.removeEventListener(Event.COMPLETE, onSurfaceLoaded);
			_loadedNormalSpecularData = Bitmap(_loader.content).bitmapData;
			_loader = null;

			var vo:PaintingInfoVO = createPaintingVO();
			requestEaselPaintingUpdateSignal.dispatch( vo, true, onEaselUpdateComplete );
			// Note: vo is disposed by the home view when the animation finishes ( second boolean parameter of signal )

			notifySurfacePreviewLoadedSignal.dispatch();
			context.release( this );
			_busy = false;
		}

		private function onEaselUpdateComplete(paintingVO : PaintingInfoVO) : void
		{
			paintingVO.dispose();
		}

		private function createPaintingVO():PaintingInfoVO {
			var vo:PaintingInfoVO = new PaintingInfoVO();
			vo.width = 512;
			vo.height = 384;
			vo.surfaceID = index;
			vo.colorPreviewData = new TrackedByteArray();
			vo.colorPreviewData.length = vo.width * vo.height * 4;	// will fill with zeroes
			vo.normalSpecularPreviewBitmap = _loadedNormalSpecularData;
			_loadedNormalSpecularData = null;
			// nothing else necessary
			return vo;
		}
	}
}
