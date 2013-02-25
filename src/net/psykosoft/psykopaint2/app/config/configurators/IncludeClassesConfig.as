package net.psykosoft.psykopaint2.app.config.configurators
{

	import net.psykosoft.psykopaint2.app.view.starling.popups.MessagePopUpView;
	import net.psykosoft.psykopaint2.app.view.starling.popups.FeatureNotImplementedPopUpView;
	import net.psykosoft.psykopaint2.app.view.starling.popups.FeatureNotInPlatformPopUpView;
	import net.psykosoft.psykopaint2.app.view.starling.popups.SettingsPopUpView;

	public class IncludeClassesConfig
	{
		public function IncludeClassesConfig() {
			MessagePopUpView;
			FeatureNotInPlatformPopUpView;
			FeatureNotImplementedPopUpView;
			SettingsPopUpView;
		}
	}
}
