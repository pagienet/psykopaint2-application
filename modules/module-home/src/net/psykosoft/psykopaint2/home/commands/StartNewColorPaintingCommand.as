package net.psykosoft.psykopaint2.home.commands
{
	import flash.display.BitmapData;
	import flash.geom.Matrix;

	import net.psykosoft.psykopaint2.base.utils.data.ByteArrayUtil;
	import net.psykosoft.psykopaint2.base.utils.images.ImageDataUtils;
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
				if (surface.color.width == paintingDataVO.width && surface.color.height == paintingDataVO.height)
					paintingDataVO.colorData = surface.color.getPixels(surface.color.rect);
				else {
					var scaled : BitmapData = new BitmapData(paintingDataVO.width, paintingDataVO.height, true, 0)
					scaled.draw(surface.color, new Matrix(paintingDataVO.width / surface.color.width, 0, 0, paintingDataVO.height / surface.color.height), null, null, null, true);
					paintingDataVO.colorData = scaled.getPixels(scaled.rect);
					scaled.dispose();
				}
				ImageDataUtils.ARGBtoBGRA(paintingDataVO.colorData, paintingDataVO.colorData.length, 0);
				paintingDataVO.colorBackgroundOriginal = surface.color;
			}
			else {
				paintingDataVO.colorData = ByteArrayUtil.createBlankColorData(paintingDataVO.width, paintingDataVO.height, 0xffffffff);
			}

			paintingDataVO.surfaceNormalSpecularData = surface.normalSpecular;
			paintingDataVO.surfaceID = surface.id;

			requestOpenPaintingDataVOSignal.dispatch(paintingDataVO);
		}
	}
}
