package net.psykosoft.psykopaint2.app.view.popups
{

	import net.psykosoft.psykopaint2.app.view.base.StarlingMediatorBase;

	public class ConfirmCapturePopUpViewMediator extends StarlingMediatorBase
	{
		override public function initialize():void {
			super.initialize();
			manageMemoryWarnings = false;
			manageStateChanges = false;
		}
	}
}
