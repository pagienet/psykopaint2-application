package net.psykosoft.psykopaint2.app.states.transitions
{
	import flash.display.BitmapData;
	import flash.geom.Matrix;
	
	import net.psykosoft.psykopaint2.app.signals.NotifyFrozenBackgroundCreatedSignal;
	import net.psykosoft.psykopaint2.app.signals.RequestCreateCanvasBackgroundSignal;
	import net.psykosoft.psykopaint2.app.signals.RequestCreatePaintingBackgroundSignal;
	import net.psykosoft.psykopaint2.app.states.PaintState;
	import net.psykosoft.psykopaint2.base.states.ns_state_machine;
	import net.psykosoft.psykopaint2.base.utils.data.ByteArrayUtil;
	import net.psykosoft.psykopaint2.base.utils.images.ImageDataUtils;
	import net.psykosoft.psykopaint2.core.commands.DisposePaintingDataCommand;
	import net.psykosoft.psykopaint2.core.configuration.CoreSettings;
	import net.psykosoft.psykopaint2.core.data.PaintingDataVO;
	import net.psykosoft.psykopaint2.core.data.SurfaceDataVO;
	import net.psykosoft.psykopaint2.core.managers.rendering.RefCountedRectTexture;
	import net.psykosoft.psykopaint2.core.models.EaselRectModel;
	import net.psykosoft.psykopaint2.core.models.NavigationStateType;
	import net.psykosoft.psykopaint2.core.models.PaintMode;
	import net.psykosoft.psykopaint2.core.signals.NotifySurfaceLoadedSignal;
	import net.psykosoft.psykopaint2.core.signals.NotifyToggleLoadingMessageSignal;
	import net.psykosoft.psykopaint2.core.signals.RequestGpuRenderingSignal;
	import net.psykosoft.psykopaint2.core.signals.RequestLoadSurfaceSignal;
	import net.psykosoft.psykopaint2.core.signals.RequestNavigationStateChangeSignal;
	import net.psykosoft.psykopaint2.crop.signals.RequestDestroyCropModuleSignal;
	import net.psykosoft.psykopaint2.home.commands.unload.DestroyBookCommand;
	import net.psykosoft.psykopaint2.home.commands.unload.DisconnectHomeModuleShakeAndBakeCommand;
	import net.psykosoft.psykopaint2.home.signals.NotifyHomeModuleDestroyedSignal;
	import net.psykosoft.psykopaint2.home.signals.RequestDestroyHomeModuleSignal;
	import net.psykosoft.psykopaint2.home.signals.RequestRemoveHomeModuleDisplaySignal;
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
		public var notifyHomeModuleDestroyedSignal:NotifyHomeModuleDestroyedSignal;

		[Inject]
		public var requestRemoveHomeModuleDisplaySignal : RequestRemoveHomeModuleDisplaySignal;
		
		[Inject]
		public var requestDestroyHomeModuleSignal : RequestDestroyHomeModuleSignal;

		
	
		[Inject]
		public var notifyCanvasBackgroundSetSignal : NotifyFrozenBackgroundCreatedSignal;

		[Inject]
		public var requestCreateCanvasBackgroundSignal : RequestCreateCanvasBackgroundSignal;

		[Inject]
		public var requestNavigationStateChangeSignal : RequestNavigationStateChangeSignal;

		
		
		
		[Inject]
		public var requestCreatePaintingBackgroundSignal : RequestCreatePaintingBackgroundSignal;

		[Inject]
		public var notifyBackgroundSetSignal : NotifyFrozenBackgroundCreatedSignal;
		
		[Inject]
		public var notifyToggleLoadingMessageSignal:NotifyToggleLoadingMessageSignal;
		
		
		[Inject]
		public var requestGpuRenderingSignal:RequestGpuRenderingSignal;


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
			//GET THE CROPPED BITMAP DATA TO GIVE TO THE CANVAS MODEL LATER ON
			_croppedBitmapData = BitmapData(data.bitmapData);
			
			//DO THAT: 
			//add( DisposePaintingDataCommand 	         );
			//add( DisconnectHomeModuleShakeAndBakeCommand );
			//add( DestroyBookCommand );
			notifyHomeModuleDestroyedSignal.addOnce(onHomeModuleDestroyed);
			requestDestroyHomeModuleSignal.dispatch();
			
		}
		
		private function onHomeModuleDestroyed():void
		{
			// force position focused on easel in case we're going to quick for tweens to finish
			notifyBackgroundSetSignal.addOnce(onBackgroundSet);
			requestCreatePaintingBackgroundSignal.dispatch();
		}
		
		private function onBackgroundSet(background : RefCountedRectTexture) : void
		{
			if (_background) _background.dispose();
			_background = background.newReference();
			
			//SET THE BG OF CANVAS VIEW
			requestSetCanvasBackgroundSignal.dispatch(_background.newReference(), easelRectModel.absoluteScreenRect);
			
			
			
			
			//THEN LOAD THE SURFACE
			notifySurfaceLoadedSignal.addOnce(onSurfaceLoaded);
			requestLoadSurfaceSignal.dispatch(PaintMode.PHOTO_MODE);
			
			
		}
		
		
		private function onSurfaceLoaded(data : SurfaceDataVO) : void
		{
			
			
			notifyPaintModuleSetUp.addOnce(onPaintingModuleSetUp);
			requestSetupPaintModuleSignal.dispatch(createPaintingVO(data));
			
		}
		
		
		private function onPaintingModuleSetUp() : void
		{
			
			notifyCanvasBackgroundSetSignal.addOnce(onCanvasBackgroundSet);
			requestCreateCanvasBackgroundSignal.dispatch();
		}
		
		private function onCanvasBackgroundSet(background : RefCountedRectTexture) : void
		{
			
			
			notifyCanvasZoomedToDefaultViewSignal.addOnce( onZoomComplete );
			requestZoomCanvasToDefaultViewSignal.dispatch();
			
			requestNavigationStateChangeSignal.dispatch(NavigationStateType.TRANSITION_TO_PAINT_MODE);
		}
		
		private function onZoomComplete() : void
		{
			
			stateMachine.setActiveState(paintState);
			notifyToggleLoadingMessageSignal.dispatch(false);
		}
		
		override ns_state_machine function deactivate() : void
		{
			//REMOVE DISPLAY OF HOME HERE
			requestRemoveHomeModuleDisplaySignal.dispatch();
			
			
			use namespace ns_state_machine;
			super.deactivate();
		}
		
	/*
		
		
		private function onSurfaceLoaded(data : SurfaceDataVO) : void
		{
			
			
			
			//REMOVE SHAKE AND BAKE (swf with assets)
			//requestDisconnectHomeModuleShakeAndBakeSignal.dispatch();
			
			
			//CREATE PAINTING
			_paintingVO = createPaintingVO(data);
		
			
			//DESTROY HOME MODULE ALREADY
			notifyHomeModuleDestroyedSignal.addOnce( onHomeModuleDestroyed );
			requestDestroyHomeModuleSignal.dispatch();
			
			
			
		
		}
		

		
		private function onPaintingModuleSetUp() : void
		{
			//MATHIEU TEST: WE DESTROY HOME MODULE BEFORE LOADING DATAS
		//	notifyHomeModuleDestroyedSignal.addOnce( onHomeModuleDestroyed );
			//requestDestroyHomeModuleSignal.dispatch();
			//notifyHomeModuleDestroyedSignal.addOnce( onHomeModuleRemoved );
		
			
			//DISPOSE PAINTING
			//requestDisposePaintingDataSignal.dispatch();
			
			
			//DISCARD OLD BG
			//	requestRemoveHomeModuleDisplaySignal.addOnce(onHomeModuleRemoved);
			//requestRemoveHomeModuleDisplaySignal.dispatch();
			
			
			
			
			requestStateChangeSignal.dispatch(NavigationStateType.TRANSITION_TO_PAINT_MODE);
			
			notifyCanvasZoomedToDefaultViewSignal.addOnce( onZoomInComplete );
			requestZoomCanvasToDefaultViewSignal.dispatch();
			
			
			
		}
		
		private function onHomeModuleDestroyed():void
		{
			//ADD AN ENTERFRAME TO DISPOSE OBJECTS
			//requestGpuRenderingSignal.addOnce(onNextFrameLoaded);
			
			requestRemoveHomeModuleDisplaySignal.dispatch();
			
			
			
			notifyPaintModuleSetUp.addOnce(onPaintingModuleSetUp);
			requestSetupPaintModuleSignal.dispatch(_paintingVO);
			_paintingVO = null;
		
		}		
		

		private function onZoomInComplete() : void
		{
			//notifyHomeModuleDestroyedSignal.addOnce( onHomeModuleDestroyed );
			
			
			
			//DESTROY CROP MODULE
			requestDestroyCropModuleSignal.dispatch();

			stateMachine.setActiveState(paintState);
			notifyToggleLoadingMessageSignal.dispatch(false);
			
			_background.dispose();
			_background = null;
		}
		
		
		override ns_state_machine function deactivate() : void
		{
		use namespace ns_state_machine;
		super.deactivate();
		
		//_background.dispose();
		//_background = null;
		}
		*/

		private function createPaintingVO(surface : SurfaceDataVO) : PaintingDataVO
		{
			var paintingDataVO : PaintingDataVO = new PaintingDataVO();
			paintingDataVO.width = CoreSettings.STAGE_WIDTH;
			paintingDataVO.height = CoreSettings.STAGE_HEIGHT;
			paintingDataVO.sourceImageData =  _croppedBitmapData.getPixels(_croppedBitmapData.rect);
		
			//MATHIEU ADDED THIS, WE DISPOSE OF THE CROPPED BMD AS SOON AS NOT NEEDED
			_croppedBitmapData.dispose();
			_croppedBitmapData = null;
			
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
			else{
				paintingDataVO.colorData = ByteArrayUtil.createBlankColorData(CoreSettings.STAGE_WIDTH, CoreSettings.STAGE_HEIGHT, 0x00000000);}
			paintingDataVO.surfaceID = surface.id;
			paintingDataVO.normalSpecularData = null;
			paintingDataVO.surfaceNormalSpecularData = surface.normalSpecular;
			return paintingDataVO;
		}
		
	}
}
