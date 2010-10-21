package ;

import flash.Lib;

import flash.display.StageScaleMode;
import flash.display.StageAlign;
import flash.display.Sprite;
import flash.display.Loader;
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.Graphics;
import flash.events.Event;
import flash.geom.Rectangle;
import flash.media.Camera;
import flash.media.Video;
import flash.net.URLRequest;
import flash.text.TextField;
import jp.maaash.objectdetection.ObjectDetector;
import jp.maaash.objectdetection.ObjectDetectorOptions;
import jp.maaash.objectdetection.ObjectDetectorEvent;


class FaceDetector extends Sprite
{
	private var debug :Bool;

	private var detector:ObjectDetector;
	private var options:ObjectDetectorOptions;
	private var faceImage:Loader;
	private var bmpTarget:Bitmap;

	private var view:Sprite;
	private var faceRectContainer:Sprite;
	private var tf:TextField;

	private var cam:Camera;
	private var faceVid:Video;
	private var isDetecting:Bool;
	
	static public function main()
	{
		Lib.current.stage.addChild(new FaceDetector());
	}
	
	public function new()
	{
		super();
		
		debug = false;
		isDetecting = false;
		
		initUI();
		initDetector();
		//startDetection();
		//faceImage.load( new URLRequest("013.jpg") );
	}

	private function initUI():Void{
		Lib.current.stage.scaleMode = StageScaleMode.NO_SCALE;
		Lib.current.stage.align = StageAlign.TOP_LEFT;

		cam = Camera.getCamera();
		faceVid = new Video(Std.int(320 * 0.5), Std.int(240 * 0.5));
		faceVid.attachCamera(cam);
		addChild(faceVid);
		
		view = new Sprite();
		addChild(view);

		/*faceImage = new Loader;
		faceImage.contentLoaderInfo.addEventListener( Event.COMPLETE, function(e :Event) :Void {
			startDetection();
		});
		view.addChild( faceImage );
		*/
		faceRectContainer = new Sprite();
		//var bmp = new Bitmap(new BitmapData(Std.int(faceVid.width), Std.int(faceVid.height)));
		/*
		faceRectContainer.x = 0;
		faceRectContainer.y = 0;
		faceRectContainer.width = faceVid.width;
		faceRectContainer.height = faceVid.height;
		faceRectContainer.graphics.beginFill(0);
		faceRectContainer.graphics.drawRect(0, 0, faceRectContainer.width, faceRectContainer.height);
		faceRectContainer.graphics.endFill();
		trace("frc=" + faceRectContainer.getRect(Lib.current));
		*/
		//faceRectContainer.addChild(bmp);
		addChild( faceRectContainer );

		tf = new TextField();
		tf.x = 256;
		tf.width  = 600;
		tf.height = 300;
		tf.textColor = 0x000000;
		tf.multiline = true;
		view.addChild( tf );
		addEventListener(Event.ENTER_FRAME, onEnterFrame);
	}
	
	private function initDetector():Void
	{
		detector = new ObjectDetector();
		detector.options = getDetectorOptions();
		var self = this;
		detector.addEventListener(ObjectDetectorEvent.DETECTION_COMPLETE, onDetectionComplete);
		var events:Array<String> = [ ObjectDetectorEvent.HAARCASCADES_LOAD_COMPLETE, ObjectDetectorEvent.HAARCASCADES_LOADING ];
		for (e in events)
		{
			detector.addEventListener(e, traceEvent);
		}
		detector.loadHaarCascades( "haarcascade_frontalface_alt.xml" ); // "face.zip" );
	}

	private function traceEvent(e:Event):Void
	{
		trace("Event! e=" + e.type);
	}
	
	private function onDetectionComplete(e:ObjectDetectorEvent):Void 
	{
		//logger("[ObjectDetectorEvent.COMPLETE]");
		//tf.appendText( "\ntime: "+(new Date)+" "+e.type );
		//detector.removeEventListener( ObjectDetectorEvent.DETECTION_COMPLETE, onDetectionComplete );
		if ( e.rects != null && e.rects.length > 0)
		{
			//trace("found a face");
			var g:Graphics = faceRectContainer.graphics;
			g.clear();
			g.lineStyle( 2 );	// black 2pix
			for (r in e.rects)
			{
				//trace("drawing face at " + r);
				g.drawRect( r.x, r.y, r.width, r.height );
			}
		}
		isDetecting = false;
	}
	
	private function onEnterFrame(e:Event):Void
	{
		if (!isDetecting)
		{
			isDetecting = true;
			startDetection();
		}
	}

	private function startDetection():Void
	{
		logger("[startDetection]");

		bmpTarget = new Bitmap( new BitmapData( Std.int(faceVid.width), Std.int(faceVid.height), false ) );
		bmpTarget.bitmapData.draw( faceVid );
		detector.detect( bmpTarget );
	}

	private function getDetectorOptions() :ObjectDetectorOptions
	{
		options = new ObjectDetectorOptions();
		options.minSize  = 50;
		options.startx    = ObjectDetectorOptions.INVALID_POS;
		options.starty    = ObjectDetectorOptions.INVALID_POS;
		options.endx      = ObjectDetectorOptions.INVALID_POS;
		options.endy      = ObjectDetectorOptions.INVALID_POS;
		return options;
	}

	private function logger(args):Void
	{
		if(!debug){ return; }
		//log(args);
	}
}
