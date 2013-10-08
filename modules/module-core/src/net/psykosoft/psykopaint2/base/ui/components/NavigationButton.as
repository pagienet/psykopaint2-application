package net.psykosoft.psykopaint2.base.ui.components
{

	import flash.display.Bitmap;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.ColorTransform;
	
	import net.psykosoft.psykopaint2.core.views.components.label.CenterLabel;
	import net.psykosoft.psykopaint2.core.views.components.label.Label;
	import net.psykosoft.psykopaint2.core.views.components.label.LeftLabel;
	import net.psykosoft.psykopaint2.core.views.components.label.RightLabel;

	public class NavigationButton extends Sprite
	{
		protected var _label:PsykoLabel;
		protected var _icon:MovieClip;
		protected var _iconBitmap:Bitmap;
		protected var _selectable:Boolean;
		protected var _selected:Boolean;
		protected var _enabled:Boolean;
		protected var _disableMouseInteractivityWhenSelected:Boolean = true;

		public var id:String;

		public function NavigationButton() {
			super();
			addEventListener( Event.ADDED_TO_STAGE, onAddedToStage );
		}

		public function dispose():void {

//			trace( this, "dispose()" );

			if( hasEventListener( MouseEvent.MOUSE_UP ) ) {
				stage.removeEventListener( MouseEvent.MOUSE_UP, onStageMouseUp );
			}

			removeEventListener( MouseEvent.MOUSE_DOWN, onThisMouseDown );

		}

		protected function setLabel( label:Sprite ):void {
			if( label is CenterLabel ) _label = CenterLabel( label );
			else if( label is RightLabel ) _label = RightLabel( label );
			else if( label is LeftLabel ) _label = LeftLabel( label );
			else if( label is Label ) _label = Label( label );
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
			mouseInteractive = _disableMouseInteractivityWhenSelected ? !_selected && _enabled : _enabled;
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
		
		public function showIcon( show:Boolean ):void {
			_icon.visible = show;
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

		public function get enabled():Boolean {
			return _enabled;
		}

		public function set enabled( value:Boolean ):void {
			_enabled = value;
			if( !_enabled ) transform.colorTransform = new ColorTransform( -1, -1, -1, 1 );
			else transform.colorTransform = new ColorTransform();
			mouseInteractive = _disableMouseInteractivityWhenSelected ? !_selected && _enabled : _enabled;
		}

		public function set mouseInteractive( value:Boolean ):void {
			mouseEnabled = mouseChildren = value;
		}

		public function get disableMouseInteractivityWhenSelected():Boolean {
			return _disableMouseInteractivityWhenSelected;
		}

		public function set disableMouseInteractivityWhenSelected( value:Boolean ):void {
			_disableMouseInteractivityWhenSelected = value;
		}
	}
}
