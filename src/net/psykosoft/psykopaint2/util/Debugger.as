package net.psykosoft.psykopaint2.util
{

	import com.junkbyte.console.Cc;

	import flash.display.DisplayObject;
	import flash.utils.getTimer;

	import net.psykosoft.psykopaint2.config.Settings;

	public class Debugger
	{
		public function Debugger( displayObject:DisplayObject ) {

			super();

			Cc.config.style.backgroundAlpha = 0.75;
			Cc.config.tracing = true;
			Cc.startOnStage( displayObject, "`" );
			Cc.visible = false;
			Cc.height = 350;
			Cc.y = displayObject.stage.stageHeight - Cc.height;
			Cc.width = displayObject.stage.stageWidth;

			// Trace all settings.
			for each( var prop:* in Settings ) {
				Cc.log( "Setting: " + prop );
			}

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
