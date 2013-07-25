package net.psykosoft.psykopaint2.core.views.navigation
{

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
			SubNavigationViewBase( _view ).scrollingStartedSignal.add( onViewScrollingStarted );
			SubNavigationViewBase( _view ).scrollingEndedSignal.add( onViewScrollingEnded );
		}

		// -----------------------
		// From view.
		// -----------------------

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
	}
}
