package net.psykosoft.psykopaint2.home.views.settings
{

	import net.psykosoft.psykopaint2.core.models.NavigationStateType;
	import net.psykosoft.psykopaint2.core.views.navigation.SubNavigationMediatorBase;

	public class SettingsSubNavViewMediator extends SubNavigationMediatorBase
	{
		[Inject]
		public var view:SettingsSubNavView;

		override public function initialize():void {
			// Init.
			registerView( view );
			super.initialize();
		}

		override protected function onButtonClicked( id:String ):void {
			switch( id ) {
				case SettingsSubNavView.ID_WALLPAPER: {
					requestStateChange__OLD_TO_REMOVE( NavigationStateType.SETTINGS_WALLPAPER );
					break;
				}
			}
		}
	}
}
