package net.psykosoft.psykopaint2.view.away3d.wall
{

	import com.junkbyte.console.Cc;

	import net.psykosoft.psykopaint2.model.packagedimages.vo.PackagedImageVO;

	import net.psykosoft.psykopaint2.model.state.StateModel;
	import net.psykosoft.psykopaint2.model.state.data.States;
	import net.psykosoft.psykopaint2.model.state.vo.StateVO;
	import net.psykosoft.psykopaint2.signal.notifications.NotifyStateChangedSignal;
	import net.psykosoft.psykopaint2.signal.notifications.NotifyWallpaperChangeSignal;
	import net.psykosoft.psykopaint2.signal.requests.RequestStateChangeSignal;

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

		private var _firstLoad:Boolean = true;
		private var _lastClosest:uint = 1;

		override public function initialize():void {

			Cc.log( this, "initialized" );

			// View starts disabled.
			view.disable();

			// From app.
			notifyStateChangedSignal.add( onApplicationStateChanged );
			notifyWallpaperChangeSignal.add( onWallPaperChanged );

			// From view.
			view.closestPaintingChangedSignal.add( onViewClosestPaintingChanged );
			view.motionStartedSignal.add( onViewMotionStarted );

		}

		// -----------------------
		// From view.
		// -----------------------

		private function onViewMotionStarted():void {
			if( stateModel.currentState.name == States.SETTINGS && stateModel.previousState.name != States.HOME_SCREEN ) {
				requestStateChangeSignal.dispatch( new StateVO( States.HOME_SCREEN ) );
			}
		}

		private function onViewClosestPaintingChanged( paintingIndex:uint ):void {

			trace( this, "closest painting changed: " + paintingIndex );

			// Remember last snapped painting.
			if( paintingIndex != 0 ) _lastClosest = paintingIndex;

			// Trigger settings state if closest to settings painting ( index 0 ).
			if( stateModel.currentState.name != States.SETTINGS && paintingIndex == 0 ) {
				trace( "snapping caused triggering of settings state." );
				requestStateChangeSignal.dispatch( new StateVO( States.SETTINGS ) );
			}

			// Restore home state if closest another painting.
			if( paintingIndex != 0 && stateModel.currentState.name.indexOf( States.SETTINGS ) != -1 ) {
				trace( "snapping caused restore of home state." );
				requestStateChangeSignal.dispatch( new StateVO( States.HOME_SCREEN ) );
			}
		}

		// -----------------------
		// From app.
		// -----------------------

		private function onWallPaperChanged( image:PackagedImageVO ):void {
			trace( this, "changing wallpaper" );
			view.changeWallpaper( image.originalBmd );
		}

		private function onApplicationStateChanged( newState:StateVO ):void {

			Cc.log( this, "application state changed: " + newState );

			// Clicking on the settings button causes animation to the settings painting.
			if( newState.name == States.SETTINGS && stateModel.previousState.name == States.HOME_SCREEN && view.currentPainting != 0 ) {
				view.animateToPainting( 0 );
				return;
			}

			// Clicking on the back button on the settings state restores to the last snapped painting.
			if( newState.name == States.HOME_SCREEN && stateModel.previousState.name == States.SETTINGS ) {
				if( !view.cameraAwake ) {
					view.animateToPainting( _lastClosest );
				}
				return;
			}

			// Regular home screen navigation.
			if( newState.name == States.HOME_SCREEN ) {
				Cc.log( this, "enabled" );
				if( _firstLoad ) {
					view.loadDefaultHomeFrames();
					view.loadUserFrames();
					_firstLoad = false;
				}
				view.enable();
			}
			else if( newState.name.indexOf( States.SETTINGS ) == -1 ) {
				view.disable();
				Cc.log( this, "disabled" );
			}

		}
	}
}
