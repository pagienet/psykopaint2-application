package net.psykosoft.psykopaint2.core.commands.bootstrap
{

	import flash.display.Stage;

	import net.psykosoft.psykopaint2.core.managers.gestures.GestureManager;

	import robotlegs.bender.bundles.mvcs.Command;

	public class InitGestureManagerCommand extends Command
	{
		[Inject]
		public var manager:GestureManager;

		[Inject]
		public var stage:Stage;

		override public function execute():void {

			trace( this, "execute()" );

			// Just trigger the singleton.
			manager.stage = stage;

		}
	}
}
