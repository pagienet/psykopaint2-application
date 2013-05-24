package net.psykosoft.psykopaint2.core.views.base
{
	import net.psykosoft.psykopaint2.core.managers.gestures.GestureManager;

	import robotlegs.bender.bundles.mvcs.Mediator;

	public class CoreRootViewMediator extends Mediator
	{
		[Inject]
		public var view:CoreRootView;

		[Inject]
		public var gestureManager:GestureManager;

		override public function initialize():void {

			// Initialize gestures.
			gestureManager.stage = view.stage;
		}
	}
}
