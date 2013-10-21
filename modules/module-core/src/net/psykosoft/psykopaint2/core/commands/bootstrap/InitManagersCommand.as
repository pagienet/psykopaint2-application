package net.psykosoft.psykopaint2.core.commands.bootstrap
{

	import com.greensock.plugins.ColorMatrixFilterPlugin;
	import com.greensock.plugins.TweenPlugin;

	import flash.display.Stage;

	import net.psykosoft.psykopaint2.core.configuration.CoreSettings;
	import net.psykosoft.psykopaint2.core.managers.accelerometer.GyroscopeManager;

	import net.psykosoft.psykopaint2.core.managers.gestures.GestureManager;
	import net.psykosoft.psykopaint2.core.managers.misc.IOAneManager;
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

		[Inject]
		public var ioAne:IOAneManager;

		[Inject]
		public var gyroscopeManager : GyroscopeManager;

		override public function execute():void {

			trace( this, "execute" );

			// Gestures...
			gestureManager.stage = stage;

			// Memory warnings...
			memoryWarningManager.initialize();

			// Keyboard debugging...
			if( CoreSettings.USE_DEBUG_KEYS ) {
				keyDebuggingManager.initialize();
			}

			// IO ANE.
			ioAne.initialize();

			gyroscopeManager.initialize();

			// Tweens.
			// Used to color button labels.
			TweenPlugin.activate( [ ColorMatrixFilterPlugin ] );

		}
	}
}
