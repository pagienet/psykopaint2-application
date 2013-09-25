package net.psykosoft.psykopaint2.core.managers.gestures
{

	import org.gestouch.core.IGestureDelegate;
	import org.gestouch.core.Touch;
	import org.gestouch.gestures.Gesture;

	public class GestureDelegate implements IGestureDelegate
	{
		public function GestureDelegate() {
		}

		public function gestureShouldReceiveTouch( gesture:Gesture, touch:Touch ):Boolean {
			return true;
		}


		public function gestureShouldBegin( gesture:Gesture ):Boolean {
			return true;
		}


		public function gesturesShouldRecognizeSimultaneously( gesture:Gesture, otherGesture:Gesture ):Boolean {
			return true;
		}
	}
}
