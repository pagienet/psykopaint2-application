package net.psykosoft.psykopaint2.core.views.navigation
{

	import flash.display.Stage;
	import flash.geom.Rectangle;

	import net.psykosoft.psykopaint2.core.managers.gestures.GestureType;

	import net.psykosoft.psykopaint2.core.models.NavigationStateType;
	import net.psykosoft.psykopaint2.core.signals.NavigationCanHideWithGesturesSignal;
	import net.psykosoft.psykopaint2.core.signals.NotifyGlobalGestureSignal;
	import net.psykosoft.psykopaint2.core.signals.NotifyNavigationMovingSignal;
	import net.psykosoft.psykopaint2.core.signals.NotifyNavigationToggledSignal;
	import net.psykosoft.psykopaint2.core.signals.RequestChangeRenderRectSignal;
	import net.psykosoft.psykopaint2.core.signals.RequestNavigationDisposalSignal;
	import net.psykosoft.psykopaint2.core.signals.RequestNavigationToggleSignal;
	import net.psykosoft.psykopaint2.core.views.base.MediatorBase;

	import org.gestouch.events.GestureEvent;
	import org.gestouch.gestures.PanGesture;
	import org.gestouch.gestures.TapGesture;

	public class NavigationViewMediator extends MediatorBase
	{
		[Inject]
		public var view:NavigationView;

		[Inject]
		public var notifyNavigationToggledSignal:NotifyNavigationToggledSignal;

		[Inject]
		public var notifyNavigationMovingSignal:NotifyNavigationMovingSignal;

		[Inject]
		public var requestNavigationToggleSignal:RequestNavigationToggleSignal;

		[Inject]
		public var requestNavigationDisposalSignal:RequestNavigationDisposalSignal;

		[Inject]
		public var requestChangeRenderRectSignal:RequestChangeRenderRectSignal;

		[Inject]
		public var notifyGlobalGestureSignal:NotifyGlobalGestureSignal;

		[Inject]
		public var navigationCanHideWithGesturesSignal:NavigationCanHideWithGesturesSignal;

		private var _navigationCanHideWithGestures:Boolean;

		override public function initialize():void {

			registerView( view );
			super.initialize();
			manageMemoryWarnings = false;

			manageStateChanges = false;
			view.enable();

			// From app.
			requestNavigationToggleSignal.add( onToggleRequest );
			requestNavigationDisposalSignal.add( onNavigationDisposalRequest );
			requestChangeRenderRectSignal.add( onRenderRectChanged );
			notifyGlobalGestureSignal.add( onGlobalGesture );
			navigationCanHideWithGesturesSignal.add( onNavigationCanHideWithGestures );

			// From view.
			view.shownSignal.add( onViewShown );
			view.showingSignal.add( onViewShowing );
			view.hiddenSignal.add( onViewHidden );
			view.hidingSignal.add( onViewHiding );
			view.showHideUpdateSignal.add( onViewShowHideUpdate );
		}

		// -----------------------
		// From view.
		// -----------------------

		private function onViewShowHideUpdate( ratio:Number ):void {
			notifyNavigationMovingSignal.dispatch( ratio );
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

		private function onToggleRequest( value:int, time:Number = 0.5 ):void {
			if( value == 1 ) view.show( time );
			else if( value == -1 ) view.hide( time );
			else view.toggle( time );
		}


		// -----------------------
		// From app.
		// -----------------------

		private function onNavigationCanHideWithGestures( value:Boolean ):void {
			_navigationCanHideWithGestures = value;
		}

		private function onGlobalGesture( gestureType:String, event:GestureEvent ):void {

//			trace( this, "gesture - type: " + gestureType );

			// Gestures to show/hide the nav.
			if( _navigationCanHideWithGestures ) {

				// Tap.
				if( gestureType == GestureType.TAP_GESTURE_RECOGNIZED ) {
					// Condition: The tap did not occur on any display object in the navigation.
					var target:Stage = Stage( TapGesture( event.target ).target );
					var objsUnderMouse:Array = target.getObjectsUnderPoint( TapGesture( event.target ).location );
					if( objsUnderMouse.length == 0 ) { // We only want clicks on the stage.
						// Perform hide/show
						if( !view.showing ) view.show();
						else view.hide();
					}
				}

				// Vertical pan.
				if( gestureType == GestureType.VERTICAL_PAN_GESTURE_BEGAN ) {
					view.startPanDrag( PanGesture( event.target ).location.y );
				}
				if( gestureType == GestureType.VERTICAL_PAN_GESTURE_ENDED ) {
					view.endPanDrag();
				}

			}
		}

		private function onRenderRectChanged( rect:Rectangle ):void {
			view.adaptToCanvas( rect );
		}

		private function onNavigationDisposalRequest():void {
			view.disposeSubNavigation();
		}

		override protected function onStateChange( newState:String ):void {
			// Evaluate a sub-nav change.
			var cl:Class = StateToSubNavLinker.getSubNavClassForState( newState );
			view.updateSubNavigation( cl );
		}
	}
}
