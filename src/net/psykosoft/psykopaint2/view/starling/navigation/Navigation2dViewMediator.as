package net.psykosoft.psykopaint2.view.starling.navigation
{

	import com.junkbyte.console.Cc;

	import net.psykosoft.psykopaint2.model.data.States;

	import net.psykosoft.psykopaint2.model.vo.StateVO;

	import net.psykosoft.psykopaint2.signal.notifications.NotifyStateChangedSignal;

	import robotlegs.extensions.starlingViewMap.impl.StarlingMediator;

	public class Navigation2dViewMediator extends StarlingMediator
	{
		[Inject]
		public var view:Navigation2dView;

		[Inject]
		public var notifyStateChangedSignal:NotifyStateChangedSignal;

		override public function initialize():void {

			Cc.info( this, "initialized" );

			// View starts disabled.
			view.disable();

			// From app.
			notifyStateChangedSignal.add( onApplicationStateChanged );

		}

		private function onApplicationStateChanged( newState:StateVO ):void {

			if( newState.name != States.SPLASH_SCREEN ) {
				view.enable();
				Cc.info( this, "enabled" );
			}

		}
	}
}
