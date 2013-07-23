package net.psykosoft.psykopaint2.home.commands
{

	import flash.display.BitmapData;
	import flash.utils.ByteArray;

	import net.psykosoft.psykopaint2.base.robotlegs.commands.TracingCommand;
	import net.psykosoft.psykopaint2.base.utils.io.BinaryLoader;
	import net.psykosoft.psykopaint2.base.utils.io.BitmapLoader;
	import net.psykosoft.psykopaint2.base.utils.misc.TrackedBitmapData;
	import net.psykosoft.psykopaint2.core.configuration.CoreSettings;
	import net.psykosoft.psykopaint2.core.data.PaintingInfoVO;
	import net.psykosoft.psykopaint2.core.signals.NotifySurfacePreviewLoadedSignal;
	import net.psykosoft.psykopaint2.core.signals.RequestEaselUpdateSignal;

	import robotlegs.bender.framework.api.IContext;

	public class LoadSurfacePreviewCommand extends TracingCommand
	{
		[Inject]
		public var index:uint; // From signal.

		[Inject]
		public var context:IContext;

		[Inject]
		public var requestEaselPaintingUpdateSignal:RequestEaselUpdateSignal;

		[Inject]
		public var notifySurfacePreviewLoadedSignal:NotifySurfacePreviewLoadedSignal;

		private static var _busy:Boolean;

		private var _byteLoader:BinaryLoader;
		private var _bitmapLoader:BitmapLoader;
		private var _loadedNormalSpecularData:ByteArray;
		private var _loadedColorData:BitmapData;

		public function LoadSurfacePreviewCommand() {
			super();
		}

		override public function execute():void {
			super.execute();

			// Need to cancel previous active load?
			if( _busy ) {
			    if( _byteLoader ) {
					_byteLoader.dispose();
					_byteLoader = null;
				}
				if( _bitmapLoader ) {
					_bitmapLoader.dispose();
					_bitmapLoader = null;
				}
				_busy = false;
			}
			else {
				context.detain( this );
				_busy = true;
			}

			disposeSurface();
			loadColorData();
		}

		private function loadColorData():void {
			_bitmapLoader = new BitmapLoader();
			_bitmapLoader.loadAsset( "/core-packaged/images/surfaces/canvas_color_" + index + "_preview.jpg",
					onColorDataLoaded,
					onColorDataError );
		}

		private function onColorDataError():void {
			_bitmapLoader.dispose();
			_bitmapLoader = null;
			trace( "Error loading '/core-packaged/images/surfaces/canvas_color_" + index + "_preview.surf'" );
			loadNormalSpecularData();
		}

		private function onColorDataLoaded( bitmap:BitmapData ):void {
			_loadedColorData = bitmap;
			_bitmapLoader.dispose();
			_bitmapLoader = null;
			loadNormalSpecularData();
		}

		private function loadNormalSpecularData():void {
			_byteLoader = new BinaryLoader();
			_byteLoader.loadAsset( "/core-packaged/images/surfaces/canvas_normal_specular_" + index + "_preview.surf", onSurfaceLoaded );
		}

		private function onSurfaceLoaded( bytes:ByteArray ):void {
			_loadedNormalSpecularData = bytes;
			_byteLoader.dispose();
			_byteLoader = null;

			var vo:PaintingInfoVO = createPaintingVO();
			requestEaselPaintingUpdateSignal.dispatch( vo, true, true );
			// Note: vo is disposed by the home view when the animation finishes ( second boolean parameter of signal )

			notifySurfacePreviewLoadedSignal.dispatch();
			context.release( this );
			_busy = false;
		}

		private function disposeSurface():void {
			if( _loadedColorData ) {
				_loadedColorData.dispose();
				_loadedColorData = null;
			}
			if( _loadedNormalSpecularData ) {
				_loadedNormalSpecularData.clear();
				_loadedNormalSpecularData = null;
			}
		}

		private function createPaintingVO():PaintingInfoVO {
			var vo:PaintingInfoVO = new PaintingInfoVO();
			vo.width = CoreSettings.STAGE_WIDTH;
			vo.height = CoreSettings.STAGE_HEIGHT;
			if( _loadedColorData ) {
				vo.colorPreviewBitmap = new TrackedBitmapData( vo.textureWidth, vo.textureHeight, false, 0 );
				vo.colorPreviewBitmap.draw( _loadedColorData );
			}
			else {
				vo.colorPreviewData = new ByteArray();
				vo.colorPreviewData.length = vo.width * vo.height * 4;	// will fill with zeroes
			}
			vo.normalSpecularPreviewData = new ByteArray();
			vo.normalSpecularPreviewData.writeBytes( _loadedNormalSpecularData, 0, 0 );
			vo.normalSpecularPreviewData.uncompress();
			// nothing else necessary
			return vo;
		}
	}
}
