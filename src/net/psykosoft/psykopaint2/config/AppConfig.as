package net.psykosoft.psykopaint2.config
{

	import com.junkbyte.console.Cc;

	import flash.utils.getTimer;

	import net.psykosoft.psykopaint2.controller.ChangeStateCommand;
	import net.psykosoft.psykopaint2.model.StateModel;
	import net.psykosoft.psykopaint2.signal.notifications.NotifyStateChangedSignal;
	import net.psykosoft.psykopaint2.signal.requests.RequestStateChangeSignal;
	import net.psykosoft.psykopaint2.view.away3d.base.Away3dRootSprite;
	import net.psykosoft.psykopaint2.view.away3d.wall.Wall3dView;
	import net.psykosoft.psykopaint2.view.away3d.wall.Wall3dViewMediator;
	import net.psykosoft.psykopaint2.view.starling.splash.Splash2dView;
	import net.psykosoft.psykopaint2.view.starling.splash.Splash2dViewMediator;

	import org.swiftsuspenders.Injector;

	import robotlegs.bender.extensions.contextView.ContextView;
	import robotlegs.bender.extensions.mediatorMap.api.IMediatorMap;
	import robotlegs.bender.extensions.signalCommandMap.api.ISignalCommandMap;
	import robotlegs.bender.framework.api.IConfig;
	import robotlegs.bender.framework.api.IContext;

	public class AppConfig implements IConfig
	{
		[Inject]
		public var context:IContext;

		[Inject]
		public var commandMap:ISignalCommandMap;

		[Inject]
		public var mediatorMap:IMediatorMap;

		[Inject]
		public var injector:Injector;

		[Inject]
		public var contextView:ContextView;

		public function AppConfig() {
			super();
		}

		public function configure():void {

			// Debug utility.
			if( Settings.DEBUG_MODE ) {
				configureLogger();
				Cc.info( this, "initializing - " + Settings.NAME + " " + Settings.VERSION );
			}

			// Map commands.
			commandMap.map( RequestStateChangeSignal ).toCommand( ChangeStateCommand );

			// Map independent notification signals.
			injector.map( NotifyStateChangedSignal ).asSingleton();

			// Map 2d views.
			mediatorMap.map( Splash2dView ).toMediator( Splash2dViewMediator );

			// Map 3d views.
			mediatorMap.map( Wall3dView ).toMediator( Wall3dViewMediator );

			// Map models.
			injector.map( StateModel ).asSingleton();

			// Map services.
//			injector.map( IPhotoGalleryService ).toSingleton( FlickrImageService );

			// Start.
			context.lifecycle.afterInitializing( init );

		}

		private function init():void {

			// Initialize 3d display tree.
			// Note: the 2d display tree ( StarlingRootSprite.as ) is initialized in the main class,
			// with the creation of the Starling object.
			contextView.view.addChild( new Away3dRootSprite() );

			Cc.info( this, "app ready" );

		}

		private function configureLogger():void {
			// TODO: add ability to not use with a global setting, this is the only regular display tree object and may be bad for performance
			Cc.config.style.backgroundAlpha = 0.75;
			Cc.config.tracing = true;
			Cc.startOnStage( contextView.view, "`" );
			Cc.visible = false;
			Cc.height = 350;
			Cc.width = contextView.view.stage.stageWidth;
			Cc.config.traceCall = function( ch:String, line:String, ...args ):void
			{
				var time:String = String( getTimer() ) + "ms";
				var priorityLevel:int = args[0];
				switch( priorityLevel )
				{
					case 1:
					case 2:
					case 3:
					case 4: { // log & info
						trace( time + " - info: " + line );
						break;
					}
					case 5:
					case 6: { // debug
						trace( time + " - debug: " + line );
						break;
					}
					case 7:
					case 8: { // warn
						trace( time + " - warn: " + line );
						break;
					}
					case 9: { // error
						trace( time + " - error: " + line );
						break;
					}
					case 10: { // fatal
						trace( time + " - fatal: " + line );
						break;
					}
				}
			}
		}
	}
}
