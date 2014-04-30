package net.psykosoft.psykopaint2.core.views.base
{

	import flash.display.DisplayObjectContainer;

	import net.psykosoft.psykopaint2.core.managers.gestures.GestureType;

	import net.psykosoft.psykopaint2.core.signals.NotifyGlobalGestureSignal;

	import net.psykosoft.psykopaint2.core.signals.RequestAddViewToMainLayerSignal;

	import org.gestouch.events.GestureEvent;

	import robotlegs.bender.bundles.mvcs.Mediator;

	public class CoreRootViewMediator extends Mediator
	{
		[Inject]
		public var view:CoreRootView;

		[Inject]
		public var notifyGlobalGestureSignal:NotifyGlobalGestureSignal;

		// TODO: Should probably do this through set-up command
		[Inject]
		public var requestAddViewToMainLayerSignal:RequestAddViewToMainLayerSignal;

		override public function initialize():void {

			// From app.
			requestAddViewToMainLayerSignal.add( onRequestToAddViewToMainLayer );
//			notifyGlobalGestureSignal.add( onGlobalGesture ); // Used for UI tests in CoreRootView. Keep commented.
		}

		// -----------------------
		// From app.
		// -----------------------

		private function onRequestToAddViewToMainLayer( child:DisplayObjectContainer, layerOrdering:int ):void {
			view.addToMainLayer( child, layerOrdering );
		}

		// So far, only used for UI tests in CoreRootView.
//		private function onGlobalGesture( gestureType:String, event:GestureEvent ):void {
//			switch( gestureType ) {
//				case GestureType.HORIZONTAL_PAN_GESTURE_BEGAN: {
//					view.evaluateScrollingInteractionStart();
//					break;
//				}
//				case GestureType.HORIZONTAL_PAN_GESTURE_ENDED: {
//					view.evaluateScrollingInteractionEnd();
//					break;
//				}
//				case GestureType.HORIZONTAL_PAN_GESTURE_UPDATED: {
//					view.evaluateScrollingInteractionUpdated();
//					break;
//				}
//
//			}
//		}
	}
}
