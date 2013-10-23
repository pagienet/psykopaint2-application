package net.psykosoft.psykopaint2.paint.commands.saving.sync
{
	import eu.alebianco.robotlegs.utils.impl.AsyncCommand;

	import flash.display.Stage;
	import flash.utils.ByteArray;

	import net.psykosoft.psykopaint2.core.io.CanvasIPPSerializer;

	import net.psykosoft.psykopaint2.core.io.CanvasSerializationEvent;

	import net.psykosoft.psykopaint2.core.io.CanvasDPPSerializer;
	import net.psykosoft.psykopaint2.core.managers.misc.IOAneManager;
	import net.psykosoft.psykopaint2.core.model.CanvasModel;

	import net.psykosoft.psykopaint2.core.models.SavingProcessModel;
	import net.psykosoft.psykopaint2.core.rendering.CanvasRenderer;
	import net.psykosoft.psykopaint2.core.signals.RequestUpdateMessagePopUpSignal;

	public class SerializeIPPCommand extends AsyncCommand
	{
		[Inject]
		public var saveVO : SavingProcessModel;

		[Inject]
		public var canvasRenderer:CanvasRenderer;

		override public function execute() : void
		{
			var dateMs:Number = new Date().getTime();
			// todo: if there's already an id associated with the painting, we need to use that again
			var paintingDate:Number = Number( saveVO.paintingId.split( "-" )[ 1 ] );
			// eww:
			if (isNaN(paintingDate))
				saveVO.paintingId = "psyko-" + dateMs;

			var serializer:CanvasIPPSerializer = new CanvasIPPSerializer();
			saveVO.infoBytes = serializer.serialize(saveVO.paintingId, dateMs, canvasRenderer, saveVO.dataBytes);
			dispatchComplete(true);
		}
	}
}
