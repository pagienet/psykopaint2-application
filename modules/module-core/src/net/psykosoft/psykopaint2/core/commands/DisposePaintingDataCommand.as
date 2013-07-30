package net.psykosoft.psykopaint2.core.commands
{

	import net.psykosoft.psykopaint2.core.models.PaintingModel;

	import robotlegs.bender.bundles.mvcs.Command;

	public class DisposePaintingDataCommand extends Command
	{
		[Inject]
		public var paintingModel:PaintingModel;

		override public function execute():void {
			paintingModel.disposePaintingCollection();
		}
	}
}
