package net.psykosoft.psykopaint2.home.commands.unload
{

	import br.com.stimuli.loading.BulkLoader;

	import net.psykosoft.psykopaint2.base.utils.io.AssetBundleLoader;

	import net.psykosoft.psykopaint2.home.views.home.HomeView;

	import robotlegs.bender.bundles.mvcs.Command;

	public class DumpHomeBundledAssetsCommand extends Command
	{
		override public function execute():void {

			trace( this, "execute" );

			var bundle:AssetBundleLoader = BulkLoader.bundles[ HomeView.HOME_BUNDLE_ID ];
			bundle.dispose();

		}
	}
}
