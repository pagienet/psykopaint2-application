package net.psykosoft.psykopaint2.book.services
{
	public interface GalleryImageService
	{
		// source = any of GalleryType
		function fetchImages(source : int, index : int, amount : int) : void;
	}
}
