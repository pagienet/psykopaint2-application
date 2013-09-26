package net.psykosoft.psykopaint2.core.views.popups.login
{

	import net.psykosoft.psykopaint2.core.signals.RequestHidePopUpSignal;
	import net.psykosoft.psykopaint2.core.views.base.MediatorBase;

	public class LoginPopUpViewMediator extends MediatorBase
	{
		[Inject]
		public var view:LoginPopUpView;

		[Inject]
		public var requestHidePopUpSignal:RequestHidePopUpSignal;

		override public function initialize():void {
			super.initialize();

			registerView( view );
			manageStateChanges = false;
			manageMemoryWarnings = false;

			// From view.
			view.popUpWantsToCloseSignal.add( onPopUpWantsToClose );

			// From app.

		}

		// -----------------------
		// From view.
		// -----------------------

		private function onPopUpWantsToClose():void {
			requestHidePopUpSignal.dispatch();
		}
	}
}
