package net.psykosoft.psykopaint2.core.signals
{

	import org.osflash.signals.Signal;

	public class RequestBookLoadSignal extends Signal
	{
		public function RequestBookLoadSignal() {
			super( String ); // BookImageSource.as string type.
		}
	}
}
