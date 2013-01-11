package net.psykosoft.psykopaint2.config.configurators
{

	import net.psykosoft.psykopaint2.commands.ChangeStateCommand;
	import net.psykosoft.psykopaint2.commands.LoadReadyToPaintImagesCommand;
	import net.psykosoft.psykopaint2.commands.RandomizeWallpaperCommand;
	import net.psykosoft.psykopaint2.signal.requests.RequestRandomWallpaperChangeSignal;
	import net.psykosoft.psykopaint2.signal.requests.RequestReadyToPaintImagesSignal;
	import net.psykosoft.psykopaint2.signal.requests.RequestStateChangeSignal;

	import robotlegs.bender.extensions.signalCommandMap.api.ISignalCommandMap;

	public class CommandsConfig
	{
		public function CommandsConfig( commandMap:ISignalCommandMap ) {

			commandMap.map( RequestStateChangeSignal ).toCommand( ChangeStateCommand );
			commandMap.map( RequestRandomWallpaperChangeSignal ).toCommand( RandomizeWallpaperCommand );
			commandMap.map( RequestReadyToPaintImagesSignal ).toCommand( LoadReadyToPaintImagesCommand );

		}
	}
}
