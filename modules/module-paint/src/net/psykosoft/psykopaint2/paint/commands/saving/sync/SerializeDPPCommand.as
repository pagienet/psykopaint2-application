package net.psykosoft.psykopaint2.paint.commands.saving.sync
{
	import flash.display.Stage;
	
	import eu.alebianco.robotlegs.utils.impl.AsyncCommand;
	
	import net.psykosoft.psykopaint2.core.io.CanvasDPPSerializer;
	import net.psykosoft.psykopaint2.core.io.CanvasSerializationEvent;
	import net.psykosoft.psykopaint2.core.managers.misc.IOAneManager;
	import net.psykosoft.psykopaint2.core.model.CanvasModel;
	import net.psykosoft.psykopaint2.core.model.UserPaintSettingsModel;
	import net.psykosoft.psykopaint2.core.models.SavingProcessModel;
	import net.psykosoft.psykopaint2.core.signals.RequestUpdateMessagePopUpSignal;
	import net.psykosoft.psykopaint2.core.views.debug.ConsoleView;

	public class SerializeDPPCommand extends AsyncCommand
	{
		[Inject]
		public var saveVO : SavingProcessModel;

		[Inject]
		public var requestUpdateMessagePopUpSignal : RequestUpdateMessagePopUpSignal;

		[Inject]
		public var ioAne : IOAneManager;

		[Inject]
		public var stage : Stage;

		[Inject]
		public var canvasModel : CanvasModel;
		
		[Inject]
		public var userPaintSettingsModel : UserPaintSettingsModel;


		override public function execute() : void
		{
			ConsoleView.instance.log( this, "execute()" );

			requestUpdateMessagePopUpSignal.dispatch("Saving: Serializing...", "");

			var serializer : CanvasDPPSerializer = new CanvasDPPSerializer(stage, ioAne);
			serializer.addEventListener(CanvasSerializationEvent.COMPLETE, onSerializationComplete);
			serializer.serialize(canvasModel,userPaintSettingsModel);
		}

		private function onSerializationComplete(event : CanvasSerializationEvent) : void
		{
			event.target.removeEventListener(CanvasSerializationEvent.COMPLETE, onSerializationComplete);
			saveVO.dataBytes = event.data;
			dispatchComplete(true);
		}
	}
}
