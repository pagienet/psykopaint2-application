package net.psykosoft.psykopaint2.crop.views.crop
{

	import flash.display.Stage3D;
	
	import net.psykosoft.psykopaint2.core.managers.gestures.GestureManager;
	import net.psykosoft.psykopaint2.core.signals.NotifyToggleSwipeGestureSignal;
	import net.psykosoft.psykopaint2.core.signals.NotifyToggleTransformGestureSignal;
	import net.psykosoft.psykopaint2.core.views.base.MediatorBase;
	import net.psykosoft.psykopaint2.crop.signals.RequestDestroyCropModuleSignal;

	
	public class CropViewMediator extends MediatorBase
	{
		[Inject]
		public var stage3D : Stage3D;

		[Inject]
		public var view:CropView;
		
		[Inject]
		public var requestDestroyCropModuleSignal : RequestDestroyCropModuleSignal;

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
			requestDestroyCropModuleSignal.add( onRequestDestroyCropModule );
			
			// From view.
			view.enabledSignal.add( onEnabled );
			view.disabledSignal.add( onDisabled );

			// Enable view.
			view.enable();
		}
		
		override public function destroy():void {

			// Clean up listeners.
			
			requestDestroyCropModuleSignal.remove( onRequestDestroyCropModule );
			view.enabledSignal.remove( onEnabled );
			view.disabledSignal.remove( onDisabled );
			

			// Disable view.
			view.disable();

			super.destroy();
		}

		private function onEnabled() : void
		{
//			GpuRenderManager.addRenderingStep(render, GpuRenderingStepType.NORMAL,0);
			toggleTransformGestureSignal.dispatch(true);
			notifyToggleSwipeGestureSignal.dispatch(false);
			GestureManager.gesturesEnabled=true;
		}

		private function onDisabled() : void
		{
//			GpuRenderManager.removeRenderingStep(render, GpuRenderingStepType.NORMAL);
//			view.background = null;
			toggleTransformGestureSignal.dispatch(false);
			notifyToggleSwipeGestureSignal.dispatch(true);
		}

		private function onRequestDestroyCropModule() : void
		{}

	}
}
