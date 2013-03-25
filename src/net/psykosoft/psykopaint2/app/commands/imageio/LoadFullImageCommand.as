package net.psykosoft.psykopaint2.app.commands.imageio
{

	import net.psykosoft.psykopaint2.app.model.FullImageModel;
	import net.psykosoft.psykopaint2.app.model.ThumbnailsModel;

	/*
	* Related to LoadImageSourceCommand, but has to do with when the user selected a particular image
	* from the thumbnails provided by the other service, if such service has not already set it directly.
	* Usually, the ones who go through this channel require the app's UI for the user to pick the final image.
	* */
	public class LoadFullImageCommand
	{
		[Inject]
		public var imageId:String;

		[Inject]
		public var thumbnailModel:ThumbnailsModel;

		[Inject]
		public var fullImageModel:FullImageModel;

		public function execute() : void {
			trace( this, "executing..." );

			thumbnailModel.disposeThumbnails();

			fullImageModel.loadFullImage( imageId );
		}
	}
}
