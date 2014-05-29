package net.psykosoft.psykopaint2.core.signals
{
	import org.osflash.signals.Signal;

	public class ToggleDepthOfFieldSignal extends Signal
	{
		public function ToggleDepthOfFieldSignal()
		{
			super(Boolean); // whether or not to enable depth of field on View3D
		}
	}
}
