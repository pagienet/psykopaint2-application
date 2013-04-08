package net.psykosoft.psykopaint2.app.config.configurators
{

	import net.psykosoft.psykopaint2.app.commands.ChangeSourceImageCommand;
	import net.psykosoft.psykopaint2.app.commands.ChangeStateCommand;
	import net.psykosoft.psykopaint2.app.commands.ChangeWallpaperCommand;
	import net.psykosoft.psykopaint2.app.commands.RenderFrameCommand;
	import net.psykosoft.psykopaint2.app.commands.UpdateAppStateFromActivatedDrawingCoreModuleCommand;
	import net.psykosoft.psykopaint2.app.signal.requests.RequestRenderFrameSignal;
	import net.psykosoft.psykopaint2.app.signal.requests.RequestSourceImageChangeSignal;
	import net.psykosoft.psykopaint2.app.signal.requests.RequestStateChangeSignal;
	import net.psykosoft.psykopaint2.app.signal.requests.RequestStateUpdateFromModuleActivationSignal;
	import net.psykosoft.psykopaint2.app.signal.requests.RequestWallpaperChangeSignal;

	import robotlegs.bender.extensions.signalCommandMap.api.ISignalCommandMap;

	public class CommandsConfig
	{
		public function CommandsConfig( commandMap:ISignalCommandMap ) {

			// Application state changes.
			commandMap.map( RequestStateChangeSignal ).toCommand( ChangeStateCommand );
			commandMap.map( RequestStateUpdateFromModuleActivationSignal ).toCommand( UpdateAppStateFromActivatedDrawingCoreModuleCommand );

			// Packaged wallpapers.
			commandMap.map( RequestWallpaperChangeSignal ).toCommand( ChangeWallpaperCommand );

			// Source image change to start the painting process.
			commandMap.map( RequestSourceImageChangeSignal ).toCommand( ChangeSourceImageCommand );

			// Drawing.
			commandMap.map( RequestRenderFrameSignal ).toCommand( RenderFrameCommand );
		}
	}
}
