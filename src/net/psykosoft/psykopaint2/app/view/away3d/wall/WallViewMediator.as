package net.psykosoft.psykopaint2.app.view.away3d.wall
{

	import com.junkbyte.console.Cc;

	import net.psykosoft.psykopaint2.app.controller.gestures.GestureType;
	import net.psykosoft.psykopaint2.app.data.types.StateType;
	import net.psykosoft.psykopaint2.app.data.vos.StateVO;
	import net.psykosoft.psykopaint2.app.model.state.StateModel;
	import net.psykosoft.psykopaint2.app.signal.notifications.NotifyGlobalGestureSignal;
	import net.psykosoft.psykopaint2.app.signal.notifications.NotifyNavigationToggleSignal;
	import net.psykosoft.psykopaint2.app.signal.notifications.NotifyStateChangedSignal;
	import net.psykosoft.psykopaint2.app.signal.notifications.NotifyWallpaperChangeSignal;
	import net.psykosoft.psykopaint2.app.signal.requests.RequestStateChangeSignal;

	import robotlegs.bender.bundles.mvcs.Mediator;

	public class WallViewMediator extends Mediator
	{
		[Inject]
		public var view:WallView;

		[Inject]
		public var stateModel:StateModel;

		[Inject]
		public var notifyStateChangedSignal:NotifyStateChangedSignal;

		[Inject]
		public var requestStateChangeSignal:RequestStateChangeSignal;

		[Inject]
		public var notifyWallpaperChangeSignal:NotifyWallpaperChangeSignal;

		[Inject]
		public var notifyGlobalGestureSignal:NotifyGlobalGestureSignal;

		[Inject]
		public var notifyNavigationToggleSignal:NotifyNavigationToggleSignal;

		private var _firstLoad:Boolean = true;
		private var _lastClosest:uint = 1;

		override public function initialize():void {

			Cc.log( this, "initialized" );

			// View starts disabled.
			view.disable();

			// From app.
			notifyStateChangedSignal.add( onApplicationStateChanged );
//			notifyWallpaperChangeSignal.add( onWallPaperChanged );
			notifyGlobalGestureSignal.add( onGlobalGesture );
			notifyNavigationToggleSignal.add( onNavigationToggled );

			// From view.
			view.closestPaintingChangedSignal.add( onViewClosestPaintingChanged );
			view.motionStartedSignal.add( onViewMotionStarted );

		}

		// -----------------------
		// From view.
		// -----------------------

		private function onViewMotionStarted():void {
			if( stateModel.currentState.name == StateType.SETTINGS && stateModel.previousState.name != StateType.HOME_SCREEN ) {
				requestStateChangeSignal.dispatch( new StateVO( StateType.HOME_SCREEN ) );
			}
		}

		private function onViewClosestPaintingChanged( paintingIndex:uint ):void {

			// Remember last snapped painting.
			if( paintingIndex != 0 ) _lastClosest = paintingIndex;

			// Trigger settings state if closest to settings painting ( index 0 ).
			if( stateModel.currentState.name != StateType.SETTINGS && paintingIndex == 0 ) {
				requestStateChangeSignal.dispatch( new StateVO( StateType.SETTINGS ) );
			}

			// Restore home state if closest another painting.
			if( paintingIndex != 0 && stateModel.currentState.name.indexOf( StateType.SETTINGS ) != -1 ) {
				requestStateChangeSignal.dispatch( new StateVO( StateType.HOME_SCREEN ) );
			}
		}

		// -----------------------
		// From app.
		// -----------------------

		private function onNavigationToggled( shown:Boolean ):void {
			view.limitScrolling = shown;
		}

		private function onGlobalGesture( type:uint ):void {
			if( type == GestureType.HORIZONTAL_PAN_GESTURE_BEGAN ) {
				view.startScrollingInteraction();
			}
			else if( type == GestureType.HORIZONTAL_PAN_GESTURE_ENDED ) {
				view.stopScrollingInteraction();
			}
			else if( type == GestureType.PINCH_GREW ) {
				view.zoomIn();
			}
			else if( type == GestureType.PINCH_SHRANK ) {
				view.zoomOut();
			}
		}

		/*private function onWallPaperChanged( image:PackagedImageVO ):void {
			trace( this, "changing wallpaper" );
			view.changeWallpaper( image.originalBmd );
		}*/

		private function onApplicationStateChanged( newState:StateVO ):void {

			// Clicking on the settings button causes animation to the settings painting.
			if( newState.name == StateType.SETTINGS && stateModel.previousState.name == StateType.HOME_SCREEN && view.currentPainting != 0 ) {
				view.animateToPainting( 0 );
				return;
			}

			// Clicking on the back button on the settings state restores to the last snapped painting.
			if( newState.name == StateType.HOME_SCREEN && stateModel.previousState.name == StateType.SETTINGS ) {
				if( !view.cameraAwake ) {
					view.animateToPainting( _lastClosest );
				}
				return;
			}

			// Regular home screen navigation.
			if( newState.name == StateType.HOME_SCREEN ) {
				Cc.log( this, "enabled" );
				if( _firstLoad ) {
					view.loadDefaultHomeFrames();
					view.loadUserFrames();
					_firstLoad = false;
				}
				view.enable();
			}
			else if( newState.name.indexOf( StateType.SETTINGS ) == -1 ) {
				view.disable();
				Cc.log( this, "disabled" );
			}

		}
	}
}
