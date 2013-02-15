package net.psykosoft.psykopaint2.view.starling.base
{

	import flash.sensors.Accelerometer;

	import net.psykosoft.psykopaint2.controller.accelerometer.AccelerometerManager;
	import net.psykosoft.psykopaint2.controller.gestures.GestureManager;

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
			if( Accelerometer.isSupported ) {
				accelManager.init();
			}

		}
	}
}
