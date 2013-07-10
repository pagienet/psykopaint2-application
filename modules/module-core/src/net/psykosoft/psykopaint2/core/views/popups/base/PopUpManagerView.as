package net.psykosoft.psykopaint2.core.views.popups.base
{

	import net.psykosoft.psykopaint2.base.ui.base.ViewBase;

	import org.osflash.signals.Signal;

	public class PopUpManagerView extends ViewBase
	{
		public var popUpClosedSignal:Signal;

		private var _popUp:PopUpViewBase;

		public function PopUpManagerView() {
			super();
			popUpClosedSignal = new Signal();
			enable();
		}

		public function showPopUpOfClass( popUpClass:Class ):void {
			trace( this, "showing pop up of class: " + popUpClass );
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
