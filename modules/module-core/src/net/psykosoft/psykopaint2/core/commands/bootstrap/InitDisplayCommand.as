package net.psykosoft.psykopaint2.core.commands.bootstrap
{

	import net.psykosoft.psykopaint2.core.configuration.CoreSettings;
	import net.psykosoft.psykopaint2.core.views.base.CoreRootView;

	import robotlegs.bender.bundles.mvcs.Command;

	public class InitDisplayCommand extends Command
	{
		override public function execute():void {

			trace( this, "execute()" );

			var coreRootView:CoreRootView = new CoreRootView();
			CoreSettings.DISPLAY_ROOT.addChild( coreRootView );
		}
	}
}
