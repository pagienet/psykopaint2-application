package net.psykosoft.psykopaint2.app.view.popups.base
{

	import flash.utils.getDefinitionByName;

	import net.psykosoft.psykopaint2.app.signal.notifications.NotifyPopUpDisplaySignal;
	import net.psykosoft.psykopaint2.app.signal.notifications.NotifyPopUpRemovalSignal;
	import net.psykosoft.psykopaint2.app.signal.notifications.NotifyPopUpRemovedSignal;
	import net.psykosoft.psykopaint2.app.view.base.StarlingMediatorBase;

	public class PopUpManagerViewMediator extends StarlingMediatorBase
	{
		[Inject]
		public var popUpManagerView:PopUpManagerView;

		[Inject]
		public var notifyPopUpDisplaySignal:NotifyPopUpDisplaySignal;

		[Inject]
		public var notifyPopUpRemovedSignal:NotifyPopUpRemovedSignal;

		[Inject]
		public var notifyPopUpRemovalSignal:NotifyPopUpRemovalSignal;

		override public function initialize():void {

			super.initialize();
			registerView( popUpManagerView );
			manageStateChanges = false;

			// From app.
			notifyPopUpDisplaySignal.add( onPopUp );
			notifyPopUpRemovalSignal.add( onPopUpRemoval );

			// From view.
			popUpManagerView.popUpClosedSignal.add( onPopUpClosed );
		}

		// -----------------------
		// From view.
		// -----------------------

		private function onPopUpClosed():void {
			popUpManagerView.hideLastPopUp();
			notifyPopUpRemovedSignal.dispatch();
		}

		// -----------------------
		// From app.
		// -----------------------

		private function onPopUpRemoval():void {
			popUpManagerView.hideLastPopUp();
		}

		private function onPopUp( popUpType:String ):void {
			var popUpClass:Class = getDefinitionByName( "net.psykosoft.psykopaint2.app.view.popups." + popUpType ) as Class;
			popUpManagerView.showPopUp( popUpClass );
		}
	}
}
