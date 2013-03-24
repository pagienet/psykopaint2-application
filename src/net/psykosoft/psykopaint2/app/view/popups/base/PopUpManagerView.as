package net.psykosoft.psykopaint2.app.view.popups.base
{

	import net.psykosoft.psykopaint2.app.view.base.StarlingViewBase;

	import org.osflash.signals.Signal;

	public class PopUpManagerView extends StarlingViewBase
	{
		public var popUpClosedSignal:Signal;

		private var _popUp:PopUpViewBase;

		public function PopUpManagerView() {
			super();
			popUpClosedSignal = new Signal();
		}

		public function showPopUp( popUpClass:Class ):void {
			if( _popUp ) hideLastPopUp();
			_popUp = new popUpClass();
			_popUp.blockerClickedSignal.add( onCurrentPopUpBlockerPressed );
			addChild( _popUp );
			_popUp.enable();
		}

		public function hideLastPopUp():void {
			if( !_popUp ) return;
			_popUp.blockerClickedSignal.remove( onCurrentPopUpBlockerPressed );
			_popUp.disable();
			removeChild( _popUp );
			_popUp = null;
		}

		private function onCurrentPopUpBlockerPressed():void {
			popUpClosedSignal.dispatch();
		}
	}
}
