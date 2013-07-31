package net.psykosoft.psykopaint2.core.views.popups
{

	import flash.utils.getDefinitionByName;
	import flash.utils.setTimeout;

	import net.psykosoft.psykopaint2.core.signals.NotifyPopUpRemovedSignal;
	import net.psykosoft.psykopaint2.core.signals.NotifyPopUpShownSignal;
	import net.psykosoft.psykopaint2.core.views.base.MediatorBase;

	public class PopUpManagerViewMediator extends MediatorBase
	{
		[Inject]
		public var view:PopUpManagerView;

		[Inject]
		public var notifyPopUpRemovedSignal:NotifyPopUpRemovedSignal;

		[Inject]
		public var notifyPopUpShownSignal:NotifyPopUpShownSignal;

		override public function initialize():void {

			registerView( view );
			super.initialize();
			manageMemoryWarnings = false;
			manageStateChanges = false;

			// From view.
			view.popUpShownSignal.add( onPopUpShown );
			view.popUpHiddenSignal.add( onPopUpHidden );
		}

		// -----------------------
		// From view.
		// -----------------------

		private function onPopUpShown():void {
			setTimeout( function():void {
				notifyPopUpShownSignal.dispatch();
			}, 100 );
		}

		private function onPopUpHidden():void {
			setTimeout( function():void {
				notifyPopUpRemovedSignal.dispatch();
			}, 100 );
		}

		// -----------------------
		// Private.
		// -----------------------

		private function showPopUp( popUpType:String ):void {
			var popUpClass:Class = Class( getDefinitionByName( popUpType ) );
			view.showPopUpOfClass( popUpClass );
		}

		private function hidePopUp():void {
			view.hideLastPopUp();
		}
	}
}
