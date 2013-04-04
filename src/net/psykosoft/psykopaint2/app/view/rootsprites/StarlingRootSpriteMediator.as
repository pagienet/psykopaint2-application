package net.psykosoft.psykopaint2.app.view.rootsprites
{

	import net.psykosoft.psykopaint2.app.controller.accelerometer.AccelerometerManager;
	import net.psykosoft.psykopaint2.app.controller.gestures.GestureManager;
	import net.psykosoft.psykopaint2.app.view.base.StarlingMediatorBase;

	public class StarlingRootSpriteMediator extends StarlingMediatorBase
	{
		[Inject]
		public var view:StarlingRootSprite;

		[Inject]
		public var gestureManager:GestureManager;

		[Inject]
		public var accelManager:AccelerometerManager;

		override public function initialize():void {

			super.initialize();
			manageMemoryWarnings = false;
			manageStateChanges = false;

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
