package net.psykosoft.psykopaint2.view.starling.navigation.subnavigation.base
{

	import feathers.controls.Button;
	import feathers.controls.ScrollContainer;
	import feathers.controls.Scroller;

	import net.psykosoft.psykopaint2.config.Settings;
	import net.psykosoft.psykopaint2.ui.extensions.buttongroups.vo.ButtonDefinitionVO;
	import net.psykosoft.psykopaint2.ui.extensions.buttongroups.vo.ButtonGroupDefinitionVO;
	import net.psykosoft.psykopaint2.ui.extensions.buttons.CompoundButton;
	import net.psykosoft.psykopaint2.ui.theme.Psykopaint2Ui;
	import net.psykosoft.psykopaint2.ui.theme.buttons.ButtonSkinType;
	import net.psykosoft.psykopaint2.view.starling.base.StarlingViewBase;

	import org.osflash.signals.Signal;

	import starling.display.Image;
	import starling.display.Sprite;
	import starling.events.Event;

	public class SubNavigationViewBase extends StarlingViewBase
	{
		private var _scrollContainer:ScrollContainer;
		private var _leftButton:CompoundButton;
		private var _rightButton:CompoundButton;
		private var _header:Button;
		private var _title:String;
		private var _leftCornerImage:Image;
		private var _rightCornerImage:Image;
		private var _frontLayer:Sprite;
		private var _backLayer:Sprite;
		private var _leftClamp:Image;
		private var _rightClamp:Image;
		private var _leftArrow:Image;
		private var _rightArrow:Image;

		public var buttonPressedSignal:Signal;

		public function SubNavigationViewBase( title:String ) {
			super();

			buttonPressedSignal = new Signal();

			_title = title;

			addChild( _backLayer = new Sprite() );
			addChild( _frontLayer = new Sprite() );
		}

		override protected function onStageAvailable():void {

			_header = new Button();
			_header.nameList.add( ButtonSkinType.LABEL );
			_header.label = _title;
			_header.isEnabled = false;
			_header.addEventListener( Event.RESIZE, onHeaderResized );
			_header.validate();
			_frontLayer.addChild( _header );

			super.onStageAvailable();
		}

		private function onHeaderResized( event:Event ):void {
			_header.x = stage.stageWidth / 2 - _header.width / 2;
			_header.y = -_header.height / 2;
		}

		protected function setLeftButton( label:String ):void {

			// TODO: clear previous button?

			var button:CompoundButton = new CompoundButton( label, ButtonSkinType.PAPER_LABEL_LEFT, -20 );
			button.placementFunction = leftButtonLabelPlacement;

			_leftCornerImage = new Image( Psykopaint2Ui.instance.getTexture( Psykopaint2Ui.TEXTURE_NAVIGATION_LEFT_CORNER ) );
			_leftCornerImage.y = Settings.NAVIGATION_AREA_CONTENT_HEIGHT - _leftCornerImage.height;
			_frontLayer.addChild( _leftCornerImage );

			_leftButton = button;
			_leftButton.addEventListener( Event.TRIGGERED, onButtonTriggered );
			_leftButton.x = _leftCornerImage.x + _leftCornerImage.width - _leftButton.width - 15;
			_leftButton.y = _leftCornerImage.y + 5;
			_frontLayer.addChild( _leftButton );

			_leftArrow = new Image( Psykopaint2Ui.instance.getTexture( Psykopaint2Ui.TEXTURE_NAVIGATION_ARROW ) );
			_leftArrow.x = 0;
			_leftArrow.y = _leftButton.y + _leftButton.height / 2;
			_frontLayer.addChild( _leftArrow );

			_leftClamp = new Image( Psykopaint2Ui.instance.getTexture( Psykopaint2Ui.TEXTURE_NAVIGATION_CLAMP) );
			_leftClamp.x = _leftCornerImage.width - 50;
			_leftClamp.y = _leftCornerImage.y + 10;
			_frontLayer.addChild( _leftClamp );
		}

		private function leftButtonLabelPlacement():void {
			var label:Button = _leftButton.labelButton;
			label.x = -_leftButton.x; // Ensure the left edge of the label touches the left edge of the screen.
			trace( this, "placing left label" );
		}

		protected function setRightButton( label:String ):void {

			// TODO: clear previous button?

			var button:CompoundButton = new CompoundButton( label, ButtonSkinType.PAPER_LABEL_RIGHT, -20 );
			button.placementFunction = rightButtonLabelPlacement;

			_rightCornerImage = new Image( Psykopaint2Ui.instance.getTexture( Psykopaint2Ui.TEXTURE_NAVIGATION_RIGHT_CORNER ) );
			_rightCornerImage.y = Settings.NAVIGATION_AREA_CONTENT_HEIGHT - _rightCornerImage.height;
			_rightCornerImage.x = stage.stageWidth - _rightCornerImage.width;
			_frontLayer.addChild( _rightCornerImage );

			_rightButton = button;
			_rightButton.addEventListener( Event.TRIGGERED, onButtonTriggered );
			_rightButton.x = _rightCornerImage.x + 5;
			_rightButton.y = _rightCornerImage.y;
			_frontLayer.addChild( _rightButton );

			_rightArrow = new Image( Psykopaint2Ui.instance.getTexture( Psykopaint2Ui.TEXTURE_NAVIGATION_ARROW ) );
			_rightArrow.scaleX = -1;
			_rightArrow.x = stage.stageWidth;
			_rightArrow.y = _rightButton.y + _rightButton.height / 2;
			_frontLayer.addChild( _rightArrow );

			_rightClamp = new Image( Psykopaint2Ui.instance.getTexture( Psykopaint2Ui.TEXTURE_NAVIGATION_CLAMP) );
			_rightClamp.x = _rightCornerImage.x + 15;
			_rightClamp.y = _rightCornerImage.y + 7;
			_frontLayer.addChild( _rightClamp );
		}

		private function rightButtonLabelPlacement():void {
			var label:Button = _rightButton.labelButton;
			label.x = _rightButton.width - label.width; // Ensure the right edge of the label touches the right edge of the screen.
			trace( this, "placing right label" );
		}

		protected function setCenterButtons( definition:ButtonGroupDefinitionVO ):void {

			// Scroll capable container.
			_scrollContainer = new ScrollContainer();
//			_scrollContainer.backgroundSkin = new Quad( 100, 100, 0x222222 ); // Uncomment for visual debugging.
			_scrollContainer.scrollerProperties.horizontalScrollPolicy = Scroller.SCROLL_POLICY_AUTO;
			_scrollContainer.scrollerProperties.verticalScrollPolicy = Scroller.SCROLL_POLICY_OFF;
			_scrollContainer.height = Settings.NAVIGATION_AREA_CONTENT_HEIGHT;
			_backLayer.addChild( _scrollContainer );

			// Add buttons to the container.
			var inflate:Number = 150;
			var accumulatedContentWidth:Number = inflate;
			var len:uint = definition.buttonVOArray.length;
			var gap:Number = 15;
			for( var i:uint = 0; i < len; i++ ) {
				var vo:ButtonDefinitionVO = definition.buttonVOArray[ i ];
				var subButton:CompoundButton = new CompoundButton( vo.label, ButtonSkinType.LABEL );
				subButton.addEventListener( Event.TRIGGERED, onButtonTriggered ); // TODO: possible memory leak
				subButton.x = inflate + ( subButton.width + gap ) * i;
				subButton.y = 30;
				accumulatedContentWidth += subButton.width;
				if( i != len - 1 ) {
					accumulatedContentWidth += gap;
				}
				else if( i == len - 1 ) {
					accumulatedContentWidth += inflate;
				}
				_scrollContainer.addChild( subButton );
			}

			// Ensure that the rightmost gap is applied.
			var contentWidthEnforcer:Sprite = new Sprite();
			contentWidthEnforcer.x = accumulatedContentWidth;
			_scrollContainer.addChild( contentWidthEnforcer );

			// Center the container.
			if( accumulatedContentWidth < 1024 ) {
				_scrollContainer.width = accumulatedContentWidth;
			}
			else {
				_scrollContainer.width = 1024;
			}
			_scrollContainer.x = 1024 / 2 - _scrollContainer.width / 2;

		}

		protected function onButtonTriggered( event:Event ):void {
			var button:CompoundButton = event.currentTarget as CompoundButton;
			buttonPressedSignal.dispatch( button.label );
		}

		override public function dispose():void {
			// TODO: disable button group, specially remove listeners
			super.disable();
		}
	}
}
