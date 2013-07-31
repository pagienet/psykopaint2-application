package net.psykosoft.psykopaint2.core.views.popups
{

	import net.psykosoft.psykopaint2.core.views.base.MediatorBase;

	public class MessagePopUpViewMediator extends MediatorBase
	{
		[Inject]
		public var view:MessagePopUpView;

		override public function initialize():void {
			super.initialize();

			registerView( view );
			manageStateChanges = false;
			manageMemoryWarnings = false;
		}

		private function onMessageUpdateRequest( newTitle:String, newMessage:String ):void {
			view.updateMessage( newTitle, newMessage );
		}
	}
}
