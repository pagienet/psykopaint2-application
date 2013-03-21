package net.psykosoft.psykopaint2.app.view.selectimage
{

	import net.psykosoft.psykopaint2.app.data.types.ApplicationStateType;
	import net.psykosoft.psykopaint2.app.data.vos.StateVO;
	import net.psykosoft.psykopaint2.app.signal.notifications.NotifySourceImageThumbnailsRetrievedSignal;
	import net.psykosoft.psykopaint2.app.signal.notifications.NotifyStateChangedSignal;
	import net.psykosoft.psykopaint2.app.signal.requests.RequestReadyToPaintImageSignal;

	import robotlegs.extensions.starlingViewMap.impl.StarlingMediator;

	import starling.textures.TextureAtlas;

	public class SelectThumbViewMediator extends StarlingMediator
	{
		[Inject]
		public var view:SelectThumbView;

		[Inject]
		public var notifyStateChangedSignal:NotifyStateChangedSignal;

		[Inject]
		public var requestReadyToPaintImageSignal:RequestReadyToPaintImageSignal;

		[Inject]
		public var notifySourceImageThumbnailsRetrievedSignal:NotifySourceImageThumbnailsRetrievedSignal;

		override public function initialize():void {

			// From view.
			view.listSelectedItemChangedSignal.add( onListItemSelected );

			// From app.
			notifyStateChangedSignal.add( onApplicationStateChanged );
			notifySourceImageThumbnailsRetrievedSignal.add( onSourceImageThumbnailsRetrieved );

			super.initialize();
		}

		// -----------------------
		// From view.
		// -----------------------

		private function onListItemSelected( itemName:String ):void {
			requestReadyToPaintImageSignal.dispatch( itemName );
			view.clearThumbs();
		}

		// -----------------------
		// From app.
		// -----------------------

		private function onSourceImageThumbnailsRetrieved( thumbs:TextureAtlas ):void {
			view.displayThumbs( thumbs );
		}

		private function onApplicationStateChanged( newState:StateVO ):void {
			if( newState.name == ApplicationStateType.PAINTING_SELECT_IMAGE ) {
				view.enable();
			}
			else {
				view.disable();
			}
		}
	}
}
