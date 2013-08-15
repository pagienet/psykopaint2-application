package net.psykosoft.psykopaint2.app.commands
{
	import flash.events.Event;

	import net.psykosoft.psykopaint2.app.signals.NotifyFrozenBackgroundCreatedSignal;

	import net.psykosoft.psykopaint2.core.managers.rendering.ApplicationRenderer;
	import net.psykosoft.psykopaint2.core.managers.rendering.SnapshotPromise;
	import net.psykosoft.psykopaint2.core.models.EaselRectModel;
	import net.psykosoft.psykopaint2.core.rendering.CanvasRenderer;
	import net.psykosoft.psykopaint2.crop.signals.RequestSetCropBackgroundSignal;
	import net.psykosoft.psykopaint2.paint.signals.RequestSetCanvasBackgroundSignal;

	import org.osflash.signals.Signal;

	public class CreateCropBackgroundCommand
	{
		[Inject]
		public var applicationRenderer : ApplicationRenderer;

		[Inject]
		public var notifyFrozenBackgroundCreatedSignal : NotifyFrozenBackgroundCreatedSignal;

		[Inject]
		public var requestSetCropBackgroundSignal : RequestSetCropBackgroundSignal;

		private var _snapshotPromise : SnapshotPromise;

		public function execute() : void
		{
			_snapshotPromise = applicationRenderer.requestSnapshot();
			_snapshotPromise.addEventListener(SnapshotPromise.PROMISE_FULFILLED, onCanvasSnapShot);
		}

		private function onCanvasSnapShot(event : Event) : void
		{
			_snapshotPromise.removeEventListener(SnapshotPromise.PROMISE_FULFILLED, onCanvasSnapShot);
			notifyFrozenBackgroundCreatedSignal.dispatch(_snapshotPromise.texture);
			requestSetCropBackgroundSignal.dispatch(_snapshotPromise.texture.newReference());
			_snapshotPromise.dispose();
			_snapshotPromise = null;
		}
	}
}
