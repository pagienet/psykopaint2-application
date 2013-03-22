package net.psykosoft.psykopaint2.app.model.thumbnails
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

		public function setThumbnails( bmd:BitmapData, descriptor:XML ):void {
			Cc.log( this, "setting thumbnails." );
			var texture:Texture = Texture.fromBitmapData( bmd );
			_atlas = new TextureAtlas( texture, descriptor );
			notifySourceImageThumbnailsRetrievedSignal.dispatch( _atlas );
		}

		public function dispose():void {
			Cc.log( this, "disposing atlas" );
			_atlas.dispose();
			_atlas = null;
		}
	}
}
