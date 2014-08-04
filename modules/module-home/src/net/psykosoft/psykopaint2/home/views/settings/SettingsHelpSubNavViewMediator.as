package net.psykosoft.psykopaint2.home.views.settings
{

	import net.psykosoft.psykopaint2.core.configuration.CoreSettings;
	import net.psykosoft.psykopaint2.core.models.NavigationStateType;
	import net.psykosoft.psykopaint2.core.views.navigation.SubNavigationMediatorBase;
	import net.psykosoft.psykopaint2.core.views.popups.faq.FAQPopupView;
	import net.psykosoft.psykopaint2.core.views.popups.tutorial.TutorialPopup;

	public class SettingsHelpSubNavViewMediator extends SubNavigationMediatorBase
	{
		[Inject]
		public var view:SettingsHelpSubNavView;

		

		override public function initialize():void {
			registerView( view );
			super.initialize();
		}

		override protected function onViewSetup():void {
			super.onViewSetup();
			
		}

		override protected function onButtonClicked( id:String ):void {
			switch( id ) {

				// Left.
				case SettingsHelpSubNavView.ID_BACK: {
					requestNavigationStateChange( NavigationStateType.SETTINGS );
					break;
				}
				case SettingsHelpSubNavView.ID_FAQ: {
					var newFAQPopupView:FAQPopupView = new FAQPopupView();
					newFAQPopupView.scaleX = newFAQPopupView.scaleY = CoreSettings.GLOBAL_SCALING;
					CoreSettings.STAGE.addChild(newFAQPopupView);
					
					break;
				}
				case SettingsHelpSubNavView.ID_VIDEO: {
					var tutorialPopup:TutorialPopup = new TutorialPopup();
					tutorialPopup.scaleX = tutorialPopup.scaleY = CoreSettings.GLOBAL_SCALING;
					CoreSettings.STAGE.addChild(tutorialPopup);
					
					break;
				}
					
					
				

				default: {
					
				}
			}
		}

		
	}
}
