package net.psykosoft.psykopaint2.view.starling.base
{

	import net.psykosoft.psykopaint2.signal.notifications.NotifyNavigationPanelToggle;

	import robotlegs.extensions.starlingViewMap.impl.StarlingMediator;

	public class StarlingRootSpriteMediator extends StarlingMediator
	{
		[Inject]
		public var view:StarlingRootSprite;

		[Inject]
		public var notifyNavigationPanelToggle:NotifyNavigationPanelToggle;

		override public function initialize():void {

			// From view.
			view.swipedUpSignal.add( onViewSwipedUp );
			view.swipedDownSignal.add( onViewSwipedDown );

		}

		private function onViewSwipedDown():void {
			notifyNavigationPanelToggle.dispatch( false );
		}

		private function onViewSwipedUp():void {
			notifyNavigationPanelToggle.dispatch( true );
		}
	}
}
