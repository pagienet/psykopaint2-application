package net.psykosoft.psykopaint2.app.signal.notifications
{

	import org.osflash.signals.Signal;

	import starling.textures.TextureAtlas;

	public class NotifySourceImageThumbnailsRetrievedSignal extends Signal
	{
		public function NotifySourceImageThumbnailsRetrievedSignal() {
			super( TextureAtlas );
		}
	}
}
