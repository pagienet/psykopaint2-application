package net.psykosoft.psykopaint2.app.view.starling.navigation
{

	import com.greensock.TweenLite;

	import net.psykosoft.psykopaint2.app.config.Settings;
	import net.psykosoft.psykopaint2.ui.theme.Psykopaint2Ui;
	import net.psykosoft.psykopaint2.app.view.starling.base.StarlingViewBase;
	import net.psykosoft.psykopaint2.app.view.starling.navigation.subnavigation.base.SubNavigationViewBase;

	import org.osflash.signals.Signal;

	import starling.display.Image;
	import starling.display.Sprite;

	/*
	* Contains the lower navigation menu background image.
	* Can add/remove sub navigation views to it.
	* */
	public class NavigationView extends StarlingViewBase
	{
		private var _subNavigationContainer:Sprite;
		private var _bgImage:Image;
		private var _activeSubNavigation:SubNavigationViewBase;
		private var _mainContainer:Sprite;
		private var _animating:Boolean;
		private var _showing:Boolean = true;

		public var backButtonTriggeredSignal:Signal;
		public var shownAnimatedSignal:Signal;
		public var hiddenAnimatedSignal:Signal;

		public function NavigationView() {
			super();

			// Main container.
			_mainContainer = new Sprite();
			addChild( _mainContainer );

			// Bg.
			_bgImage = new Image( Psykopaint2Ui.instance.getTexture( Psykopaint2Ui.TEXTURE_NAVIGATION_BG ) );
			_mainContainer.addChild( _bgImage );

			// Container will hold sub navigation views.
			_subNavigationContainer = new Sprite();
			_mainContainer.addChild( _subNavigationContainer );

			// Init signals.
			backButtonTriggeredSignal = new Signal();
			shownAnimatedSignal = new Signal();
			hiddenAnimatedSignal = new Signal();
		}

		// ---------------------------------------------------------------------
		// Sub-navigation life cycles.
		// ---------------------------------------------------------------------

		public function enableSubNavigationView( view:SubNavigationViewBase ):void {
			if( _activeSubNavigation == view ) return;
			if( _activeSubNavigation ) disableSubNavigation();
			_activeSubNavigation = view;
			_subNavigationContainer.addChild( _activeSubNavigation );
			onLayout();
		}

		public function disableSubNavigation():void {
			_subNavigationContainer.removeChild( _activeSubNavigation );
			_activeSubNavigation = null;
		}

		// TODO: implement when appropriate
		public function destroySubNavigation( view:SubNavigationViewBase ):void {
			view.dispose();
			view = null;
		}

		// ---------------------------------------------------------------------
		// Overrides.
		// ---------------------------------------------------------------------

		override protected function onLayout():void {

			_bgImage.y = stage.stageHeight - _bgImage.height;
			_bgImage.width = stage.stageWidth;

			_subNavigationContainer.y = stage.stageHeight - Settings.NAVIGATION_AREA_CONTENT_HEIGHT;
		}

		// ---------------------------------------------------------------------
		// Show/hide.
		// ---------------------------------------------------------------------

		public function showAnimated():void {
			if( _animating ) return;
			if( _showing ) return;
			_showing = true;
			_animating = true;
			_mainContainer.visible = true;
			TweenLite.to( _mainContainer, 0.25, { y: 0, onComplete: onShowAnimatedComplete } );
		}

		private function onShowAnimatedComplete():void {
			_animating = false;
			shownAnimatedSignal.dispatch();
		}

		public function hideAnimated():void {
			if( _animating ) return;
			if( !_showing ) return;
			_showing = false;
			_animating = true;
			TweenLite.to( _mainContainer, 0.25, { y: Settings.NAVIGATION_AREA_CONTENT_HEIGHT + 100, onComplete: onHideAnimatedComplete } );
		}

		private function onHideAnimatedComplete():void {
			_mainContainer.visible = false;
			_animating = false;
			hiddenAnimatedSignal.dispatch();
		}

		public function get showing():Boolean {
			return _showing;
		}
	}
}
