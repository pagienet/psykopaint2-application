package net.psykosoft.psykopaint2.home.commands.load
{
	import eu.alebianco.robotlegs.utils.impl.AsyncCommand;

	import net.psykosoft.psykopaint2.home.views.book.BookGeometryProxy;

	import net.psykosoft.psykopaint2.home.views.book.BookMaterialsProxy;

	public class InitializeBookCommand extends AsyncCommand
	{
		override public function execute() : void
		{
			// make sure book is ready to go before it's shown
			// can be moved if memory is necessary later
			BookMaterialsProxy.launch(onMaterialsLoaded);
			BookGeometryProxy.launch();
		}

		private function onMaterialsLoaded() : void
		{
			dispatchComplete(true);
		}
	}
}
