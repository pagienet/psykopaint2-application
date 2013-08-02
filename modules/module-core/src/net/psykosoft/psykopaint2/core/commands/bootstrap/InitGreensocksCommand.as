package net.psykosoft.psykopaint2.core.commands.bootstrap
{

	import com.greensock.plugins.ColorMatrixFilterPlugin;
	import com.greensock.plugins.TweenPlugin;

	import robotlegs.bender.bundles.mvcs.Command;

	public class InitGreensocksCommand extends Command
	{
		override public function execute():void {

			trace( this, "execute()" );

			// Used to color button labels.
			TweenPlugin.activate( [ ColorMatrixFilterPlugin ] );

		}
	}
}
