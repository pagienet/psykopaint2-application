package net.psykosoft.psykopaint2.core.signals
{
	import org.osflash.signals.Signal;

	public class NotifyAMFConnectionFailed extends Signal
	{
		public function NotifyAMFConnectionFailed()
		{
			// pass along error code, see AMFErrorCode
			super(int);
		}
	}
}
