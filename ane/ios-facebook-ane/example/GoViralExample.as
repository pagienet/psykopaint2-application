package  
{
import com.milkmangames.nativeextensions.events.*;
import flash.display.Bitmap;
import flash.display.Sprite;
import flash.events.MouseEvent;
import flash.geom.Rectangle;
import flash.text.TextField;
import com.milkmangames.nativeextensions.*;
import flash.text.TextFieldType;
import flash.utils.getDefinitionByName;

/** GoViralExample App */
public class GoViralExample extends Sprite
{
	//
	// Definitions
	//
	
	/** CHANGE THIS TO YOUR FACEBOOK APP ID! */
	public static const FACEBOOK_APP_ID:String="YOUR_FACEBOOK_APP_ID";
	
	/** An embedded image for testing image attachments. */
	[Embed(source="v202.jpg")]
	private var testImageClass:Class;

	//
	// Instance Variables
	//
	
	/** Status */
	private var txtStatus:TextField;
	
	/** Buttons */
	private var buttonContainer:Sprite;
	
	//
	// Public Methods
	//
	
	/** Create New GoViralExample */
	public function GoViralExample() 
	{		
		createUI();		
		log("Started GoViral Example.");
		init();
	}

	
	/** Init */
	public function init():void
	{
		// check if GoViral is supported.  note that this just determines platform support- iOS - and not
		// whether the particular version supports it.		
		if (!GoViral.isSupported())
		{
			log("Extension is not supported on this platform.");
			return;
		}
		
		log("will create.");
		
		// initialize the extension.
		GoViral.create();

		log("Extension Initialized.");

		// initialize facebook.		
		// this is to make sure you remembered to put in your app ID !
		if (FACEBOOK_APP_ID=="YOUR_FACEBOOK_APP_ID")
		{
			log("You forgot to put in Facebook ID!");
		}
		else
		{
			log("Init facebook...");
			GoViral.goViral.initFacebook(FACEBOOK_APP_ID,"");
			log("init fb done.");
		}
		
		// set up all the event listeners.
		// you only need the ones for the services you want to use.		

		// mail events
		GoViral.goViral.addEventListener(GVMailEvent.MAIL_CANCELED,onMailEvent);
		GoViral.goViral.addEventListener(GVMailEvent.MAIL_FAILED,onMailEvent);
		GoViral.goViral.addEventListener(GVMailEvent.MAIL_SAVED,onMailEvent);
		GoViral.goViral.addEventListener(GVMailEvent.MAIL_SENT,onMailEvent);
		
		// facebook events
		GoViral.goViral.addEventListener(GVFacebookEvent.FB_DIALOG_CANCELED,onFacebookEvent);
		GoViral.goViral.addEventListener(GVFacebookEvent.FB_DIALOG_FAILED,onFacebookEvent);
		GoViral.goViral.addEventListener(GVFacebookEvent.FB_DIALOG_FINISHED,onFacebookEvent);
		GoViral.goViral.addEventListener(GVFacebookEvent.FB_LOGGED_IN,onFacebookEvent);
		GoViral.goViral.addEventListener(GVFacebookEvent.FB_LOGGED_OUT,onFacebookEvent);
		GoViral.goViral.addEventListener(GVFacebookEvent.FB_LOGIN_CANCELED,onFacebookEvent);
		GoViral.goViral.addEventListener(GVFacebookEvent.FB_LOGIN_FAILED,onFacebookEvent);
		GoViral.goViral.addEventListener(GVFacebookEvent.FB_REQUEST_FAILED,onFacebookEvent);
		GoViral.goViral.addEventListener(GVFacebookEvent.FB_REQUEST_RESPONSE,onFacebookEvent);
		
		// twitter events
		GoViral.goViral.addEventListener(GVTwitterEvent.TW_DIALOG_CANCELED,onTwitterEvent);
		GoViral.goViral.addEventListener(GVTwitterEvent.TW_DIALOG_FAILED,onTwitterEvent);
		GoViral.goViral.addEventListener(GVTwitterEvent.TW_DIALOG_FINISHED,onTwitterEvent);
		
		// Generic sharing events
		GoViral.goViral.addEventListener(GVShareEvent.GENERIC_MESSAGE_SHARED,onShareEvent);
		GoViral.goViral.addEventListener(GVShareEvent.SOCIAL_COMPOSER_CANCELED,onShareEvent);
		GoViral.goViral.addEventListener(GVShareEvent.SOCIAL_COMPOSER_FINISHED,onShareEvent);
		
		log("Show Main UI.");
		showMainUI();
	}

	// facebook
	
	/** Login to facebook */
	public function loginFacebook():void
	{
		log("Login facebook...");
		if(!GoViral.goViral.isFacebookAuthenticated())
		{			
			// you must set at least one read permission.  if you don't know what to pick, 'basic_info' is fine.
			GoViral.goViral.authenticateWithFacebook("user_likes,user_photos"); 
		}
		log("done.");
	}
	
	/** Logout of facebook */
	public function logoutFacebook():void
	{
		log("logout fb.");
		GoViral.goViral.logoutFacebook();
		log("done logout.");
	}
	
	/** Post to the facebook wall / feed via dialog */
	public function postFeedFacebook():void
	{
		if (!checkLoggedInFacebook()) return;
		
		log("posting fb feed...");
		GoViral.goViral.showFacebookFeedDialog(
			"Posting from AIR",
			"This is a caption",
			"This is a message!",
			"This is a description",
			"http://www.milkmangames.com",
			"http://www.milkmangames.com/blog/wp-content/uploads/2012/01/v202.jpg"
		);
			
		log("done feed post.");
	}
	
	/** Get a list of all your facebook friends */
	public function getFriendsFacebook():void
	{
		if (!checkLoggedInFacebook()) return;
		
		log("getting friends.(finstn)..");
		GoViral.goViral.requestFacebookFriends({fields:"installed,first_name"});
		log("sent friend list request.");		
	}
	
	/** Get your own facebook profile */
	public function getMeFacebook():void
	{
		if (!checkLoggedInFacebook()) return;
		
		log("Getting profile...");
		GoViral.goViral.requestMyFacebookProfile();
		log("sent profile request.");
	}
	
	/** Get Facebook Access Token */
	public function getFacebookToken():void
	{
		log("Retrieving access token...");
		var accessToken:String=GoViral.goViral.getFbAccessToken();
		var accessExpiry:int=GoViral.goViral.getFbAccessExpiry();
		log("Token is:"+accessToken+",expiry:"+accessExpiry);
	}
	
	
	
	/** Make a post graph request */
	public function postGraphFacebook():void
	{
		if (!checkLoggedInFacebook()) return;
		
		log("Graph posting...");
		var params:Object={};
		params.name="Name Test";
		params.caption="Caption Test";
		params.link="http://www.google.com";
		params.picture="http://www.milkmangames.com/blog/wp-content/uploads/2012/01/v202.jpg";
		params.actions=new Array();
		params.actions.push({name:"Link NOW!",link:"http://www.google.com"});

		// notice the "publish_actions", a required publish permission to write to the graph!
		GoViral.goViral.facebookGraphRequest("me/feed",GVHttpMethod.POST,params,"publish_actions");
		log("post complete.");
	}
	
	/** Show a facebook friend invite dialog */
	public function inviteFriendsFacebook():void
	{
		if (!checkLoggedInFacebook()) return;
		
		log("inviting friends.");
		GoViral.goViral.showFacebookRequestDialog("This is just a test","My Title","somedata");
		log("sent friend invite.");
	}
	
	/** Post a photo to the facebook stream */
	public function postPhotoFacebook():void
	{
		if (!checkLoggedInFacebook()) return;
		
		log("post facebook pic...");
		var asBitmap:Bitmap=new testImageClass() as Bitmap;

		GoViral.goViral.facebookPostPhoto("posted from mobile sdk",asBitmap.bitmapData);
	
		log("posted fb pic.");
		
	}	
	
	/** Check you're logged in to facebook before doing anything else. */
	private function checkLoggedInFacebook():Boolean
	{
		// make sure you're logged in first
		if (!GoViral.goViral.isFacebookAuthenticated())
		{
			log("Not logged in!");
			return false;
		}
		return true;
	}
	
	//
	// Email
	//
	
	/** Send Test Email */
	public function sendTestEmail():void
	{
		if (GoViral.goViral.isEmailAvailable())
		{
			log("Opening email composer...");
			GoViral.goViral.showEmailComposer("This is a subject!","who@where.com,john@doe.com","This is the body of the message.",false);
			log("Composer opened.");
		}
		else
		{
			log("Email is not set up on this device.");
		}
	}
	
	/** Send Email with attached image */
	public function sendImageEmail():void
	{
		var asBitmap:Bitmap=new testImageClass() as Bitmap;
		log("Email composer w/image...");
		if (GoViral.goViral.isEmailAvailable())
		{
			GoViral.goViral.showEmailComposerWithBitmap("This has an attachment!","john@doe.com","I think youll like my pic",false,asBitmap.bitmapData);
		}
		else
		{
			log("Email is not available on this device.");
			return;
		}
		log("Mail composer opened.");
	}
	
	//
	// Android Generic Sharing
	//
	
	/** Send Generic Message */
	public function sendGenericMessage():void
	{
		if (!GoViral.goViral.isGenericShareAvailable())
		{
			log("Generic share doesn't work on this platform.");
			return;
		}
		
		log("Sending generic share intent...");
		GoViral.goViral.shareGenericMessage("The Subject","The message!",false);
		log("done send share intent.");
	}
	
	/** Send Generic Message */
	public function sendGenericMessageWithImage():void
	{
		if (!GoViral.goViral.isGenericShareAvailable())
		{
			log("Generic share doesn't work on this platform.");
			return;
		}
		
		log("Sending generic share img intent...");
		var asBitmap:Bitmap=new testImageClass() as Bitmap;
		GoViral.goViral.shareGenericMessageWithImage("The Subject","The message!",false,asBitmap.bitmapData);
		log("done send share img intent.");
	}
	
	/** iOS 6 only sharing */
	public function shareSocialComposer():void
	{
		// note that SINA_WEIBO and TWITTER are also available...
		if (GoViral.goViral.isSocialServiceAvailable(GVSocialServiceType.FACEBOOK))
		{
			log("launch ios 6 social composer...");
			var asBitmap:Bitmap=new testImageClass() as Bitmap;
			GoViral.goViral.displaySocialComposerView(GVSocialServiceType.FACEBOOK,"Social Composer message",asBitmap.bitmapData,"http://www.milkmangames.com");
		}
		else
		{
			log("social composer service not available on device.");
		}
	}
	//
	// twitter
	//
	
	/** Post a status message to Twitter */
	public function postTwitter():void
	{
		log("posting to twitter.");
		
		// You should check GoViral.goViral.isTweetSheetAvailable() to determine
		// if you're able to use the built-in iOS Twitter UI.  If the phone supports it
		// (because its running iOS 5.0+, or an Android device with Twitter) it will return true and you can call
		// 'showTweetSheet'. 

		if (GoViral.goViral.isTweetSheetAvailable())
		{
			GoViral.goViral.showTweetSheet("This is a native twitter post!");
		}
		else
		{
			log("Twitter not available on this device.");
			return;
		}
	}
	
	/** Post a picture to twitter */
	public function postTwitterPic():void
	{
		log("post twitter pic.");
		
		// You should check GoViral.goViral.isTweetSheetAvailable() to determine
		// if you're able to use the built-in iOS Twitter UI.  If the phone supports it
		// (because its running iOS 5.0+, or an Android device with Twitter) it will return true and you can call
		// 'showTweetSheetWithImage'.
		if (GoViral.goViral.isTweetSheetAvailable())
		{
			var asBitmap:Bitmap=new testImageClass() as Bitmap;
			GoViral.goViral.showTweetSheetWithImage("This is a twitter post with a pic!",asBitmap.bitmapData);
		}
		else
		{
			log("Twitter not available on this device.");
			return;
		}
		log("done show tweet.");
	}
	
	
	//
	// Events
	//
	
	/** Handle Facebook Event */
	private function onFacebookEvent(e:GVFacebookEvent):void
	{
		switch(e.type)
		{
			case GVFacebookEvent.FB_DIALOG_CANCELED:
				log("Facebook dialog '"+e.dialogType+"' canceled.");
				break;
			case GVFacebookEvent.FB_DIALOG_FAILED:
				log("dialog err:"+e.errorMessage);
				break;
			case GVFacebookEvent.FB_DIALOG_FINISHED:
				log("fin dialog '"+e.dialogType+"'="+e.jsonData);
				break;
			case GVFacebookEvent.FB_LOGGED_IN:
				log("Logged in to facebook!");
				break;
			case GVFacebookEvent.FB_LOGGED_OUT:
				log("Logged out of facebook.");
				break;
			case GVFacebookEvent.FB_LOGIN_CANCELED:
				log("Canceled facebook login.");
				break;
			case GVFacebookEvent.FB_LOGIN_FAILED:
				log("Login failed:"+e.errorMessage);
				break;
			case GVFacebookEvent.FB_REQUEST_FAILED:
				log("Facebook '"+e.graphPath+"' failed:"+e.errorMessage);
				break;
			case GVFacebookEvent.FB_REQUEST_RESPONSE:
				// handle a friend list- there will be only 1 item in it if 
				// this was a 'my profile' request.				
				if (e.friends!=null)
				{					
					// 'me' was a request for own profile.
					if (e.graphPath=="me")
					{
						var myProfile:GVFacebookFriend=e.friends[0];
						log("Me: name='"+myProfile.name+"',gender='"+myProfile.gender+"',location='"+myProfile.locationName+"',bio='"+myProfile.bio+"'");
						return;
					}
					
					// 'me/friends' was a friends request.
					if (e.graphPath=="me/friends")
					{					
						var allFriends:String="";
						for each(var friend:GVFacebookFriend in e.friends)
						{
							allFriends+=","+friend.name;
						}
						
						log(e.graphPath+"= ("+e.friends.length+")="+allFriends+",json="+e.jsonData);
					}
					else
					{
						log(e.graphPath+" res="+e.jsonData);	
					}
				}
				else
				{
					log(e.graphPath+" res="+e.jsonData);
				}
				break;
		}
	}
	
	/** Handle Twitter Event */
	private function onTwitterEvent(e:GVTwitterEvent):void
	{
		switch(e.type)
		{
			case GVTwitterEvent.TW_DIALOG_CANCELED:
				log("Twitter canceled.");
				break;
			case GVTwitterEvent.TW_DIALOG_FAILED:
				log("Twitter failed: "+e.errorMessage);
				break;
			case GVTwitterEvent.TW_DIALOG_FINISHED:
				log("Twitter finished.");
				break;
		}
	}
	
	/** Handle Mail Event */
	private function onMailEvent(e:GVMailEvent):void
	{
		switch(e.type)
		{
			case GVMailEvent.MAIL_CANCELED:
				log("Mail canceled.");
				break;
			case GVMailEvent.MAIL_FAILED:
				log("Mail failed:"+e.errorMessage);
				break;
			case GVMailEvent.MAIL_SAVED:
				log("Mail saved.");
				break;
			case GVMailEvent.MAIL_SENT:
				log("Mail sent!");
				break;
		}
	}
	
	/** Handle Generic Share Event */
	private function onShareEvent(e:GVShareEvent):void
	{
		log("share finished.");
	}

	//
	// Impelementation
	//
	
	/** Log */
	private function log(msg:String):void
	{
		trace("[GoViralExample] "+msg);
		txtStatus.text=msg;
	}
	
	private function logStatus(msg:String):void
	{
		txtStatus.appendText("-"+msg);
	}
	
	/** Create UI */
	public function createUI():void
	{
		txtStatus=new TextField();
		
		txtStatus.defaultTextFormat=new flash.text.TextFormat("Arial",19);
		txtStatus.width=stage.stageWidth;
		txtStatus.multiline=true;
		txtStatus.wordWrap=true;
		txtStatus.text="Ready";
		txtStatus.y=txtStatus.textHeight;
		//txtStatus.height=1000;
		txtStatus.mouseEnabled=false;
		txtStatus.type=TextFieldType.DYNAMIC;
		
		addChild(txtStatus);
	}
	
	/** Show Main Menu */
	public function showMainUI():void
	{
		if (buttonContainer)
		{
			removeChild(buttonContainer);
			buttonContainer=null;
		}
		
		buttonContainer=new Sprite();
		buttonContainer.y=txtStatus.height;
		addChild(buttonContainer);
		
		var uiRect:Rectangle=new Rectangle(0,0,stage.stageWidth,stage.stageHeight);
		var layout:ButtonLayout=new ButtonLayout(uiRect,14);
		layout.addButton(new SimpleButton(new Command("Send Test Email",sendTestEmail)));
		layout.addButton(new SimpleButton(new Command("Send Pic Email",sendImageEmail)));		
		layout.addButton(new SimpleButton(new Command("Tweet Msg",postTwitter)));
		layout.addButton(new SimpleButton(new Command("Tweet Pic",postTwitterPic)));
		layout.addButton(new SimpleButton(new Command("Share Generic",sendGenericMessage)));
		layout.addButton(new SimpleButton(new Command("Share Generic Img",sendGenericMessageWithImage)));
		layout.addButton(new SimpleButton(new Command("iOS 6 Social Share",shareSocialComposer)));
		layout.addButton(new SimpleButton(new Command("Facebook Stuff >",showFacebookUI)));
		layout.attach(buttonContainer);
		layout.layout();	
		log("Main UI displayed.");
	}
	
	/** Show Facebook Menu */
	public function showFacebookUI():void
	{
		// make sure facebook is set up first
		if (FACEBOOK_APP_ID=="YOUR_FACEBOOK_APP_ID")
		{
			log("You forgot to put in Facebook ID!");
			return;
		}
		
		if (buttonContainer)
		{
			removeChild(buttonContainer);
			buttonContainer=null;
		}
		
		buttonContainer=new Sprite();
		buttonContainer.y=txtStatus.height;
		addChild(buttonContainer);
		
		var uiRect:Rectangle=new Rectangle(0,0,stage.stageWidth,stage.stageHeight);
		var layout:ButtonLayout=new ButtonLayout(uiRect,14);
		layout.addButton(new SimpleButton(new Command("Login",loginFacebook)));
		layout.addButton(new SimpleButton(new Command("Post wall",postFeedFacebook)));
		layout.addButton(new SimpleButton(new Command("post wall pic",postPhotoFacebook)));
		layout.addButton(new SimpleButton(new Command("List friends",getFriendsFacebook)));
		layout.addButton(new SimpleButton(new Command("My profile",getMeFacebook)));
		layout.addButton(new SimpleButton(new Command("Graph Post",postGraphFacebook)));
		layout.addButton(new SimpleButton(new Command("invite friends",inviteFriendsFacebook)));
		layout.addButton(new SimpleButton(new Command("Get Token",getFacebookToken)));
		layout.addButton(new SimpleButton(new Command("Logout fb",logoutFacebook)));
		layout.addButton(new SimpleButton(new Command("< Back",showMainUI)));
		layout.attach(buttonContainer);
		layout.layout();	
	}
	
}
}

