package net.psykosoft.psykopaint2.core.signals
{
	import com.milkmangames.nativeextensions.ios.StoreKitProduct;
	
	import net.psykosoft.psykopaint2.base.robotlegs.signals.TracingSignal;

	public class NotifyProductPriceSignal extends TracingSignal
	{
		public function NotifyProductPriceSignal() {
			super( StoreKitProduct); //purchase status id, status code
		}
	}
}
