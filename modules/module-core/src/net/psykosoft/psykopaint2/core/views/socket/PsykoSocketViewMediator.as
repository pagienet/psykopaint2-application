package net.psykosoft.psykopaint2.core.views.socket
{

	import net.psykosoft.psykopaint2.core.views.base.MediatorBase;

	public class PsykoSocketViewMediator extends MediatorBase
	{
		[Inject]
		public var view:PsykoSocketView;

		override public function initialize():void {
			// Init.
			super.initialize();
			registerView( view );
			manageStateChanges = false;
			manageMemoryWarnings = false;
			view.enable();
		}
	}
}
