package net.psykosoft.psykopaint2.view.starling.navigation.subnavigation.base
{

	import feathers.controls.Button;
	import feathers.controls.ButtonGroup;
	import feathers.controls.ScrollContainer;
	import feathers.controls.Scroller;
	import feathers.core.FeathersControl;
	import feathers.data.ListCollection;

	import net.psykosoft.psykopaint2.config.Settings;
	import net.psykosoft.psykopaint2.ui.extensions.buttongroups.vo.ButtonDefinitionVO;
	import net.psykosoft.psykopaint2.ui.extensions.buttongroups.vo.ButtonGroupDefinitionVO;
	import net.psykosoft.psykopaint2.ui.theme.Psykopaint2UiTheme;
	import net.psykosoft.psykopaint2.view.starling.base.StarlingViewBase;

	import org.osflash.signals.Signal;

	import starling.display.Image;
	import starling.display.Sprite;
	import starling.events.Event;

	public class SubNavigationViewBase extends StarlingViewBase
	{
		private var _scrollContainer:ScrollContainer;
		private var _buttonGroup:ButtonGroup;
		private var _leftButton:Button;
		private var _rightButton:Button;
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

		private const SUB_NAVIGATION_SCROLL_AREA_WIDTH:Number = 800;

		public function SubNavigationViewBase( title:String ) {
			super();

			buttonPressedSignal = new Signal();

			_title = title;

			addChild( _backLayer = new Sprite() );
			addChild( _frontLayer = new Sprite() );
		}

		override protected function onStageAvailable():void {

			_header = new Button();
			_header.nameList.add( Psykopaint2UiTheme.BUTTON_TYPE_HEADER );
			_header.label = _title;
			_header.height = 30;
			_header.width = 200;
			_header.isEnabled = false;
			_header.x = stage.stageWidth / 2 - _header.width / 2;
			_header.y = -_header.height / 2;
			_header.validate();
			_frontLayer.addChild( _header );

			super.onStageAvailable();
		}

		protected function setLeftButton( button:Button ):void {

			// TODO: clear previous button?

			_leftCornerImage = new Image( Psykopaint2UiTheme.instance.getTexture( Psykopaint2UiTheme.TEXTURE_NAVIGATION_LEFT_CORNER ) );
			_leftCornerImage.y = Settings.NAVIGATION_AREA_CONTENT_HEIGHT - _leftCornerImage.height;
			_frontLayer.addChild( _leftCornerImage );

			_leftButton = button;
			_leftButton.nameList.add( Psykopaint2UiTheme.pickRandomPaperButtonName() );
			_leftButton.width = _leftButton.height = Psykopaint2UiTheme.SIZE_PAPER_BUTTON;
			_leftButton.addEventListener( Event.TRIGGERED, onButtonTriggered );
			_leftButton.x = _leftCornerImage.x + _leftCornerImage.width - _leftButton.width - 15;
			_leftButton.y = _leftCornerImage.y + 5;
			_leftButton.validate();
			_frontLayer.addChild( _leftButton );

			_leftArrow = new Image( Psykopaint2UiTheme.instance.getTexture( Psykopaint2UiTheme.TEXTURE_NAVIGATION_ARROW ) );
			_leftArrow.x = 0;
			_leftArrow.y = _leftButton.y + _leftButton.height / 2;
			_frontLayer.addChild( _leftArrow );

			_leftClamp = new Image( Psykopaint2UiTheme.instance.getTexture( Psykopaint2UiTheme.TEXTURE_NAVIGATION_CLAMP) );
			_leftClamp.x = _leftCornerImage.width - 50;
			_leftClamp.y = _leftCornerImage.y + 10;
			_frontLayer.addChild( _leftClamp );
		}

		protected function setRightButton( button:Button ):void {

			// TODO: clear previous button?

			_rightCornerImage = new Image( Psykopaint2UiTheme.instance.getTexture( Psykopaint2UiTheme.TEXTURE_NAVIGATION_RIGHT_CORNER ) );
			_rightCornerImage.y = Settings.NAVIGATION_AREA_CONTENT_HEIGHT - _rightCornerImage.height;
			_rightCornerImage.x = stage.stageWidth - _rightCornerImage.width;
			_frontLayer.addChild( _rightCornerImage );

			_rightButton = button;
			_rightButton.nameList.add( Psykopaint2UiTheme.pickRandomPaperButtonName() );
			_rightButton.width = _rightButton.height = Psykopaint2UiTheme.SIZE_PAPER_BUTTON;
			_rightButton.addEventListener( Event.TRIGGERED, onButtonTriggered );
			_rightButton.x = _rightCornerImage.x + 5;
			_rightButton.y = _rightCornerImage.y;
			_rightButton.validate();
			_frontLayer.addChild( _rightButton );

			_rightArrow = new Image( Psykopaint2UiTheme.instance.getTexture( Psykopaint2UiTheme.TEXTURE_NAVIGATION_ARROW ) );
			_rightArrow.scaleX = -1;
			_rightArrow.x = stage.stageWidth;
			_rightArrow.y = _rightButton.y + _rightButton.height / 2;
			_frontLayer.addChild( _rightArrow );

			_rightClamp = new Image( Psykopaint2UiTheme.instance.getTexture( Psykopaint2UiTheme.TEXTURE_NAVIGATION_CLAMP) );
			_rightClamp.x = _rightCornerImage.x + 15;
			_rightClamp.y = _rightCornerImage.y + 7;
			_frontLayer.addChild( _rightClamp );
		}

		protected function setCenterButtons( definition:ButtonGroupDefinitionVO ):void {

			_buttonGroup = new ButtonGroup();
			_buttonGroup.customFirstButtonName = Psykopaint2UiTheme.pickRandomPaperButtonName();
			_buttonGroup.customLastButtonName = Psykopaint2UiTheme.pickRandomPaperButtonName();
			_buttonGroup.customButtonName = Psykopaint2UiTheme.pickRandomPaperButtonName();
			_buttonGroup.direction = ButtonGroup.DIRECTION_HORIZONTAL;
			_buttonGroup.buttonInitializer = buttonInitializer;
			_buttonGroup.dataProvider = new ListCollection( definition.buttonVOArray );
			_buttonGroup.invalidate( FeathersControl.INVALIDATION_FLAG_ALL );
			_buttonGroup.setSize( definition.buttonVOArray.length * ( Psykopaint2UiTheme.SIZE_PAPER_BUTTON + 10 ), Psykopaint2UiTheme.SIZE_PAPER_BUTTON ); // TODO: properly do this calculation

			_scrollContainer = new ScrollContainer();
//			_scrollContainer.backgroundSkin = new Quad( 100, 100, 0x222222 );
			_scrollContainer.scrollerProperties.horizontalScrollPolicy = Scroller.SCROLL_POLICY_AUTO;
			_scrollContainer.scrollerProperties.verticalScrollPolicy = Scroller.SCROLL_POLICY_OFF;
			_scrollContainer.width = SUB_NAVIGATION_SCROLL_AREA_WIDTH;
			_scrollContainer.height = Settings.NAVIGATION_AREA_CONTENT_HEIGHT;
			_scrollContainer.x = 1024 / 2 - SUB_NAVIGATION_SCROLL_AREA_WIDTH / 2;
			_scrollContainer.y = 0;
			_scrollContainer.addChild( _buttonGroup );
			_backLayer.addChild( _scrollContainer );

			_buttonGroup.validate();
			if( _buttonGroup.width < SUB_NAVIGATION_SCROLL_AREA_WIDTH ) {
				_buttonGroup.x = SUB_NAVIGATION_SCROLL_AREA_WIDTH / 2 - _buttonGroup.width / 2;
			}
			_buttonGroup.y = Settings.NAVIGATION_AREA_CONTENT_HEIGHT / 2 - _buttonGroup.height / 2;
		}

		private function buttonInitializer( button:Button, data:ButtonDefinitionVO ):void {
			button.isEnabled = data.isEnabled;
			button.label = data.label;
			button.addEventListener( Event.TRIGGERED, data.triggered );
		}

		protected function onButtonTriggered( event:Event ):void {
			var button:Button = event.currentTarget as Button;
			buttonPressedSignal.dispatch( button.label );
		}

		override public function dispose():void {
			// TODO: disable button group, specially remove listeners
			super.disable();
		}
	}
}
