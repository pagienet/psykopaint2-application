package net.psykosoft.psykopaint2.view.away3d.wall
{
	import net.psykosoft.psykopaint2.view.base.IView;

	import org.osflash.signals.Signal;

	public interface IWallView extends IView
	{
		function loadDefaultHomeFrames():void;
		function loadUserFrames():void;
		function reset():void;
		function get wallFrameClickedSignal():Signal;
		function randomizeWallpaper():void;
	}
}
