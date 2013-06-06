package net.psykosoft.psykopaint2.core.views.navigation
{

	import net.psykosoft.psykopaint2.core.managers.gestures.GestureType;
	import net.psykosoft.psykopaint2.core.signals.NotifyExpensiveUiActionToggledSignal;
	import net.psykosoft.psykopaint2.core.signals.NotifyGlobalGestureSignal;
	import net.psykosoft.psykopaint2.core.signals.NotifyNavigationToggledSignal;
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
					view.evaluateScrollingInteractionStart();
					break;
				}
				case GestureType.HORIZONTAL_PAN_GESTURE_ENDED: {
					view.evaluateScrollingInteractionEnd();
					break;
				}
				case GestureType.VERTICAL_PAN_GESTURE_BEGAN: {
					view.evaluateReactiveHideStart();
					break;
				}
				case GestureType.VERTICAL_PAN_GESTURE_ENDED: {
					view.evaluateReactiveHideEnd();
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
