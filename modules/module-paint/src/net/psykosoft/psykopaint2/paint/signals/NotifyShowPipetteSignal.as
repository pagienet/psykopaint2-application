package net.psykosoft.psykopaint2.paint.signals
{
	import flash.display.Sprite;
	import flash.geom.Point;
	
	import org.osflash.signals.Signal;

	public class NotifyShowPipetteSignal extends Signal
	{
		public function NotifyShowPipetteSignal()
		{
			super( Sprite, uint, Point, Boolean);
		}
	}
}
