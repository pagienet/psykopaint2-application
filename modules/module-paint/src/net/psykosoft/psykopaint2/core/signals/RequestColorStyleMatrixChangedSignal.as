package net.psykosoft.psykopaint2.core.signals
{
	import com.quasimondo.geom.ColorMatrix;
	
	import org.osflash.signals.Signal;

	public class RequestColorStyleMatrixChangedSignal extends Signal
	{
		public function RequestColorStyleMatrixChangedSignal()
		{
			super(ColorMatrix,ColorMatrix,Number,Number);
		}
	}
}
