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
	import net.psykosoft.psykopaint2.crop.signals.RequestDestroyCropModuleSignal;
	import net.psykosoft.psykopaint2.crop.signals.RequestSetupCropModuleSignal;

	use namespace ns_state_machine;

	public class CropState extends State
	{
		[Inject]
		public var requestStateChangeSignal : RequestNavigationStateChangeSignal_OLD_TO_REMOVE;

		[Inject]
		public var requestSetupCropModuleSignal : RequestSetupCropModuleSignal;

		[Inject]
		public var requestDestroyCropModuleSignal : RequestDestroyCropModuleSignal;

		[Inject]
		public var notifyCropModuleSetUpSignal : NotifyCropModuleSetUpSignal;

		[Inject]
		public var transitionToPaintState : TransitionCropToPaintState;

		[Inject]
		public var requestOpenCroppedBitmapDataSignal : RequestOpenCroppedBitmapDataSignal;
		// TODO: add requestHomeStateSignal

		public function CropState()
		{
		}

		/**
		 * @param data A BitmapData object containing the source image to be cropped
		 */
		override ns_state_machine function activate(data : Object = null) : void
		{
			var bitmapData : BitmapData = BitmapData(data);
			requestOpenCroppedBitmapDataSignal.add(onRequestOpenCroppedBitmapData);
			notifyCropModuleSetUpSignal.addOnce(onCropModuleSetUp);
			requestSetupCropModuleSignal.dispatch(bitmapData);
		}

		private function onCropModuleSetUp() : void
		{
			requestStateChangeSignal.dispatch(NavigationStateType.CROP);
		}

		override ns_state_machine function deactivate() : void
		{
			requestOpenCroppedBitmapDataSignal.remove(onRequestOpenCroppedBitmapData);
			requestDestroyCropModuleSignal.dispatch();
			requestStateChangeSignal.dispatch(NavigationStateType.CROP);
		}

		private function onRequestOpenCroppedBitmapData(bitmapData : BitmapData) : void
		{
			stateMachine.setActiveState(transitionToPaintState, bitmapData);
		}
	}
}
