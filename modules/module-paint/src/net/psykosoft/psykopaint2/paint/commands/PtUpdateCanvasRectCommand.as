package net.psykosoft.psykopaint2.paint.commands
{

	import flash.display.Stage;
	import flash.geom.Rectangle;

	import net.psykosoft.psykopaint2.base.robotlegs.BsTracingCommand;
	import net.psykosoft.psykopaint2.core.signals.RequestChangeRenderRectSignal;

	public class PtUpdateCanvasRectCommand extends BsTracingCommand
	{
		[Inject]
		public var navVisible:Boolean;

		[Inject]
		public var stage:Stage;

		[Inject]
		public var requestChangeRenderRectSignal:RequestChangeRenderRectSignal;

		override public function execute():void {
			super.execute();

			if( navVisible ) {
				requestChangeRenderRectSignal.dispatch( new Rectangle( 0, 0, stage.stageWidth, stage.stageHeight * .76 ) );
			}
			else {
				requestChangeRenderRectSignal.dispatch( new Rectangle( 0, 0, stage.stageWidth, stage.stageHeight ) );
			}
		}
	}
}
