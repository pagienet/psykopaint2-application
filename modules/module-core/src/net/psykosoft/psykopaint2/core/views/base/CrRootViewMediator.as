package net.psykosoft.psykopaint2.core.views.base
{
	import net.psykosoft.psykopaint2.core.managers.gestures.CrGestureManager;

	import robotlegs.bender.bundles.mvcs.Mediator;

	public class CrRootViewMediator extends Mediator
	{
		[Inject]
		public var view:CrRootView;

		[Inject]
		public var gestureManager:CrGestureManager;

		override public function initialize():void {

			// Initialize gestures.
			gestureManager.stage = view.stage;
		}
	}
}
