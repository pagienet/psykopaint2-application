package net.psykosoft.psykopaint2.app.view.selectimage
{

	import net.psykosoft.psykopaint2.app.data.types.ApplicationStateType;
	import net.psykosoft.psykopaint2.app.signal.notifications.NotifySourceImageThumbnailsRetrievedSignal;
	import net.psykosoft.psykopaint2.app.signal.requests.RequestFullImageSignal;
	import net.psykosoft.psykopaint2.app.view.base.StarlingMediatorBase;

	import starling.textures.TextureAtlas;

	public class SelectImageViewMediator extends StarlingMediatorBase
	{
		[Inject]
		public var selectImageView:SelectImageView;

		[Inject]
		public var requestFullImageSignal:RequestFullImageSignal;

		[Inject]
		public var notifySourceImageThumbnailsRetrievedSignal:NotifySourceImageThumbnailsRetrievedSignal;

		override public function initialize():void {

			super.initialize();
			registerView( selectImageView );
			registerEnablingState( ApplicationStateType.PAINTING_SELECT_IMAGE );

			// From view.
			selectImageView.listSelectedItemChangedSignal.add( onListItemSelected );

			// From app.
			notifySourceImageThumbnailsRetrievedSignal.add( onSourceImageThumbnailsRetrieved );
		}

		// -----------------------
		// From view.
		// -----------------------

		private function onListItemSelected( itemName:String ):void {
			// TODO: how does it know which image source to call?
			requestFullImageSignal.dispatch( itemName );
			selectImageView.disable(); // TODO: services store textures in models, requesting a single image load clears the thumb atlases, this needs to be separated
		}

		// -----------------------
		// From app.
		// -----------------------

		private function onSourceImageThumbnailsRetrieved( thumbs:TextureAtlas ):void {
			selectImageView.displayThumbs( thumbs );
		}
	}
}
