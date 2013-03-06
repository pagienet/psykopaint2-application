package net.psykosoft.psykopaint2.app.view.base
{

	import com.junkbyte.console.Cc;

	import net.psykosoft.psykopaint2.app.view.base.IView;

	import starling.display.Sprite;
	import starling.events.Event;
	import starling.events.ResizeEvent;

	public class StarlingViewBase extends Sprite implements IView
	{
		private var _enabled:Boolean = true;

		public function StarlingViewBase() {
			super();
			addEventListener( Event.ADDED_TO_STAGE, onAddedToStage );
		}

		private function onAddedToStage( event:Event ):void {

			removeEventListener( Event.ADDED_TO_STAGE, onAddedToStage );

			stage.addEventListener( ResizeEvent.RESIZE, onStageResize );
			stage.addEventListener( Event.ENTER_FRAME, onEnterFrame );

			onStageAvailable();
		}

		protected function onUpdate():void {
			// Override.
		}

		// TODO: remove all onLayouts? we are working with a fix screen size really 1024x768 ( view port changes only, coordinate system is always that )
		protected function onLayout():void {
			// Override.
		}

		protected function onStageAvailable():void {
			onLayout();
		}

		private function onStageResize( event:ResizeEvent ):void {
			onLayout();
		}

		private function onEnterFrame( event:Event ):void {
			if( _enabled ) {
				onUpdate();
			}
		}

		// ---------------------------------------------------------------------
		// IView interface implementation.
		// ---------------------------------------------------------------------

		public function enable():void {
			if( _enabled ) return;
			onLayout();
			visible = true;
			_enabled = true;
			Cc.info( this, "enable()." );
		}

		public function disable():void {
			if( !_enabled ) return;
			visible = false;
			_enabled = false;
			Cc.info( this, "disable()." );
		}

		public function destroy():void {
			// TODO
		}
	}
}

