package net.psykosoft.psykopaint2.home.commands
{
	import net.psykosoft.psykopaint2.base.utils.data.ByteArrayUtil;
	import net.psykosoft.psykopaint2.core.configuration.CoreSettings;
	import net.psykosoft.psykopaint2.core.data.PaintingDataVO;
	import net.psykosoft.psykopaint2.core.data.SurfaceDataVO;
	import net.psykosoft.psykopaint2.core.models.PaintMode;
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
			requestLoadSurfaceSignal.dispatch(PaintMode.COLOR_MODE);
		}

		private function onSurfaceLoaded(surface : SurfaceDataVO):void {
			var paintingDataVO : PaintingDataVO = new PaintingDataVO();
			paintingDataVO.width = CoreSettings.STAGE_WIDTH;
			paintingDataVO.height = CoreSettings.STAGE_HEIGHT;

			if (surface.color) {
				paintingDataVO.colorData = surface.color;
				paintingDataVO.colorBackgroundOriginal = surface.color;
			}
			else {
				paintingDataVO.colorData = ByteArrayUtil.createBlankColorData(paintingDataVO.width, paintingDataVO.height, 0xffffffff);}

			paintingDataVO.surfaceNormalSpecularData = surface.normalSpecular;
			paintingDataVO.surfaceID = surface.id;

			requestOpenPaintingDataVOSignal.dispatch(paintingDataVO);
		}
	}
}
