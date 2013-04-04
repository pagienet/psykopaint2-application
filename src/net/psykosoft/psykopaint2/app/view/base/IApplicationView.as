package net.psykosoft.psykopaint2.app.view.base
{
	public interface IApplicationView
	{
		function enable():void;
		function disable():void;
		function get enabled():Boolean

		function create():void;
		function dispose():void;
	}
}
