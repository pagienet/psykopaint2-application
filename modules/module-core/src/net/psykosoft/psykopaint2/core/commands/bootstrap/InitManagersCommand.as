package net.psykosoft.psykopaint2.core.commands.bootstrap
{

	import com.greensock.plugins.ColorMatrixFilterPlugin;
	import com.greensock.plugins.TweenPlugin;

	import flash.display.Stage;

	import net.psykosoft.psykopaint2.core.configuration.CoreSettings;

	import net.psykosoft.psykopaint2.core.managers.gestures.GestureManager;
	import net.psykosoft.psykopaint2.core.managers.misc.KeyDebuggingManager;
	import net.psykosoft.psykopaint2.core.managers.misc.MemoryWarningManager;

	import robotlegs.bender.bundles.mvcs.Command;

	public class InitManagersCommand extends Command
	{
		[Inject]
		public var stage:Stage;

		[Inject]
		public var gestureManager:GestureManager;

		[Inject]
		public var keyDebuggingManager:KeyDebuggingManager;

		[Inject]
		public var memoryWarningManager:MemoryWarningManager;

		override public function execute():void {

			trace( this, "execute" );

			gestureManager.stage = stage;

			if( CoreSettings.USE_DEBUG_KEYS ) {
				keyDebuggingManager.initialize();
			}

			memoryWarningManager.initialize();

			// Used to color button labels.
			TweenPlugin.activate( [ ColorMatrixFilterPlugin ] );

		}
	}
}
