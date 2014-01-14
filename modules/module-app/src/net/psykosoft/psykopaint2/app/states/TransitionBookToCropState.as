package net.psykosoft.psykopaint2.app.states
{
	import flash.display.BitmapData;

	import net.psykosoft.psykopaint2.app.signals.NotifyFrozenBackgroundCreatedSignal;

	import net.psykosoft.psykopaint2.app.signals.RequestCreateCropBackgroundSignal;

	import net.psykosoft.psykopaint2.base.states.State;
	import net.psykosoft.psykopaint2.base.states.ns_state_machine;
	import net.psykosoft.psykopaint2.book.signals.RequestDestroyBookModuleSignal;
	import net.psykosoft.psykopaint2.core.managers.rendering.RefCountedTexture;
	import net.psykosoft.psykopaint2.crop.signals.NotifyCropModuleSetUpSignal;
	import net.psykosoft.psykopaint2.crop.signals.RequestSetCropBackgroundSignal;
	import net.psykosoft.psykopaint2.crop.signals.RequestSetupCropModuleSignal;

	use namespace ns_state_machine;

	public class TransitionBookToCropState extends State
	{
		[Inject]
		public var cropState : CropState;

		[Inject]
		public var requestSetupCropModuleSignal : RequestSetupCropModuleSignal;

		[Inject]
		public var notifyCropModuleSetUpSignal : NotifyCropModuleSetUpSignal;

		[Inject]
		public var requestDestroyBookModuleSignal : RequestDestroyBookModuleSignal;

		[Inject]
		public var requestSetCropBackgroundSignal : RequestSetCropBackgroundSignal;

		[Inject]
		public var notifyBackgroundSetSignal : NotifyFrozenBackgroundCreatedSignal;

		[Inject]
		public var requestCreateCropBackgroundSignal : RequestCreateCropBackgroundSignal;

		private var _bitmapData : BitmapData;
		private var _background : RefCountedTexture;

		public function TransitionBookToCropState()
		{
		}

		/**
		 * @param data An object with the following layout:
		 * - bitmapData : BitmapData // object containing the source image to be cropped
		 * - background : RefCountedTexture // object containing the background for the crop module
		 */
		override ns_state_machine function activate(data : Object = null) : void
		{
			_bitmapData = BitmapData(data.bitmapData);
		}

		private function onAnimateOutComplete() : void
		{
			notifyBackgroundSetSignal.addOnce(onBackgroundSet);
			requestCreateCropBackgroundSignal.dispatch();
		}

		private function onBackgroundSet(background : RefCountedTexture) : void
		{
			if (_background) _background.dispose();
			_background = background.newReference();

			notifyCropModuleSetUpSignal.addOnce(onCropModuleSetUp);
			requestSetupCropModuleSignal.dispatch(_bitmapData);
		}

		private function onCropModuleSetUp() : void
		{
			stateMachine.setActiveState(cropState, {bitmapData: _bitmapData, background: _background.newReference()});
		}

		override ns_state_machine function deactivate() : void
		{
			requestDestroyBookModuleSignal.dispatch();
			if (_background) _background.dispose();
			_background = null;
			_bitmapData = null;
		}
	}
}
