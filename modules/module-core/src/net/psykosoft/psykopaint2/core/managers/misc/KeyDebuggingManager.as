package net.psykosoft.psykopaint2.core.managers.misc
{

	import flash.display.Stage;
	import flash.events.KeyboardEvent;
	import flash.ui.Keyboard;

	import net.psykosoft.psykopaint2.core.debug.UndisposedObjects;

	public class KeyDebuggingManager
	{
		[Inject]
		public var stage:Stage;

		public function KeyDebuggingManager() {

		}

		public function initialize():void {
			stage.addEventListener( KeyboardEvent.KEY_DOWN, onStageKeyDown );
		}

		private function onStageKeyDown( event:KeyboardEvent ):void {

			trace( this, "key pressed: " + event.keyCode );

			switch( event.keyCode ) {

				case Keyboard.M:
//					_memoryWarningNotification.dispatch();
					break;

				case Keyboard.F11:

					var unDisposedObjects:UndisposedObjects = UndisposedObjects.getInstance();
					unDisposedObjects.getStackTraceReport().forEach(
						function ( item:Object, index:int, vector:Vector.<Object> ):void {
							trace( "Usage count: " + item.count + "\n\n" + item.stackTrace + "\n---------------\n\n" );
						}
					);

					break;

				case Keyboard.SPACE:
//					_requestNavigationToggleSignal.dispatch( 0, 0.5 );
					break;
			}
		}
	}
}
