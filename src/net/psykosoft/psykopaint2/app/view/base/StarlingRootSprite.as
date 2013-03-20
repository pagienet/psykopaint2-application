package net.psykosoft.psykopaint2.app.view.base
{

	import com.junkbyte.console.Cc;

	import feathers.controls.Button;
	import feathers.core.DisplayListWatcher;

	import net.psykosoft.psykopaint2.app.config.Settings;
	import net.psykosoft.psykopaint2.app.view.navigation.NavigationView;
	import net.psykosoft.psykopaint2.app.view.painting.canvas.CanvasView;
	import net.psykosoft.psykopaint2.app.view.painting.colorstyle.ColorStyleView;
	import net.psykosoft.psykopaint2.app.view.painting.crop.CropView;
	import net.psykosoft.psykopaint2.app.view.painting.stateproxy.StateProxyView;
	import net.psykosoft.psykopaint2.app.view.popups.base.PopUpManagerView;
	import net.psykosoft.psykopaint2.app.view.selectimage.SelectThumbView;
	import net.psykosoft.psykopaint2.app.view.splash.SplashView;
	import net.psykosoft.psykopaint2.ui.theme.Psykopaint2Ui;

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

			_mainLayer.addChild( new StateProxyView() );
			_mainLayer.addChild( new CanvasView() );
			_mainLayer.addChild( new CropView() );
			_mainLayer.addChild( new ColorStyleView() );
			_mainLayer.addChild( new SelectThumbView() );
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