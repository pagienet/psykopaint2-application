package net.psykosoft.psykopaint2.config.configurators
{

	import net.psykosoft.psykopaint2.controller.ChangeStateCommand;
	import net.psykosoft.psykopaint2.signal.requests.RequestStateChangeSignal;

	import robotlegs.bender.extensions.signalCommandMap.api.ISignalCommandMap;

	public class CommandsConfig
	{
		public function CommandsConfig( commandMap:ISignalCommandMap ) {

			commandMap.map( RequestStateChangeSignal ).toCommand( ChangeStateCommand );

		}
	}
}
