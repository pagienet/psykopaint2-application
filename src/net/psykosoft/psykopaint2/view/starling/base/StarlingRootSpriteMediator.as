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
			view.acceleratedToHorizontalSignal.add( onViewAcceleratedToHorizontal );
			view.acceleratedToVerticalSignal.add( onViewAcceleratedToVertical );

		}

		private function onViewAcceleratedToHorizontal():void {
			notifyNavigationPanelToggle.dispatch( true );
		}

		private function onViewAcceleratedToVertical():void {
			notifyNavigationPanelToggle.dispatch( false );
		}

		private function onViewSwipedDown():void {
			notifyNavigationPanelToggle.dispatch( false );
		}

		private function onViewSwipedUp():void {
			notifyNavigationPanelToggle.dispatch( true );
		}
	}
}
