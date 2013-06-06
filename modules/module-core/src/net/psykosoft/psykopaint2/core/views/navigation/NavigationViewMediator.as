package net.psykosoft.psykopaint2.core.views.navigation
{

	import net.psykosoft.psykopaint2.core.managers.gestures.GestureType;
	import net.psykosoft.psykopaint2.core.models.StateType;
	import net.psykosoft.psykopaint2.core.signals.NotifyGlobalGestureSignal;
	import net.psykosoft.psykopaint2.core.signals.NotifyNavigationToggledSignal;
	import net.psykosoft.psykopaint2.core.signals.NotifyExpensiveUiActionToggledSignal;
	import net.psykosoft.psykopaint2.core.signals.RequestNavigationToggleSignal;
	import net.psykosoft.psykopaint2.core.views.base.MediatorBase;

	public class NavigationViewMediator extends MediatorBase
	{
		[Inject]
		public var view:SbNavigationView;

		[Inject]
		public var notifyGlobalGestureSignal:NotifyGlobalGestureSignal;

		[Inject]
		public var notifyNavigationToggledSignal:NotifyNavigationToggledSignal;

		[Inject]
		public var notifyExpensiveUiActionToggledSignal:NotifyExpensiveUiActionToggledSignal;

		[Inject]
		public var requestNavigationToggleSignal:RequestNavigationToggleSignal;

		override public function initialize():void {

			super.initialize();
			registerView( view );
			manageMemoryWarnings = false;
			manageStateChanges = false;

			// From app.
			notifyGlobalGestureSignal.add( onGlobalGesture );
			requestNavigationToggleSignal.add( onToggleRequest );

			// From view.
			view.shownSignal.add( onViewShown );
			view.showingSignal.add( onViewShowing );
			view.hiddenSignal.add( onViewHidden );
			view.hidingSignal.add( onViewHiding );
			view.scrollingStartedSignal.add( onViewScrollingStarted );
			view.scrollingEndedSignal.add( onViewScrollingEnded );
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

		private function onViewHiding():void {
			notifyExpensiveUiActionToggledSignal.dispatch( true, "nav-hiding" );
			notifyNavigationToggledSignal.dispatch( false );
		}

		private function onViewHidden():void {
			notifyExpensiveUiActionToggledSignal.dispatch( false, "nav-hiding" );
		}

		private function onViewShowing():void {
			notifyExpensiveUiActionToggledSignal.dispatch( true, "nav-showing" );
		}

		private function onViewShown():void {
			notifyExpensiveUiActionToggledSignal.dispatch( false, "nav-showing" );
			notifyNavigationToggledSignal.dispatch( true );
		}

		private function onToggleRequest():void {
			view.toggle();
		}

		// -----------------------
		// From app.
		// -----------------------

		private function onGlobalGesture( gestureType:String ):void {
			switch( gestureType ) {
				case GestureType.HORIZONTAL_PAN_GESTURE_BEGAN: {
					view.evaluateInteractionStart();
					break;
				}
				case GestureType.HORIZONTAL_PAN_GESTURE_ENDED: {
					view.evaluateInteractionEnd();
					break;
				}
				case GestureType.TWO_FINGER_SWIPE_DOWN: {
					view.hide();
					break;
				}
				case GestureType.TWO_FINGER_SWIPE_UP: {
					view.show();
					break;
				}
			}
		}

		override protected function onStateChange( newState:String ):void {
			trace( this, "state change: " + newState );

			// Evaluate a sub-nav change.
			var cl:Class = StateToSubNavLinker.getSubNavClassForState( newState );
			view.updateSubNavigation( cl );
		}
	}
}
