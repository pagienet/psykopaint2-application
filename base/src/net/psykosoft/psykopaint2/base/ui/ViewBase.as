package net.psykosoft.psykopaint2.base.ui
{
	import com.junkbyte.console.Cc;

	import flash.display.Sprite;
	import flash.events.Event;

	public class ViewBase extends Sprite
	{
		public function ViewBase() {
			super();
			Cc.log( this, "constructor" );
			addEventListener( Event.ADDED_TO_STAGE, onAddedToStage );
			scaleX = scaleY = ViewCore.globalScaling;
			visible = false;
		}

		// ---------------------------------------------------------------------
		// Private.
		// ---------------------------------------------------------------------

		private function onAddedToStage( event:Event ):void {
			removeEventListener( Event.ADDED_TO_STAGE, onAddedToStage );
//			trace( this, "onAddedToStage() - stage dimensions: " + stage.stageWidth + ", " + stage.stageHeight );
			onSetup();
		}

		// ---------------------------------------------------------------------
		// Public.
		// ---------------------------------------------------------------------

		public function enable():void {
			if( visible ) return;
			Cc.log( this, "enabled" );
			onEnabled();
			visible = true;
		}

		public function disable():void {
			if( !visible ) return;
			Cc.log( this, "disabled" );
			onDisabled();
			visible = false;
		}

		public function dispose():void {
			onDisposed();
		}

		// ---------------------------------------------------------------------
		// To override...
		// ---------------------------------------------------------------------

		protected function onSetup():void {
			// Override.
		}

		protected function onEnabled():void {
			// Override.
		}

		protected function onDisabled():void {
			// Override.
		}

		protected function onDisposed():void {
			// Override.
		}
	}
}
