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
		}
	}
}
