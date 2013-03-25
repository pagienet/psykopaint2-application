package net.psykosoft.psykopaint2.app.service.images
{

	import org.osflash.signals.Signal;

	public interface IImageService
	{
		function loadThumbnails():void;
		function loadFullImage( id:String ):void;
		function getThumbnailsLoadedSignal():Signal;
		function getFullImageLoadedSignal():Signal;
		function disposeService():void;
	}
}
