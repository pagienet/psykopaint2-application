package net.psykosoft.psykopaint2.view.starling.navigation
{

	import feathers.controls.Button;

	import net.psykosoft.psykopaint2.util.AssetManager;
	import net.psykosoft.psykopaint2.config.Settings;
	import net.psykosoft.psykopaint2.view.starling.base.StarlingViewBase;
	import net.psykosoft.psykopaint2.view.starling.navigation.subnavigation.base.SubNavigationViewBase;

	import org.osflash.signals.Signal;

	import starling.display.Image;
	import starling.display.Sprite;
	import starling.events.Event;

	public class NavigationView extends StarlingViewBase
	{
		private var _container:Sprite;
		private var _bgImage:Image;
		private var _backButton:Button;
		private var _activeSubNavigation:SubNavigationViewBase;

		private const CONTENT_AREA_HEIGHT:uint = 300;

		public var backButtonTriggeredSignal:Signal;

		public function NavigationView() {

			super();

			// Init container.
			_container = new Sprite();
			addChild( _container );

			// Init bg image.
			_bgImage = new Image( AssetManager.getTextureById( AssetManager.NavigationBackgroundTexture ) );
			_bgImage.y = -_bgImage.height;
			_container.addChild( _bgImage );

			// Test button.
			_backButton = new Button();
			_backButton.width = 250 * Settings.CONTENT_SCALE_MULTIPLIER;
			_backButton.height = 250 * Settings.CONTENT_SCALE_MULTIPLIER;
			_backButton.x = 10;
			_backButton.y = -( CONTENT_AREA_HEIGHT + _backButton.height ) / 2;
			_backButton.label = "<< Back";
			_backButton.visible = false;
			_backButton.addEventListener( Event.TRIGGERED, onBackButtonTriggered );
			_container.addChild( _backButton );

			backButtonTriggeredSignal = new Signal();
		}

		private function onBackButtonTriggered( event:Event ):void {
			backButtonTriggeredSignal.dispatch();
		}

		public function showBackButton():void {
			_backButton.visible = true;
		}

		public function hideBackButton():void {
			_backButton.visible = false;
		}

		public function enableSubNavigationView( view:SubNavigationViewBase ):void {
			if( _activeSubNavigation == view ) return;
			if( _activeSubNavigation ) disableSubNavigation();
			_activeSubNavigation = view;
			_activeSubNavigation.y = -CONTENT_AREA_HEIGHT / 2 - _activeSubNavigation.height / 2;
			_container.addChild( _activeSubNavigation );
			onLayout();
		}

		public function disableSubNavigation():void {
			_container.removeChild( _activeSubNavigation );
			_activeSubNavigation.dispose();
			_activeSubNavigation = null;
		}

		override protected function onLayout():void {

			// container.
			_container.y = stage.stageHeight;

			// bg image.
			_bgImage.width = stage.stageWidth;

			// sub navigation.
			if( _activeSubNavigation ) {
				_activeSubNavigation.x = stage.stageWidth / 2 - _activeSubNavigation.width / 2;
			}
		}
	}
}
