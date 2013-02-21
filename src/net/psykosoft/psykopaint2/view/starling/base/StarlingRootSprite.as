package net.psykosoft.psykopaint2.view.starling.base
{

	import com.junkbyte.console.Cc;

	import feathers.controls.Button;
	import feathers.core.DisplayListWatcher;

	import net.psykosoft.psykopaint2.config.Settings;
	import net.psykosoft.psykopaint2.ui.theme.Psykopaint2Ui;
	import net.psykosoft.psykopaint2.view.starling.popups.CaptureImagePopUpView;
	import net.psykosoft.psykopaint2.view.starling.navigation.NavigationView;
	import net.psykosoft.psykopaint2.view.starling.popups.base.PopUpManagerView;
	import net.psykosoft.psykopaint2.view.starling.selectimage.SelectImageView;
	import net.psykosoft.psykopaint2.view.starling.splash.SplashView;

	import starling.display.Sprite;
	import starling.events.Event;

	public class StarlingRootSprite extends StarlingViewBase
	{
		private var _mainLayer:Sprite;
		private var _debugLayer:Sprite;

		public function StarlingRootSprite() {
			super();
		}

		override protected function onStageAvailable():void {

			// -----------------------
			// Ui theme.
			// -----------------------

			var theme:DisplayListWatcher = new Psykopaint2Ui( stage, Settings.RUNNING_ON_HD );

			// -----------------------
			// Layering.
			// -----------------------

			addChild( _mainLayer = new Sprite() );
			if( Settings.ENABLE_DEBUG_CONSOLE ) {
				addChild( _debugLayer = new Sprite() );
			}

			// -----------------------
			// << VIEWS >>.
			// -----------------------

			_mainLayer.addChild( new SelectImageView() );
			_mainLayer.addChild( new NavigationView() );
			_mainLayer.addChild( new PopUpManagerView() );
			if( Settings.SHOW_SPLASH_SCREEN ) {
				_mainLayer.addChild( new SplashView() );
			}

			// -----------------------
			// Debugging console.
			// -----------------------

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