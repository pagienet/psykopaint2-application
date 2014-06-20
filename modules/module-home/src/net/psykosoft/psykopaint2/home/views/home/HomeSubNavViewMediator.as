package net.psykosoft.psykopaint2.home.views.home
{
	import net.psykosoft.psykopaint2.core.models.LoggedInUserProxy;
	import net.psykosoft.psykopaint2.core.models.NavigationStateType;
	import net.psykosoft.psykopaint2.core.views.navigation.SubNavigationMediatorBase;

	public class HomeSubNavViewMediator extends SubNavigationMediatorBase
	{
		
		[Inject]
		public var view : HomeSubNavView;
		
		[Inject]
		public var loggedInUser : LoggedInUserProxy;
		
		public function HomeSubNavViewMediator()
		{
			super();
		}
		
		override public function initialize() : void
		{
			// Init.
			registerView(view);
			super.initialize();
		}
		
		override protected function onButtonClicked(id : String) : void
		{
			switch (id) {
				case HomeSubNavView.ID_GALLERY:
					//GO TO GALLERY
					requestNavigationStateChange(NavigationStateType.GALLERY_BROWSE_MOST_LOVED);

					break;
				case HomeSubNavView.ID_PAINT:
					//GO TO PAINT
					requestNavigationStateChange(NavigationStateType.PICK_IMAGE);
					break;
				case HomeSubNavView.ID_SETTINGS:
					//GO TO SETTINGS
					requestNavigationStateChange(NavigationStateType.SETTINGS);
					break;
			}
		}
		
		
	}
}