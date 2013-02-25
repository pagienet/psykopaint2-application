package net.psykosoft.psykopaint2.app.config.configurators
{

	import net.psykosoft.psykopaint2.app.commands.ChangeStateCommand;
	import net.psykosoft.psykopaint2.app.commands.ChangeWallpaperCommand;
	import net.psykosoft.psykopaint2.app.commands.LoadReadyToPaintImagesCommand;
	import net.psykosoft.psykopaint2.app.commands.LoadWallpaperImagesCommand;
	import net.psykosoft.psykopaint2.app.signal.requests.RequestReadyToPaintImagesLoadSignal;
	import net.psykosoft.psykopaint2.app.signal.requests.RequestStateChangeSignal;
	import net.psykosoft.psykopaint2.app.signal.requests.RequestWallpaperChangeSignal;
	import net.psykosoft.psykopaint2.app.signal.requests.RequestWallpaperImagesLoadSignal;

	import robotlegs.bender.extensions.signalCommandMap.api.ISignalCommandMap;

	public class CommandsConfig
	{
		public function CommandsConfig( commandMap:ISignalCommandMap ) {

			commandMap.map( RequestStateChangeSignal ).toCommand( ChangeStateCommand );
			commandMap.map( RequestReadyToPaintImagesLoadSignal ).toCommand( LoadReadyToPaintImagesCommand );
			commandMap.map( RequestWallpaperImagesLoadSignal ).toCommand( LoadWallpaperImagesCommand );
			commandMap.map( RequestWallpaperChangeSignal ).toCommand( ChangeWallpaperCommand );

		}
	}
}
