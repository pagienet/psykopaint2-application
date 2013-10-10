package net.psykosoft.psykopaint2.home.views.home
{
	import net.psykosoft.psykopaint2.core.configuration.CoreSettings;
	import net.psykosoft.psykopaint2.home.model.WallpaperModel;
	import net.psykosoft.psykopaint2.home.signals.RequestWallpaperChangeSignal;

	import robotlegs.bender.bundles.mvcs.Mediator;

	public class RoomViewMediator extends Mediator
	{
		[Inject]
		public var view : RoomView;

		[Inject]
		public var requestWallpaperChangeSignal : RequestWallpaperChangeSignal;

		[Inject]
		public var wallpaperModel:WallpaperModel;


		public function RoomViewMediator()
		{
		}

		override public function initialize() : void
		{
			super.initialize();
			requestWallpaperChangeSignal.add(onWallPaperChanged);
			changeWallpaperFromId( wallpaperModel.wallpaperId );
		}

		override public function destroy() : void
		{
			super.destroy();
			requestWallpaperChangeSignal.remove(onWallPaperChanged);
		}

		private function onWallPaperChanged(id : String) : void
		{
			changeWallpaperFromId(id);
		}

		private function changeWallpaperFromId(id : String) : void
		{
			var rootUrl : String = CoreSettings.RUNNING_ON_iPAD ? "/home-packaged-ios/" : "/home-packaged-desktop/";
			var extra : String = CoreSettings.RUNNING_ON_iPAD ? "-ios" : "-desktop";
			var url : String = rootUrl + "away3d/wallpapers/fullsize/" + id + extra + ".atf";
			// todo: provide RoomView/RoomViewMediator
			view.changeWallpaper(url);
		}
	}
}
