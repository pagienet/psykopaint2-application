package net.psykosoft.psykopaint2.home.commands
{
	import net.psykosoft.psykopaint2.base.utils.data.ByteArrayUtil;
	import net.psykosoft.psykopaint2.core.configuration.CoreSettings;
	import net.psykosoft.psykopaint2.core.data.PaintingDataVO;
	import net.psykosoft.psykopaint2.core.data.SurfaceDataVO;
	import net.psykosoft.psykopaint2.core.signals.NotifySurfaceLoadedSignal;
	import net.psykosoft.psykopaint2.core.signals.RequestLoadSurfaceSignal;
	import net.psykosoft.psykopaint2.home.signals.RequestOpenPaintingDataVOSignal;

	public class StartNewColorPaintingCommand
	{
		[Inject]
		public var requestLoadSurfaceSignal:RequestLoadSurfaceSignal;

		[Inject]
		public var notifySurfaceLoadedSignal:NotifySurfaceLoadedSignal;

		[Inject]
		public var requestOpenPaintingDataVOSignal : RequestOpenPaintingDataVOSignal;

		public function execute() : void
		{
			notifySurfaceLoadedSignal.addOnce( onSurfaceLoaded );
			requestLoadSurfaceSignal.dispatch();
		}

		private function onSurfaceLoaded(surface : SurfaceDataVO):void {
			var vo : PaintingDataVO = new PaintingDataVO();
			vo.width = CoreSettings.STAGE_WIDTH;
			vo.height = CoreSettings.STAGE_HEIGHT;

			if (surface.color) {
				vo.colorData = surface.color;
				vo.colorBackgroundOriginal = surface.color;
			}
			else
				vo.colorData = ByteArrayUtil.createBlankColorData(vo.width, vo.height, 0xffffffff);

			vo.normalSpecularOriginal = surface.normalSpecular;

			requestOpenPaintingDataVOSignal.dispatch(vo);
		}
	}
}
