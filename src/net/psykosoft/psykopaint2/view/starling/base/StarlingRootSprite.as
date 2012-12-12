package net.psykosoft.psykopaint2.view.starling.base
{

	import com.junkbyte.console.Cc;

	import feathers.controls.Button;
	import feathers.core.DisplayListWatcher;
	import feathers.themes.MinimalMobileTheme;

	import net.psykosoft.psykopaint2.config.Settings;
	import net.psykosoft.psykopaint2.view.starling.navigation.NavigationView;
	import net.psykosoft.psykopaint2.view.starling.splash.SplashView;

	import starling.display.Sprite;

	import starling.events.Event;

	public class StarlingRootSprite extends StarlingViewBase
	{
		protected var _feathersTheme:DisplayListWatcher;

		private var _mainLayer:Sprite;
		private var _debugLayer:Sprite;

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

			// Define main layers.
			addChild( _mainLayer = new Sprite() );
			if( Settings.ENABLE_DEBUG_CONSOLE ) {
				addChild( _debugLayer = new Sprite() );
			}

			// Initialize 2d display tree.
			_mainLayer.addChild( new NavigationView() );
			if( Settings.SHOW_SPLASH_SCREEN ) {
				_mainLayer.addChild( new SplashView() );
			}

			if( Settings.ENABLE_DEBUG_CONSOLE ) {
			    // Place a little button at the left corner of the app for toggling the console.
				var button:Button = new Button();
				button.label = "console";
				button.x = Settings.SHOW_STATS ? 50 : 0;
				button.addEventListener( Event.TRIGGERED, onConsoleButtonTriggered );
				_debugLayer.addChild( button );
			}

			super.onStageAvailable();
		}

		private function onConsoleButtonTriggered( event:Event ):void {
			Cc.visible = !Cc.visible;
		}
	}
}