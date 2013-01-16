package net.psykosoft.psykopaint2.config.configurators
{

	import net.psykosoft.psykopaint2.commands.ChangeStateCommand;
	import net.psykosoft.psykopaint2.commands.ChangeWallpaperCommand;
	import net.psykosoft.psykopaint2.commands.LoadReadyToPaintImagesCommand;
	import net.psykosoft.psykopaint2.commands.LoadWallpaperImagesCommand;
	import net.psykosoft.psykopaint2.signal.requests.RequestReadyToPaintImagesLoadSignal;
	import net.psykosoft.psykopaint2.signal.requests.RequestStateChangeSignal;
	import net.psykosoft.psykopaint2.signal.requests.RequestWallpaperChangeSignal;
	import net.psykosoft.psykopaint2.signal.requests.RequestWallpaperImagesLoadSignal;

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