//
// Code Below is generic code for building UI
//


import flash.display.DisplayObjectContainer;
import flash.display.Sprite;
import flash.events.MouseEvent;
import flash.geom.Rectangle;
import flash.text.TextField;
import flash.text.TextFieldAutoSize;
import flash.text.TextFormat;

/** Simple Button */
class SimpleButton extends Sprite
{
	//
	// Instance Variables
	//
	
	/** Command */
	private var cmd:Command;
	
	/** Width */
	private var _width:Number;
	
	/** Label */
	private var txtLabel:TextField;
	
	//
	// Public Methods
	//
	
	/** Create New SimpleButton */
	public function SimpleButton(cmd:Command)
	{
		super();
		this.cmd=cmd;
		
		mouseChildren=false;
		mouseEnabled=buttonMode=useHandCursor=true;
		
		txtLabel=new TextField();
		txtLabel.defaultTextFormat=new TextFormat("Arial",42,0xFFFFFF);
		txtLabel.mouseEnabled=txtLabel.mouseEnabled=txtLabel.selectable=false;
		txtLabel.text=cmd.getLabel();
		txtLabel.autoSize=TextFieldAutoSize.LEFT;
		
		redraw();
		
		addEventListener(MouseEvent.CLICK,onSelect);
	}
	
	/** Set Width */
	override public function set width(val:Number):void
	{
		this._width=val;
		redraw();
	}

	
	/** Dispose */
	public function dispose():void
	{
		removeEventListener(MouseEvent.CLICK,onSelect);
	}
	
