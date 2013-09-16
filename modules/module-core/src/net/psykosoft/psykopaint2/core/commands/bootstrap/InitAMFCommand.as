package net.psykosoft.psykopaint2.core.commands.bootstrap
{
	import eu.alebianco.robotlegs.utils.impl.AsyncCommand;

	import net.psykosoft.psykopaint2.core.services.AMFBridge;

	public class InitAMFCommand extends AsyncCommand
	{
		[Inject]
		public var bridge : AMFBridge;

		override public function execute() : void
		{
			trace (this, "execute()");
			bridge.connect();
			dispatchComplete( true );
		}
	}
}
