package net.psykosoft.psykopaint2.app.states.transitions
{
	import flash.display.BitmapData;
	
	import net.psykosoft.psykopaint2.app.signals.NotifyFrozenBackgroundCreatedSignal;
	import net.psykosoft.psykopaint2.app.signals.RequestCreatePaintingBackgroundSignal;
	import net.psykosoft.psykopaint2.app.states.PaintState;
	import net.psykosoft.psykopaint2.base.states.ns_state_machine;
	import net.psykosoft.psykopaint2.base.utils.data.ByteArrayUtil;
	import net.psykosoft.psykopaint2.core.configuration.CoreSettings;
	import net.psykosoft.psykopaint2.core.data.PaintingDataVO;
	import net.psykosoft.psykopaint2.core.data.SurfaceDataVO;
	import net.psykosoft.psykopaint2.core.managers.rendering.RefCountedRectTexture;
	import net.psykosoft.psykopaint2.core.models.EaselRectModel;
	import net.psykosoft.psykopaint2.core.models.NavigationStateType;
	import net.psykosoft.psykopaint2.core.signals.NotifySurfaceLoadedSignal;
	import net.psykosoft.psykopaint2.core.signals.RequestLoadSurfaceSignal;
	import net.psykosoft.psykopaint2.core.signals.RequestNavigationStateChangeSignal;
	import net.psykosoft.psykopaint2.crop.signals.RequestDestroyCropModuleSignal;
	import net.psykosoft.psykopaint2.home.signals.NotifyHomeModuleDestroyedSignal;
	import net.psykosoft.psykopaint2.home.signals.RequestDestroyHomeModuleSignal;
	import net.psykosoft.psykopaint2.paint.signals.NotifyCanvasZoomedToDefaultViewSignal;
	import net.psykosoft.psykopaint2.paint.signals.NotifyPaintModuleSetUpSignal;
	import net.psykosoft.psykopaint2.paint.signals.RequestSetCanvasBackgroundSignal;
	import net.psykosoft.psykopaint2.paint.signals.RequestSetupPaintModuleSignal;
	import net.psykosoft.psykopaint2.paint.signals.RequestZoomCanvasToDefaultViewSignal;

	public class TransitionCropToPaintState extends AbstractTransitionState
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

		[Inject]
		public var notifyHomeModuleDestroyedSignal:NotifyHomeModuleDestroyedSignal;

		[Inject]
		public var requestCreatePaintingBackgroundSignal : RequestCreatePaintingBackgroundSignal;

		[Inject]
		public var notifyBackgroundSetSignal : NotifyFrozenBackgroundCreatedSignal;

		private var _croppedBitmapData : BitmapData;
		private var _background : RefCountedRectTexture;

		use namespace ns_state_machine;

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
			super.activate(data);
			_croppedBitmapData = BitmapData(data.bitmapData);
			// force position focused on easel in case we're going to quick for tweens to finish
			notifyBackgroundSetSignal.addOnce(onBackgroundSet);
			requestCreatePaintingBackgroundSignal.dispatch();
		}

		private function onBackgroundSet(background : RefCountedRectTexture) : void
		{
			if (_background) _background.dispose();
			_background = background.newReference();

			notifySurfaceLoadedSignal.addOnce(onSurfaceLoaded);
			requestLoadSurfaceSignal.dispatch();
		}
		
		private function onSurfaceLoaded(data : SurfaceDataVO) : void
		{
			var vo : PaintingDataVO = createPaintingVO(data);
			notifyPaintModuleSetUp.addOnce(onPaintingModuleSetUp);
			requestSetupPaintModuleSignal.dispatch(vo);
		}
		
		private function onHomeModuleDestroyed():void {
			_croppedBitmapData.dispose();
			_croppedBitmapData = null;
		}
		
		private function onPaintingModuleSetUp() : void
		{
			notifyHomeModuleDestroyedSignal.addOnce( onHomeModuleDestroyed );
			requestDestroyHomeModuleSignal.dispatch();
			
			requestStateChangeSignal.dispatch(NavigationStateType.TRANSITION_TO_PAINT_MODE);
			requestSetCanvasBackgroundSignal.dispatch(_background.newReference(), easelRectModel.absoluteScreenRect);
			
			notifyCanvasZoomedToDefaultViewSignal.addOnce( onZoomInComplete );
			requestZoomCanvasToDefaultViewSignal.dispatch();
		}
		

		private function onZoomInComplete() : void
		{
			stateMachine.setActiveState(paintState);
		}

		private function createPaintingVO(surface : SurfaceDataVO) : PaintingDataVO
		{
			var vo : PaintingDataVO = new PaintingDataVO();
			vo.width = CoreSettings.STAGE_WIDTH;
			vo.height = CoreSettings.STAGE_HEIGHT;
			vo.sourceImageData =  _croppedBitmapData.getPixels(_croppedBitmapData.rect);
			if (surface.color) {
				vo.colorBackgroundOriginal = surface.color;
				vo.colorData = ByteArrayUtil.createBlankColorData(CoreSettings.STAGE_WIDTH, CoreSettings.STAGE_HEIGHT, 0x00000000);
			}
			else
				vo.colorData = ByteArrayUtil.createBlankColorData(CoreSettings.STAGE_WIDTH, CoreSettings.STAGE_HEIGHT, 0x00000000);
			vo.normalSpecularData = null;
			vo.normalSpecularOriginal = surface.normalSpecular;
			return vo;
		}

		override ns_state_machine function deactivate() : void
		{
			use namespace ns_state_machine;
			super.deactivate();
			requestDestroyCropModuleSignal.dispatch();
			_background.dispose();
			_background = null;
		}
	}
}
