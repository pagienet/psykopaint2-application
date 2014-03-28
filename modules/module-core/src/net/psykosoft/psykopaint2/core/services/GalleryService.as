package net.psykosoft.psykopaint2.core.services
{
	public interface GalleryService
	{
		// source = any of GalleryType
		function fetchImages(source : int, index : int, amount : int, onSuccess : Function, onFailure : Function) : void;
		function addComment(paintingID : int, text : String, onSuccess : Function, onFailure : Function) : void;
		function favorite(paintingID : int, onSuccess : Function, onFailure : Function) : void;
		function unfavorite(paintingID : int, onSuccess : Function, onFailure : Function) : void;

		function get targetUserID():int ;
		function set targetUserID(value:int):void;
	}
}
