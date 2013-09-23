package net.psykosoft.psykopaint2.paint.commands.saving.async
{

	import eu.alebianco.robotlegs.utils.impl.AsyncCommand;

	import net.psykosoft.psykopaint2.core.views.debug.ConsoleView;

	public class SerializePaintingDataCommand extends AsyncCommand
	{
		override public function execute():void {

			ConsoleView.instance.log( this, "execute()" );

		}
	}
}
