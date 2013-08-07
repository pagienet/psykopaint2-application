package net.psykosoft.psykopaint2.core.commands
{

	import net.psykosoft.psykopaint2.core.configuration.CoreSettings;
	import net.psykosoft.psykopaint2.core.managers.misc.UnDisposedObjectsManager;
	import net.psykosoft.psykopaint2.core.signals.RequestGpuRenderingSignal;

	import robotlegs.bender.bundles.mvcs.Command;

	public class UpdateFrameCommand extends Command
	{
		[Inject]
		public var requestGpuRenderingSignal:RequestGpuRenderingSignal;

		[Inject]
		public var unDisposedObjectsManager:UnDisposedObjectsManager;

		override public function execute():void {

//			trace( this, "execute()" );

			requestGpuRenderingSignal.dispatch();

			if( CoreSettings.TRACK_NON_GCED_OBJECTS ) {
				unDisposedObjectsManager.update()
			}
		}
	}
}
