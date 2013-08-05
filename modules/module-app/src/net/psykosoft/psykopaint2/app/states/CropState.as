package net.psykosoft.psykopaint2.app.states
{
	import flash.display.BitmapData;

	import mx.modules.IModule;

	import net.psykosoft.psykopaint2.base.states.ns_state_machine;

	import net.psykosoft.psykopaint2.base.states.State;
	import net.psykosoft.psykopaint2.core.models.NavigationStateType;
	import net.psykosoft.psykopaint2.core.signals.RequestNavigationStateChangeSignal_OLD_TO_REMOVE;
	import net.psykosoft.psykopaint2.core.signals.RequestOpenCroppedBitmapDataSignal;
	import net.psykosoft.psykopaint2.crop.signals.NotifyCropModuleSetUpSignal;
	import net.psykosoft.psykopaint2.crop.signals.RequestCancelCropSignal;
	import net.psykosoft.psykopaint2.crop.signals.RequestDestroyCropModuleSignal;
	import net.psykosoft.psykopaint2.crop.signals.RequestSetupCropModuleSignal;

	use namespace ns_state_machine;

	public class CropState extends State
	{
		[Inject]
		public var requestStateChangeSignal : RequestNavigationStateChangeSignal_OLD_TO_REMOVE;

		[Inject]
		public var requestDestroyCropModuleSignal : RequestDestroyCropModuleSignal;

		[Inject]
		public var requestOpenCroppedBitmapDataSignal : RequestOpenCroppedBitmapDataSignal;

		[Inject]
		public var requestCancelCropSignal : RequestCancelCropSignal;

		[Inject]
		public var transitionToPaintState : TransitionCropToPaintState;

		// Effing Robotlegs can't inject circular dependencies -_-
		// HomeState will set this explicitly
		public var homeState : HomeState;

		public function CropState()
		{
		}


		override ns_state_machine function activate(data : Object = null) : void
		{
			requestStateChangeSignal.dispatch(NavigationStateType.CROP);
			requestCancelCropSignal.add(onRequestCancelCropSignal);
			requestOpenCroppedBitmapDataSignal.add(onRequestOpenCroppedBitmapData);
		}

		override ns_state_machine function deactivate() : void
		{
			requestCancelCropSignal.remove(onRequestCancelCropSignal);
			requestOpenCroppedBitmapDataSignal.remove(onRequestOpenCroppedBitmapData);
			requestDestroyCropModuleSignal.dispatch();
		}

		private function onRequestOpenCroppedBitmapData(bitmapData : BitmapData) : void
		{
			stateMachine.setActiveState(transitionToPaintState, bitmapData);
		}

		private function onRequestCancelCropSignal() : void
		{
			stateMachine.setActiveState(homeState);
			requestStateChangeSignal.dispatch(NavigationStateType.PICK_IMAGE);
		}
	}
}
