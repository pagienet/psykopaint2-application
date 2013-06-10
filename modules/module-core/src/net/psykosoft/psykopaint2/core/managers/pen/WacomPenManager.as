package net.psykosoft.psykopaint2.core.managers.pen
{

	import net.psykosoft.wacom.WacomExtension;
	import net.psykosoft.wacom.events.WacomExtensionEvent;

	public class WacomPenManager
	{
		private var wacomPen : WacomExtension;

		
		public function WacomPenManager()
		{
		}

		[PostConstruct]
		public function init() : void
		{
			
		wacomPen = new WacomExtension();
			wacomPen.addEventListener( WacomExtensionEvent.DEVICE_DISCOVERED, onDeviceDiscovered );
			wacomPen.addEventListener( WacomExtensionEvent.BATTERY_LEVEL_CHANGED, onBatteryLevelChanged );
			wacomPen.addEventListener( WacomExtensionEvent.BUTTON_1_PRESSED, onButton1Pressed );
			wacomPen.addEventListener( WacomExtensionEvent.BUTTON_2_PRESSED, onButton2Pressed );
			wacomPen.addEventListener( WacomExtensionEvent.BUTTON_1_RELEASED, onButton1Released );
			wacomPen.addEventListener( WacomExtensionEvent.BUTTON_2_RELEASED, onButton2Released );
			wacomPen.addEventListener( WacomExtensionEvent.PRESSURE_CHANGED, onPressureChanged );
			wacomPen.initialize();
		}

		private function onBatteryLevelChanged( event:WacomExtensionEvent ):void {
			trace( "Pen battery level changed: " + event.data );
		}
		
		private function onButton1Pressed( event:WacomExtensionEvent ):void {
			trace( "Button 1 pressed." );
		}
		
		private function onButton2Pressed( event:WacomExtensionEvent ):void {
			trace( "Button 2 pressed." );
		}
		
		private function onButton1Released( event:WacomExtensionEvent ):void {
			trace( "Button 1 released." );
		}
		
		private function onButton2Released( event:WacomExtensionEvent ):void {
			trace( "Button 2 released." );
		}
		
		private function onPressureChanged( event:WacomExtensionEvent ):void {
			trace( "Pen pressure changed: " + event.data );
		}
		
		private function onDeviceDiscovered( event:WacomExtensionEvent ):void {
			trace( "Device discovered.");
		}
	}
}
