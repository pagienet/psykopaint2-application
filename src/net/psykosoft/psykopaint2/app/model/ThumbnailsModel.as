package net.psykosoft.psykopaint2.app.model
{

	import com.junkbyte.console.Cc;

	import flash.display.BitmapData;

	import net.psykosoft.psykopaint2.app.signal.notifications.NotifySourceImageThumbnailsRetrievedSignal;

	import starling.textures.Texture;
	import starling.textures.TextureAtlas;

	public class ThumbnailsModel
	{
		[Inject]
		public var notifySourceImageThumbnailsRetrievedSignal:NotifySourceImageThumbnailsRetrievedSignal;

		private var _atlas:TextureAtlas;

		public function ThumbnailsModel() {
		}

		public function setThumbnails( atlas:TextureAtlas ):void {
			Cc.log( this, "setting thumbnails." );
			_atlas = atlas;
			notifySourceImageThumbnailsRetrievedSignal.dispatch( _atlas );
		}

		public function disposeThumbnails():void {
			Cc.log( this, "disposing atlas" );
			_atlas.dispose();
			_atlas = null;
		}
	}
}
