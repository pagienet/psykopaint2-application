package net.psykosoft.psykopaint2.core.views.popups
{

	import flash.utils.getDefinitionByName;
	import flash.utils.setTimeout;

	import net.psykosoft.psykopaint2.core.signals.NotifyCanvasExportEndedSignal;

	import net.psykosoft.psykopaint2.core.signals.NotifyCanvasExportStartedSignal;

	import net.psykosoft.psykopaint2.core.signals.NotifyPaintingSavedSignal;

	import net.psykosoft.psykopaint2.core.signals.NotifyPaintingSavingStartedSignal;

	import net.psykosoft.psykopaint2.core.signals.NotifyPopUpRemovedSignal;
	import net.psykosoft.psykopaint2.core.signals.NotifyPopUpShownSignal;
	import net.psykosoft.psykopaint2.core.signals.RequestHidePopUpSignal;
	import net.psykosoft.psykopaint2.core.signals.RequestShowPopUpSignal;
	import net.psykosoft.psykopaint2.core.signals.RequestUpdateMessagePopUpSignal;
	import net.psykosoft.psykopaint2.core.views.base.MediatorBase;
	import net.psykosoft.psykopaint2.core.views.popups.base.Jokes;
	import net.psykosoft.psykopaint2.core.views.popups.base.PopUpType;

	public class PopUpManagerViewMediator extends MediatorBase
	{
		[Inject]
		public var view:PopUpManagerView;

		[Inject]
		public var notifyPopUpRemovedSignal:NotifyPopUpRemovedSignal;

		[Inject]
		public var notifyPopUpShownSignal:NotifyPopUpShownSignal;

		[Inject]
		public var requestUpdateMessagePopUpSignal:RequestUpdateMessagePopUpSignal;

		[Inject]
		public var requestShowPopUpSignal:RequestShowPopUpSignal;

		[Inject]
		public var requestHidePopUpSignal:RequestHidePopUpSignal;

		override public function initialize():void {

			registerView( view );
			super.initialize();
			manageMemoryWarnings = false;
			manageStateChanges = false;

			// From app.
//			notifyPaintingSavingStartedSignal.add( onPaintingSavingStarted );
//			notifyPaintingSavedSignal.add( onPaintingSavingEnded );
			notifyCanvasExportStartedSignal.add( onExportCanvasStarted );
			notifyCanvasExportEndedSignal.add( onExportCanvasEnded );
			requestShowPopUpSignal.add( onShowPopUpRequest );
			requestHidePopUpSignal.add( onHidePopUpRequest );

			// From view.
			view.popUpShownSignal.add( onPopUpShown );
			view.popUpHiddenSignal.add( onPopUpHidden );
		}

		// ---------------------------------------------------------------------
		// From app.
		// ---------------------------------------------------------------------

		private function onShowPopUpRequest( popUpType:String ):void {
			showPopUp( popUpType );
		}

		private function onHidePopUpRequest():void {
			hidePopUp();
		}

		// -----------------------
		// Saving.
		// -----------------------

		[Inject]
		public var notifyPaintingSavingStartedSignal:NotifyPaintingSavingStartedSignal;

		[Inject]
		public var notifyPaintingSavedSignal:NotifyPaintingSavedSignal;

		private function onPaintingSavingStarted():void {
			showPopUp( PopUpType.MESSAGE );
			var randomJoke:String = Jokes.JOKES[ Math.floor( Jokes.JOKES.length * Math.random() ) ];
			requestUpdateMessagePopUpSignal.dispatch( "Saving...", randomJoke );
		}

		private function onPaintingSavingEnded( success:Boolean ):void {
			hidePopUp();
		}

		// -----------------------
		// Exporting.
		// -----------------------

		[Inject]
		public var notifyCanvasExportStartedSignal:NotifyCanvasExportStartedSignal;

		[Inject]
		public var notifyCanvasExportEndedSignal:NotifyCanvasExportEndedSignal;

		private function onExportCanvasStarted():void {
			showPopUp( PopUpType.MESSAGE );
			requestUpdateMessagePopUpSignal.dispatch( "Saving...", "" );
		}

		private function onExportCanvasEnded():void {
			hidePopUp();
		}

		// ---------------------------------------------------------------------
		// From view.
		// ---------------------------------------------------------------------

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
