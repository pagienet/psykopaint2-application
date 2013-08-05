package net.psykosoft.psykopaint2.app.states
{
	import flash.display.BitmapData;

	import net.psykosoft.psykopaint2.app.signals.NotifyFrozenBackgroundCreatedSignal;
	import net.psykosoft.psykopaint2.app.signals.RequestCreateCropBackgroundSignal;

	import net.psykosoft.psykopaint2.base.states.State;
	import net.psykosoft.psykopaint2.base.states.ns_state_machine;
	import net.psykosoft.psykopaint2.core.signals.RequestNavigationStateChangeSignal_OLD_TO_REMOVE;
	import net.psykosoft.psykopaint2.crop.signals.NotifyCropModuleSetUpSignal;
	import net.psykosoft.psykopaint2.crop.signals.RequestSetupCropModuleSignal;
	import net.psykosoft.psykopaint2.home.signals.RequestDestroyHomeModuleSignal;

	use namespace ns_state_machine;

	public class TransitionHomeToCropState extends State
	{
		[Inject]
		public var cropState : CropState;

		[Inject]
		public var requestSetupCropModuleSignal : RequestSetupCropModuleSignal;

		[Inject]
		public var notifyCropModuleSetUpSignal : NotifyCropModuleSetUpSignal;

		[Inject]
		public var requestDestroyHomeModuleSignal : RequestDestroyHomeModuleSignal;

		[Inject]
		public var notifyBackgroundSetSignal : NotifyFrozenBackgroundCreatedSignal;

		[Inject]
		public var requestCreateCropBackgroundSignal : RequestCreateCropBackgroundSignal;

		[Inject]
		public var requestStateChangeSignal : RequestNavigationStateChangeSignal_OLD_TO_REMOVE;
		private var _bitmapData : BitmapData;

		public function TransitionHomeToCropState()
		{
		}

		/**
		 * @param data A BitmapData object containing the source image to be cropped
		 */
		override ns_state_machine function activate(data : Object = null) : void
		{
			_bitmapData = BitmapData(data);
			notifyBackgroundSetSignal.addOnce(onBackgroundSet);
			requestCreateCropBackgroundSignal.dispatch();

		}

		private function onBackgroundSet() : void
		{
			notifyCropModuleSetUpSignal.addOnce(onCropModuleSetUp);
			requestSetupCropModuleSignal.dispatch(_bitmapData);
			_bitmapData = null;
		}

		private function onCropModuleSetUp() : void
		{
			stateMachine.setActiveState(cropState);
		}

		override ns_state_machine function deactivate() : void
		{
			requestDestroyHomeModuleSignal.dispatch();
		}
	}
}
