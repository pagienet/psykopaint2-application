package net.psykosoft.psykopaint2.home.views.settings
{

	import net.psykosoft.psykopaint2.core.models.StateType;
	import net.psykosoft.psykopaint2.core.views.base.MediatorBase;

	public class SettingsSubNavViewMediator extends MediatorBase
	{
		[Inject]
		public var view:SettingsSubNavView;

		override public function initialize():void {

			// Init.
			super.initialize();
			registerView( view );
			manageStateChanges = false;
			manageMemoryWarnings = false;
			view.navigation.buttonClickedCallback = onButtonClicked;
		}

		private function onButtonClicked( label:String ):void {
			switch( label ) {
				case SettingsSubNavView.LBL_WALLPAPER: {
					requestStateChange__OLD_TO_REMOVE( StateType.SETTINGS_WALLPAPER );
					break;
				}
			}
		}
	}
}
