package net.psykosoft.psykopaint2.app.view.painting.colorstyle
{

	import com.quasimondo.geom.ColorMatrix;

	import flash.display.BitmapData;
	import flash.utils.setTimeout;

	import net.psykosoft.psykopaint2.app.model.ApplicationStateType;
	import net.psykosoft.psykopaint2.app.view.base.StarlingMediatorBase;
	import net.psykosoft.psykopaint2.core.drawing.modules.ColorStyleModule;
	import net.psykosoft.psykopaint2.core.signals.NotifyColorStyleChangedSignal;
	import net.psykosoft.psykopaint2.core.signals.NotifyColorStyleCompleteSignal;
	import net.psykosoft.psykopaint2.core.signals.NotifyColorStyleConfirmSignal;
	import net.psykosoft.psykopaint2.core.signals.NotifyColorStyleModuleActivatedSignal;
	import net.psykosoft.psykopaint2.core.signals.RequestColorStyleMatrixChangedSignal;

	public class ColorStyleViewMediator extends StarlingMediatorBase
	{
		[Inject]
		public var colorStyleModule:ColorStyleModule;

		[Inject]
		public var colorStyleView:ColorStyleView;

		[Inject]
		public var notifyColorStyleModuleActivatedSignal:NotifyColorStyleModuleActivatedSignal;

		[Inject]
		public var notifyColorStyleCompleteSignal:NotifyColorStyleCompleteSignal;

		[Inject]
		public var notifyColorStyleChangedSignal:NotifyColorStyleChangedSignal;

		[Inject]
		public var notifyColorStyleConfirmSignal:NotifyColorStyleConfirmSignal;

		[Inject]
		public var requestColorStyleMatrixChangedSignal:RequestColorStyleMatrixChangedSignal;

		override public function initialize():void {

			super.initialize();
			registerView( colorStyleView );
			registerEnablingState( ApplicationStateType.PAINTING_SELECT_COLORS );

			// From app.
			notifyColorStyleModuleActivatedSignal.add( onModuleActivated );
			notifyColorStyleChangedSignal.add( onColorStyleChanged );
			notifyColorStyleConfirmSignal.add( confirmColorStyle );
			requestColorStyleMatrixChangedSignal.add( onColorStyleMatrixChanged );
		}

		// -----------------------
		// From app.
		// -----------------------

		private function onModuleActivated( bitmapData:BitmapData ):void {
			trace( this, "color style module activated" );
			colorStyleView.previewMap = colorStyleModule.sourceMap;
		}

		private function onColorStyleChanged( styleName:String ):void {
			colorStyleModule.setColorStyle( styleName );
		}

		private function confirmColorStyle():void {
			colorStyleView.renderPreviewToBitmapData();
			colorStyleModule.confirmColorStyle();
		}

		private function onColorStyleMatrixChanged( matrix1:ColorMatrix, matrix2:ColorMatrix, threshold:Number, range:Number ):void {
			trace( this, "color style matrix changed" );
			colorStyleView.updateColorMatrices( matrix1, matrix2, threshold, range );
		}
	}
}
