package net.psykosoft.psykopaint2.app.states
{
	import flash.display.BitmapData;

	import net.psykosoft.psykopaint2.app.signals.NotifyFrozenBackgroundCreatedSignal;
	import net.psykosoft.psykopaint2.app.signals.RequestCreateCropBackgroundSignal;

	import net.psykosoft.psykopaint2.base.states.State;
	import net.psykosoft.psykopaint2.base.states.ns_state_machine;
	import net.psykosoft.psykopaint2.book.signals.NotifyAnimateBookOutCompleteSignal;
	import net.psykosoft.psykopaint2.book.signals.RequestAnimateBookOutSignal;
	import net.psykosoft.psykopaint2.book.signals.RequestDestroyBookModuleSignal;
	import net.psykosoft.psykopaint2.core.managers.rendering.RefCountedTexture;
	import net.psykosoft.psykopaint2.core.models.NavigationStateType;
	import net.psykosoft.psykopaint2.core.signals.RequestNavigationStateChangeSignal;
	import net.psykosoft.psykopaint2.crop.signals.NotifyCropModuleSetUpSignal;
	import net.psykosoft.psykopaint2.crop.signals.RequestSetCropBackgroundSignal;
	import net.psykosoft.psykopaint2.crop.signals.RequestSetupCropModuleSignal;
	import net.psykosoft.psykopaint2.home.signals.RequestDestroyHomeModuleSignal;

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
		public var notifyBackgroundSetSignal : NotifyFrozenBackgroundCreatedSignal;

		[Inject]
		public var requestSetCropBackgroundSignal : RequestSetCropBackgroundSignal;

		[Inject]
		public var requestStateChangeSignal : RequestNavigationStateChangeSignal;

		[Inject]
		public var requestAnimateOutSignal : RequestAnimateBookOutSignal;

		[Inject]
		public var notifyAnimateBookOutCompleteSignal : NotifyAnimateBookOutCompleteSignal;

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
			var bitmapData : BitmapData = BitmapData(data.bitmapData);
			_background = RefCountedTexture(data.background);

			notifyCropModuleSetUpSignal.addOnce(onCropModuleSetUp);
			requestSetupCropModuleSignal.dispatch(bitmapData);
		}

		private function onCropModuleSetUp() : void
		{
			requestSetCropBackgroundSignal.dispatch(_background.newReference());
			notifyAnimateBookOutCompleteSignal.addOnce(onAnimateOutComplete);
			requestAnimateOutSignal.dispatch();
		}

		private function onAnimateOutComplete() : void
		{
			stateMachine.setActiveState(cropState);
		}

		override ns_state_machine function deactivate() : void
		{
			requestDestroyBookModuleSignal.dispatch();
			_background.dispose();
			_background = null;
		}
	}
}
