package net.psykosoft.psykopaint2.base.robotlegs
{
	import com.junkbyte.console.Cc;

	import org.osflash.signals.Signal;

	public class BsTracingSignal extends Signal
	{
		public function BsTracingSignal( ...params ) {
			super( params );
		}

		override public function dispatch( ...valueObjects ):void {
			Cc.log( this, "dispatch(" + valueObjects + ")" );
			super.dispatch.apply( this, valueObjects );
		}
	}
}
