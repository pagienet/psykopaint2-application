package net.psykosoft.psykopaint2.view.starling.base
{

	import starling.display.Sprite;
	import starling.events.Event;
	import starling.events.ResizeEvent;

	public class StarlingViewBase extends Sprite
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

			onSetup();

		}

		protected function onUpdate():void {
			// Override.
		}

		protected function onLayout():void {
			// Override.
		}

		protected function onSetup():void {
			onLayout();
		}

		public function enable():void {
			if( _enabled ) return;
			visible = true;
			_enabled = true;
		}

		public function disable():void {
			if( !_enabled ) return;
			visible = false;
			_enabled = false;
		}

		private function onStageResize( event:ResizeEvent ):void {
			onLayout();
		}

		private function onEnterFrame( event:Event ):void {
			if( _enabled ) {
				onUpdate();
			}
		}
	}
}

