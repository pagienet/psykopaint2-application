package net.psykosoft.psykopaint2.core.views.navigation
{

	import net.psykosoft.psykopaint2.base.ui.base.ViewBase;
	import net.psykosoft.psykopaint2.core.managers.gestures.GestureType;
	import net.psykosoft.psykopaint2.core.signals.NotifyExpensiveUiActionToggledSignal;
	import net.psykosoft.psykopaint2.core.signals.NotifyGlobalGestureSignal;
	import net.psykosoft.psykopaint2.core.views.base.MediatorBase;

	import org.gestouch.events.GestureEvent;

	public class SubNavigationMediatorBase extends MediatorBase
	{
		[Inject]
		public var notifyGlobalGestureSignal:NotifyGlobalGestureSignal;

		[Inject]
		public var notifyExpensiveUiActionToggledSignal:NotifyExpensiveUiActionToggledSignal;

		public function SubNavigationMediatorBase() {
			super();
		}

		override public function initialize():void {

			// Init.
			super.initialize();
			manageStateChanges = false;
			manageMemoryWarnings = false;

			// From app.
			notifyGlobalGestureSignal.add( onGlobalGesture );

			// From view.
			SubNavigationViewBase( _view ).enabledSignal.add( onViewEnabled );
			SubNavigationViewBase( _view ).disabledSignal.add( onViewDisabled );
			SubNavigationViewBase( _view ).scrollingStartedSignal.add( onViewScrollingStarted );
			SubNavigationViewBase( _view ).scrollingEndedSignal.add( onViewScrollingEnded );
		}

		// -----------------------
		// From view.
		// -----------------------

		protected function onViewEnabled():void {
			SubNavigationViewBase( _view ).navigation.buttonClickedSignal.add( onButtonClicked );
		}

		protected function onViewDisabled():void {
			SubNavigationViewBase( _view ).navigation.buttonClickedSignal.remove( onButtonClicked );
		}

		private function onViewScrollingEnded():void {
			notifyExpensiveUiActionToggledSignal.dispatch( false, "nav-scrolling" );
		}

		private function onViewScrollingStarted():void {
			notifyExpensiveUiActionToggledSignal.dispatch( true, "nav-scrolling" );
		}

		// -----------------------
		// From app.
		// -----------------------

		private function onGlobalGesture( gestureType:String, event:GestureEvent ):void {
//			trace( this, "onGlobalGesture: " + gestureType );
			switch( gestureType ) {
				case GestureType.HORIZONTAL_PAN_GESTURE_BEGAN: {
					SubNavigationViewBase( _view ).evaluateScrollingInteractionStart();
					break;
				}
				case GestureType.HORIZONTAL_PAN_GESTURE_ENDED: {
					SubNavigationViewBase( _view ).evaluateScrollingInteractionEnd();
					break;
				}
			}
		}

		// -----------------------
		// Private
		// -----------------------

		protected function onButtonClicked( label:String ):void {
			// Override to react to clicks on scroller and side buttons...
		}
	}
}