	//
	// Events
	//
	
	/** On Press */
	private function onSelect(e:MouseEvent):void
	{
		this.cmd.execute();
	}
	
	//
	// Implementation
	//
	
	/** Redraw */
	private function redraw():void
	{		
		txtLabel.text=cmd.getLabel();
		_width=_width||txtLabel.width*1.1;
		
		graphics.clear();
		graphics.beginFill(0x444444);
		graphics.lineStyle(2,0);
		graphics.drawRoundRect(0,0,_width,txtLabel.height*1.1,txtLabel.height*.4);
		graphics.endFill();
		
		txtLabel.x=_width/2-(txtLabel.width/2);
		txtLabel.y=txtLabel.height*.05;
		addChild(txtLabel);
	}
}

/** Button Layout */
class ButtonLayout
{
	private var buttons:Array;
	private var rect:Rectangle;
	private var padding:Number;
	private var parent:DisplayObjectContainer;
	
	public function ButtonLayout(rect:Rectangle,padding:Number)
	{
		this.rect=rect;
		this.padding=padding;
		this.buttons=new Array();
	}
	
	public function addButton(btn:SimpleButton):uint
	{
		return buttons.push(btn);
	}
	
	public function attach(parent:DisplayObjectContainer):void
	{
		this.parent=parent;
		for each(var btn:SimpleButton in this.buttons)
		{
			parent.addChild(btn);
		}
	}
	
	public function layout():void
	{
		var btnX:Number=rect.x+padding;
		var btnY:Number=rect.y;
		for each( var btn:SimpleButton in this.buttons)
		{
			btn.width=rect.width-(padding*2);
			btnY+=this.padding;
			btn.x=btnX;
			btn.y=btnY;
			btnY+=btn.height;
		}
	}
}

/** Inline Command */
class Command
{
	/** Callback Method */
	private var fnCallback:Function;
	
	/** Label */
	private var label:String;
	
	//
	// Public Methods
	//
	
	/** Create New Command */
	public function Command(label:String,fnCallback:Function)
	{
		this.fnCallback=fnCallback;
		this.label=label;
	}
	
	//
	// Command Implementation
	//
	
	/** Get Label */
	public function getLabel():String
	{
		return label;
	}
	
	/** Execute */
	public function execute():void
	{
		fnCallback();
	}
}