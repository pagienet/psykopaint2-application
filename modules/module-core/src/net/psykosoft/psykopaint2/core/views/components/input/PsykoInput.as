package net.psykosoft.psykopaint2.core.views.components.input
{

	import br.hellokeita.utils.TextFieldColor;

	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.FocusEvent;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.text.TextFieldType;
	import flash.ui.Keyboard;

	import org.osflash.signals.Signal;

	public class PsykoInput extends Sprite
	{
		// Declared in Flash.
		public var bg:Sprite;
		public var selRed:Sprite;
		public var selBlue:Sprite;
		public var cancelBtn:Sprite;
		public var tf:TextField;

		private var _defaultText:String = "default text";
		private var _behavesAsPassword:Boolean;

		public var enterPressedSignal:Signal;

		public function PsykoInput() {
			super();

			enterPressedSignal = new Signal();

			selRed.mouseEnabled = selRed.mouseChildren = false;
			selBlue.mouseEnabled = selBlue.mouseChildren = false;

			selRed.visible = false;
			selBlue.visible = false;

			showCancelButton( false );

			tf.selectable = true;
			tf.restrict = "^\u0020\u0013";
			tf.multiline = false;
			tf.type = TextFieldType.INPUT;

			// Used to modify the colors during selection
			new TextFieldColor( tf, 0, 0xFFFFFF, 0x000000 );

			addEventListener( Event.ADDED_TO_STAGE, onAddedToStage );
		}

		public function dispose():void {
			if( tf.hasEventListener( MouseEvent.CLICK ) ) tf.removeEventListener( MouseEvent.CLICK, onTfClick );
			if( tf.hasEventListener( FocusEvent.FOCUS_OUT ) ) tf.removeEventListener( FocusEvent.FOCUS_OUT, onTfFocusOut );
			if( tf.hasEventListener( Event.CHANGE ) ) tf.removeEventListener( Event.CHANGE, onTfChange );
			if( tf.hasEventListener( KeyboardEvent.KEY_DOWN ) ) tf.addEventListener( KeyboardEvent.KEY_DOWN, onTfKeyDown );
			if( cancelBtn.hasEventListener( MouseEvent.MOUSE_DOWN ) ) cancelBtn.removeEventListener( MouseEvent.CLICK, onCancelBtnMouseDown );
		}

		// -----------------------
		// Interface.
		// -----------------------

		public function get defaultText():String {
			return _defaultText;
		}

		public function set defaultText( value:String ):void {
			tf.text = _defaultText = value;
		}

		public function get text():String {
			return tf.text;
		}

		public function showBlueHighlight():void {
	   		selRed.visible = false;
			selBlue.visible = true;
		}

		public function showRedHighlight():void {
			selRed.visible = true;
			selBlue.visible = false;
		}

		public function showNoHighlight():void {
			selRed.visible = selBlue.visible = false;
		}

		public function behavesAsPassword( value:Boolean ):void {
			_behavesAsPassword = value;
		}

		public function focusIn( hideHighlights:Boolean = true ):void {

			if( hideHighlights ) showNoHighlight();

			if( _behavesAsPassword ) tf.displayAsPassword = true;

			// From default text to empty string?
			if( tf.text == _defaultText ) {
				tf.text = "";
			}

			// Show cancel button?
			showCancelButton( tf.text.length > 0 );

			// Gain focus and place cursor at last character.
			stage.focus = tf;
			tf.setSelection( tf.text.length, tf.text.length );
		}

		// -----------------------
		// Event handlers.
		// -----------------------

		private function onAddedToStage( event:Event ):void {
			removeEventListener( Event.ADDED_TO_STAGE, onAddedToStage );
			tf.addEventListener( MouseEvent.CLICK, onTfClick );
			tf.addEventListener( FocusEvent.FOCUS_OUT, onTfFocusOut );
			tf.addEventListener( Event.CHANGE, onTfChange );
			tf.addEventListener( KeyboardEvent.KEY_DOWN, onTfKeyDown );
			cancelBtn.addEventListener( MouseEvent.MOUSE_DOWN, onCancelBtnMouseDown );
		}

		private function onTfKeyDown( event:KeyboardEvent ):void {
			if( event.keyCode == Keyboard.ENTER ) enterPressedSignal.dispatch();
		}

		private function onTfChange( event:Event ):void {
			if( _behavesAsPassword ) tf.displayAsPassword = true;
			showCancelButton( tf.text.length > 0 );
		}

		private function onTfFocusOut( event:FocusEvent ):void {

			// We need to check if the focus out was caused by clicking on the cancel button,
			// case which we should ignore.
			var hitsBtn:Boolean = cancelBtn.hitTestPoint( stage.mouseX, stage.mouseY );
			if( hitsBtn ) return;

			if( tf.text == "" ) {
				if( _behavesAsPassword ) tf.displayAsPassword = false;
				tf.text = _defaultText;
			}
			showCancelButton( false );
		}

		private function onTfClick( event:MouseEvent ):void {
			focusIn( true );
		}

		private function onCancelBtnMouseDown( event:MouseEvent ):void {
			tf.text = "";
			focusIn( true );
		}

		private function showCancelButton( show:Boolean ):void {
			cancelBtn.visible = show;
		}
	}
}
