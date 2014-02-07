package net.psykosoft.psykopaint2.crop.views.crop
{

	import flash.display.BitmapData;
	import flash.display.Stage3D;
	import flash.display3D.textures.Texture;
	import flash.geom.Rectangle;
	
	import net.psykosoft.psykopaint2.core.managers.gestures.GestureType;
	import net.psykosoft.psykopaint2.core.managers.rendering.GpuRenderManager;
	import net.psykosoft.psykopaint2.core.managers.rendering.GpuRenderingStepType;
	import net.psykosoft.psykopaint2.core.managers.rendering.RefCountedTexture;
	import net.psykosoft.psykopaint2.core.models.EaselRectModel;
	import net.psykosoft.psykopaint2.core.models.NavigationStateType;
	import net.psykosoft.psykopaint2.core.signals.NotifyEaselRectUpdateSignal;
	import net.psykosoft.psykopaint2.core.signals.NotifyGlobalGestureSignal;
	import net.psykosoft.psykopaint2.core.signals.NotifyToggleSwipeGestureSignal;
	import net.psykosoft.psykopaint2.core.signals.NotifyToggleTransformGestureSignal;
	import net.psykosoft.psykopaint2.core.signals.RequestFinalizeCropSignal;
	import net.psykosoft.psykopaint2.core.signals.RequestOpenCroppedBitmapDataSignal;
	import net.psykosoft.psykopaint2.core.signals.RequestUpdateCropImageSignal;
	import net.psykosoft.psykopaint2.core.views.base.MediatorBase;
	import net.psykosoft.psykopaint2.crop.signals.RequestDestroyCropModuleSignal;
	import net.psykosoft.psykopaint2.crop.signals.RequestSetCropBackgroundSignal;
	
	import org.gestouch.events.GestureEvent;

	public class CropViewMediator extends MediatorBase
	{
		[Inject]
		public var stage3D : Stage3D;

		[Inject]
		public var view:CropView;

		[Inject]
		public var requestSetCropBackgroundSignal : RequestSetCropBackgroundSignal;

		[Inject]
		public var requestUpdateCropImageSignal:RequestUpdateCropImageSignal;

		[Inject]
		public var requestOpenCroppedBitmapDataSignal:RequestOpenCroppedBitmapDataSignal;

		[Inject]
		public var notifyCropConfirmSignal:RequestFinalizeCropSignal;

		[Inject]
		public var easelRectModel : EaselRectModel;
		
		[Inject]
		public var notifyEaselRectUpdateSignal:NotifyEaselRectUpdateSignal;

		[Inject]
		public var requestDestroyCropModuleSignal : RequestDestroyCropModuleSignal;

		[Inject]
		public var notifyGlobalGestureSignal:NotifyGlobalGestureSignal;
		
		[Inject]
		public var toggleTransformGestureSignal:NotifyToggleTransformGestureSignal;
		
		[Inject]
		public var notifyToggleSwipeGestureSignal:NotifyToggleSwipeGestureSignal;
		
		override public function initialize():void {

			registerView( view );
			super.initialize();
			manageStateChanges = false;
//			registerEnablingState( NavigationStateType.CROP );
//			registerEnablingState( NavigationStateType.CROP_SKIP );

			// From app.
			requestUpdateCropImageSignal.add( updateCropSourceImage );
			notifyCropConfirmSignal.add( onRequestFinalizeCrop );
			requestSetCropBackgroundSignal.add( onSetCropBackgroundSignal );
			requestDestroyCropModuleSignal.add( onRequestDestroyCropModule );
			notifyEaselRectUpdateSignal.add( onEaselRectChanged );
			
			notifyGlobalGestureSignal.add( onGlobalGesture );
			
			// From view.
			view.enabledSignal.add( onEnabled );
			view.disabledSignal.add( onDisabled );

			// Enable view.
			view.enable();
			GpuRenderManager.addRenderingStep(render, GpuRenderingStepType.NORMAL,0);
		}
		
		private function onEaselRectChanged(value : Rectangle):void
		{
			view.easelRect = value;
			
		}
		
		private function onGlobalGesture( gestureType:String, event:GestureEvent):void
		{
			if ( gestureType == GestureType.TRANSFORM_GESTURE_BEGAN ||  gestureType == GestureType.TRANSFORM_GESTURE_ENDED || gestureType == GestureType.TRANSFORM_GESTURE_CHANGED )
			{
				view.onTransformGesture(event) ;
			}  
		}
		
		override public function destroy():void {

			// Clean up listeners.
			requestUpdateCropImageSignal.remove( updateCropSourceImage );
			notifyCropConfirmSignal.remove( onRequestFinalizeCrop );
			requestSetCropBackgroundSignal.remove( onSetCropBackgroundSignal );
			requestDestroyCropModuleSignal.remove( onRequestDestroyCropModule );
			notifyGlobalGestureSignal.remove( onGlobalGesture );
			notifyEaselRectUpdateSignal.remove( onEaselRectChanged );
			view.enabledSignal.remove( onEnabled );
			view.disabledSignal.remove( onDisabled );
			

			// Disable view.
			view.disable();
			GpuRenderManager.removeRenderingStep(render, GpuRenderingStepType.NORMAL);
			view.background = null;

			super.destroy();
		}

		private function onEnabled() : void
		{
//			GpuRenderManager.addRenderingStep(render, GpuRenderingStepType.NORMAL,0);
			toggleTransformGestureSignal.dispatch(true);
			notifyToggleSwipeGestureSignal.dispatch(false);
		}

		private function onDisabled() : void
		{
//			GpuRenderManager.removeRenderingStep(render, GpuRenderingStepType.NORMAL);
//			view.background = null;
			toggleTransformGestureSignal.dispatch(false);
			notifyToggleSwipeGestureSignal.dispatch(true);
		}

		private function render(target:Texture) : void
		{
			view.render(stage3D.context3D);
		}

		private function onRequestDestroyCropModule() : void
		{
			view.disposeCropData();
		}

		private function onSetCropBackgroundSignal(texture : RefCountedTexture) : void
		{
			view.background = texture;
		}

		// -----------------------
		// From app.
		// -----------------------

		public function onRequestFinalizeCrop():void {
			requestOpenCroppedBitmapDataSignal.dispatch( view.getCroppedImage() );
			view.disposeCropData();
		}

		private function updateCropSourceImage( bitmapData:BitmapData, orientation:int ):void {
			trace( this, "updateCropSourceImage" );
			view.easelRect = easelRectModel.localScreenRect;
			view.sourceMap = bitmapData;
		}
	}
}
