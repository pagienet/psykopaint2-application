package net.psykosoft.psykopaint2.app.view.popups
{

	import net.psykosoft.psykopaint2.app.signal.notifications.NotifyCameraFlipSignal;
	import net.psykosoft.psykopaint2.app.view.base.StarlingMediatorBase;

	public class CaptureImagePopUpViewMediator extends StarlingMediatorBase
	{
		[Inject]
		public var view:CaptureImagePopUpView;

		[Inject]
		public var notifyCameraFlipSignal:NotifyCameraFlipSignal;

		override public function initialize():void {

			super.initialize();
			manageMemoryWarnings = false;
			manageStateChanges = false;

			// From app.
			notifyCameraFlipSignal.add( onFlipRequested );
		}

		// -----------------------
		// From app.
		// -----------------------

		private function onFlipRequested():void {
			view.flipCamera();
		}
	}
}
