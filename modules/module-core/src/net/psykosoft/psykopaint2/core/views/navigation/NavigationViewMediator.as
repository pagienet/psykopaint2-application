package net.psykosoft.psykopaint2.core.views.navigation
{

	import com.junkbyte.console.Cc;

	import net.psykosoft.psykopaint2.core.managers.gestures.GestureType;
	import net.psykosoft.psykopaint2.core.signals.notifications.NotifyGlobalGestureSignal;
	import net.psykosoft.psykopaint2.core.signals.notifications.NotifyNavigationToggledSignal;
	import net.psykosoft.psykopaint2.core.views.base.MediatorBase;

	public class NavigationViewMediator extends MediatorBase
	{
		[Inject]
		public var view:SbNavigationView;

		[Inject]
		public var notifyGlobalGestureSignal:NotifyGlobalGestureSignal;

		[Inject]
		public var notifyNavigationToggledSignal:NotifyNavigationToggledSignal;

		override public function initialize():void {

			super.initialize();
			registerView( view );
			manageMemoryWarnings = false;
			manageStateChanges = false;
			view.visible = true; // Starts visible, independent of state.

			// From app.
			notifyGlobalGestureSignal.add( onGlobalGesture );

			// From view.
			view.shownAnimatedSignal.add( onViewShown );
			view.hiddenAnimatedSignal.add( onViewHidden );

			// Causes the first canvas size.
			notifyNavigationToggledSignal.dispatch( true );
		}

		// -----------------------
		// From view.
		// -----------------------

		private function onViewHidden():void {
			notifyNavigationToggledSignal.dispatch( false );
		}

		private function onViewShown():void {
			notifyNavigationToggledSignal.dispatch( true );
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
			Cc.log( this, "state change: " + newState );

			// Evaluate a sub-nav change.
			var cl:Class = StateToSubNavLinker.getSubNavClassForState( newState );
			view.updateSubNavigation( cl );
		}
	}
}