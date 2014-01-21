package net.psykosoft.psykopaint2.core.views.popups.undo
{

	import net.psykosoft.psykopaint2.core.views.base.MediatorBase;

	public class UndoPopUpViewMediator extends MediatorBase
	{
		[Inject]
		public var view:UndoPopUpView;

		
		override public function initialize():void {
			super.initialize();

			registerView( view );
			manageStateChanges = false;
			manageMemoryWarnings = false;

			// From app.
		}

		
	}
}
