package net.psykosoft.psykopaint2.home.commands.load
{

	import br.com.stimuli.loading.BulkLoader;

	import eu.alebianco.robotlegs.utils.impl.AsyncCommand;

	import flash.events.Event;

	import net.psykosoft.psykopaint2.base.utils.io.AssetBundleLoader;
	import net.psykosoft.psykopaint2.core.configuration.CoreSettings;
	import net.psykosoft.psykopaint2.home.views.home.HomeView;
	import net.psykosoft.psykopaint2.home.views.home.objects.FrameType;

	public class LoadHomeBundledAssetsCommand extends AsyncCommand
	{
		private var _loader:AssetBundleLoader;

		override public function execute():void {

			trace( this, "execute()" );

			_loader = new AssetBundleLoader( HomeView.HOME_BUNDLE_ID );
			_loader.addEventListener( Event.COMPLETE, onBundledAssetsReady );

			// Remember for clean up.
			BulkLoader.bundles[ HomeView.HOME_BUNDLE_ID ] = _loader;

			var rootUrl:String = CoreSettings.RUNNING_ON_iPAD ? "/home-packaged-ios/" : "/home-packaged-desktop/";
			var extra:String = CoreSettings.RUNNING_ON_iPAD ? "-ios" : "-desktop";

			// -----------------------
			// Default paintings.
			// -----------------------

			_loader.registerAsset( "/home-packaged/away3d/frames/whiteFrame.png", FrameType.WHITE_FRAME );
			_loader.registerAsset( "/home-packaged/away3d/paintings/settingsFrame.png", "settingsPainting" );

			// -----------------------
			// Room stuff.
			// -----------------------

			_loader.registerAsset( "/home-packaged/away3d/easel/easel-uncompressed.atf", "easelImage", BulkLoader.TYPE_BINARY );
			_loader.registerAsset( "/home-packaged/away3d/objects/settingsPanel.png", "settingsPanel" );
			_loader.registerAsset( rootUrl + "away3d/wallpapers/fullsize/white" + extra + ".atf", "defaultWallpaper", BulkLoader.TYPE_BINARY );
			_loader.registerAsset( rootUrl + "away3d/floorpapers/wood" + extra + "-mips.atf", "floorWood", BulkLoader.TYPE_BINARY );

			_loader.startLoad();
		}

		private function onBundledAssetsReady( event:Event ):void {
			_loader.removeEventListener( Event.COMPLETE, onBundledAssetsReady );
			dispatchComplete( true );
		}
	}
}
