package net.psykosoft.psykopaint2.home.signals
{

	import org.osflash.signals.Signal;

	public class NotifyHomeViewDeleteModeChangedSignal extends Signal
	{
		public function NotifyHomeViewDeleteModeChangedSignal() {
			//true: delete mode on, false: delete mode off
			super( Boolean );
		}
	}
}
