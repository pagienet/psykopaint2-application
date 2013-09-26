package net.psykosoft.psykopaint2.home.views.settings
{

	import net.psykosoft.psykopaint2.core.models.NavigationStateType;
	import net.psykosoft.psykopaint2.core.signals.RequestShowPopUpSignal;
	import net.psykosoft.psykopaint2.core.views.navigation.SubNavigationMediatorBase;
	import net.psykosoft.psykopaint2.core.views.popups.base.PopUpType;

	public class SettingsSubNavViewMediator extends SubNavigationMediatorBase
	{
		[Inject]
		public var view:SettingsSubNavView;

		[Inject]
		public var requestShowPopUpSignal:RequestShowPopUpSignal;

		override public function initialize():void {
			// Init.
			registerView( view );
			super.initialize();
		}

		override protected function onButtonClicked( id:String ):void {
			switch( id ) {

				case SettingsSubNavView.ID_WALLPAPER: {
					requestNavigationStateChange( NavigationStateType.SETTINGS_WALLPAPER );
					break;
				}

				case SettingsSubNavView.ID_LOGIN: {
					requestShowPopUpSignal.dispatch( PopUpType.LOGIN );
					break;
				}
			}
		}
	}
}
