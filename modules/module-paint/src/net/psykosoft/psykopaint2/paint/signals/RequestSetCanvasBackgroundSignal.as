package net.psykosoft.psykopaint2.paint.signals
{
	import flash.geom.Rectangle;

	import net.psykosoft.psykopaint2.core.managers.rendering.RefCountedRectTexture;

	import org.osflash.signals.Signal;

	public class RequestSetCanvasBackgroundSignal extends Signal
	{
		public function RequestSetCanvasBackgroundSignal()
		{
			super(RefCountedRectTexture, Rectangle);
		}
	}
}
