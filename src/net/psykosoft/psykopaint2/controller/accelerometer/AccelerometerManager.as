package net.psykosoft.psykopaint2.controller.accelerometer
{

	import flash.events.AccelerometerEvent;
	import flash.sensors.Accelerometer;
	import flash.utils.getTimer;

	import net.psykosoft.psykopaint2.signal.notifications.NotifyGlobalAccelerometerSignal;

	public class AccelerometerManager
	{
		private var avgY:Vector.<Number>;
		private var sumY:Number;
		private var acy:Number;
		private var accel:Accelerometer;
		private var bufferSize:uint = 16;
		private var bufferIndex:uint = 0;
		private var lastTrigger:uint = 0;
		private var sampleCount:uint;

		private const THRESHOLD:Number = 0.25;

		[Inject]
		public var notifyGlobalAccelerometerSignal:NotifyGlobalAccelerometerSignal;

		public function AccelerometerManager() {

			avgY = new Vector.<Number>( bufferSize, true );

			sumY = 0;
			acy = 0;

		}

		public function init():void {
			accel = new Accelerometer();
			accel.addEventListener( AccelerometerEvent.UPDATE, onAccelerometerUpdate );
		}

		private function onAccelerometerUpdate( event:AccelerometerEvent ):void {

			acy = event.accelerationY;

			sumY += acy - avgY[ bufferIndex ];

			avgY[ bufferIndex ] = acy;

			bufferIndex = ( bufferIndex + 1 ) % bufferSize;

			var difY:Number = sumY / bufferSize - acy;

			sampleCount++;

			if( sampleCount < 100 ) {
				return;
			}

			if( getTimer() - lastTrigger > 800 ) {
//				trace( this, difY );
				if( difY > THRESHOLD ) {
//					trace( "flip forward!" );
					notifyGlobalAccelerometerSignal.dispatch( AccelerationType.SHAKE_FORWARD );
					lastTrigger = getTimer();
				}
				if( difY < -THRESHOLD ) {
//					trace( "flip backward!" );
					notifyGlobalAccelerometerSignal.dispatch( AccelerationType.SHAKE_BACKWARD );
					lastTrigger = getTimer();
				}
			}

			if( sampleCount > uint.MAX_VALUE ) {
				sampleCount = 0;
			}
		}
	}
}
