package net.psykosoft.psykopaint2.base.ui.components
{
	import flash.display.Sprite;
	import flash.events.MouseEvent;

	import net.psykosoft.psykopaint2.core.views.components.button.SbButton;

	public class ButtonGroup extends Sprite
	{
		private var _buttonPositionOffsetX:Number;
		private var _buttons:Array;
		private var _selected:SbButton;

		private const BUTTON_GAP_X:Number = 8;

		public function ButtonGroup() {
			super();
			reset();
		}

		public function get numButtons():uint {
			return _buttons.length;
		}

		public function addButton( btn:SbButton ):void {
			btn.x = _buttonPositionOffsetX + btn.width / 2;
			btn.y = btn.height / 2;
			_buttons.push( btn );
			_buttonPositionOffsetX += btn.width + BUTTON_GAP_X;
			addChild( btn );
			btn.addEventListener( MouseEvent.CLICK, onButtonClicked );
		}

		public function reset():void {
			// Reset offset to half a btn's width.
			_buttonPositionOffsetX = 0;
			// Clear buttons.
			if( _buttons && _buttons.length > 0 ) {
				var len:uint = _buttons.length;
				for( var i:uint; i < len; ++i ) {
					var btn:SbButton = _buttons[ i ];
					btn.removeEventListener( MouseEvent.CLICK, onButtonClicked );
					btn.dispose();
					btn = null;
				}
			}
			_buttons = [];
		}

		private function onButtonClicked( event:MouseEvent ):void {
			_selected = event.target.parent;
			var len:uint = _buttons.length;
			for( var i:uint; i < len; ++i ) {
				var btn:SbButton = _buttons[ i ];
				var clickedButton:Boolean = btn == _selected;
				btn.toggleSelect( clickedButton );
			}
		}

		public function getButtonWithLabel( label:String ):SbButton {
			var labelBtn:SbButton;
			var len:uint = _buttons.length;
			for( var i:uint; i < len; ++i ) {
				var btn:SbButton = _buttons[ i ];
				if( btn.labelText == label ) labelBtn = btn;
			}
			return labelBtn;
		}

		public function setSelectedButtonByIndex( index:uint ):void {
			var len:uint = _buttons.length;
			for( var i:uint; i < len; ++i ) {
				var btn:SbButton = _buttons[ i ];
				if( i == index ) {
					_selected = btn;
					btn.toggleSelect( true );
				}
				else btn.toggleSelect( false );
			}
		}

		public function setSelectedButtonByLabel( btnLabel:String ):void {
			var len:uint = _buttons.length;
			for( var i:uint; i < len; ++i ) {
				var btn:SbButton = _buttons[ i ];
				if( btn.labelText == btnLabel ) {
					_selected = btn;
					btn.toggleSelect( true );
				}
				else btn.toggleSelect( false );
			}
		}

		public function getSelectedBtnLabel():String {
			return _selected.labelText;
		}

		override public function get width():Number {
			var numButtons:uint = _buttons.length;
			if( numButtons == 0 ) return 0;
			var firstButton:SbButton = _buttons[ 0 ];
			if( numButtons == 1 ) return firstButton.width;
			var lastButton:SbButton = _buttons[ numButtons - 1 ];
			return ( lastButton.x + lastButton.width / 2 ) - ( firstButton.x - firstButton.width / 2 );
		}

		override public function get height():Number {
			var aButton:SbButton = _buttons[ 0 ];
			return aButton.height;
		}

		public function get buttons():Array {
			return _buttons;
		}

		public function getSelectedBtnIndex():int {
			var len:uint = _buttons.length;
			for( var i:uint; i < len; i++ ) {
				var btn:SbButton = _buttons[ i ];
				if( btn.isSelected ) {
					return i;
				}
			}
			return -1;
		}
	}
}
