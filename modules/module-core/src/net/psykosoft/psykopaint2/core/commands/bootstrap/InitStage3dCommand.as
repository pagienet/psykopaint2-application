package net.psykosoft.psykopaint2.core.commands.bootstrap
{

	import flash.display.Stage;
	import flash.display.Stage3D;
	import flash.display3D.Context3DProfile;
	import flash.events.Event;
	
	import away3d.core.managers.Stage3DManager;
	import away3d.core.managers.Stage3DProxy;
	import away3d.events.Stage3DEvent;
	
	import eu.alebianco.robotlegs.utils.impl.AsyncCommand;
	
	import net.psykosoft.psykopaint2.core.configuration.CoreSettings;
	import net.psykosoft.psykopaint2.core.rendering.CopyTexture;
	import net.psykosoft.psykopaint2.core.rendering.CopyTextureWithAlpha;
	
	import robotlegs.bender.framework.api.IInjector;

	public class InitStage3dCommand extends AsyncCommand
	{
		[Inject]
		public var stage:Stage;

		[Inject]
		public var injector:IInjector;

		private var _stage3d:Stage3D;
		private var _stage3dProxy:Stage3DProxy;

		override public function execute():void {

			trace( this, "execute()" );

			var stage3dManager:Stage3DManager = Stage3DManager.getInstance( stage );
			_stage3dProxy = stage3dManager.getFreeStage3DProxy(false, Context3DProfile.BASELINE_EXTENDED);
			_stage3dProxy.width = 1024 * CoreSettings.GLOBAL_SCALING;
			_stage3dProxy.height = 768 * CoreSettings.GLOBAL_SCALING;
			_stage3d = _stage3dProxy.stage3D;
			_stage3dProxy.addEventListener( Stage3DEvent.CONTEXT3D_CREATED, onContext3dCreated );

			injector.map( Stage3D ).toValue( _stage3d );
			injector.map( Stage3DProxy ).toValue( _stage3dProxy );
		}

		private function onContext3dCreated( event:Event ):void {

			trace( this, "context3d created: " + _stage3dProxy.context3D );
			_stage3dProxy.removeEventListener( Event.CONTEXT3D_CREATE, onContext3dCreated );

			CopyTexture.init( _stage3d.context3D );
			CopyTextureWithAlpha.init( _stage3d.context3D );

			// TODO: listen for context loss?
			// This simulates a context loss. A bit of googling shows that context loss on iPad is rare, but could be possible.
			/*setTimeout( function():void {
			 trace( "<<< CONTEXT3D LOSS TEST >>>" );
			 _stage3D.context3D.dispose();
			 }, 60000 );*/

			_stage3dProxy.context3D.configureBackBuffer( stage.stageWidth, stage.stageHeight, CoreSettings.STAGE_3D_ANTI_ALIAS, true );
			_stage3dProxy.context3D.enableErrorChecking = CoreSettings.STAGE_3D_ERROR_CHECKING;

			dispatchComplete( true );
		}
	}
}
