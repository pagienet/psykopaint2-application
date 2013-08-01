package net.psykosoft.psykopaint2.core.commands
{

	import com.bit101.MinimalComps;

	import net.psykosoft.psykopaint2.base.utils.misc.PlatformUtil;
	import net.psykosoft.psykopaint2.core.configuration.CoreSettings;

	import robotlegs.bender.bundles.mvcs.Command;

	public class InitPlatformCommand extends Command
	{
		override public function execute():void {

			trace( this, "execute()" );

			CoreSettings.RUNNING_ON_iPAD = PlatformUtil.isRunningOnIPad();
			CoreSettings.RUNNING_ON_RETINA_DISPLAY = PlatformUtil.isRunningOnDisplayWithDpi( CoreSettings.RESOLUTION_DPI_RETINA );

			if( CoreSettings.RUNNING_ON_RETINA_DISPLAY ) {
				CoreSettings.GLOBAL_SCALING = 2;
				// TODO: remove ( temporary )
				MinimalComps.globalScaling = 2;
			}

			trace( this, "initializing platform - " +
					"running on iPad: " + CoreSettings.RUNNING_ON_iPAD + "," +
					"running on HD: " + CoreSettings.RUNNING_ON_RETINA_DISPLAY + ", " +
					"global scaling: " + CoreSettings.GLOBAL_SCALING
			);

		}
	}
}
