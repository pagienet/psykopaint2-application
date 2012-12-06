package net.psykosoft.psykopaint2.view.away3d.wall
{

	import com.junkbyte.console.Cc;

	import net.psykosoft.psykopaint2.model.data.States;
	import net.psykosoft.psykopaint2.model.vo.StateVO;
	import net.psykosoft.psykopaint2.signal.notifications.NotifyStateChangedSignal;
	import net.psykosoft.psykopaint2.signal.requests.RequestStateChangeSignal;

	import robotlegs.bender.bundles.mvcs.Mediator;

	public class Wall3dViewMediator extends Mediator
	{
		[Inject]
		public var view:Wall3dView;

		[Inject]
		public var notifyStateChangedSignal:NotifyStateChangedSignal;

		[Inject]
		public var requestStateChangeSignal:RequestStateChangeSignal;

		override public function initialize():void {

			Cc.info( this, "initialized" );

			// View starts disabled.
			view.disable();

			// From app.
			notifyStateChangedSignal.add( onApplicationStateChanged );

			// From view.
			view.objectClickedSignal.add( onViewObjectClicked );

		}

		private function onViewObjectClicked():void {
			requestStateChangeSignal.dispatch( new StateVO( States.IDLE ) );
		}

		private function onApplicationStateChanged( newState:StateVO ):void {

			if( newState.name == States.HOME_SCREEN ) {
				view.enable();
				Cc.info( this, "enabled" );
			}
			else {
				view.disable();
				Cc.info( this, "disabled" );
			}

		}
	}
}
