package net.psykosoft.psykopaint2.core.services
{
	public interface SourceImageService
	{
		function fetchImages(index : int, amount : int, onSuccess : Function, onFailure : Function) : void;
	}
}
