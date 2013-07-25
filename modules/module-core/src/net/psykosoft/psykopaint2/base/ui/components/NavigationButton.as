package net.psykosoft.psykopaint2.base.ui.components
{

	import flash.display.Bitmap;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;

	import net.psykosoft.psykopaint2.core.views.components.label.SbCenterLabel;
	import net.psykosoft.psykopaint2.core.views.components.label.SbLabel;
	import net.psykosoft.psykopaint2.core.views.components.label.SbLeftLabel;
	import net.psykosoft.psykopaint2.core.views.components.label.SbRightLabel;

	public class NavigationButton extends Sprite
	{
		protected var _label:PsykoLabel;
		protected var _icon:MovieClip;
		protected var _iconBitmap:Bitmap;
		protected var _pins:Sprite;
		protected var _pin1:Sprite;
		protected var _pin2:Sprite;

		private var _initialPinX1:Number;
		private var _initialPinX2:Number;

		public function NavigationButton() {
			super();
			addEventListener( Event.ADDED_TO_STAGE, onAddedToStage );
		}

		protected function setLabel( label:Sprite ):void {
			if( label is SbCenterLabel ) _label = SbCenterLabel( label );
			else if( label is SbRightLabel ) _label = SbRightLabel( label );
			else if( label is SbLeftLabel ) _label = SbLeftLabel( label );
			else if( label is SbLabel ) _label = SbLabel( label );
			else throw new Error( "Problem casting shake-n-bake element." );
		}

		protected function setIcon( icon:MovieClip ):void {
			_icon = icon;
			_icon.stop();
		}

		protected function setPins( pins:Sprite ):void {
			_pins = pins;
			_pin1 = _pins.getChildByName( "pin1" ) as Sprite;
			_pin2 = _pins.getChildByName( "pin2" ) as Sprite;
			_initialPinX1 = _pin1.x;
			_initialPinX2 = _pin2.x;
		}

		// ---------------------------------------------------------------------
		// Public.
		// ---------------------------------------------------------------------

		public function set iconType( frameName:String ):void {
			_icon.gotoAndStop( frameName );
		}

		public function set labelText( value:String ):void {
			_label.text = value;
			randomizePinsAndRotation();
		}

		public function get labelText():String {
			return _label.text;
		}

		// Can be used dynamically by virtual lists.
		public function set iconBitmap( bitmap:Bitmap ):void {
			if( _iconBitmap ) {
				_icon.removeChild( _iconBitmap );
				_iconBitmap = null;
				// TODO: dispose bitmap and bitmap data?
			}
			_iconBitmap = bitmap;
			adjustBitmap();
			_icon.addChild( _iconBitmap );
		}

		// ---------------------------------------------------------------------
		// Protected.
		// ---------------------------------------------------------------------

		protected function adjustBitmap():void {
			_iconBitmap.x = -_iconBitmap.width / 2;
			_iconBitmap.y = -_iconBitmap.height / 2;
		}

		// ---------------------------------------------------------------------
		// Private.
		// ---------------------------------------------------------------------

		private function scaleIcon( value:Number ):void {
			_icon.scaleX = _icon.scaleY = value;
		}

		private function randomizePinsAndRotation():void {

			if( !_pins.visible ) return;
			_pin1.visible = _pin2.visible = false;

			// Random rotation.
			_icon.rotation = rand( 1, 2 ) * ( Math.random() > 0.5 ? 1 : -1 );

			// Decide pin visibility depending on angle.
			if( _icon.rotation < 0 ) _pin2.visible = true;
			else _pin1.visible = true;

			// Random displacement of pins.
			_pin1.x = _initialPinX1 + rand( -5, 5 );
			_pin2.x = _initialPinX2 + rand( -5, 5 );
		}

		private function rand( min:Number, max:Number ):Number {
			return (max - min) * Math.random() + min;
		}

		// ---------------------------------------------------------------------
		// Listeners.
		// ---------------------------------------------------------------------

		private function onAddedToStage( event:Event ):void {
			removeEventListener( Event.ADDED_TO_STAGE, onAddedToStage );
			addEventListener( MouseEvent.MOUSE_DOWN, onThisMouseDown );
		}

		private function onStageMouseUp( event:MouseEvent ):void {
			if( hasEventListener( MouseEvent.MOUSE_UP ) ) {
				stage.removeEventListener( MouseEvent.MOUSE_UP, onStageMouseUp );
			}
			scaleIcon( 1 );
		}

		private function onThisMouseDown( event:MouseEvent ):void {
			if( !hasEventListener( MouseEvent.MOUSE_UP ) ) {
				stage.addEventListener( MouseEvent.MOUSE_UP, onStageMouseUp );
			}
			scaleIcon( 0.98 );
		}
	}
}
