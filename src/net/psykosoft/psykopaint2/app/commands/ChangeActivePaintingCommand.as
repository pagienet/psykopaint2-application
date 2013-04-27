package net.psykosoft.psykopaint2.app.commands
{

	import net.psykosoft.psykopaint2.app.model.ActivePaintingModel;

	public class ChangeActivePaintingCommand
	{
		[Inject]
		public var name:String;

		[Inject]
		public var activePaintingModel:ActivePaintingModel;

		public function execute():void {

			activePaintingModel.changeActivePaintingName( name );

		}
	}
}
