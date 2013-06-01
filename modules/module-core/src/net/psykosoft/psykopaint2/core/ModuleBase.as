package net.psykosoft.psykopaint2.core
{

	import flash.display.Sprite;

	import org.osflash.signals.Signal;

	public class ModuleBase extends Sprite
	{
		public var isStandalone:Boolean = true;

		public var moduleReadySignal:Signal;

		public function ModuleBase() {
			super();
			inlineTest();
			moduleReadySignal = new Signal();
		}

		private function inlineTest():void {
			// TODO: how to verify on ipad?
			trace( "**inline test**  ----------------------" );
			trace( "( decompile swf, then, if you see a method call below, then this module wasn't compiled with asc2.0 )" );
			avg( 4, 5 );
		}

		[Inline]
		final private function avg( value1:Number, value2:Number ):Number {
			return ( value1 + value2 ) / 2;
		}
	}
}
