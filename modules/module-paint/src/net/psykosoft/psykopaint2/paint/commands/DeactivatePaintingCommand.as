package net.psykosoft.psykopaint2.paint.commands
{

	import net.psykosoft.psykopaint2.base.robotlegs.commands.TracingCommand;
	import net.psykosoft.psykopaint2.core.data.PaintingVO;
	import net.psykosoft.psykopaint2.core.models.PaintingModel;

	public class DeactivatePaintingCommand extends TracingCommand
	{
		[Inject]
		public var paintingId:String; // From signal.

		[Inject]
		public var paintingModel:PaintingModel;

		override public function execute():void {
			super.execute();

			// Remove painting surface data from memory.
			var vo:PaintingVO = paintingModel.getVoWithId( paintingId );
			vo.colorImageBGRA = null;
			vo.heightmapImageBGRA = null;
			vo.sourceImageARGB = null;
			vo.dataDeSerialized = false;

			// TODO: need to do something on the drawing core to 1) release the byte data and 2) make the core sleep?
		}
	}
}
