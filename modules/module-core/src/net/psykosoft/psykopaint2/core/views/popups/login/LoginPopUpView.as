package net.psykosoft.psykopaint2.core.views.popups.login
{

	import flash.display.Sprite;
	import flash.events.MouseEvent;

	import net.psykosoft.psykopaint2.core.views.popups.base.PopUpViewBase;

	import org.osflash.signals.Signal;

	public class LoginPopUpView extends PopUpViewBase
	{
		// Declared in Flash.
		public var bg:Sprite;

		public var popUpWantsToCloseSignal:Signal;

		public function LoginPopUpView() {
			super();
			popUpWantsToCloseSignal = new Signal();
		}

		override protected function onEnabled():void {

			super.onEnabled();

			_blocker.addEventListener( MouseEvent.CLICK, onBlockerClick );

			//...

			layout();

		}

		override protected function onDisabled():void {
			_blocker.removeEventListener( MouseEvent.CLICK, onBlockerClick );
			super.onDisabled();
		}

		private function onBlockerClick( event:MouseEvent ):void {
			popUpWantsToCloseSignal.dispatch();
		}
	}
}
