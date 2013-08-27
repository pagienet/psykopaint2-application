package net.psykosoft.psykopaint2.book.model
{
	public interface SourceImageProxy
	{
		function loadThumbnail(onComplete : Function, onError : Function) : void;
		function loadFullSized(onComplete : Function, onError : Function) : void;
	}
}
