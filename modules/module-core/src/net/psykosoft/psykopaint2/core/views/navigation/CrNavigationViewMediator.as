package net.psykosoft.psykopaint2.core.views.navigation
{

	import com.junkbyte.console.Cc;

	import net.psykosoft.psykopaint2.core.managers.gestures.CrGestureType;
	import net.psykosoft.psykopaint2.core.signals.notifications.CrNotifyGlobalGestureSignal;
	import net.psykosoft.psykopaint2.core.signals.notifications.CrNotifyNavigationToggledSignal;
	import net.psykosoft.psykopaint2.core.views.base.CrMediatorBase;

	public class CrNavigationViewMediator extends CrMediatorBase
	{
		[Inject]
		public var view:CrSbNavigationView;

		[Inject]
		public var notifyGlobalGestureSignal:CrNotifyGlobalGestureSignal;

		[Inject]
		public var notifyNavigationToggledSignal:CrNotifyNavigationToggledSignal;

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
				case CrGestureType.HORIZONTAL_PAN_GESTURE_BEGAN: {
					view.evaluateInteractionStart();
					break;
				}
				case CrGestureType.HORIZONTAL_PAN_GESTURE_ENDED: {
					view.evaluateInteractionEnd();
					break;
				}
				case CrGestureType.TWO_FINGER_SWIPE_DOWN: {
					view.hide();
					break;
				}
				case CrGestureType.TWO_FINGER_SWIPE_UP: {
					view.show();
					break;
				}
			}
		}

		override protected function onStateChange( newState:String ):void {
			Cc.log( this, "state change: " + newState );

			// Evaluate a sub-nav change.
			var cl:Class = CrStateToSubNavLinker.getSubNavClassForState( newState );
			view.updateSubNavigation( cl );
		}
	}
}
