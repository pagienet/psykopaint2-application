package net.psykosoft.psykopaint2.home.commands
{

	import flash.utils.ByteArray;

	import net.psykosoft.psykopaint2.base.robotlegs.commands.TracingCommand;
	import net.psykosoft.psykopaint2.base.utils.io.BinaryLoader;
	import net.psykosoft.psykopaint2.core.configuration.CoreSettings;
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

		private var _byteLoader:BinaryLoader;
		private var _loadedNormalSpecularData:ByteArray;
		private var _loadedColorData:ByteArray;

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
			_byteLoader = new BinaryLoader();
			_byteLoader.loadAsset( "/core-packaged/images/surfaces/canvas_color_" + index + "_512.surf",
					onColorDataLoaded, onColorDataError);
		}

		private function onColorDataError() : void
		{
			_byteLoader.dispose();
			_byteLoader = null;
			_loadedColorData = null;
			loadNormalSpecularData();
		}

		private function onColorDataLoaded( bytes:ByteArray ):void {
			_loadedColorData = bytes;
			_byteLoader.dispose();
			_byteLoader= null;
			loadNormalSpecularData();
		}

		private function loadNormalSpecularData():void {
			_byteLoader = new BinaryLoader();
			_byteLoader.loadAsset( "/core-packaged/images/surfaces/canvas_normal_specular_" + index + "_512.surf", onSurfaceLoaded );
		}

		private function onSurfaceLoaded( bytes:ByteArray ):void {
			_loadedNormalSpecularData = bytes;
			_byteLoader.dispose();
			_byteLoader = null;

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

		private function disposeSurface():void {
			if( _loadedColorData ) {
				_loadedColorData.clear();
				_loadedColorData = null;
			}
			if( _loadedNormalSpecularData ) {
				_loadedNormalSpecularData.clear();
				_loadedNormalSpecularData = null;
			}
		}

		private function createPaintingVO():PaintingInfoVO {
			var vo:PaintingInfoVO = new PaintingInfoVO();
			vo.width = 512;
			vo.height = 384;
			vo.surfaceID = index;
			if( _loadedColorData ) {
				vo.colorPreviewData = _loadedColorData;
				vo.colorPreviewData.uncompress();
				_loadedColorData = null;
			}
			else {
				vo.colorPreviewData = new ByteArray();
				vo.colorPreviewData.length = vo.width * vo.height * 4;	// will fill with zeroes
			}
			vo.normalSpecularPreviewData = new ByteArray();
			vo.normalSpecularPreviewData = _loadedNormalSpecularData;
			vo.normalSpecularPreviewData.uncompress();
			_loadedNormalSpecularData = null;
			// nothing else necessary
			return vo;
		}
	}
}
