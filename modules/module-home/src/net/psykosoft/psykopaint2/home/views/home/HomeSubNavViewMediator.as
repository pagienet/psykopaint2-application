package net.psykosoft.psykopaint2.home.views.home
{

	import net.psykosoft.psykopaint2.core.views.navigation.SubNavigationMediatorBase;

	public class HomeSubNavViewMediator extends SubNavigationMediatorBase
	{
		[Inject]
		public var view:HomeSubNavView;

		override public function initialize():void {

			// Init.
			registerView( view );
			super.initialize();
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
