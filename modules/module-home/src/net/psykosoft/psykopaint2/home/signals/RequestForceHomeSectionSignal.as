package net.psykosoft.psykopaint2.home.signals
{
	import org.osflash.signals.Signal;

	public class RequestForceHomeSectionSignal extends Signal
	{
		public function RequestForceHomeSectionSignal()
		{
			super(int);	// HomeView.SETTINGS, HomeView.EASEL, etc
		}
	}
}
