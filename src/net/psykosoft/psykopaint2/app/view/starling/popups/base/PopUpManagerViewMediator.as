package net.psykosoft.psykopaint2.app.view.starling.popups.base
{

	import flash.utils.getDefinitionByName;

	import net.psykosoft.psykopaint2.app.signal.notifications.NotifyPopUpDisplaySignal;
	import net.psykosoft.psykopaint2.app.signal.notifications.NotifyPopUpRemovalSignal;
	import net.psykosoft.psykopaint2.app.signal.notifications.NotifyPopUpRemovedSignal;
	import net.psykosoft.psykopaint2.app.view.starling.popups.base.PopUpManagerView;

	import robotlegs.extensions.starlingViewMap.impl.StarlingMediator;

	public class PopUpManagerViewMediator extends StarlingMediator
	{
		[Inject]
		public var view:PopUpManagerView;

		[Inject]
		public var notifyPopUpDisplaySignal:NotifyPopUpDisplaySignal;

		[Inject]
		public var notifyPopUpRemovedSignal:NotifyPopUpRemovedSignal;

		[Inject]
		public var notifyPopUpRemovalSignal:NotifyPopUpRemovalSignal;

		override public function initialize():void {

			// From app.
			notifyPopUpDisplaySignal.add( onPopUp );
			notifyPopUpRemovalSignal.add( onPopUpRemoval );

			// From view.
			view.popUpClosedSignal.add( onPopUpClosed );

			super.initialize();
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

		private function onPopUpRemoval():void {
			view.hideLastPopUp();
		}

		private function onPopUp( popUpType:String ):void {
			var popUpClass:Class = getDefinitionByName( "net.psykosoft.psykopaint2.app.view.starling.popups." + popUpType ) as Class;
			view.showPopUp( popUpClass );
		}
	}
}
