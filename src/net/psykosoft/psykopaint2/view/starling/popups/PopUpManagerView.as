package net.psykosoft.psykopaint2.view.starling.popups
{

	import net.psykosoft.psykopaint2.view.starling.base.StarlingViewBase;
	import net.psykosoft.psykopaint2.view.starling.popups.base.PopUpViewBase;

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
			_popUp.destroy();
			removeChild( _popUp );
			_popUp = null;
		}

		private function onCurrentPopUpBlockerPressed():void {
			popUpClosedSignal.dispatch();
		}
	}
}
