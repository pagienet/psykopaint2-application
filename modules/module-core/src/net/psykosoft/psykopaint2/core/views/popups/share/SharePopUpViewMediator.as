package net.psykosoft.psykopaint2.core.views.popups.share
{

import net.psykosoft.psykopaint2.core.views.base.MediatorBase;

public class SharePopUpViewMediator extends MediatorBase
{
	[Inject]
	public var view:SharePopUpView;

	override public function initialize():void {
		super.initialize();

		registerView( view );
		manageStateChanges = false;
		manageMemoryWarnings = false;

		// From app.
		// ...
	}

	override public function destroy():void
	{
		super.destroy();
	}
}
}
