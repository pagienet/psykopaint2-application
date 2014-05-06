package net.psykosoft.psykopaint2.core.views.popups.share
{

import net.psykosoft.psykopaint2.core.signals.RequestHidePopUpSignal;
import net.psykosoft.psykopaint2.core.views.base.MediatorBase;

public class SharePopUpViewMediator extends MediatorBase
{
	[Inject]
	public var view:SharePopUpView;

	[Inject]
	public var requestHidePopUpSignal:RequestHidePopUpSignal;

	override public function initialize():void {
		super.initialize();

		registerView( view );
		manageStateChanges = false;
		manageMemoryWarnings = false;

		// From app.
		// ...

		// From view.
		view.popUpWantsToCloseSignal.add( onPopUpWantsToClose );
	}

	override public function destroy():void {
		super.destroy();
		view.popUpWantsToCloseSignal.remove( onPopUpWantsToClose );
	}

	private function onPopUpWantsToClose():void {
		requestHidePopUpSignal.dispatch();
	}
}
}
