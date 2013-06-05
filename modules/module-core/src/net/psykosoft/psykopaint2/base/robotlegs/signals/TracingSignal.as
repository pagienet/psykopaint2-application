package net.psykosoft.psykopaint2.base.robotlegs.signals
{

	import flash.utils.ByteArray;

	import org.osflash.signals.Signal;

	public class TracingSignal extends Signal
	{
		public function TracingSignal( ...params ) {
			super( params );
			for( var i:uint; i < params.length; i++ ) {
				if( params[ i ] == ByteArray ) {
					throw new Error( this + " - please don't use ByteArrays in TracingSignal... causes nasty crashes on intellij, no idea why. Use Signal instead." );
				}
			}
		}

		override public function dispatch( ...valueObjects ):void {
			trace( this, "dispatch(" + valueObjects + ")" );
			super.dispatch.apply( this, valueObjects );
		}
	}
}
