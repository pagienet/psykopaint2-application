package net.psykosoft.psykopaint2.home.commands
{

	import net.psykosoft.psykopaint2.core.data.PaintingInfoVO;
	import net.psykosoft.psykopaint2.core.models.PaintingModel;
	import net.psykosoft.psykopaint2.core.signals.RequestEaselUpdateSignal;

	import robotlegs.bender.bundles.mvcs.Command;

	public class UpdateEaselWithLatestPaintingCommand extends Command
	{
		[Inject]
		public var paintingModel:PaintingModel;

		[Inject]
		public var requestEaselPaintingUpdateSignal:RequestEaselUpdateSignal;

		override public function execute():void {

			trace( this, "execute()" );

			var infoVO:PaintingInfoVO = paintingModel.getSortedPaintingCollection()[ 0 ];
			if( infoVO ) {
				requestEaselPaintingUpdateSignal.dispatch( infoVO, false, false );
			}
		}
	}
}
