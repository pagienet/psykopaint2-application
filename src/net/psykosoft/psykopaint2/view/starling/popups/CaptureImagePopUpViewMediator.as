package net.psykosoft.psykopaint2.view.starling.popups
{

	import net.psykosoft.psykopaint2.signal.notifications.NotifyCameraFlipSignal;

	import robotlegs.extensions.starlingViewMap.impl.StarlingMediator;

	public class CaptureImagePopUpViewMediator extends StarlingMediator
	{
		[Inject]
		public var view:CaptureImagePopUpView;

		[Inject]
		public var notifyCameraFlipSignal:NotifyCameraFlipSignal;

		override public function initialize():void {

			// From app.
			notifyCameraFlipSignal.add( onFlipRequested );

			super.initialize();

		}

		// -----------------------
		// From app.
		// -----------------------

		private function onFlipRequested():void {
			view.flipCamera();
		}
	}
}
