package net.psykosoft.psykopaint2.base.robotlegs.signals
{

	import com.junkbyte.console.Cc;

	import org.osflash.signals.Signal;

	public class TracingSignal extends Signal
	{
		public function TracingSignal( ...params ) {
			super( params );
		}

		override public function dispatch( ...valueObjects ):void {
			Cc.log( this, "dispatch(" + valueObjects + ")" );
			super.dispatch.apply( this, valueObjects );
		}
	}
}
