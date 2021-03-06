package net.psykosoft.psykopaint2.core.views.navigation
{

	import net.psykosoft.psykopaint2.core.managers.gestures.GestureType;
	import net.psykosoft.psykopaint2.core.signals.NotifyGlobalGestureSignal;
	import net.psykosoft.psykopaint2.core.signals.RequestSaveCPUForUISignal;
	import net.psykosoft.psykopaint2.core.signals.RequestResumeCPUUsageForUISignal;
	import net.psykosoft.psykopaint2.core.views.base.MediatorBase;

	import org.gestouch.events.GestureEvent;

	public class SubNavigationMediatorBase extends MediatorBase
	{
		[Inject]
		public var notifyGlobalGestureSignal:NotifyGlobalGestureSignal;

		[Inject]
		public var requestSaveCPUForUISignal:RequestSaveCPUForUISignal;

		[Inject]
		public var requestResumeCPUUsageForUISignal:RequestResumeCPUUsageForUISignal;

		private var _subNavigationView:SubNavigationViewBase;

		public function SubNavigationMediatorBase() {
			super();
		}

		override public function initialize():void {

			// Init.
			super.initialize();
			manageStateChanges = false;
			manageMemoryWarnings = false;

			// From app.
			notifyGlobalGestureSignal.add( onGlobalGesture );

			// From view.
			_subNavigationView = SubNavigationViewBase( _view );
			_subNavigationView.enabledSignal.add( onViewEnabled );
			_subNavigationView.disabledSignal.add( onViewDisabled );
			_subNavigationView.setupSignal.add( onViewSetup );
			_subNavigationView.scrollingStartedSignal.add( onViewScrollingStarted );
			_subNavigationView.scrollingEndedSignal.add( onViewScrollingEnded );
		}

		override public function destroy():void {

			notifyGlobalGestureSignal.remove( onGlobalGesture );
			_subNavigationView.enabledSignal.remove( onViewEnabled );
			_subNavigationView.disabledSignal.remove( onViewDisabled );
			_subNavigationView.setupSignal.remove( onViewSetup );
			_subNavigationView.scrollingStartedSignal.remove( onViewScrollingStarted );
			_subNavigationView.scrollingEndedSignal.remove( onViewScrollingEnded );
			_subNavigationView.navigationButtonClickedSignal.remove( onButtonClicked );

			// Note: Mediator base disposes the view.

			super.destroy();
		}

		// -----------------------
		// From view.
		// -----------------------

		protected function onViewEnabled():void {
			_subNavigationView.navigationButtonClickedSignal.add( onButtonClicked );
		}

		protected function onViewDisabled():void {
			_subNavigationView.navigationButtonClickedSignal.remove( onButtonClicked );
		}

		protected function onViewSetup():void {
			// Override.
		}

		private function onViewScrollingEnded():void {
			requestResumeCPUUsageForUISignal.dispatch();
			
		}

		private function onViewScrollingStarted():void {
			requestSaveCPUForUISignal.dispatch();
		}
		
		private function onViewScrollingUpdating():void {
			
			trace(this,"onViewScrollingUpdating");
		}

		// -----------------------
		// From app.
		// -----------------------

		private function onGlobalGesture( gestureType:String, event:GestureEvent ):void {
			switch( gestureType ) {
				case GestureType.HORIZONTAL_PAN_GESTURE_BEGAN: {
					_subNavigationView.evaluateScrollingInteractionStart();
					break;
				}
				case GestureType.HORIZONTAL_PAN_GESTURE_ENDED: {
					_subNavigationView.evaluateScrollingInteractionEnd();
					break;
				}
				case GestureType.HORIZONTAL_PAN_GESTURE_UPDATED: {
					_subNavigationView.evaluateScrollingInteractionUpdated();
					break;
				}
						
			}
		}

		// -----------------------
		// Private
		// -----------------------

		protected function onButtonClicked( id:String ):void {
			// Override to react to clicks on scroller and side buttons...
		}
	}
}
