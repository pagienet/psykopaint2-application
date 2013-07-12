package net.psykosoft.psykopaint2.core.commands
{
	import net.psykosoft.psykopaint2.core.managers.rendering.ApplicationRenderer;

	import robotlegs.bender.bundles.mvcs.Command;

	public class RenderGpuCommand extends Command
	{
		[Inject]
		public var applicationRenderer : ApplicationRenderer;

		override public function execute():void {
			super.execute();

			applicationRenderer.render();
		}
	}
}
