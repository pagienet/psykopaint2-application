package net.psykosoft.psykopaint2.app.states
{
	import flash.display.BitmapData;

	import net.psykosoft.psykopaint2.app.signals.NotifyFrozenBackgroundCreatedSignal;
	import net.psykosoft.psykopaint2.app.signals.RequestCreatePaintingBackgroundSignal;

	import net.psykosoft.psykopaint2.base.states.State;
	import net.psykosoft.psykopaint2.base.states.ns_state_machine;
	import net.psykosoft.psykopaint2.core.managers.rendering.RefCountedRectTexture;
	import net.psykosoft.psykopaint2.core.signals.RequestNavigationStateChangeSignal;
	import net.psykosoft.psykopaint2.crop.signals.NotifyCropModuleSetUpSignal;
	import net.psykosoft.psykopaint2.crop.signals.RequestSetupCropModuleSignal;

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
		public var requestStateChangeSignal : RequestNavigationStateChangeSignal;

		private var _bitmapData : BitmapData;
		private var _orientation : int;

		public function TransitionHomeToCropState()
		{
		}

		/**
		 * @param data A BitmapData object containing the source image to be cropped
		 */
		override ns_state_machine function activate(data : Object = null) : void
		{
			_bitmapData = BitmapData(data.map);
			_orientation = int( data.orientation );

			notifyCropModuleSetUpSignal.addOnce(onCropModuleSetUp);
			requestSetupCropModuleSignal.dispatch(_bitmapData, _orientation);
		}

		private function onCropModuleSetUp() : void
		{
			stateMachine.setActiveState(cropState, {bitmapData: _bitmapData, orientation:_orientation});
		}

		override ns_state_machine function deactivate() : void
		{
			_bitmapData = null;
			_orientation = 0;
		}
	}
}
