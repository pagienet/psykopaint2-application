package net.psykosoft.psykopaint2.paint.views.canvas
{
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	import net.psykosoft.psykopaint2.core.configuration.CoreSettings;
	import net.psykosoft.psykopaint2.core.model.UserPaintSettingsModel;
	import net.psykosoft.psykopaint2.core.models.NavigationStateType;
	import net.psykosoft.psykopaint2.core.models.PaintingModel;
	import net.psykosoft.psykopaint2.core.views.base.MediatorBase;
	import net.psykosoft.psykopaint2.paint.signals.NotifyChangePipetteColorSignal;
	import net.psykosoft.psykopaint2.paint.signals.NotifyPipetteChargeChangedSignal;
	import net.psykosoft.psykopaint2.paint.signals.NotifyShowPipetteSignal;


	public class PipetteViewMediator extends MediatorBase
	{
		[Inject]
		public var view:PipetteView;

		[Inject]
		public var paintingModel:PaintingModel;

		[Inject]
		public var notifyShowPipetteSignal:NotifyShowPipetteSignal;
		
		[Inject]
		public var notifyPipetteChargeChangedSignal:NotifyPipetteChargeChangedSignal;
		
		[Inject]
		public var notifyChangePipetteColorSignal:NotifyChangePipetteColorSignal;
		
		[Inject]
		public var userPaintSettingsModel:UserPaintSettingsModel;
		
		override public function initialize():void {
			
			registerView( view );
			super.initialize();
			registerEnablingState( NavigationStateType.PAINT );
			registerEnablingState( NavigationStateType.PAINT_SELECT_BRUSH );
			registerEnablingState( NavigationStateType.PAINT_ADJUST_COLOR );
			registerEnablingState( NavigationStateType.TRANSITION_TO_PAINT_MODE );
			//registerEnablingState( NavigationStateType.PAINT_ADJUST_ALPHA );
			
			notifyShowPipetteSignal.add( onShowPipette );
			notifyChangePipetteColorSignal.add( onChangePipetteColor );
			view.chargeChangedSignal = notifyPipetteChargeChangedSignal;
			view.userPaintSettingsModel = userPaintSettingsModel;
			//view.enabledSignal.add(onEnabled);
			//view.disabledSignal.add(onDisabled);
		}
		
		private function onChangePipetteColor(color:uint ):void
		{
			view.pipette.currentColor = color;
		}
		
		override public function destroy():void {
			super.destroy();
			notifyShowPipetteSignal.remove( onShowPipette );
			
		}
		
		private function onShowPipette( holder:Sprite, color:uint, screenPos:Point, showSpotColor:Boolean ):void
		{
			view.showPipette( holder, color, screenPos, showSpotColor);
		}
	}
}
