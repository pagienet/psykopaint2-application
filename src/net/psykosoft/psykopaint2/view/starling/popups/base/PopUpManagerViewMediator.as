package net.psykosoft.psykopaint2.view.starling.popups.base
{

	import flash.utils.getDefinitionByName;

	import net.psykosoft.psykopaint2.signal.notifications.NotifyPopUpDisplaySignal;
	import net.psykosoft.psykopaint2.signal.notifications.NotifyPopUpRemovalSignal;
	import net.psykosoft.psykopaint2.view.starling.popups.base.PopUpManagerView;

	import robotlegs.extensions.starlingViewMap.impl.StarlingMediator;

	public class PopUpManagerViewMediator extends StarlingMediator
	{
		[Inject]
		public var view:PopUpManagerView;

		[Inject]
		public var notifyPopUpDisplaySignal:NotifyPopUpDisplaySignal;

		[Inject]
		public var notifyPopUpRemovalSignal:NotifyPopUpRemovalSignal;

		override public function initialize():void {

			// From app.
			notifyPopUpDisplaySignal.add( onPopUp );

			// From view.
			view.popUpClosedSignal.add( onPopUpClosed );

			super.initialize();
		}

		// -----------------------
		// From view.
		// -----------------------

		private function onPopUpClosed():void {
			view.hideLastPopUp();
			notifyPopUpRemovalSignal.dispatch();
		}

		// -----------------------
		// From app.
		// -----------------------

		private function onPopUp( popUpType:String ):void {
			var popUpClass:Class = getDefinitionByName( "net.psykosoft.psykopaint2.view.starling.popups." + popUpType ) as Class;
			view.showPopUp( popUpClass );
		}
	}
}
