package net.psykosoft.psykopaint2.app.view.navigation
{

	import com.greensock.TweenLite;
	import com.greensock.easing.Expo;
	
	import feathers.controls.Button;
	
	import net.psykosoft.psykopaint2.app.config.AppConfig;
	import net.psykosoft.psykopaint2.app.config.Settings;
	import net.psykosoft.psykopaint2.app.view.base.StarlingViewBase;
	import net.psykosoft.psykopaint2.ui.extensions.buttons.CompoundButton;
	import net.psykosoft.psykopaint2.ui.theme.Psykopaint2Ui;
	import net.psykosoft.psykopaint2.ui.theme.data.ButtonSkinType;
	
	import org.osflash.signals.Signal;
	
	import starling.display.Image;
	import starling.display.Sprite;
	import starling.events.Event;
	import starling.textures.RenderTexture;

	/*
	* Contains the lower navigation menu background image and the edge buttons.
	* Can add/remove sub navigation views to it ( scrollable center buttons and general button behaviour ).
	* */
	public class NavigationView extends StarlingViewBase
	{
		private var _subNavigationContainer:Sprite;
		private var _bgImage:Image;
		private var _activeSubNavigation:SubNavigationViewBase;
		private var _mainContainer:Sprite;
		private var _animating:Boolean;
		private var _showing:Boolean = true;

		public var shownAnimatedSignal:Signal;
		public var hiddenAnimatedSignal:Signal;

		public function NavigationView() {
			super();
			shownAnimatedSignal = new Signal();
			hiddenAnimatedSignal = new Signal();
		}

		// ---------------------------------------------------------------------
		// Sub-navigation life cycles.
		// ---------------------------------------------------------------------

		public function enableSubNavigationView( view:SubNavigationViewBase ):void {

			
			if( _activeSubNavigation == view ) return;
			trace( this, "adding sub-navigation view: " + view );
						
			//TRANSITION OUT PREVIOUS VIEW
			if(_activeSubNavigation)
			{
				//TODO : EDGE BUTTONS TRANSITION TOO
				hideEdgeButtons();
				var previousSubNavigation:SubNavigationViewBase = _activeSubNavigation;
				
				TweenLite.to(previousSubNavigation,0.3,{x:(_isBackButton)?(previousSubNavigation.x+stage.stageWidth):previousSubNavigation.x-stage.stageWidth,ease:Expo.easeIn,onComplete:function():void{
					_subNavigationContainer.removeChild( previousSubNavigation );
					previousSubNavigation.disable();	
				}});
			}
			
			
			_activeSubNavigation = view;
			_activeSubNavigation.setNavigation( this );
			_activeSubNavigation.enable();
			_subNavigationContainer.addChild( _activeSubNavigation );
			
			//TRANSITION IN NEW VIEW
			view.x = (_isBackButton)?-stage.stageWidth-_activeSubNavigation.width/2:+stage.stageWidth+_activeSubNavigation.width/2;
			TweenLite.to(view,0.5,{x:0,ease:Expo.easeOut});
			
			
		}

		public function disableSubNavigation():void {
			trace( this, "removing sub-navigation view: " + _activeSubNavigation );
			hideEdgeButtons();
			_subNavigationContainer.removeChild( _activeSubNavigation );
			_activeSubNavigation.disable();
			_activeSubNavigation = null;
		}

		// ---------------------------------------------------------------------
		// Edge buttons ( called by sub views ).
		// ---------------------------------------------------------------------

		private var _leftButton:CompoundButton;
		private var _rightButton:CompoundButton;
		private var _leftCornerImage:Image;
		private var _rightCornerImage:Image;
		private var _leftClamp:Image;
		private var _rightClamp:Image;
		private var _leftArrow:Image;
		private var _rightArrow:Image;
		private var _leftButtonContainer:Sprite;
		private var _rightButtonContainer:Sprite;
		private var _isBackButton:Boolean;

		public function setLeftButton( textureID:String,label:String ):void {
			_leftButton.label = label;
			_leftButton.texture = Psykopaint2Ui.instance.getTexture(textureID );
			_leftButtonContainer.visible = true;
		}

		public function setRightButton( textureID:String, label:String  ):void {
			_rightButton.label = label;
			_rightButton.texture = Psykopaint2Ui.instance.getTexture(textureID );
			_rightButtonContainer.visible = true;
		}

		private function hideEdgeButtons():void {
			_leftButtonContainer.visible = false;
			_rightButtonContainer.visible = false;
		}

		private function initializeLeftEdgeButton():void {

			_leftButtonContainer = new Sprite();
			_subNavigationContainer.addChild( _leftButtonContainer );

			_leftCornerImage = new Image( Psykopaint2Ui.instance.getTexture( Psykopaint2Ui.TEXTURE_NAVIGATION_LEFT_CORNER ) );
			_leftCornerImage.y = Settings.NAVIGATION_AREA_CONTENT_HEIGHT - _leftCornerImage.height;
			_leftButtonContainer.addChild( _leftCornerImage );

			_leftButton = new CompoundButton(Psykopaint2Ui.instance.footerAtlas.getTexture( "paper 1" ), "", ButtonSkinType.PAPER_LABEL_LEFT, -20 );
			_leftButton.placementFunction = leftButtonLabelPlacement;
			_leftButton.addEventListener( Event.TRIGGERED, onButtonTriggered );
			_leftButton.x = _leftCornerImage.x + _leftCornerImage.width - _leftButton.width - 15;
			_leftButton.y = _leftCornerImage.y + 5;
			_leftButtonContainer.addChild( _leftButton );

			_leftArrow = new Image( Psykopaint2Ui.instance.getTexture( Psykopaint2Ui.TEXTURE_NAVIGATION_ARROW ) );
			_leftArrow.x = 0;
			_leftArrow.y = _leftButton.y + _leftButton.height / 2;
			_leftButtonContainer.addChild( _leftArrow );

			_leftClamp = new Image( Psykopaint2Ui.instance.getTexture( Psykopaint2Ui.TEXTURE_NAVIGATION_CLAMP) );
			_leftClamp.x = _leftCornerImage.width - 50;
			_leftClamp.y = _leftCornerImage.y + 10;
			_leftButtonContainer.addChild( _leftClamp );

			_leftButtonContainer.visible = false;
		}

		private function initializeRightEdgeButton():void {

			_rightButtonContainer = new Sprite();
			_subNavigationContainer.addChild( _rightButtonContainer );

			var button:CompoundButton = new CompoundButton( Psykopaint2Ui.instance.footerAtlas.getTexture( "paper 1" ),"", ButtonSkinType.PAPER_LABEL_RIGHT, -20 );
			button.placementFunction = rightButtonLabelPlacement;

			_rightCornerImage = new Image( Psykopaint2Ui.instance.getTexture( Psykopaint2Ui.TEXTURE_NAVIGATION_RIGHT_CORNER ) );
			_rightCornerImage.y = Settings.NAVIGATION_AREA_CONTENT_HEIGHT - _rightCornerImage.height;
			_rightCornerImage.x = stage.stageWidth - _rightCornerImage.width;
			_rightButtonContainer.addChild( _rightCornerImage );

			_rightButton = button;
			_rightButton.addEventListener( Event.TRIGGERED, onButtonTriggered );
			_rightButton.x = _rightCornerImage.x + 5;
			_rightButton.y = _rightCornerImage.y;
			_rightButtonContainer.addChild( _rightButton );

			_rightArrow = new Image( Psykopaint2Ui.instance.getTexture( Psykopaint2Ui.TEXTURE_NAVIGATION_ARROW ) );
			_rightArrow.scaleX = -1;
			_rightArrow.x = stage.stageWidth;
			_rightArrow.y = _rightButton.y + _rightButton.height / 2;
			_rightButtonContainer.addChild( _rightArrow );

			_rightClamp = new Image( Psykopaint2Ui.instance.getTexture( Psykopaint2Ui.TEXTURE_NAVIGATION_CLAMP) );
			_rightClamp.x = _rightCornerImage.x + 15;
			_rightClamp.y = _rightCornerImage.y + 7;
			_rightButtonContainer.addChild( _rightClamp );

			_rightButtonContainer.visible = false;
		}

		private function leftButtonLabelPlacement():void {
			var label:Button = _leftButton.labelButton;
			label.x = -_leftButton.x; // Ensure the left edge of the label touches the left edge of the screen.
			label.labelOffsetX = 0;
		}

		private function rightButtonLabelPlacement():void {
			var label:Button = _rightButton.labelButton;
			label.x = _rightButton.width - label.width; // Ensure the right edge of the label touches the right edge of the screen.
			label.labelOffsetX = -10;
		}

		protected function onButtonTriggered( event:Event ):void {
			var button:CompoundButton = event.currentTarget as CompoundButton;
			_isBackButton = (button ==_leftButton )?true:false;
			if( _activeSubNavigation ) {
				_activeSubNavigation.notifyButtonPress( button.label );
			}
		}

		// ---------------------------------------------------------------------
		// Overrides.
		// ---------------------------------------------------------------------

		override protected function onEnabled():void {

			// Main container.
			_mainContainer = new Sprite();
			addChild( _mainContainer );

			// Bg image.
			_bgImage = new Image( Psykopaint2Ui.instance.getTexture( Psykopaint2Ui.TEXTURE_NAVIGATION_BG ) );
			_mainContainer.addChild( _bgImage );
			_bgImage.y = stage.stageHeight - _bgImage.height;
			_bgImage.width = stage.stageWidth;

			// Sub container will hold sub navigation views.
			_subNavigationContainer = new Sprite();
			_mainContainer.addChild( _subNavigationContainer );
			_subNavigationContainer.y = stage.stageHeight - Settings.NAVIGATION_AREA_CONTENT_HEIGHT;

			// Edge buttons.
			initializeLeftEdgeButton();
			initializeRightEdgeButton();
			
			
		}

		override protected function onDisabled():void {

			// Sub container.
			if( _subNavigationContainer ) {
				disableSubNavigation();
				_mainContainer.removeChild( _subNavigationContainer );
				_subNavigationContainer = null;
			}

			// Bg image.
			if( _bgImage ) {
				_bgImage.dispose();
				_mainContainer.removeChild( _bgImage );
			}

			// Main container.
			if( _mainContainer ) {
				removeChild( _mainContainer );
			}

			if( _leftButtonContainer ) {
				_leftButtonContainer.removeChild( _leftArrow );
				_leftArrow.texture.dispose();
				_leftArrow.dispose();
				_leftArrow = null;
				_leftButtonContainer.removeChild( _leftClamp );
				_leftClamp.texture.dispose();
				_leftClamp.dispose();
				_leftClamp = null;
				_leftButtonContainer.removeChild( _leftCornerImage );
				_leftCornerImage.texture.dispose();
				_leftCornerImage.dispose();
				_leftCornerImage = null;
				_leftButtonContainer.removeChild( _leftButton );
				_leftButton.removeEventListener( Event.TRIGGERED, onButtonTriggered );
				_leftButton.dispose();
				_leftButton = null;
				_subNavigationContainer.removeChild( _leftButtonContainer );
				_leftButtonContainer.dispose();
				_leftButtonContainer = null;
			}

			if( _rightButtonContainer ) {
				_rightButtonContainer.removeChild( _rightArrow );
				_rightArrow.texture.dispose();
				_rightArrow.dispose();
				_rightArrow = null;
				_rightButtonContainer.removeChild( _rightClamp );
				_rightClamp.texture.dispose();
				_rightClamp.dispose();
				_rightClamp = null;
				_rightButtonContainer.removeChild( _rightCornerImage );
				_rightCornerImage.texture.dispose();
				_rightCornerImage.dispose();
				_rightCornerImage = null;
				_rightButtonContainer.removeChild( _rightButton );
				_rightButton.removeEventListener( Event.TRIGGERED, onButtonTriggered );
				_rightButton.dispose();
				_rightButton = null;
				_subNavigationContainer.removeChild( _rightButtonContainer );
				_rightButtonContainer.dispose();
				_rightButtonContainer = null;
			}

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
