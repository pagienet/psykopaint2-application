package net.psykosoft.psykopaint2.app.states
{

	import flash.utils.setTimeout;

	import net.psykosoft.psykopaint2.base.states.ns_state_machine;

	import net.psykosoft.psykopaint2.base.states.State;
	import net.psykosoft.psykopaint2.core.model.CanvasHistoryModel;
	import net.psykosoft.psykopaint2.core.models.NavigationStateType;
	import net.psykosoft.psykopaint2.core.models.PaintingModel;
	import net.psykosoft.psykopaint2.core.signals.NotifyPaintingSavedSignal;
	import net.psykosoft.psykopaint2.core.signals.NotifyPopUpRemovedSignal;
	import net.psykosoft.psykopaint2.core.signals.NotifyPopUpShownSignal;
	import net.psykosoft.psykopaint2.core.signals.RequestHidePopUpSignal;
	import net.psykosoft.psykopaint2.core.signals.RequestNavigationStateChangeSignal;
	import net.psykosoft.psykopaint2.core.signals.RequestShowPopUpSignal;
	import net.psykosoft.psykopaint2.core.signals.RequestUpdateMessagePopUpSignal;
	import net.psykosoft.psykopaint2.core.views.popups.base.Jokes;
	import net.psykosoft.psykopaint2.core.views.popups.base.PopUpType;
	import net.psykosoft.psykopaint2.paint.signals.RequestClosePaintViewSignal;
	import net.psykosoft.psykopaint2.paint.signals.RequestPaintingSaveSignal;

	use namespace ns_state_machine;

	public class PaintState extends State
	{
		[Inject]
		public var requestStateChangeSignal:RequestNavigationStateChangeSignal;

		[Inject]
		public var transitionToHomeState:TransitionPaintToHomeState;

		[Inject]
		public var requestClosePaintView:RequestClosePaintViewSignal;

		[Inject]
		public var requestPaintingSaveSignal:RequestPaintingSaveSignal;

		[Inject]
		public var notifyPaintingSavedSignal:NotifyPaintingSavedSignal;

		[Inject]
		public var paintingModel:PaintingModel;

		[Inject]
		public var canvasHistoryModel:CanvasHistoryModel;

		[Inject]
		public var requestShowPopUpSignal:RequestShowPopUpSignal;

		[Inject]
		public var requestUpdateMessagePopUpSignal:RequestUpdateMessagePopUpSignal;

		[Inject]
		public var notifyPopUpShownSignal:NotifyPopUpShownSignal;

		[Inject]
		public var requestHidePopUpSignal:RequestHidePopUpSignal;

		[Inject]
		public var notifyPopUpRemovedSignal:NotifyPopUpRemovedSignal;

		public function PaintState() {
		}

		override ns_state_machine function activate( data:Object = null ):void {
			requestClosePaintView.add( onClosePaintView );
			requestStateChangeSignal.dispatch( NavigationStateType.PAINT_SELECT_BRUSH );
		}

		override ns_state_machine function deactivate():void {
			requestClosePaintView.remove( onClosePaintView );
		}

		private function onClosePaintView():void {
			if( canvasHistoryModel.hasHistory ) displaySavingPopUpCommand();
			else continueToHome();
		}

		private function displaySavingPopUpCommand():void {
			requestShowPopUpSignal.dispatch( PopUpType.MESSAGE );
			var randomJoke:String = Jokes.JOKES[ Math.floor( Jokes.JOKES.length * Math.random() ) ];
			requestUpdateMessagePopUpSignal.dispatch( "Saving...", randomJoke );
			notifyPopUpShownSignal.addOnce( savePainting );
		}

		private function savePainting():void {
			notifyPaintingSavedSignal.addOnce( onPaintingSaved );
			requestPaintingSaveSignal.dispatch( paintingModel.activePaintingId, true );
		}

		private function onPaintingSaved( success:Boolean ):void {
			setTimeout( hideSavingPopUp, 1000 );
		}

		private function hideSavingPopUp():void {
			notifyPopUpRemovedSignal.addOnce( onPopUpRemoved );
			requestHidePopUpSignal.dispatch();
		}

		private function onPopUpRemoved():void {
			continueToHome();
		}

		private function continueToHome():void {
			stateMachine.setActiveState( transitionToHomeState );
		}
	}
}
