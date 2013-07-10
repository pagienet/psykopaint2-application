package net.psykosoft.psykopaint2.core.views.popups.base
{

	import flash.utils.getDefinitionByName;

	import net.psykosoft.psykopaint2.core.signals.NotifyPopUpRemovedSignal;
	import net.psykosoft.psykopaint2.core.signals.RequestPopUpDisplaySignal;
	import net.psykosoft.psykopaint2.core.signals.RequestPopUpRemovalSignal;
	import net.psykosoft.psykopaint2.core.views.base.MediatorBase;
	import net.psykosoft.psykopaint2.core.views.popups.SavingPopUpView;

	public class PopUpManagerViewMediator extends MediatorBase
	{
		[Inject]
		public var view:PopUpManagerView;

		[Inject]
		public var requestPopUpDisplaySignal:RequestPopUpDisplaySignal;

		[Inject]
		public var requestPopUpRemovalSignal:RequestPopUpRemovalSignal;

		[Inject]
		public var notifyPopUpRemovedSignal:NotifyPopUpRemovedSignal;

		override public function initialize():void {

			super.initialize();
			registerView( view );
			manageMemoryWarnings = false;
			manageStateChanges = false;

			// From app.
			requestPopUpDisplaySignal.add( onPopUpDisplayRequest );
			requestPopUpRemovalSignal.add( onPopUpRemovalRequest );

			// From view.
			view.popUpClosedSignal.add( onPopUpClosed );
		}

		// -----------------------
		// From view.
		// -----------------------

		private function onPopUpClosed():void {
			view.hideLastPopUp();
			notifyPopUpRemovedSignal.dispatch();
		}

		// -----------------------
		// From app.
		// -----------------------

		private function onPopUpDisplayRequest( popUpType:String ):void {
			var popUpClass:Class = Class( getDefinitionByName( popUpType ) );
			view.showPopUpOfClass( popUpClass );
		}

		private function onPopUpRemovalRequest():void {
			view.hideLastPopUp();
			notifyPopUpRemovedSignal.dispatch();
		}
	}
}
