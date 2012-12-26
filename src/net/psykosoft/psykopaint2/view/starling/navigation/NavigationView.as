package net.psykosoft.psykopaint2.view.starling.navigation
{

	import feathers.controls.Button;

	import net.psykosoft.psykopaint2.assets.starling.StarlingTextureManager;
	import net.psykosoft.psykopaint2.assets.starling.data.StarlingTextureType;
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

		private const CONTENT_AREA_HEIGHT:uint = 170;

		public var backButtonTriggeredSignal:Signal;

		public function NavigationView() {
			super();

			// Bg.
			_bgImage = new Image( StarlingTextureManager.getTextureById( StarlingTextureType.NAVIGATION_BACKGROUND ) );
			addChild( _bgImage );

			// Container will hold buttons.
			_container = new Sprite();
			addChild( _container );

			// Back button.
			_backButton = new Button();
			_backButton.width = 100;
			_backButton.height = 100;
			_backButton.label = "<< Back";
			_backButton.visible = false;
			_backButton.addEventListener( Event.TRIGGERED, onBackButtonTriggered );
			_container.addChild( _backButton );

			backButtonTriggeredSignal = new Signal();
		}

		override protected function onLayout():void {

			// back btn
			_backButton.x = 10;
			_backButton.y = CONTENT_AREA_HEIGHT / 2 - _backButton.height / 2;

			// bg image.
			_bgImage.y = stage.stageHeight - _bgImage.height;
			_bgImage.width = stage.stageWidth;

			// container.
			_container.y = stage.stageHeight - CONTENT_AREA_HEIGHT;

			// sub navigation.
			if( _activeSubNavigation ) {
				_activeSubNavigation.x = stage.stageWidth / 2 - _activeSubNavigation.width / 2;
				_activeSubNavigation.y = CONTENT_AREA_HEIGHT / 2 - _activeSubNavigation.height / 2;
			}
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
			_container.addChild( _activeSubNavigation );
			onLayout();
		}

		public function disableSubNavigation():void {
			_container.removeChild( _activeSubNavigation );
			_activeSubNavigation.dispose();
			_activeSubNavigation = null;
		}
	}
}
