package net.psykosoft.psykopaint2.app.commands
{
	import flash.events.Event;

	import net.psykosoft.psykopaint2.core.managers.rendering.ApplicationRenderer;
	import net.psykosoft.psykopaint2.core.managers.rendering.SnapshotPromise;
	import net.psykosoft.psykopaint2.core.models.EaselRectModel;
	import net.psykosoft.psykopaint2.core.rendering.CanvasRenderer;

	public class CreateCanvasBackgroundCommand
	{
		[Inject]
		public var applicationRenderer:ApplicationRenderer;

		[Inject]
		public var canvasRenderer:CanvasRenderer;

		[Inject]
		public var easelRectModel : EaselRectModel;

		private var _snapshotPromise : SnapshotPromise;

		public function execute() : void
		{
			_snapshotPromise = applicationRenderer.requestSnapshot();
			_snapshotPromise.addEventListener( SnapshotPromise.PROMISE_FULFILLED, onCanvasSnapShot );
		}

		private function onCanvasSnapShot(event : Event) : void
		{
			_snapshotPromise.removeEventListener( SnapshotPromise.PROMISE_FULFILLED, onCanvasSnapShot );
			canvasRenderer.setBackground(_snapshotPromise.texture.newReference(), easelRectModel.rect);
			_snapshotPromise.dispose();
			_snapshotPromise = null;
		}
	}
}
