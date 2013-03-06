package net.psykosoft.psykopaint2.app.config.configurators
{

	import net.psykosoft.psykopaint2.app.commands.ChangeSourceImageCommand;
	import net.psykosoft.psykopaint2.app.commands.ChangeStateCommand;
	import net.psykosoft.psykopaint2.app.commands.ChangeWallpaperCommand;
	import net.psykosoft.psykopaint2.app.commands.LoadReadyToPaintImageCommand;
	import net.psykosoft.psykopaint2.app.commands.LoadReadyToPaintThumbnailsCommand;
	import net.psykosoft.psykopaint2.app.commands.LoadWallpaperThumbsCommand;
	import net.psykosoft.psykopaint2.app.commands.UpdateAppStateFromActivedDrawingCoreModuleCommand;
	import net.psykosoft.psykopaint2.app.signal.requests.RequestAppStateUpdateFromCoreModuleActivationSignal;
	import net.psykosoft.psykopaint2.app.signal.requests.RequestReadyToPaintImageSignal;
	import net.psykosoft.psykopaint2.app.signal.requests.RequestReadyToPaintThumbnailsSignal;
	import net.psykosoft.psykopaint2.app.signal.requests.RequestSourceImageChangeSignal;
	import net.psykosoft.psykopaint2.app.signal.requests.RequestStateChangeSignal;
	import net.psykosoft.psykopaint2.app.signal.requests.RequestWallpaperChangeSignal;
	import net.psykosoft.psykopaint2.app.signal.requests.RequestWallpaperThumbsLoadSignal;

	import robotlegs.bender.extensions.signalCommandMap.api.ISignalCommandMap;

	public class CommandsConfig
	{
		public function CommandsConfig( commandMap:ISignalCommandMap ) {

			// Application state changes.
			commandMap.map( RequestStateChangeSignal ).toCommand( ChangeStateCommand );
			commandMap.map( RequestAppStateUpdateFromCoreModuleActivationSignal ).toCommand( UpdateAppStateFromActivedDrawingCoreModuleCommand );

			// Packaged wallpapers.
			commandMap.map( RequestWallpaperThumbsLoadSignal ).toCommand( LoadWallpaperThumbsCommand );
			commandMap.map( RequestWallpaperChangeSignal ).toCommand( ChangeWallpaperCommand );

			// Ready to paint packaged images.
			commandMap.map( RequestReadyToPaintThumbnailsSignal ).toCommand( LoadReadyToPaintThumbnailsCommand );
			commandMap.map( RequestReadyToPaintImageSignal ).toCommand( LoadReadyToPaintImageCommand );

			// Source image change to start the painting process.
			commandMap.map( RequestSourceImageChangeSignal ).toCommand( ChangeSourceImageCommand );

		}
	}
}
