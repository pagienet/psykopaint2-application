package net.psykosoft.psykopaint2.core.views.popups.error
{
	import net.psykosoft.psykopaint2.core.signals.RequestHidePopUpSignal;
	import net.psykosoft.psykopaint2.core.signals.RequestUpdateErrorPopUpSignal;
	import net.psykosoft.psykopaint2.core.views.base.MediatorBase;

	public class ErrorPopUpViewMediator extends MediatorBase
	{
		[Inject]
		public var view:ErrorPopUpView;

		[Inject]
		public var requestUpdateErrorPopUpSignal:RequestUpdateErrorPopUpSignal;

		[Inject]
		public var requestHidePopUpSignal:RequestHidePopUpSignal;

		override public function initialize():void {
			super.initialize();

			registerView( view );
			manageStateChanges = false;
			manageMemoryWarnings = false;

			// From app.
			view.popUpWantsToCloseSignal.add(onRequestClose);
			requestUpdateErrorPopUpSignal.add( onMessageUpdateRequest );
		}

		override public function destroy():void
		{
			super.destroy();
			view.popUpWantsToCloseSignal.remove(onRequestClose);
		}

		private function onMessageUpdateRequest( newTitle:String, newMessage:String ):void {
			view.updateMessage( newTitle, newMessage );
		}

		private function onRequestClose():void
		{
			requestHidePopUpSignal.dispatch();
		}
	}
}
