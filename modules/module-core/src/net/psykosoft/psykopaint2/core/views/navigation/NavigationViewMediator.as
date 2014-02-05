package net.psykosoft.psykopaint2.core.views.navigation
{

	import flash.display.Stage;
	
	import net.psykosoft.psykopaint2.base.utils.ui.CanvasInteractionUtil;
	import net.psykosoft.psykopaint2.core.managers.gestures.GestureType;
	import net.psykosoft.psykopaint2.core.signals.NavigationCanHideWithGesturesSignal;
	import net.psykosoft.psykopaint2.core.signals.NotifyGlobalGestureSignal;
	import net.psykosoft.psykopaint2.core.signals.NotifyNavigationMovingSignal;
	import net.psykosoft.psykopaint2.core.signals.NotifyNavigationToggledSignal;
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
			notifyGlobalGestureSignal.add( onGlobalGesture );
			navigationCanHideWithGesturesSignal.add( onNavigationCanHideWithGestures );

			// From view.
			view.panel.shownSignal.add( onViewShown );
			view.panel.showingSignal.add( onViewShowing );
			view.panel.hiddenSignal.add( onViewHidden );
			view.panel.hidingSignal.add( onViewHiding );
			view.panel.showHideUpdateSignal.add( onViewShowHideUpdate );
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

		private function onToggleRequest( value:int ):void {
			if( value == 1 ) view.panel.show();
			else if( value == -1 ) view.panel.hide();
			else view.panel.toggle();
		}


		// -----------------------
		// From app.
		// -----------------------

		private function onNavigationCanHideWithGestures( value:Boolean ):void {
			_navigationCanHideWithGestures = value;
		}

		private const ACCEPT_TAP_GESTURES_FOR_SHOW_HIDE:Boolean = true;
		private const ALWAYS_SHOW_HIDE:Boolean = false;

		private function onGlobalGesture( gestureType:String, event:GestureEvent ):void {

//			trace( this, "gesture - type: " + gestureType );

			// Gestures to show/hide the nav.
			if( ALWAYS_SHOW_HIDE || _navigationCanHideWithGestures ) {

				// Tap.
				// Nav show/hide with nav is currently disabled.
				if( ACCEPT_TAP_GESTURES_FOR_SHOW_HIDE && gestureType == GestureType.TAP_GESTURE_RECOGNIZED ) {
					// Uncomment these lines to only accept taps on stage ( hence only in paint mode ).
					var target:Stage = Stage( TapGesture( event.target ).target );
					
					//var objsUnderMouse:Array = target.getObjectsUnderPoint( TapGesture( event.target ).location );
					if( CanvasInteractionUtil.canContentsUnderMouseBeIgnored(target) ) { // We only want clicks on the stage.
						// Perform hide/show
						if( !view.panel.shown ) view.panel.show();
						else view.panel.hide();
					}
				}

				// Vertical pan.
				if( gestureType == GestureType.VERTICAL_PAN_GESTURE_BEGAN ) {
					view.panel.startPanDrag( PanGesture( event.target ).location.y );
				}
				if( gestureType == GestureType.VERTICAL_PAN_GESTURE_ENDED ) {
					view.panel.endPanDrag();
				}

			}
		}

		override protected function onStateChange( newState:String ):void {
			// Evaluate a sub-nav change.
			var cl:Class = StateToSubNavLinker.getSubNavClassForState( newState );
			view.updateSubNavigation( cl );
		}
	}
}
