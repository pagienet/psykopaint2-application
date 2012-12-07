package net.psykosoft.psykopaint2.view.starling.base
{

	import feathers.core.DisplayListWatcher;
	import feathers.themes.MinimalMobileTheme;

	import net.psykosoft.psykopaint2.config.Settings;
	import net.psykosoft.psykopaint2.view.starling.navigation.NavigationView;
	import net.psykosoft.psykopaint2.view.starling.splash.SplashView;

	public class StarlingRootSprite extends StarlingViewBase
	{
		protected var _feathersTheme:DisplayListWatcher;

		public function StarlingRootSprite() {
			super();
		}

		override protected function onStageAvailable():void {

			// Define application UI theme.
			if( Settings.USE_DEBUG_THEME ) {
				_feathersTheme = new MinimalMobileTheme( stage );
			}
			else {
				// TODO: Link to own theme
			}

			// Initialize 2d display tree.
			addChild( new NavigationView() );
			if( Settings.SHOW_SPLASH_SCREEN ) {
				addChild( new SplashView() );
			}

			super.onStageAvailable();
		}
	}
}