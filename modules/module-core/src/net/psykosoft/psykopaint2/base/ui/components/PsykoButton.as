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

	public class PsykoButton extends Sprite
	{
		protected var _label:PsykoLabel;
		protected var _icon:MovieClip;
		protected var _iconBitmap:Bitmap;

		public function PsykoButton() {
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

		// ---------------------------------------------------------------------
		// Public.
		// ---------------------------------------------------------------------

		public function set iconType( frameName:String ):void {
			_icon.gotoAndStop( frameName );
		}

		public function set labelText( value:String ):void {
			_label.text = value;
		}

		public function get labelText():String {
			return _label.text;
		}

		// Can be used dynamically by virtual lists.
		public function set iconBitmap( bitmap:Bitmap ):void {
			if( _iconBitmap ) {
				_icon.removeChild( _iconBitmap );
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
