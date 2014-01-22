package net.psykosoft.psykopaint2.core.signals
{
	import org.osflash.signals.Signal;

	public class NotifyColorStyleChangedSignal extends Signal
	{
		public function NotifyColorStyleChangedSignal()
		{
			// pass color matrix vector and blend factor
			super(Vector.<Number>,Number);
		}
	}
}
