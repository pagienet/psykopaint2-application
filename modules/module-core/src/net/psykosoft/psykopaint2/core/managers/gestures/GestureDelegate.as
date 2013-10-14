package net.psykosoft.psykopaint2.core.managers.gestures
{

	import org.gestouch.core.IGestureDelegate;
	import org.gestouch.core.Touch;
	import org.gestouch.gestures.Gesture;
	import org.gestouch.gestures.PanGesture;
	import org.gestouch.gestures.TapGesture;

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
			var allow:Boolean = true;

			// Avoids horizontal and vertical pan gestures acting simultaneously.
			if( gesture is PanGesture && otherGesture is PanGesture ) {
				allow = false;
			}

			// Avoids taps and pan gestures acting simultaneously.
			if( gesture is PanGesture && otherGesture is TapGesture ) {
				allow = false;
			}

			return allow;
		}
	}
}
