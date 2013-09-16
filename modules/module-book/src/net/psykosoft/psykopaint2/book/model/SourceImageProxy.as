package net.psykosoft.psykopaint2.book.model
{
	public interface SourceImageProxy
	{
		// size: any of ImageThumbnailSize
		function loadThumbnail(onComplete : Function, onError : Function, size : int = 1) : void;
		function loadFullSized(onComplete : Function, onError : Function) : void;
	}
}
