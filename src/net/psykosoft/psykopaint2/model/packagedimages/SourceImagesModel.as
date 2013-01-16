package net.psykosoft.psykopaint2.model.packagedimages
{

	import net.psykosoft.psykopaint2.model.packagedimages.vo.PackagedImageVO;
	import net.psykosoft.psykopaint2.signal.notifications.NotifySourceImagesUpdatedSignal;

	public class SourceImagesModel extends PackagedImagesModelBase
	{
		[Inject]
		public var notifySourceImagesUpdatedSignal:NotifySourceImagesUpdatedSignal;

		override protected function reportUpdate( images:Vector.<PackagedImageVO> ):void {
			notifySourceImagesUpdatedSignal.dispatch( images );
		}
	}
}
