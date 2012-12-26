package net.psykosoft.psykopaint2.view.away3d.wall
{

	import com.junkbyte.console.Cc;

	import net.psykosoft.psykopaint2.model.state.data.States;
	import net.psykosoft.psykopaint2.model.state.vo.StateVO;
	import net.psykosoft.psykopaint2.signal.notifications.NotifyRandomWallpaperChangeSignal;
	import net.psykosoft.psykopaint2.signal.notifications.NotifyStateChangedSignal;
	import net.psykosoft.psykopaint2.signal.requests.RequestStateChangeSignal;

	import robotlegs.bender.bundles.mvcs.Mediator;

	public class WallViewMediator extends Mediator
	{
		[Inject]
		public var view:IWallView;

		[Inject]
		public var notifyStateChangedSignal:NotifyStateChangedSignal;

		[Inject]
		public var notifyRandomWallpaperChangeSignal:NotifyRandomWallpaperChangeSignal;

		[Inject]
		public var requestStateChangeSignal:RequestStateChangeSignal;

		override public function initialize():void {

			Cc.log( this, "initialized" );

			// View starts disabled.
			view.disable();

			// From app.
			notifyStateChangedSignal.add( onApplicationStateChanged );
			notifyRandomWallpaperChangeSignal.add( onRandomWallPaperRequested );

			// From view.
			view.wallFrameClickedSignal.add( onViewObjectClicked );

		}

		// -----------------------
		// View -> app.
		// -----------------------

		private function onViewObjectClicked():void {
			// TODO
//			requestStateChangeSignal.dispatch( new StateVO( States.IDLE ) );
		}

		// -----------------------
		// App -> view.
		// -----------------------

		private function onRandomWallPaperRequested():void {
			view.randomizeWallpaper();
		}

		private function onApplicationStateChanged( newState:StateVO ):void {

			if( newState.name == States.HOME_SCREEN ) {
				Cc.log( this, "enabled" );
				view.clearFrames();
				view.loadDefaultHomeFrames();
				view.loadUserFrames();
				view.enable();
			}
			else {
				view.disable();
				Cc.log( this, "disabled" );
			}

		}
	}
}
