package net.psykosoft.psykopaint2.app.states
{
	import flash.display.BitmapData;
	import flash.utils.setTimeout;

	import net.psykosoft.psykopaint2.app.signals.NotifyFrozenBackgroundCreatedSignal;

	import net.psykosoft.psykopaint2.base.states.ns_state_machine;
	import net.psykosoft.psykopaint2.base.states.State;
	import net.psykosoft.psykopaint2.base.utils.data.ByteArrayUtil;
	import net.psykosoft.psykopaint2.core.configuration.CoreSettings;
	import net.psykosoft.psykopaint2.core.data.PaintingDataVO;
	import net.psykosoft.psykopaint2.core.data.SurfaceDataVO;
	import net.psykosoft.psykopaint2.core.managers.rendering.RefCountedTexture;
	import net.psykosoft.psykopaint2.core.models.EaselRectModel;
	import net.psykosoft.psykopaint2.core.models.NavigationStateType;
	import net.psykosoft.psykopaint2.core.signals.NotifySurfaceLoadedSignal;
	import net.psykosoft.psykopaint2.core.signals.RequestLoadSurfaceSignal;
	import net.psykosoft.psykopaint2.core.signals.RequestNavigationStateChangeSignal;
	import net.psykosoft.psykopaint2.crop.signals.RequestDestroyCropModuleSignal;
	import net.psykosoft.psykopaint2.home.signals.RequestDestroyHomeModuleSignal;
	import net.psykosoft.psykopaint2.paint.signals.NotifyCanvasZoomedToDefaultViewSignal;
	import net.psykosoft.psykopaint2.paint.signals.NotifyPaintModuleSetUpSignal;
	import net.psykosoft.psykopaint2.paint.signals.RequestSetCanvasBackgroundSignal;
	import net.psykosoft.psykopaint2.paint.signals.RequestSetupPaintModuleSignal;
	import net.psykosoft.psykopaint2.paint.signals.RequestZoomCanvasToDefaultViewSignal;

	public class TransitionCropToPaintState extends State
	{
		[Inject]
		public var requestDestroyCropModuleSignal : RequestDestroyCropModuleSignal;

		[Inject]
		public var requestLoadSurfaceSignal : RequestLoadSurfaceSignal;

		[Inject]
		public var notifySurfaceLoadedSignal : NotifySurfaceLoadedSignal;

		[Inject]
		public var requestSetupPaintModuleSignal : RequestSetupPaintModuleSignal;

		[Inject]
		public var notifyPaintModuleSetUp : NotifyPaintModuleSetUpSignal;

		[Inject]
		public var requestZoomCanvasToDefaultViewSignal:RequestZoomCanvasToDefaultViewSignal;

		[Inject]
		public var paintState : PaintState;

		[Inject]
		public var easelRectModel : EaselRectModel;

		[Inject]
		public var requestSetCanvasBackgroundSignal : RequestSetCanvasBackgroundSignal;

		[Inject]
		public var requestStateChangeSignal : RequestNavigationStateChangeSignal;

		[Inject]
		public var notifyCanvasZoomedToDefaultViewSignal:NotifyCanvasZoomedToDefaultViewSignal;

		[Inject]
		public var requestDestroyHomeModuleSignal : RequestDestroyHomeModuleSignal;

		private var _croppedBitmapData : BitmapData;
		private var _background : RefCountedTexture;

		public function TransitionCropToPaintState()
		{
		}

		/**
		 *
		 * @param data An Object with the following layout:
		 * {
		 * 	bitmapData : BitmapData; // containing BitmapData containing the cropped bitmap
		 * 	background : RefCountedTexture; // containing the background for the renderer
		 * }
		 */
		override ns_state_machine function activate(data : Object = null) : void
		{
			_croppedBitmapData = BitmapData(data.bitmapData);
			_background = RefCountedTexture(data.background);

			notifySurfaceLoadedSignal.addOnce(onSurfaceLoaded);
			requestLoadSurfaceSignal.dispatch(0);
		}

		private function onSurfaceLoaded(data : SurfaceDataVO) : void
		{
			var vo : PaintingDataVO = createPaintingVO(data);

			_croppedBitmapData.dispose();
			_croppedBitmapData = null;

			requestDestroyHomeModuleSignal.dispatch();

			notifyPaintModuleSetUp.addOnce(onPaintingModuleSetUp);
			requestSetupPaintModuleSignal.dispatch(vo);
		}

		private function onPaintingModuleSetUp() : void
		{
			requestStateChangeSignal.dispatch(NavigationStateType.TRANSITION_TO_PAINT_MODE);
			requestSetCanvasBackgroundSignal.dispatch(_background.newReference(), easelRectModel.absoluteScreenRect);

			notifyCanvasZoomedToDefaultViewSignal.addOnce( onZoomOutComplete );
			requestZoomCanvasToDefaultViewSignal.dispatch();
		}

		private function onZoomOutComplete() : void
		{
			stateMachine.setActiveState(paintState);
		}

		private function createPaintingVO(surface : SurfaceDataVO) : PaintingDataVO
		{
			var vo : PaintingDataVO = new PaintingDataVO();
			vo.width = CoreSettings.STAGE_WIDTH;
			vo.height = CoreSettings.STAGE_HEIGHT;
			vo.sourceBitmapData = _croppedBitmapData.getPixels(_croppedBitmapData.rect);
			if (surface.color) {
				vo.colorBackgroundOriginal = surface.color;
				vo.colorData = ByteArrayUtil.createBlankColorData(CoreSettings.STAGE_WIDTH, CoreSettings.STAGE_HEIGHT, 0x00000000);
			}
			else
				vo.colorData = ByteArrayUtil.createBlankColorData(CoreSettings.STAGE_WIDTH, CoreSettings.STAGE_HEIGHT, 0x00000000);
			vo.normalSpecularData = surface.normalSpecular;
			vo.normalSpecularOriginal = surface.normalSpecular;
			return vo;
		}

		override ns_state_machine function deactivate() : void
		{
			requestDestroyCropModuleSignal.dispatch();
			_background.dispose();
			_background = null;
		}
	}
}
