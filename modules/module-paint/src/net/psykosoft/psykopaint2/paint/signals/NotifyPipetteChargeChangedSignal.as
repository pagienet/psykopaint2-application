package net.psykosoft.psykopaint2.paint.signals
{
	import net.psykosoft.psykopaint2.paint.views.color.Pipette;
	
	import org.osflash.signals.Signal;

	public class NotifyPipetteChargeChangedSignal extends Signal
	{
		public function NotifyPipetteChargeChangedSignal()
		{
			super( Pipette, Boolean );
		}
	}
}
