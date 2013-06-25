package net.psykosoft.psykopaint2.home.views.home
{

	import net.psykosoft.psykopaint2.core.views.base.MediatorBase;

	public class ContinuePaintingSubNavViewMediator extends MediatorBase
	{
		[Inject]
		public var view:ContinuePaintingSubNavView;

		public function ContinuePaintingSubNavViewMediator() {
			super();
		}

		override public function initialize():void {

			// Init.
			super.initialize();
			registerView( view );
			manageStateChanges = false;
			manageMemoryWarnings = false;
			view.setButtonClickCallback( onButtonClicked );
		}

		// -----------------------
		// From view.
		// -----------------------

		private function onButtonClicked( label:String ):void {
			switch( label ) {
				case ContinuePaintingSubNavView.LBL_CONTINUE: {
					// TODO
					break;
				}
				case ContinuePaintingSubNavView.LBL_DELETE: {
					// TODO
					break;
				}
			}
		}
	}
}
