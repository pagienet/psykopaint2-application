package net.psykosoft.psykopaint2.app.states
{
	import flash.display.BitmapData;

	import mx.modules.IModule;

	import net.psykosoft.psykopaint2.base.states.ns_state_machine;

	import net.psykosoft.psykopaint2.base.states.State;
	import net.psykosoft.psykopaint2.core.models.NavigationStateType;
	import net.psykosoft.psykopaint2.core.signals.RequestNavigationStateChangeSignal_OLD_TO_REMOVE;
	import net.psykosoft.psykopaint2.crop.signals.NotifyCropModuleSetUpSignal;
	import net.psykosoft.psykopaint2.crop.signals.RequestDestroyCropModuleSignal;
	import net.psykosoft.psykopaint2.crop.signals.RequestSetupCropModuleSignal;
	import net.psykosoft.psykopaint2.home.signals.RequestDestroyHomeModuleSignal;

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

		private var _bitmapData : BitmapData;

		public function CropState()
		{
		}

		override ns_state_machine function activate() : void
		{
			notifyCropModuleSetUpSignal.addOnce(onCropModuleSetUp);
			requestSetupCropModuleSignal.dispatch(_bitmapData);
		}

		private function onCropModuleSetUp() : void
		{
			requestStateChangeSignal.dispatch(NavigationStateType.CROP);
		}

		override ns_state_machine function deactivate() : void
		{
			requestDestroyCropModuleSignal.dispatch();
			requestStateChangeSignal.dispatch(NavigationStateType.CROP);
		}

		// provided by home state, not sure if I'm a fan of passing stuff like this :s
		public function setSourceBitmapData(bitmapData : BitmapData) : void
		{
			_bitmapData = bitmapData;
		}
	}
}
