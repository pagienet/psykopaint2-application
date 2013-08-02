package net.psykosoft.psykopaint2.app.states
{
	import flash.display.BitmapData;
	import flash.utils.ByteArray;

	import net.psykosoft.psykopaint2.base.states.ns_state_machine;
	import net.psykosoft.psykopaint2.base.states.State;
	import net.psykosoft.psykopaint2.base.utils.data.ByteArrayUtil;
	import net.psykosoft.psykopaint2.core.configuration.CoreSettings;
	import net.psykosoft.psykopaint2.core.data.PaintingDataVO;
	import net.psykosoft.psykopaint2.core.models.NavigationStateType;
	import net.psykosoft.psykopaint2.core.signals.NotifySurfaceLoadedSignal;
	import net.psykosoft.psykopaint2.core.signals.RequestLoadSurfaceSignal;
	import net.psykosoft.psykopaint2.paint.signals.NotifyPaintModuleSetUpSignal;
	import net.psykosoft.psykopaint2.paint.signals.RequestSetupPaintModuleSignal;
	import net.psykosoft.psykopaint2.paint.signals.RequestZoomCanvasToDefaultViewSignal;

	public class TransitionCropToPaintState extends State
	{
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

		private var _croppedBitmapData : BitmapData;

		public function TransitionCropToPaintState()
		{
		}

		/**
		 *
		 * @param data A BitmapData containing the cropped bitmap
		 */
		override ns_state_machine function activate(data : Object = null) : void
		{
			_croppedBitmapData = BitmapData(data);

			notifySurfaceLoadedSignal.addOnce(onSurfaceLoaded);
			requestLoadSurfaceSignal.dispatch(0);
		}

		private function onSurfaceLoaded(data : ByteArray) : void
		{
			var vo : PaintingDataVO = createPaintingVO(data);
			_croppedBitmapData.dispose();
			_croppedBitmapData = null;

			// TODO: Go to paint view
			notifyPaintModuleSetUp.addOnce(onPaintingModuleSetUp);
			requestSetupPaintModuleSignal.dispatch(vo);
		}

		private function onPaintingModuleSetUp() : void
		{
			// TODO: Pass on background image from crop to paint module renderer
			requestZoomCanvasToDefaultViewSignal.dispatch(onZoomOutComplete);
//			requestStateChangeSignal.dispatch(NavigationStateType.TRANSITION_TO_PAINT_MODE);
		}

		private function onZoomOutComplete() : void
		{
			stateMachine.setActiveState(paintState);
		}

		private function createPaintingVO(data : ByteArray) : PaintingDataVO
		{
			var vo : PaintingDataVO = new PaintingDataVO();
			vo.width = CoreSettings.STAGE_WIDTH;
			vo.height = CoreSettings.STAGE_HEIGHT;
			vo.sourceBitmapData = _croppedBitmapData.getPixels(_croppedBitmapData.rect);
			vo.colorData = ByteArrayUtil.createBlankColorData(CoreSettings.STAGE_WIDTH, CoreSettings.STAGE_HEIGHT, 0x00000000);
			vo.normalSpecularData = data;
			return vo;
		}

		override ns_state_machine function deactivate() : void
		{
		}
	}
}
