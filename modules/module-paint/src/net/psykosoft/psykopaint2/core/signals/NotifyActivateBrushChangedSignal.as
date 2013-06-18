package net.psykosoft.psykopaint2.core.signals
{

	import net.psykosoft.psykopaint2.core.drawing.data.ParameterSetVO;
	
	import org.osflash.signals.Signal;

	public class NotifyActivateBrushChangedSignal extends Signal
	{
		public function NotifyActivateBrushChangedSignal() {
			super( ParameterSetVO ); // BrushType, Array of brush shapes
		}
	}
}
