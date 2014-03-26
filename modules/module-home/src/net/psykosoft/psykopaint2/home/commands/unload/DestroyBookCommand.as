package net.psykosoft.psykopaint2.home.commands.unload
{
	import net.psykosoft.psykopaint2.home.views.book.BookMaterialsProxy;

	import robotlegs.bender.bundles.mvcs.Command;

	public class DestroyBookCommand extends Command
	{
		override public function execute():void
		{
			// this is kind of silly, but it's probably easier to find if there's some symmetry
			BookMaterialsProxy.dispose();
		}
	}
}
