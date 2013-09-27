package net.psykosoft.psykopaint2.core.models
{
	public interface GalleryService
	{
		// source = any of GalleryType
		function fetchImages(source : int, index : int, amount : int) : void;
		function addComment(paintingID : int, text : String) : void;
	}
}
