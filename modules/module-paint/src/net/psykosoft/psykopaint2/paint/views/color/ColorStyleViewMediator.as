package net.psykosoft.psykopaint2.paint.views.color
{

	import com.quasimondo.geom.ColorMatrix;

	import flash.display.BitmapData;

	import net.psykosoft.psykopaint2.core.drawing.modules.ColorStyleModule;
	import net.psykosoft.psykopaint2.core.models.StateType;
	import net.psykosoft.psykopaint2.core.signals.NotifyColorStyleChangedSignal;
	import net.psykosoft.psykopaint2.core.signals.NotifyColorStyleConfirmSignal;
	import net.psykosoft.psykopaint2.core.signals.NotifyColorStyleModuleActivatedSignal;
	import net.psykosoft.psykopaint2.core.signals.RequestColorStyleMatrixChangedSignal;
	import net.psykosoft.psykopaint2.core.views.base.MediatorBase;

	public class ColorStyleViewMediator extends MediatorBase
	{
		[Inject]
		public var view:ColorStyleView;

		[Inject]
		public var notifyColorStyleModuleActivatedSignal:NotifyColorStyleModuleActivatedSignal;

		[Inject]
		public var notifyColorStyleChangedSignal:NotifyColorStyleChangedSignal;

		[Inject]
		public var notifyColorStyleConfirmSignal:NotifyColorStyleConfirmSignal;

		[Inject]
		public var requestColorStyleMatrixChangedSignal:RequestColorStyleMatrixChangedSignal;

		[Inject]
		public var colorStyleModule:ColorStyleModule;

		override public function initialize():void {

			// Init.
			super.initialize();
			registerView( view );
			registerEnablingState( StateType.STATE_COLOR_STYLE );

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
			view.previewMap = colorStyleModule.sourceMap;
		}

		private function onColorStyleChanged( styleName:String ):void {
			colorStyleModule.setColorStyle( styleName );
		}

		private function confirmColorStyle():void {
			view.renderPreviewToBitmapData();
			colorStyleModule.confirmColorStyle();
		}

		private function onColorStyleMatrixChanged( matrix1:ColorMatrix, matrix2:ColorMatrix, threshold:Number, range:Number ):void {
			view.updateColorMatrices( matrix1, matrix2, threshold, range );
		}

		// -----------------------
		// From view.
		// -----------------------

		// ...
	}
}
