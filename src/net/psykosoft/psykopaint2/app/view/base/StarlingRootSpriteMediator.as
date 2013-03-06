package net.psykosoft.psykopaint2.app.view.base
{

	import flash.sensors.Accelerometer;

	import net.psykosoft.psykopaint2.app.controller.accelerometer.AccelerometerManager;
	import net.psykosoft.psykopaint2.app.controller.gestures.GestureManager;
	import net.psykosoft.psykopaint2.app.view.base.StarlingRootSprite;

	import robotlegs.extensions.starlingViewMap.impl.StarlingMediator;

	public class StarlingRootSpriteMediator extends StarlingMediator
	{
		[Inject]
		public var view:StarlingRootSprite;

		[Inject]
		public var gestureManager:GestureManager;

		[Inject]
		public var accelManager:AccelerometerManager;

		override public function initialize():void {

			// Initialize the gesture manager.
			gestureManager.stage = view.stage;

			// Initialize the accelerometer manager.
			// NOTE: accelerometer is disabled
			// TODO: remove if not used
			/*if( Accelerometer.isSupported ) {
				accelManager.init();
			}*/

		}
	}
}
