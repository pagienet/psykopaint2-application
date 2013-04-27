package net.psykosoft.psykopaint2.app.config.configurators
{

	import net.psykosoft.psykopaint2.app.commands.ChangeActivePaintingCommand;
	import net.psykosoft.psykopaint2.app.commands.ChangeSourceImageCommand;
	import net.psykosoft.psykopaint2.app.commands.ChangeStateCommand;
	import net.psykosoft.psykopaint2.app.commands.RenderFrameCommand;
	import net.psykosoft.psykopaint2.app.commands.UpdateAppStateFromActivatedDrawingCoreModuleCommand;
	import net.psykosoft.psykopaint2.app.signal.requests.RequestActivePaintingChangeSignal;
	import net.psykosoft.psykopaint2.app.signal.requests.RequestRenderFrameSignal;
	import net.psykosoft.psykopaint2.app.signal.requests.RequestSourceImageChangeSignal;
	import net.psykosoft.psykopaint2.app.signal.requests.RequestStateChangeSignal;
	import net.psykosoft.psykopaint2.app.signal.requests.RequestStateUpdateFromModuleActivationSignal;

	import robotlegs.bender.extensions.signalCommandMap.api.ISignalCommandMap;

	public class CommandsConfig
	{
		public function CommandsConfig( commandMap:ISignalCommandMap ) {

			commandMap.map( RequestStateChangeSignal ).toCommand( ChangeStateCommand );
			commandMap.map( RequestStateUpdateFromModuleActivationSignal ).toCommand( UpdateAppStateFromActivatedDrawingCoreModuleCommand );
			commandMap.map( RequestSourceImageChangeSignal ).toCommand( ChangeSourceImageCommand );
			commandMap.map( RequestRenderFrameSignal ).toCommand( RenderFrameCommand );
			commandMap.map( RequestActivePaintingChangeSignal ).toCommand( ChangeActivePaintingCommand );
		}
	}
}
