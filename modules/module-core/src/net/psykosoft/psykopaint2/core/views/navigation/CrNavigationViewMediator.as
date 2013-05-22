package net.psykosoft.psykopaint2.core.views.navigation
{

	import com.junkbyte.console.Cc;

	import net.psykosoft.psykopaint2.core.managers.gestures.CrGestureType;

	import net.psykosoft.psykopaint2.core.signals.notifications.CrNotifyGlobalGestureSignal;

	import net.psykosoft.psykopaint2.core.views.base.CrMediatorBase;

	public class CrNavigationViewMediator extends CrMediatorBase
	{
		[Inject]
		public var view:CrSbNavigationView;

		[Inject]
		public var notifyGlobalGestureSignal:CrNotifyGlobalGestureSignal;

		override public function initialize():void {

			super.initialize();
			registerView( view );
			manageMemoryWarnings = false;
			manageStateChanges = false;
			view.visible = true; // Starts visible, independent of state.

			// From app.
			notifyGlobalGestureSignal.add( onGlobalGesture );
		}

		// -----------------------
		// From app.
		// -----------------------

		private function onGlobalGesture( gestureType:String ):void {
			trace( this, "global gesture: " + gestureType );
			switch( gestureType ) {
				case CrGestureType.HORIZONTAL_PAN_GESTURE_BEGAN: {
					view.evaluateInteractionStart();
					break;
				}
				case CrGestureType.HORIZONTAL_PAN_GESTURE_ENDED: {
					view.evaluateInteractionEnd();
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
