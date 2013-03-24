package net.psykosoft.psykopaint2.app.view.selectimage
{

	import net.psykosoft.psykopaint2.app.data.types.ApplicationStateType;
	import net.psykosoft.psykopaint2.app.data.vos.StateVO;
	import net.psykosoft.psykopaint2.app.signal.notifications.NotifySourceImageThumbnailsRetrievedSignal;
	import net.psykosoft.psykopaint2.app.signal.notifications.NotifyStateChangedSignal;
	import net.psykosoft.psykopaint2.app.signal.requests.RequestReadyToPaintImageSignal;

	import robotlegs.extensions.starlingViewMap.impl.StarlingMediator;

	import starling.textures.TextureAtlas;

	public class SelectImageViewMediator extends StarlingMediator
	{
		[Inject]
		public var view:SelectImageView;

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
			// TODO: how does it know which image source to call?
			requestReadyToPaintImageSignal.dispatch( itemName );
			view.disable(); // TODO: services store textures in models, requesting a single image load clears the thumb atlases, this needs to be separated
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
