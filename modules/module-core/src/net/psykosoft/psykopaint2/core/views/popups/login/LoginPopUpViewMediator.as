package net.psykosoft.psykopaint2.core.views.popups.login
{

	import net.psykosoft.psykopaint2.core.models.LoggedInUserProxy;
	import net.psykosoft.psykopaint2.core.signals.NotifyUserLogInFailedSignal;
	import net.psykosoft.psykopaint2.core.signals.NotifyUserLoggedInSignal;
	import net.psykosoft.psykopaint2.core.signals.RequestHidePopUpSignal;
	import net.psykosoft.psykopaint2.core.views.base.MediatorBase;

	public class LoginPopUpViewMediator extends MediatorBase
	{
		[Inject]
		public var view:LoginPopUpView;

		[Inject]
		public var requestHidePopUpSignal:RequestHidePopUpSignal;

		[Inject]
		public var loggedInUserProxy:LoggedInUserProxy;

		[Inject]
		public var notifyUserLoggedInSignal : NotifyUserLoggedInSignal;

		[Inject]
		public var notifyUserLogInFailedSignal : NotifyUserLogInFailedSignal;

		override public function initialize():void {
			super.initialize();

			registerView( view );
			manageStateChanges = false;
			manageMemoryWarnings = false;

			// From view.
			view.popUpWantsToCloseSignal.add( onPopUpWantsToClose );
			view.popUpWantsToLogInSignal.add( onPopUpWantsToLogIn );

			// From app.
			notifyUserLoggedInSignal.add( onLoginSuccess );
			notifyUserLogInFailedSignal.add( onLoginFailure );
		}

		override public function destroy():void {
			super.destroy();

			view.popUpWantsToCloseSignal.remove( onPopUpWantsToClose );
			view.popUpWantsToLogInSignal.remove( onPopUpWantsToLogIn );
			notifyUserLoggedInSignal.remove( onLoginSuccess );
			notifyUserLogInFailedSignal.remove( onLoginFailure );
		}

		private function onLoginFailure( amfErrorCode:int ):void {
			trace( this, "login failed" );
			// TODO: give feedback about error
			view.rejectPassword();
		}

		private function onLoginSuccess():void {
			trace( this, "login successful!" );
			requestHidePopUpSignal.dispatch();
		}

		// -----------------------
		// From view.
		// -----------------------

		private function onPopUpWantsToLogIn( email:String, password:String ):void {
			loggedInUserProxy.logIn( email, password );
		}

		private function onPopUpWantsToClose():void {
			requestHidePopUpSignal.dispatch();
		}
	}
}
