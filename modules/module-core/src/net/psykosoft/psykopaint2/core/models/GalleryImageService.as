package net.psykosoft.psykopaint2.core.models
{
	public interface GalleryImageService
	{
		// source = any of GalleryType
		function fetchImages(source : int, index : int, amount : int) : void;
		function fetchPainting(paintingID : int) : void;
	}
}
