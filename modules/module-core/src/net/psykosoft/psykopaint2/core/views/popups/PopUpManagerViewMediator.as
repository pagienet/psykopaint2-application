package net.psykosoft.psykopaint2.core.views.popups
{

	import flash.utils.getDefinitionByName;
	import flash.utils.setTimeout;

	import net.psykosoft.psykopaint2.core.signals.NotifyCanvasExportEndedSignal;
	import net.psykosoft.psykopaint2.core.signals.NotifyCanvasExportStartedSignal;
import net.psykosoft.psykopaint2.core.signals.NotifyDataForPopUpSignal;
import net.psykosoft.psykopaint2.core.signals.NotifyPopUpRemovedSignal;
	import net.psykosoft.psykopaint2.core.signals.NotifyPopUpShownSignal;
	import net.psykosoft.psykopaint2.core.signals.RequestHidePopUpSignal;
	import net.psykosoft.psykopaint2.core.signals.RequestShowPopUpSignal;
	import net.psykosoft.psykopaint2.core.signals.RequestUpdateMessagePopUpSignal;
	import net.psykosoft.psykopaint2.core.views.base.MediatorBase;
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

		/*
			BEFORE YOU DELETE THESE!
			If you're thinking about refactoring pop ups so that other application elements do not request
			when to show/hide pop ups and instead simply notify what they're doing, consider that the
			current reverse implementation exists because of the lack of workers in iOS and our inhability to
			run the UI on a separate thread. Hence, we delegate the responsibility of showing and hiding pop ups
			to other objects.
			For example, the saving process could notify that it's saving and get on with it right away. This view would listen
			and trigger a pop up, but since the saving started, the cpu is busy and the pop up will not show until saving is done.
			Instead, and in the current implementation, saving starts, requests the pop up, -waits for it- and continues. It sucks,
			but this way we actually see the pop up in time.
		 */

		[Inject]
		public var requestShowPopUpSignal:RequestShowPopUpSignal;

		[Inject]
		public var requestHidePopUpSignal:RequestHidePopUpSignal;

		[Inject]
		public var notifyDataForPopUpSignal:NotifyDataForPopUpSignal;

		override public function initialize():void {

			registerView( view );
			super.initialize();
			manageMemoryWarnings = false;
			manageStateChanges = false;

			// From app.
			notifyCanvasExportStartedSignal.add( onExportCanvasStarted );
			notifyCanvasExportEndedSignal.add( onExportCanvasEnded );
			requestShowPopUpSignal.add( onShowPopUpRequest );
			requestHidePopUpSignal.add( onHidePopUpRequest );
			notifyDataForPopUpSignal.add( onDataForPopUp );

			// From view.
			view.popUpShownSignal.add( onPopUpShown );
			view.popUpHiddenSignal.add( onPopUpHidden );

			// For working on pop ups. Keep commented...
//			onShowPopUpRequest(PopUpType.SHARE);
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

		private function onDataForPopUp(data:Array):void {
			view.data = data;
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
