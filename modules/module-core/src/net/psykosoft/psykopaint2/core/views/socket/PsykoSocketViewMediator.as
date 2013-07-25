package net.psykosoft.psykopaint2.core.views.socket
{

	import net.psykosoft.psykopaint2.core.views.base.MediatorBase;

	public class PsykoSocketViewMediator extends MediatorBase
	{
		[Inject]
		public var view:PsykoSocketView;

		override public function initialize():void {
			// Init.
			registerView( view );
			super.initialize();
			manageStateChanges = false;
			manageMemoryWarnings = false;
			view.enable();
		}
	}
}
