package net.psykosoft.psykopaint2.core.signals
{
	import net.psykosoft.psykopaint2.base.robotlegs.signals.TracingSignal;

	public class NotifyPurchaseStatusSignal extends TracingSignal
	{
		public function NotifyPurchaseStatusSignal() {
			super( String, int ); //purchase object id, status code
		}
	}
}
