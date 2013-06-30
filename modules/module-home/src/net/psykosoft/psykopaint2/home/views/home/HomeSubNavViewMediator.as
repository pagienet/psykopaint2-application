package net.psykosoft.psykopaint2.home.views.home
{

	import net.psykosoft.psykopaint2.core.views.base.MediatorBase;

	public class HomeSubNavViewMediator extends MediatorBase
	{
		[Inject]
		public var view:HomeSubNavView;

		override public function initialize():void {

			// Init.
			super.initialize();
			registerView( view );
			manageStateChanges = false;
			manageMemoryWarnings = false;
			view.navigation.buttonClickedCallback = onButtonClicked;
		}

		private function onButtonClicked( label:String ):void {
			/*switch( label ) {
				case HomeSubNavView.LBL_PAINT: {
					requestStateChange( StateType.STATE_PAINT );
					break;
				}
			}*/
		}
	}
}
