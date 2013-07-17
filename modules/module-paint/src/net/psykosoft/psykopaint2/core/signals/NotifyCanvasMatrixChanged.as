package net.psykosoft.psykopaint2.core.signals
{
	import flash.geom.Matrix;

	import org.osflash.signals.Signal;

	public class NotifyCanvasMatrixChanged extends Signal
	{
		public function NotifyCanvasMatrixChanged()
		{
			super(Matrix);
		}
	}
}
