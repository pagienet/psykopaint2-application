package net.psykosoft.psykopaint2.core.views.navigation
{

	import flash.events.Event;
	
	import net.psykosoft.psykopaint2.core.managers.gestures.GestureType;
	import net.psykosoft.psykopaint2.core.models.StateType;
	import net.psykosoft.psykopaint2.core.signals.NotifyExpensiveUiActionToggledSignal;
	import net.psykosoft.psykopaint2.core.signals.NotifyGlobalGestureSignal;
	import net.psykosoft.psykopaint2.core.signals.NotifyNavigationMovingSignal;
	import net.psykosoft.psykopaint2.core.signals.NotifyNavigationToggledSignal;
	import net.psykosoft.psykopaint2.core.signals.RequestNavigationAutohideModeSignal;
	import net.psykosoft.psykopaint2.core.signals.RequestNavigationToggleSignal;
	import net.psykosoft.psykopaint2.core.views.base.MediatorBase;
	
	import org.gestouch.events.GestureEvent;

	public class NavigationViewMediator extends MediatorBase
	{
		[Inject]
		public var view:SbNavigationView;

		[Inject]
		public var notifyGlobalGestureSignal:NotifyGlobalGestureSignal;

		[Inject]
		public var notifyNavigationToggledSignal:NotifyNavigationToggledSignal;

		[Inject]
		public var notifyNavigationMovingSignal:NotifyNavigationMovingSignal;

		[Inject]
		public var notifyExpensiveUiActionToggledSignal:NotifyExpensiveUiActionToggledSignal;

		[Inject]
		public var requestNavigationToggleSignal:RequestNavigationToggleSignal;

		[Inject]
		public var requestNavigationAutohideModeSignal:RequestNavigationAutohideModeSignal;

		
		override public function initialize():void {

			super.initialize();
			registerView( view );
			manageMemoryWarnings = false;
			manageStateChanges = false;

			// From app.
			notifyGlobalGestureSignal.add( onGlobalGesture );
			requestNavigationToggleSignal.add( onToggleRequest );
			requestNavigationAutohideModeSignal.add( onStartAutoHideMode );
			// From view.
			view.shownSignal.add( onViewShown );
			view.showingSignal.add( onViewShowing );
			view.hiddenSignal.add( onViewHidden );
			view.hidingSignal.add( onViewHiding );
			view.scrollingStartedSignal.add( onViewScrollingStarted );
			view.scrollingEndedSignal.add( onViewScrollingEnded );
			view.showHideUpdateSignal.add( onViewShowHideUpdate );
		}

		// -----------------------
		// From view.
		// -----------------------

		private function onViewShowHideUpdate( ratio:Number ):void {
			notifyNavigationMovingSignal.dispatch( ratio );
		}

		private function onViewScrollingEnded():void {
			notifyExpensiveUiActionToggledSignal.dispatch( false, "nav-scrolling" );
		}

		private function onViewScrollingStarted():void {
			notifyExpensiveUiActionToggledSignal.dispatch( true, "nav-scrolling" );
		}

		private function onViewHiding():void {
//			notifyExpensiveUiActionToggledSignal.dispatch( true, "nav-hiding" ); // TODO: reactivate this signal when render freeze is less glitchy
			notifyNavigationToggledSignal.dispatch( false );
		}

		private function onViewHidden():void {
//			notifyExpensiveUiActionToggledSignal.dispatch( false, "nav-hiding" );
		}

		private function onViewShowing():void {
//			notifyExpensiveUiActionToggledSignal.dispatch( true, "nav-showing" );
		}

		private function onViewShown():void {
//			notifyExpensiveUiActionToggledSignal.dispatch( false, "nav-showing" );
			notifyNavigationToggledSignal.dispatch( true );
		}

		private function onToggleRequest( value:int, time: Number = 0.5 ):void {
			if( value == 1 ) view.show( time );
			else if( value == -1 ) view.hide( time );
			else view.toggle(time);
		}

		
		// -----------------------
		// From app.
		// -----------------------

		private function onGlobalGesture( gestureType:String, event:GestureEvent ):void {
//			trace( this, "onGlobalGesture: " + gestureType );
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

		private function onStartAutoHideMode( start:Boolean ):void
		{
			if ( start ) 
				view.startAutoHideMode();
			else
				view.stopAutoHideMode();
		}
		
		
		
		override protected function onStateChange( newState:String ):void {
//			trace( this, "state change: " + newState );

			if( newState == StateType.PAINT_COLOR ) {
				view.wire.visible = false;
				view.woodBg.visible = true;
			}
			else {
				view.wire.visible = true;
				view.woodBg.visible = false;
			}
			// Evaluate a sub-nav change.
			var cl:Class = StateToSubNavLinker.getSubNavClassForState( newState );
			view.updateSubNavigation( cl );
		}
	}
}
