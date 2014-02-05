package net.psykosoft.psykopaint2.core.commands.bootstrap
{

	import flash.display.Stage;
	import flash.display.StageAlign;
	import flash.display.StageQuality;
	import flash.display.StageScaleMode;
	
	import net.psykosoft.psykopaint2.core.configuration.CoreSettings;
	
	import robotlegs.bender.bundles.mvcs.Command;
	import robotlegs.bender.framework.api.IInjector;

	public class InitStageCommand extends Command
	{
		[Inject]
		public var injector:IInjector;

		override public function execute():void {

			trace( this, "execute()" );

			var stage:Stage = CoreSettings.STAGE;

			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;
			stage.frameRate = 60;
			//stage.quality = StageQuality.LOW; // Note: On Desktop, the quality will be set to a lowest value of HIGH.
			stage.quality = StageQuality.HIGH;
			
			trace( this, "incoming stage dimensions: " + stage.stageWidth + "x" + stage.stageHeight );
			if( CoreSettings.RUNNING_ON_iPAD ) {
				stage.stageWidth = CoreSettings.GLOBAL_SCALING * 1024;
				stage.stageHeight = CoreSettings.GLOBAL_SCALING * 768;
			}
			trace( this, "resulting stage dimensions: " + stage.stageWidth + "x" + stage.stageHeight );

			CoreSettings.STAGE_WIDTH = stage.stageWidth;
			CoreSettings.STAGE_HEIGHT = stage.stageHeight;

			injector.map( Stage ).toValue( stage );
		}
	}
}
