package net.psykosoft.psykopaint2.core.signals
{

	import org.osflash.signals.Signal;

	public class NotifyAvailableBrushTypesSignal extends Signal
	{
		public function NotifyAvailableBrushTypesSignal() {
			super( Vector.<String> ); // Array of BrushType constants that have been registered in the PaintModule.
		}
	}
}
