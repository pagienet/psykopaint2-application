package net.psykosoft.psykopaint2.core.signals
{
	import com.milkmangames.nativeextensions.ios.StoreKitProduct;
	
	import net.psykosoft.psykopaint2.base.robotlegs.signals.TracingSignal;

	public class NotifyFullUpgradePriceSignal extends TracingSignal
	{
		public function NotifyFullUpgradePriceSignal() {
			super( StoreKitProduct); //purchase status id, status code
		}
	}
}
