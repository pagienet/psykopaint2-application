package net.psykosoft.psykopaint2.view.starling.navigation
{

	import com.greensock.TweenLite;
	import com.greensock.easing.Strong;

	import net.psykosoft.psykopaint2.config.Settings;
	import net.psykosoft.psykopaint2.ui.theme.Psykopaint2Ui;
	import net.psykosoft.psykopaint2.view.starling.base.StarlingViewBase;
	import net.psykosoft.psykopaint2.view.starling.navigation.subnavigation.base.SubNavigationViewBase;

	import org.osflash.signals.Signal;

	import starling.display.Image;
	import starling.display.Sprite;

	/*
	* Contains the lower navigation menu background image.
	* Can add/remove sub navigation views to it.
	* */
	public class NavigationView extends StarlingViewBase
	{
		private var _container:Sprite;
		private var _bgImage:Image;
		private var _activeSubNavigation:SubNavigationViewBase;

		public var backButtonTriggeredSignal:Signal;

		public function NavigationView() {
			super();

			// Bg.
			_bgImage = new Image( Psykopaint2Ui.instance.getTexture( Psykopaint2Ui.TEXTURE_NAVIGATION_BG ) );
			addChild( _bgImage );

			// Container will hold buttons.
			_container = new Sprite();
			addChild( _container );

			backButtonTriggeredSignal = new Signal();
		}

		override protected function onLayout():void {

			// Bg image.
			_bgImage.y = stage.stageHeight - _bgImage.height;
			_bgImage.width = stage.stageWidth;

			// Container.
			_container.y = stage.stageHeight - Settings.NAVIGATION_AREA_CONTENT_HEIGHT;
		}

		public function showAnimated():void {
			visible = true;
			TweenLite.to( this, 0.5, { y:0, ease:Strong.easeOut } );
		}

		public function hideAnimated():void {
			TweenLite.to( this, 0.5, { y:Settings.NAVIGATION_AREA_CONTENT_HEIGHT + 100, ease:Strong.easeOut, onComplete: onHideAnimatedComplete } );
		}

		private function onHideAnimatedComplete():void {
			visible = false;
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
