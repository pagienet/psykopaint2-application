package net.psykosoft.psykopaint2.core.commands
{
	import net.psykosoft.psykopaint2.core.rendering.RubberMeshRenderer;

	public class RenderRubberMeshCommand
	{
		[Inject]
		public var renderer : RubberMeshRenderer;

		public function execute() : void
		{
			renderer.markForRender();
		}
	}
}
