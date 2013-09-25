package net.psykosoft.psykopaint2.core.signals
{

	import flash.display.DisplayObjectContainer;
	
	import org.osflash.signals.Signal;

	public class RequestAddViewToMainLayerSignal extends Signal
	{
		public function RequestAddViewToMainLayerSignal() {
			super( DisplayObjectContainer, int ); // View to add, layer ordering (possible values found in core.views.base.ViewLayerOrdering, default is bottom layer)
		}
	}
}
