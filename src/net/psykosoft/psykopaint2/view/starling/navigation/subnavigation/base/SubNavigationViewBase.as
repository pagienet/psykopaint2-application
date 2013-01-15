package net.psykosoft.psykopaint2.view.starling.navigation.subnavigation.base
{

	import com.junkbyte.console.Cc;

	import feathers.controls.Button;
	import feathers.controls.ButtonGroup;
	import feathers.controls.Header;
	import feathers.data.ListCollection;

	import net.psykosoft.psykopaint2.config.Settings;
	import net.psykosoft.psykopaint2.ui.buttons.buttongroups.vo.ButtonDefinitionVO;

	import net.psykosoft.psykopaint2.ui.buttons.buttongroups.vo.ButtonGroupDefinitionVO;
	import net.psykosoft.psykopaint2.view.starling.base.StarlingViewBase;

	import org.osflash.signals.Signal;

	import starling.events.Event;

	public class SubNavigationViewBase extends StarlingViewBase
	{
		private var _buttonGroup:ButtonGroup;
		private var _leftButton:Button;
		private var _rightButton:Button;
		private var _header:Button;
		private var _title:String;

		public var buttonPressedSignal:Signal;

		public function SubNavigationViewBase( title:String ) {
			super();
			buttonPressedSignal = new Signal();
			_title = title;
		}

		override protected function onStageAvailable():void {

			_header = new Button();
			_header.label = _title;
			_header.height = 30;
			_header.width = 200;
			_header.isEnabled = false;
			addChild( _header );

			super.onStageAvailable();
		}

		protected function setLeftButton( button:Button ):void {
			// TODO: clear previous button?
			_leftButton = button;
			_leftButton.width = _leftButton.height = 100;
			_leftButton.addEventListener( Event.TRIGGERED, onButtonTriggered );
			addChild( _leftButton );
		}

		protected function setRightButton( button:Button ):void {
			// TODO: clear previous button?
			_rightButton = button;
			_rightButton.width = _rightButton.height = 100;
			_rightButton.addEventListener( Event.TRIGGERED, onButtonTriggered );
			addChild( _rightButton );
		}

		protected function setCenterButtons( definition:ButtonGroupDefinitionVO ):void {
			if( !_buttonGroup ) {
				_buttonGroup = new ButtonGroup();
				_buttonGroup.direction = ButtonGroup.DIRECTION_HORIZONTAL;
				_buttonGroup.buttonProperties = { width: 100, height: 100 };
				_buttonGroup.buttonInitializer = buttonInitializer;
				addChild( _buttonGroup );
			}
			_buttonGroup.dataProvider = new ListCollection( definition.buttonVOArray );
		}

		private function buttonInitializer( button:Button, data:ButtonDefinitionVO ):void {
			button.isEnabled = data.isEnabled;
			button.label = data.label;
			button.addEventListener( Event.TRIGGERED, data.triggered );
		}

		override protected function onLayout():void {

			_header.x = stage.stageWidth / 2 - _header.width / 2;
			_header.y = -_header.height / 2;
			_header.validate();

			if( _leftButton ) {
				_leftButton.x = 10;
				_leftButton.y = Settings.NAVIGATION_AREA_CONTENT_HEIGHT / 2 - _leftButton.height / 2;
				_leftButton.validate();
			}

			if( _rightButton ) {
				_rightButton.x = stage.stageWidth - _rightButton.width - 10;
				_rightButton.y = Settings.NAVIGATION_AREA_CONTENT_HEIGHT / 2 - _rightButton.height / 2;
				_rightButton.validate();
			}

			if( _buttonGroup ) {
				_buttonGroup.validate();
				_buttonGroup.x = stage.stageWidth / 2 - _buttonGroup.width / 2;
				_buttonGroup.y = Settings.NAVIGATION_AREA_CONTENT_HEIGHT / 2 - _buttonGroup.height / 2;
			}

			super.onLayout();
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
