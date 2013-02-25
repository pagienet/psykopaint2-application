package net.psykosoft.psykopaint2.app.util
{

	import com.junkbyte.console.Cc;

	import flash.display.DisplayObject;
	import flash.utils.describeType;
	import flash.utils.getTimer;

	import net.psykosoft.psykopaint2.app.config.Settings;

	public class DebuggingConsole
	{
		public function DebuggingConsole( displayObject:DisplayObject ) {

			super();

			// Configure.
			Cc.config.style.backgroundAlpha = 0.75;
			Cc.config.tracing = true;
			Cc.startOnStage( displayObject, "`" );
			Cc.visible = false;
			Cc.height = 350;
			Cc.y = displayObject.stage.stageHeight - Cc.height;
			Cc.width = displayObject.stage.stageWidth;

			remapTraces();

			traceAllSettings();

		}

		private function traceAllSettings():void {
			Cc.log( this, "Application settings: -----------------------------------------" );
			var typeDescription:XML = describeType( Settings );
			var constantsList:XMLList = typeDescription.constant;
			for( var i:uint; i < constantsList.length(); i++ ) {
				var constantItem:XML = constantsList[ i ];
				Cc.log( constantItem.@name + ": " + Settings[ String( constantItem.@name ) ] );
			}
			Cc.log( "----------------------------------------------------------------------------------" );
		}

		private function remapTraces():void {
			// Map calls to the IDE console in a custom fashion.
			Cc.config.traceCall = function( ch:String, line:String, ...args ):void
			{
				var time:String = String( getTimer() ) + "ms";
				var priorityLevel:int = args[0];
				switch( priorityLevel )
				{
					case 1:
					case 2:
					case 3:
					case 4: { // log & info
						trace( time + " - info: " + line );
						break;
					}
					case 5:
					case 6: { // debug
						trace( time + " - debug: " + line );
						break;
					}
					case 7:
					case 8: { // warn
						trace( time + " - warn: " + line );
						break;
					}
					case 9: { // error
						trace( time + " - error: " + line );
						break;
					}
					case 10: { // fatal
						trace( time + " - fatal: " + line );
						break;
					}
				}
			}
		}
	}
}
