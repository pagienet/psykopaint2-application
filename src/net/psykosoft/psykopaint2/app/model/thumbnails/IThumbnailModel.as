package net.psykosoft.psykopaint2.app.model.thumbnails
{

	import flash.display.BitmapData;

	public interface IThumbnailModel
	{
		/*
		* Constructs a texture atlas of thumbnails and dispatches it with a signal.
		* A service provides the atlas and its descriptor.
		* */
		function setThumbnails( atlas:BitmapData, descriptor:XML ):void;

		/*
		* Disposes all texture and bitmap data, as well as xml data, etc.
		* */
		function dispose():void;
	}
}
