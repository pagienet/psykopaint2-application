package net.psykosoft.psykopaint2.core
{

	import flash.display.Sprite;
	import flash.events.Event;

	public class HomeModule extends Sprite
	{
		public function HomeModule() {
			super();
			trace( ">>>>> HomeModule starting..." );
			addEventListener( Event.ADDED_TO_STAGE, onAddedToStage );
		}

		// ---------------------------------------------------------------------
		// Initialization.
		// ---------------------------------------------------------------------

		private function initialize():void {

		}

		// ---------------------------------------------------------------------
		// Listeners.
		// ---------------------------------------------------------------------

		private function onAddedToStage( event:Event ):void {
			removeEventListener( Event.ADDED_TO_STAGE, onAddedToStage );
			initialize();
		}
	}
}
