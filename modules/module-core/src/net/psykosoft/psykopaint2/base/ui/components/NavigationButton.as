package net.psykosoft.psykopaint2.base.ui.components
{

	import flash.display.Bitmap;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.ColorTransform;

	import net.psykosoft.psykopaint2.core.views.components.label.SbCenterLabel;
	import net.psykosoft.psykopaint2.core.views.components.label.SbLabel;
	import net.psykosoft.psykopaint2.core.views.components.label.SbLeftLabel;
	import net.psykosoft.psykopaint2.core.views.components.label.SbRightLabel;

	public class NavigationButton extends Sprite
	{
		protected var _label:PsykoLabel;
		protected var _icon:MovieClip;
		protected var _iconBitmap:Bitmap;
		protected var _selectable:Boolean;
		protected var _selected:Boolean;

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

		protected function updateSelected():void {
			transform.colorTransform = _selected ? new ColorTransform( 1, 0.5, 0.5 ) : new ColorTransform();
		}

		// ---------------------------------------------------------------------
		// Public.
		// ---------------------------------------------------------------------

		public function set selectable( value:Boolean ):void {
			if( !value ) selected = false;
			_selectable = value;
		}

		public function get selectable():Boolean {
			return _selectable;
		}

		public function set selected( value:Boolean ):void {
//			trace( this, "selected: " + value + ", " + _label.text );
			if( !_selectable ) return;
			_selected = value;
			mouseEnabled = mouseChildren = !_selected;
			updateSelected();
		}

		public function get selected():Boolean {
			return _selected;
		}

		public function set iconType( frameName:String ):void {
			if( !frameName ) return;
			_icon.gotoAndStop( frameName );
		}

		public function get iconType():String {
			return _icon.currentFrameLabel;
		}

		public function set labelText( value:String ):void {
			_label.text = value;
		}

		public function get labelText():String {
			return _label.text;
		}

		// Can be used dynamically by virtual lists.
		public function set iconBitmap( bitmap:Bitmap ):void {
			if( !bitmap ) return;
			if( _iconBitmap ) {
				if( _iconBitmap.parent == _icon ) {
					_icon.removeChild( _iconBitmap );
				}
				_iconBitmap = null;
				// TODO: dispose bitmap and bitmap data?
			}
			_iconBitmap = bitmap;
			adjustBitmap();
			_icon.addChild( _iconBitmap );
		}

		public function get iconBitmap():Bitmap {
			return _iconBitmap;
		}

		// ---------------------------------------------------------------------
		// Protected.
		// ---------------------------------------------------------------------

		protected function adjustBitmap():void {
			if( !_iconBitmap ) return;
			_iconBitmap.x = -_iconBitmap.width / 2;
			_iconBitmap.y = -_iconBitmap.height / 2;
		}

		// ---------------------------------------------------------------------
		// Private.
		// ---------------------------------------------------------------------

		private function scaleIcon( value:Number ):void {
			_icon.scaleX = _icon.scaleY = value;
		}

		private function rand( min:Number, max:Number ):Number {
			return (max - min) * Math.random() + min;
		}

		// ---------------------------------------------------------------------
		// Listeners.
		// ---------------------------------------------------------------------

		private function onAddedToStage( event:Event ):void {
			removeEventListener( Event.ADDED_TO_STAGE, onAddedToStage );
			updateSelected();
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
