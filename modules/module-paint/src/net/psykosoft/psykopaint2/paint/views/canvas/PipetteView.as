package net.psykosoft.psykopaint2.paint.views.canvas
{

	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.Point;
	
	import net.psykosoft.psykopaint2.base.ui.base.ViewBase;
	import net.psykosoft.psykopaint2.core.model.UserPaintSettingsModel;
	import net.psykosoft.psykopaint2.core.models.PaintMode;
	import net.psykosoft.psykopaint2.paint.signals.NotifyPipetteChargeChangedSignal;
	import net.psykosoft.psykopaint2.paint.views.color.Pipette;

	public class PipetteView extends ViewBase
	{
		public var pipette:Pipette;
		private var holder:Sprite;
		public var chargeChangedSignal:NotifyPipetteChargeChangedSignal;
		public var userPaintSettingsModel:UserPaintSettingsModel;
		
		public function PipetteView() {
			super();
		}
		
		
		override public function setup():void
		{
			super.setup();
			
			pipette = new Pipette();
			pipette.addEventListener( Event.COMPLETE, onPipetteClosed );
			
			pipette.gotoAndStop(1);
			pipette.visible = false;
		}
		
		override public function dispose():void
		{
			super.dispose();
			if ( pipette )
			{
				pipette.removeEventListener( Event.COMPLETE, onPipetteClosed );
				onPipetteClosed(null);
			}
			chargeChangedSignal = null;
		}
		
		private function onPipetteClosed( event:Event ):void 
		{
			pipette.removeEventListener( "PipetteDischarge", onPipetteDischarge );
			pipette.removeEventListener( "PipetteCharge", onPipetteCharge )
			if ( holder != null )
			{
				holder.removeChild(pipette);
				this.holder = null;
			}
		}
		
		public function showPipette( holder:Sprite, color:uint, screenPos:Point, showSpotColor:Boolean ):void
		{
			if ( this.holder != null ) return;
			this.holder = holder;
			holder.addChild(pipette);
			pipette.x = screenPos.x;
			pipette.y = screenPos.y;
			pipette.startCharge( color, showSpotColor );	
			pipette.addEventListener( "PipetteDischarge", onPipetteDischarge );
			pipette.addEventListener( "PipetteCharge", onPipetteCharge );
		}
		
		protected function onPipetteDischarge(event:Event):void
		{
			chargeChangedSignal.dispatch(pipette, false);
			userPaintSettingsModel.pipetteIsEmpty = pipette.isEmpty;
			if ( userPaintSettingsModel.hasSourceImage ) userPaintSettingsModel.setColorMode( userPaintSettingsModel.pipetteIsEmpty  ? PaintMode.PHOTO_MODE :  PaintMode.COLOR_MODE );
		}
		
		protected function onPipetteCharge(event:Event):void
		{
			userPaintSettingsModel.pipetteIsEmpty = pipette.isEmpty;
			if ( userPaintSettingsModel.hasSourceImage )
			{
				userPaintSettingsModel.setColorMode( pipette.isEmpty ? PaintMode.PHOTO_MODE :  PaintMode.COLOR_MODE );
			}
			if ( !pipette.isEmpty) userPaintSettingsModel.setCurrentColor(pipette.currentColor);
			chargeChangedSignal.dispatch(pipette, true);
		}
	}
}
