package net.psykosoft.psykopaint2.paint.commands.saving.async
{

	import eu.alebianco.robotlegs.utils.impl.ParallelMacro;

	public class SaveInfoAndDataCommand extends ParallelMacro
	{
		override public function prepare():void {

			add( SavePaintingInfoCommand );
			add( SavePaintingDataCommand );

		}
	}
}
