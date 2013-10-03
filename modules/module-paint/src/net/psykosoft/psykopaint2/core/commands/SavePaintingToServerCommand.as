package net.psykosoft.psykopaint2.core.commands
{
	import eu.alebianco.robotlegs.utils.impl.SequenceMacro;

	import net.psykosoft.psykopaint2.core.signals.NotifyPaintingSavingStartedSignal;

	public class SavePaintingToServerCommand extends SequenceMacro
	{
		[Inject]
		public var notifyPaintingSavingStartedSignal:NotifyPaintingSavingStartedSignal;



		override public function execute() : void
		{

		}
	}
}
