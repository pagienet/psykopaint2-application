package net.psykosoft.psykopaint2.app.commands
{

	import flash.events.Event;

	import net.psykosoft.psykopaint2.app.signals.NotifyFrozenBackgroundCreatedSignal;
	import net.psykosoft.psykopaint2.core.managers.rendering.ApplicationRenderer;
	import net.psykosoft.psykopaint2.core.managers.rendering.SnapshotPromise;
	import net.psykosoft.psykopaint2.core.models.EaselRectModel;
	import net.psykosoft.psykopaint2.paint.signals.RequestSetCanvasBackgroundSignal;

	public class CreateCanvasBackgroundCommand
	{
		[Inject]
		public var applicationRenderer : ApplicationRenderer;

		[Inject]
		public var notifyFrozenBackgroundCreatedSignal : NotifyFrozenBackgroundCreatedSignal;

		[Inject]
		public var requestSetCanvasBackgroundSignal : RequestSetCanvasBackgroundSignal;

		[Inject]
		public var easelRectModel : EaselRectModel;

		private var _snapshotPromise : SnapshotPromise;

		public function execute() : void
		{
			trace( this, "execute" );

			_snapshotPromise = applicationRenderer.requestSnapshot();
			_snapshotPromise.addEventListener(SnapshotPromise.PROMISE_FULFILLED, onCanvasSnapShot);
		}

		private function onCanvasSnapShot(event : Event) : void
		{
			_snapshotPromise.removeEventListener(SnapshotPromise.PROMISE_FULFILLED, onCanvasSnapShot);
			notifyFrozenBackgroundCreatedSignal.dispatch(_snapshotPromise.texture);
			requestSetCanvasBackgroundSignal.dispatch(_snapshotPromise.texture.newReference(), easelRectModel.rect);
			_snapshotPromise.dispose();
			_snapshotPromise = null;
		}
	}
}
