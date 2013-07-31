package net.psykosoft.psykopaint2.core.views.popups
{

	import net.psykosoft.psykopaint2.core.views.popups.base.*;

	import com.greensock.TweenLite;
	import com.greensock.easing.Strong;

	import net.psykosoft.psykopaint2.base.ui.base.ViewBase;

	import org.osflash.signals.Signal;

	public class PopUpManagerView extends ViewBase
	{
		private var _popUp:PopUpViewBase;

		public var popUpHiddenSignal:Signal;
		public var popUpShownSignal:Signal;

		public function PopUpManagerView() {
			super();
			popUpHiddenSignal = new Signal();
			popUpShownSignal = new Signal();
			enable();
		}

		// -----------------------
		// Show.
		// -----------------------

		public function showPopUpOfClass( popUpClass:Class ):void {

			trace( this, "showing pop up of class: " + popUpClass );

			if( _popUp ) {
				onHidePopUpComplete();
			}

			_popUp = new popUpClass();
			addChild( _popUp );
			_popUp.enable();
			showPopUpAnimated( _popUp );
		}

		private function showPopUpAnimated( popUp:PopUpViewBase ):void {
			TweenLite.killTweensOf( popUp );
			popUp.x = 1024;
			TweenLite.to( popUp, 0.5, { x: 0, delay: 0.5, ease: Strong.easeOut, onComplete: onShowPopUpComplete } );
		}

		private function onShowPopUpComplete():void {
			popUpShownSignal.dispatch();
		}

		// -----------------------
		// Hide.
		// -----------------------

		public function hideLastPopUp():void {
			if( !_popUp ) return;
			hidePopUpAnimated( _popUp );
		}

		private function hidePopUpAnimated( popUp:PopUpViewBase ):void {
			TweenLite.killTweensOf( popUp );
			popUp.x = 0;
			TweenLite.to( popUp, 0.5, { x: 1024, delay: 0.5, ease: Strong.easeIn, onComplete: onHidePopUpComplete } );
		}

		private function onHidePopUpComplete():void {
			_popUp.disable();
			removeChild( _popUp );
			_popUp = null;
			popUpHiddenSignal.dispatch();
		}
	}
}
