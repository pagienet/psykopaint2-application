package net.psykosoft.psykopaint2.commands
{

	import com.junkbyte.console.Cc;

	import net.psykosoft.psykopaint2.model.packagedimages.WallpapersModel;

	import net.psykosoft.psykopaint2.model.packagedimages.vo.PackagedImageVO;
	import net.psykosoft.psykopaint2.signal.notifications.NotifyWallpaperChangeSignal;

	public class ChangeWallpaperCommand
	{
		[Inject]
		public var imageId:String;

		[Inject]
		public var wallpapersModel:WallpapersModel;

		[Inject]
		public var notifyWallpaperChangeSignal:NotifyWallpaperChangeSignal;

		public function execute():void {

			Cc.log( this, "image id: " + imageId );

			var vo:PackagedImageVO = wallpapersModel.getOriginal( imageId );
			notifyWallpaperChangeSignal.dispatch( vo );

		}
	}
}
